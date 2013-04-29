
# Slugify
urlify = require('urlify').create(addEToUmlauts: false, szToSs: true, spaces: '-', nonPrintable: '-', trim: true)
slug = require('slug')
slugs = {}
slugify = (str) ->
    res = slugs[str]
    unless res?
        res = urlify(slug(str)).toLowerCase()
        slugs[str] = res
    return res
cc = require('coffeecup')
uuid = require('node-uuid')
gm = require('gm')
fs = require('fs')
exec = require('child_process').exec
esc = (arg) -> (''+arg).replace(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/gm, '\\').replace(/\n/g, "'\n'").replace(/^$/, "''")
deepCopy = require('owl-deepcopy').deepCopy
YAML = require('yamljs')

generating = null

applyContext = (input, context) ->
    if input instanceof Array
        res = []
        for item in input
            res.push applyContext(item, context)
        return res
    else if typeof(input) is 'function'
        return input.apply(context)
    else if typeof(input) is 'object'
        res = {}
        for key, val of input
            res[key] = applyContext(val, context)
        return res
    else
        return input

# Export Plugin
module.exports = (BasePlugin) ->

    # Define Plugin
    class MinicmsPlugin extends BasePlugin

        # Plugin name
        name: 'minicms'

        config:
            # Some config to change the reserved "values"
            prefix:
                url:    'cms' # The prefix used to load the admin panel
                meta:   'cms' # The key used to store form info in metadata

            # Default validator for all fields
            validate: (field, val) ->
                if field.optional and not val?
                    return true

                # Image
                if field.type is 'file' and field.images
                    expectedKeys = []
                    for key of field.images
                        expectedKeys.push key
                    i = 0
                    if typeof(val) isnt 'object' then return false
                    if not val? then return false
                    keys = []
                    for k, v of val
                        keys.push k
                    if keys.length isnt expectedKeys.length then return false
                    for k in expectedKeys
                        if not (k in keys) then return false
                    for k in keys
                        if typeof(val[k].url) isnt 'string' then return false
                        if typeof(val[k].width) isnt 'number' or val[k].width < 1 then return false
                        if typeof(val[k].height) isnt 'number' or val[k].height < 1 then return false
                    return true

                # Text
                else if field.type is 'text'
                    return typeof(val) is 'string' and val.trim().length > 0

                # Textarea
                else if field.type is 'textarea'
                    return typeof(val) is 'string' and val.trim().length > 0

                # Wysiwyg
                else if field.type is 'wysiwyg'
                    return typeof(val) is 'string' and val.trim().length > 0

                # Markdown
                else if field.type is 'markdown'
                    return typeof(val) is 'string' and val.trim().length > 0

                # Choice
                else if field.type is 'choice'
                    return typeof(val) is 'string' and val.trim().length > 0

                # Date
                else if field.type is 'date'
                    return typeof(val) is 'number' and Math.floor(val) is val

                # Tags
                else if field.type is 'tags'
                    if not (val instanceof Array)
                        return false
                    for item in val
                        if not typeof(item) is 'string'
                            return false
                    return true

                # Other, not handled, so not valid
                else
                    return false

            # Default sanitizer for all fields
            sanitize: (field, val) ->

                # Text
                if field.type is 'text'
                    return val.trim()

                # Textarea
                if field.type is 'textarea'
                    return val.trim()

                # Wysiwyg
                if field.type is 'wysiwyg'
                    return val.split("\n").join(' ').split("\r").join(' ').trim()

                # Choice
                else if field.type is 'choice'
                    return val.trim()

                # Date
                else if field.type is 'date'
                    return Math.floor(val / 1000) * 1000

                # Tags
                else if field.type is 'tags'
                    if not (val instanceof Array)
                        return []
                    result = []
                    for item in val
                        result.push item.trim()
                    return result

                # Other, do nothing
                else
                    return val


        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract useful values
            app = opts.server
            express = opts.express
            docpad = @docpad
            config = @config

            # Reset tmp directory
            exec "rm -rf #{esc docpad.config.srcPath+'/files/tmp'}", ->

            # Serve static files used by minicms
            app.use '/'+@config.prefix.url, express.static(__dirname+'/static')

            if not @config.secret?
                throw "Secret is required for cookie sessions (minicms)"

            # Use session handler
            app.use express.cookieParser()
            app.use express.cookieSession secret: @config.secret

            # Session
            # a: authenticated
            # b: authenticating
            # c: lastAuthAttempt

            # Authenticate (logout)
            app.get '/'+@config.prefix.url+'/logout', (req, res) ->

                delete req.session.a
                delete req.session.b
                res.redirect '/'+config.prefix.url+'/login'

            # Authenticate (page)
            app.get '/'+@config.prefix.url+'/login', (req, res) ->

                req.session.b = 1
                res.send cc.render require('./components/layout/authenticate'), layout: 'authenticate', url: req.url, config: config, prefix: config.prefix.url, title: 'Admin - Authenticate', slugify: slugify

            # Authenticate (submit)
            app.post '/'+@config.prefix.url+'/login', (req, res) ->

                if not req.session.b or not config.auth?
                    res.redirect req.url
                    return

                time = new Date().getTime()

                if req.session.c and req.session.c > time - 1000 # Prevent brute force attack
                    req.session.b = 0
                    res.redirect req.url
                    return

                req.session.c = time

                config.auth req.body.login, req.body.password, (err, result) ->
                    if result
                        req.session.a = 1
                        if req.query.url
                            res.redirect req.query.url
                        else
                            res.redirect '/'+config.prefix.url
                    else
                        res.redirect req.url
                

            # Serve admin root
            app.get '/'+@config.prefix.url, (req, res) ->

                unless req.session?.a
                    res.redirect '/'+config.prefix.url+'/login?url='+req.url
                    return

                content = cc.render require('./components/layout/index'), config: config, slugify: slugify

                res.set 'Content-Type', 'text/html; charset=UTF-8'
                res.send cc.render require('./components/layout'), layout: 'index', url: req.url, config: config, prefix: config.prefix.url, title: 'Admin', content: content, slugify: slugify

            # Serve admin content list
            app.get '/'+@config.prefix.url+'/:content/list', (req, res) ->

                unless req.session?.a
                    res.redirect '/'+config.prefix.url+'/login?url='+req.url
                    return

                model = null

                for item in config.models
                    if slugify(item.name[0]) is req.params.content
                        model = item

                unless model?.list?
                    req.redirect '/'+config.prefix.url
                    return

                context = docpad: docpad, slugify: slugify
                filters = {}
                if req.query.filters? and typeof req.query.filters is 'string'
                    comps = req.query.filters.split(' ').join('/').split('/')
                    len = comps.length
                    i = 0
                    while i < len
                        key = comps[i]
                        val = comps[i+1]
                        i += 2
                        if typeof val is 'string' and val.length
                            key = slugify key
                            val = slugify val
                            context[key] = val
                            filters[key] = val

                filterData = []
                if model.list.filters?
                    for filter in model.list.filters
                        data = filter.data
                        if typeof data is 'function'
                            data = data.apply docpad: docpad
                        if data instanceof Array
                            data = deepCopy data
                            data.sort()
                        else
                            data = []
                        filterData.push data

                data = model.list?.data

                if typeof data is 'function'
                    data = data.apply context
                    if data.models?.length
                        data = data.toJSON()
                    else if not data? or not (data instanceof Array)
                        data = []

                makeFilter = (key, val) ->
                    comps = []
                    key = slugify(key)
                    if val?
                        val = slugify(val)
                        comps.push key+'/'+val
                    for k, v of filters
                        if k isnt key
                            comps.push k+'/'+v
                    if comps.length
                        return '?filters='+comps.join('+')
                    return ''

                content = cc.render require('./components/layout/list'), filters: filters, filterData: filterData, config: config, model: model, slugify: slugify, data: data, makeFilter: makeFilter

                res.set 'Content-Type', 'text/html; charset=UTF-8'
                res.send cc.render require('./components/layout'), layout: 'list', model: model, url: req.url, config: config, prefix: config.prefix.url, title: 'Admin - '+model.name[1], content: content, slugify: slugify
            
            # Server admin content edit
            handleEdit = (req, res) ->

                unless req.session?.a
                    res.redirect '/'+config.prefix.url+'/login?url='+req.url
                    return

                model = null
                data = null

                for item in config.models
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

                if item?[config.prefix.meta]?
                    # Ensure the original won't be modified
                    data = deepCopy item[config.prefix.meta]
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

                # Add docpad instance
                context.docpad = docpad

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

                    computed.config = config
                    computed.slugify = slugify
                    computed.model = model
                    computed.value = if data? then data[computed.field] else null
                    computedData[computed.field] = computed.value

                    # Run base validator
                    valid[computed.field] = false
                    try
                        valid[computed.field] = config.validate.apply(context, [component, computed.value])
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
                                finalData[computed.field] = config.sanitize.apply(context, [component, finalData[computed.field]])
                            if component.sanitize?
                                finalData[computed.field] = component.sanitize.apply(context, [finalData[computed.field]])
                            else
                                finalData[computed.field] = finalData[computed.field]

                    try
                        components.push cc.render(require('./components/input/'+computed.type), computed)
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
                                            await exec "mkdir -p #{esc filesPath+newUrlDirs}", defer err
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
                        content = applyContext model.form.content, finalContext
                        doc = """
                        ```
                        #{YAML.stringify(meta, 8, 4).trim()}
                        ```
                        #{content}
                        """

                        # Save/Re-save/Move document
                        pathDirs = path[0...path.lastIndexOf('/')]
                        if item? and itemPath?
                            await fs.unlink itemPath, defer err
                        await fs.exists path, defer itemExists
                        if itemExists
                            await fs.unlink path, defer err
                        await exec "mkdir -p #{esc pathDirs}", defer err
                        await fs.writeFile path, doc, defer err

                        # Wait until document is created and perform redirect
                        realUrl = (if url is '/index' then '/' else url)
                        setTimeout (->
                            if docpad.getCollection('html').findOne(url: realUrl)?
                                res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/edit?url='+url
                            else
                                setTimeout (->
                                    if docpad.getCollection('html').findOne(url: realUrl)?
                                        res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/edit?url='+url
                                    else
                                        setTimeout (->
                                            if docpad.getCollection('html').findOne(url: realUrl)?
                                                res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/edit?url='+url
                                            else
                                                # If after 10s there is still no document, redirect to list anyway
                                                # After forcing generate
                                                docpad.generate reset: true, ->
                                                    res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                                        ), 5000
                                ), 2500
                        ), 1000
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
                    
                    # Perform deletes
                    for toRemove in filesToRemove
                        await fs.unlink toRemove, defer err

                    # Wait until document is removed and perform redirect
                    url = applyContext model.form.url, context
                    setTimeout (->
                        if not docpad.getCollection('html').findOne(url: url)?
                            res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                        else
                            setTimeout (->
                                if not docpad.getCollection('html').findOne(url: url)?
                                    res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                                else
                                    setTimeout (->
                                        if not docpad.getCollection('html').findOne(url: url)?
                                            res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                                        else
                                            # If after 10s document is still there, redirect to list anyway
                                            # After forcing generate
                                            docpad.generate reset: true, ->
                                                res.redirect '/'+config.prefix.url+'/'+slugify(model.name[0])+'/list'
                                    ), 5000
                            ), 2500
                    ), 1000
                    return


                content = cc.render require('./components/layout/edit'), form: 'edit', config: config, model: model, slugify: slugify, item: item, data: computedData, components: components, deps: deps, keys: keys, valid: valid, errors: errors, successes: successes

                res.set 'Content-Type', 'text/html; charset=UTF-8'
                res.send cc.render require('./components/layout'), layout: 'edit', model: model, url: req.url, config: config, prefix: config.prefix.url, title: 'Admin - '+model.name[1], content: content, slugify: slugify
            

            app.get '/'+@config.prefix.url+'/:content/edit', handleEdit
            app.post '/'+@config.prefix.url+'/:content/edit', handleEdit

            app.post '/'+@config.prefix.url+'/generate', (req, res) ->

                unless req.session?.a
                    res.redirect '/'+config.prefix.url+'/login?url='+req.url
                    return

                if generating
                    res.set 'Content-Type', 'application/json; charset=UTF-8'
                    res.send JSON.stringify result: 0
                    return

                # Force generate
                generating = true;
                time = new Date().getTime();
                docpad.generate reset: true, ->
                    generating = false
                    res.set 'Content-Type', 'application/json; charset=UTF-8'
                    res.send JSON.stringify result: (new Date().getTime() - time)

            # Handle file upload
            app.post '/'+@config.prefix.url+'/:content/:field/upload', (req, res) ->

                unless req.session?.a
                    res.redirect '/'+config.prefix.url+'/login?url='+req.url
                    return

                model = null

                for item in config.models
                    if slugify(item.name[0]) is req.params.content
                        model = item

                unless model?.form?
                    res.set 'Content-Type', 'text/plain'
                    res.status(404).send('Not Found')
                    return

                field = req.params.field
                file = req.files?.file?[field]
                options = null

                for component in model.form.components
                    if component.field is field
                        options = component
                        break

                if not options?.type? or options.type isnt 'file' or not options.images?
                    res.set 'Content-Type', 'application/json'
                    res.status(404).send error: 'Invalid field.'
                    return

                if not file
                    res.set 'Content-Type', 'application/json'
                    res.status(404).send error: 'Please upload a valid file.'
                    return

                if options.images?
                    if not (file.type in ['image/png', 'image/jpeg', 'image/gif'])
                        res.set 'Content-Type', 'application/json'
                        res.status(404).send error: 'File type '+file.type+' is not valid. Please upload PNG, JPEG or GIF file.'
                        return

                    # Generate final images but put them in temporary place until the form is completely validated
                    rnd = (uuid.v1()+''+uuid.v4()).split('-').join('').substring(0,48)
                    result = {}
                    errs = []

                    # Ensure temporary directory exists
                    await fs.mkdir docpad.config.srcPath+'/files/tmp', defer()

                    # Get original image format and size
                    gm(file.path).format (err, format) ->
                        if err?
                            res.set 'Content-Type', 'application/json'
                            res.status(404).send error: 'Invalid image file.'
                            return
                        format = format.toLowerCase()[0...3]
                        if format is 'jpe' then format = 'jpg'
                        gm(file.path).size (err, size) ->
                            if err?
                                res.set 'Content-Type', 'application/json'
                                res.status(404).send error: 'Invalid image file.'
                                return

                            # Workaround in order to get correct gif file size
                            if format is 'gif'
                                if size.width < 1000 and size.height > 10000
                                    size.height = (''+size.height)[0...3]
                                else if size.height < 1000 and size.width > 10000
                                    size.width = (''+size.width)[0...3]

                            for key, val of options.images
                                fnParts = options.images[key].url.toString().split('.')
                                ext = 'jpg'
                                for i in [fnParts.length-1..0]
                                    if fnParts[i][0...3] is 'ext'
                                        ext = format
                                        break
                                    if fnParts[i][0...3] is 'jpg' or fnParts[i][0...4] is 'jpeg'
                                        ext = 'jpg'
                                        break
                                    else if fnParts[i][0...3] is 'png'
                                        ext = 'png'
                                        break
                                    else if fnParts[i][0...3] is 'gif'
                                        ext = 'gif'
                                        break

                                url = '/tmp/'+rnd+'.'+key+'.'+ext
                                path = docpad.config.srcPath+'/files'+url

                                # Perform resize(s)
                                if val.crop
                                    scale = Math.max(val.width / size.width, val.height / size.height)
                                    width = Math.round(size.width * scale)
                                    height = Math.round(size.height * scale)
                                    dx = Math.floor((width - val.width) / 2)
                                    dy = Math.floor((height - val.height) / 2)
                                    await gm(file.path).resize(width, height).crop(val.width, val.height, dx, dy).noProfile().write path, defer err
                                    width = val.width
                                    height = val.height
                                else
                                    scale = Math.min(val.width / size.width, val.height / size.height)
                                    width = Math.round(size.width * scale)
                                    height = Math.round(size.height * scale)
                                    await gm(file.path).resize(width, height).noProfile().write path, defer err
                                if err
                                    errs.push err
                                    break

                                result[key] = {url, width, height}

                            if errs.length
                                res.set 'Content-Type', 'application/json'
                                res.status(404).send error: 'Error when resizing image.'
                            else
                                res.set 'Content-Type', 'application/json; charset=UTF-8'
                                res.send JSON.stringify result: result

                else
                    res.set 'Content-Type', 'application/json'
                    res.status(404).send error: 'Not handled in this version.'
                    return

            


















