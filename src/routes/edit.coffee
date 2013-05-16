
slugify = require '../utils/slugify'
cc = require 'coffeecup'
uuid = require 'node-uuid'
gm = require 'gm'
fs = require 'fs'
exec = require('child_process').exec
shellEscape = require '../utils/shellEscape'
deepCopy = require('owl-deepcopy').deepCopy
YAML = require('yamljs')
applyContext = require '../utils/applyContext'
sessionBridge = require '../utils/sessionBridge'

# Edit/Create/Save content
module.exports = (req, res) ->

    docpad = @docpad
    config = @config
    session = sessionBridge.get(req)

    unless session.authenticated
        res.redirect '/'+@config.prefix.url+'/login?url='+req.url
        return

    model = null
    data = null

    for item in @config.models
        if slugify(item.name[0]) is req.params.content
            model = item

    unless model?.form?
        res.set 'Content-Type', 'text/plain'
        res.status(404).send('Not Found')
        return

    item = null
    if req.query.url?
        realUrl = (if req.query.url is '/index' then '/' else req.query.url)
        item = docpad.getCollection('html').findOne(url: realUrl)?.toJSON()

    if item?[@config.prefix.meta]?
        # Ensure the original won't be modified
        data = deepCopy item[@config.prefix.meta]
    else
        data = {}
        item = null

    # Check if we should remove this content
    remove = false
    unless save
        if req.body.do is 'delete'
            remove = true

    # Check if fields are given
    save = false
    if not remove and req.body.fields?
        try
            fieldsData = JSON.parse req.body.fields
            for key, val of fieldsData
                data[key] = val

            # Check if we should save those fields
            if req.body.do is 'save'
                save = true

    # Compute context
    context = {}
    if data?
        for key, val of data
            context[key] = val

    # Add docpad instance and slugify
    context.docpad = @docpad
    context.slugify = slugify

    # Compute input fields
    components = []
    scriptLoaded = {}
    computedData = {}
    valid = {}
    deps = {}
    keys = []
    errors = []
    successes = []
    finalData = {}
    allValid = true
    for component in model.form.components
        computed = {}
        unless scriptLoaded[component.field]
            scriptLoaded[component.field] = true
            computed.shouldLoadScript = true
        for key, val of component
            if typeof val is 'function' and key isnt 'validate' and key isnt 'sanitize'
                computed[key] = val.apply(context)
            else
                computed[key] = val

        computed.config = @config
        computed.slugify = slugify
        computed.model = model
        computed.value = if data? then data[computed.field] else computed.default
        if not computed.value? then computed.value = null
        computedData[computed.field] = computed.value

        # Run base validator
        valid[computed.field] = false
        try
            valid[computed.field] = @config.validate.apply(context, [component, computed.value])
        catch e
            console.log "base validator of #{computed.field} thrown exception."
            console.log e

        # Run custom validator
        if valid[computed.field]
            if typeof component.validate is 'function'
                try
                    valid[computed.field] = !!component.validate.apply(context, [computed.value])
                catch e
                    console.log "validator of #{computed.field} thrown exception."
                    console.log e
                    valid[computed.field] = false
            else
                valid[computed.field] = true

        computed.valid = valid[computed.field]
        allValid = (allValid and computed.valid)

        keys.push computed.field
        deps[computed.field] = []
        if computed.deps?
            deps[computed.field] = computed.deps
        computed.form = 'edit'
        unless computed.label?
            computed.label = computed.field.charAt(0).toUpperCase()+computed.field.substring(1)

        if save
            if not computed.valid
                errors.push
                    field: computed.field
                    message: "#{computed.label} is not valid."
                computed.error =
                    message: "#{computed.label} is not valid."
            else
                finalData[computed.field] = computed.value
                try
                    finalData[computed.field] = @config.sanitize.apply(context, [component, finalData[computed.field]])
                if component.sanitize?
                    finalData[computed.field] = component.sanitize.apply(context, [finalData[computed.field]])
                else
                    finalData[computed.field] = finalData[computed.field]

        try
            components.push cc.render(require('../components/input/'+computed.type), computed)
        catch e
            console.log 'Failed to render '+computed.type+' component for '+computed.field+' field.'
            throw e

    # Save changes
    if save and allValid

        # Compute final context
        finalContext = {}
        if data?
            for key, val of finalData
                finalContext[key] = val
        finalContext.docpad = docpad
        finalContext.slugify = slugify

        # Compute url and path
        url = applyContext model.form.url, finalContext
        path = docpad.config.srcPath+'/documents'+url+'.'+model.form.ext
        if item?
            urlForFile = (if item.url is '/' then '/index' else item.url)
            itemPath = docpad.config.srcPath+'/documents'+urlForFile+'.'+model.form.ext

        await fs.exists path, defer exists

        if exists and not item?
            errors.push
                message: 'The file '+url+'.'+model.form.ext+' already exists.'
        else
            # Move related images
            for component in model.form.components
                if component.type is 'file' and component.images?
                    if finalData[component.field]?
                        fieldData = finalData[component.field]
                        filesPath = docpad.config.srcPath+'/files'
                        for key, val of component.images
                            prevUrl = fieldData[key].url
                            await fs.exists filesPath+prevUrl, defer prevExists
                            ext = 'jpg'
                            if prevExists
                                await gm(filesPath+prevUrl).format defer err, format
                                if err
                                    process.stderr.write "#{err.message ? err}\n"
                                else
                                    ext = format.toLowerCase()[0...3]
                                    if ext is 'jpe' then ext = 'jpg'
                            imgContext = {}
                            for k, v of finalContext
                                imgContext[k] = v
                            imgContext.ext = ext
                            newUrl = applyContext component.images[key].url, imgContext
                            if newUrl isnt prevUrl
                                newUrlDirs = newUrl[0...newUrl.lastIndexOf('/')]
                                await exec "mkdir -p #{shellEscape filesPath+newUrlDirs}", defer err
                                if prevExists
                                    await fs.exists filesPath+newUrl, defer newExists
                                    if newExists
                                        await fs.unlink filesPath+newUrl, defer err
                                        if err then process.stderr.write "#{err.message ? err}\n"
                                    await fs.rename filesPath+prevUrl, filesPath+newUrl, defer err
                                    if err then process.stderr.write "#{err.message ? err}\n"
                                finalData[component.field][key].url = newUrl
                                finalContext[component.field][key].url = newUrl
                    else
                        filesPath = docpad.config.srcPath+'/files'
                        for key, val of component.images
                            for ext in ['jpg', 'gif', 'png'] # Check for each extension
                                imgContext = {}
                                for k, v of finalContext
                                    imgContext[k] = v
                                imgContext.ext = ext
                                imgUrl = applyContext component.images[key].url, imgContext
                                await fs.exists filesPath+imgUrl, defer imgExists
                                if imgExists
                                    await fs.unlink filesPath+imgUrl, defer err
                                    if err then process.stderr.write "#{err.message ? err}\n"

            # Compute document file
            meta = applyContext model.form.meta, finalContext
            meta[config.prefix.meta] = finalData
            saveTime = new Date().getTime()
            meta[config.prefix.meta].updated_at = saveTime

            # Generate a unique id for this entry if not already generated
            if not meta[config.prefix.meta].id?
                meta[config.prefix.meta].id = (uuid.v1()+''+uuid.v4()).split('-').join('').substring(0,48)

            content = applyContext model.form.content, finalContext
            yamlString = YAML.stringify(meta, 8, 4).trim()
            char = null
            for c in ['-','`','#','_','*','=','+',',',':','@','&',';','?','°']
                if yamlString.split(''+c+''+c+''+c).length < 2
                    char = c
                    break
            doc = """
            #{char+''+char+''+char}
            #{yamlString}
            #{char+''+char+''+char}
            #{content}
            """

            # Save/Re-save/Move document
            pathDirs = path[0...path.lastIndexOf('/')]
            if item? and itemPath?
                await fs.unlink itemPath, defer err
            await fs.exists path, defer itemExists
            if itemExists
                await fs.unlink path, defer err
            await exec "mkdir -p #{shellEscape pathDirs}", defer err
            await fs.writeFile path, doc, defer err

            # Wait until document is created/updated and perform redirect
            docpad.action 'generate', reset: false, (err) ->
                if err then (process.stderr.write(err.message ? err)+'').trim()+"\n"
                setTimeout (=>
                    realUrl = (if url is '/index' then '/' else url)
                    docItem = null

                    for i in [0...20]
                        if docItem?.get?(config.prefix.meta)?.updated_at isnt saveTime
                            await setTimeout(defer(), 1000)
                            docItem = docpad.getCollection('html').findOne(url: realUrl)
                        else
                            break

                    if docItem?.get?(config.prefix.meta)?.updated_at isnt saveTime
                        # If after 20s there is still no document,
                        # Force generate and redirect
                        docpad.action 'generate', reset: true, (err) ->
                            if err then (process.stderr.write(err.message ? err)+'').trim()+"\n"
                            res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/edit?url='+url
                    else
                        res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/edit?url='+url
                ), 1

            return

    # Remove content
    else if remove
        # Create an array of all the files to remove
        filesToRemove = []

        # Remove document file
        urlForFile = (if item.url is '/' then '/index' else item.url)
        filesToRemove.push docpad.config.srcPath+'/documents'+urlForFile+'.'+model.form.ext

        # Remove related images
        for component in model.form.components
            if component.type is 'file' and component.images?
                fieldData = data[component.field]
                filesPath = docpad.config.srcPath+'/files'
                for key, val of component.images
                    imgUrl = applyContext component.images[key].url, context
                    filesToRemove.push filesPath+imgUrl
        
        for toRemove in filesToRemove
            await fs.unlink toRemove, defer err

        # Wait until document is removed and perform redirect
        docpad.action 'generate', reset: false, (err) ->
            if err then (process.stderr.write(err.message ? err)+'').trim()+"\n"
            setTimeout (=>
                url = applyContext model.form.url, context

                for i in [0...20]
                    if docpad.getCollection('html').findOne(url: url)?
                        await setTimeout(defer(), 1000)
                    else
                        break

                if docpad.getCollection('html').findOne(url: url)?
                    # If after 20s there is still the document,
                    # Force generate and redirect
                    docpad.action 'generate', reset: true, (err) ->
                        if err then return (process.stderr.write(err.message ? err)+'').trim()+"\n"
                        res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                else
                    res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
            ), 1

        return


    content = cc.render require('../components/layout/edit'), form: 'edit', config: config, model: model, slugify: slugify, item: item, data: computedData, components: components, deps: deps, keys: keys, valid: valid, errors: errors, successes: successes

    res.set 'Content-Type', 'text/html; charset=UTF-8'
    res.send cc.render require('../components/layout'), layout: 'edit', model: model, url: req.url, config: config, prefix: config.prefix.url, title: 'Admin - '+model.name[1], content: content, slugify: slugify



