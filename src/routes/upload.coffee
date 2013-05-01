
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

# Upload file
module.exports = (req, res) ->

    config = @config
    docpad = @docpad
    session = sessionBridge.get(req)

    unless session.authenticated
        res.redirect '/'+@config.prefix.url+'/login?url='+req.url
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


