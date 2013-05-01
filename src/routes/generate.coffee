
sessionBridge = require '../utils/sessionBridge'

module.exports = (req, res) ->
    config = @config
    docpad = @docpad
    session = sessionBridge.get(req)

    unless session.authenticated
        res.redirect '/'+config.prefix.url+'/login?url='+req.url
        return

    # Force generate
    time = new Date().getTime();
    docpad.generate reset: true, ->
        res.set 'Content-Type', 'application/json; charset=UTF-8'
        res.send JSON.stringify result: (new Date().getTime() - time)
