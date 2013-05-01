
# Trick to have an elegant way of creating getters and setters
Function::def = (prop, desc) ->
    Object.defineProperty @prototype, prop, desc

# Convert session params to lightweight data for signed cookie
class Session
    
    constructor: (@req) ->

    @def 'authenticated'
        get: ->
            if @req.session.a
                return true
            else
                return false
        set: (value) ->
            if value
                @req.session.a = 1
            else
                delete @req.session.a

    @def 'authenticating'
        get: ->
            if @req.session.b
                return true
            else
                return false
        set: (value) ->
            if value
                @req.session.b = 1
            else
                delete @req.session.b

    @def 'lastAuthAttempt'
        get: ->
            if @req.session.c
                return true
            else
                return false
        set: (value) ->
            @req.session.c = value

exports.get = (req) -> new Session(req)
