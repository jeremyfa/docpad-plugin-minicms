
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

# List content
module.exports = (req, res) ->

    session = sessionBridge.get(req)
    docpad = @docpad
    config = @config

    unless session.authenticated
        res.redirect '/'+@config.prefix.url+'/login?url='+req.url
        return

    model = null

    for item in @config.models
        if slugify(item.name[0]) is req.params.content
            model = item

    unless model?.list?
        req.redirect '/'+@config.prefix.url
        return

    context = docpad: @docpad, slugify: slugify
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
                data = data.apply docpad: @docpad
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

    content = cc.render require('../components/layout/list'), filters: filters, filterData: filterData, config: @config, model: model, slugify: slugify, data: data, makeFilter: makeFilter

    res.set 'Content-Type', 'text/html; charset=UTF-8'
    res.send cc.render require('../components/layout'), layout: 'list', model: model, url: req.url, config: @config, prefix: @config.prefix.url, title: 'Admin - '+model.name[1], content: content, slugify: slugify


