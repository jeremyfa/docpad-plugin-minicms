
sessionBridge = require '../utils/sessionBridge'
slugify = require '../utils/slugify'
cc = require 'coffeecup'

# Authenticate (page)
module.exports = (req, res) ->
    session = sessionBridge.get(req)
    session.authenticating = true
    res.send cc.render require('../components/layout/authenticate'), layout: 'authenticate', url: req.url, config: @config, prefix: @config.prefix.url, title: 'Admin - Authenticate', slugify: slugify
