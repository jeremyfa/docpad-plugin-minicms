
sessionBridge = require '../utils/sessionBridge'
slugify = require '../utils/slugify'
cc = require 'coffeecup'

# Admin root
module.exports = (req, res) ->
    docpad = @docpad
    config = @config
    session = sessionBridge.get(req)

    unless session.authenticated
        res.redirect '/'+@config.prefix.url+'/login?url='+req.url
        return

    content = cc.render require('../components/layout/index'), config: @config, slugify: slugify

    res.set 'Content-Type', 'text/html; charset=UTF-8'
    res.send cc.render require('../components/layout'), layout: 'index', url: req.url, config: @config, prefix: @config.prefix.url, title: 'Admin', content: content, slugify: slugify
