
sessionBridge = require '../utils/sessionBridge'

# Authenticate (logout)
module.exports = (req, res) ->
    session = sessionBridge.get(req)
    session.authenticated = false
    session.authenticating = false
    res.redirect '/'+@config.prefix.url+'/login'

