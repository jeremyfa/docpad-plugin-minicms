
sessionBridge = require '../utils/sessionBridge'

# Authenticate (submit)
module.exports = (req, res) ->
    docpad = @docpad
    config = @config
    session = sessionBridge.get(req)

    if not session.authenticating or not config.auth?
        res.redirect req.url
        return

    time = new Date().getTime()

    if session.lastAuthAttempt and session.lastAuthAttempt > time - 1000 # Prevent brute force attack
        session.authenticating = false
        res.redirect req.url
        return

    session.lastAuthAttempt = time

    @config.auth req.body.login, req.body.password, (err, result) ->
        if result
            session.authenticated = true
            if req.query.url
                res.redirect req.query.url
            else
                res.redirect '/'+config.prefix.url
        else
            res.redirect req.url
