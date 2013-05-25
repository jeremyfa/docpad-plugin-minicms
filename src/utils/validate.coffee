
# Default validator for all fields
module.exports = (field, val) ->

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
        return typeof(val) is 'string' and (val.trim().length > 0 or field.optional)

    # Textarea
    else if field.type is 'textarea'
        return typeof(val) is 'string' and (val.trim().length > 0 or field.optional)

    # Wysiwyg
    else if field.type is 'wysiwyg'
        return typeof(val) is 'string' and (val.trim().length > 0 or field.optional)

    # Markdown
    else if field.type is 'markdown'
        return typeof(val) is 'string' and (val.trim().length > 0 or field.optional)

    # Choice
    else if field.type is 'choice'
        return typeof(val) is 'string' and (val.trim().length > 0 or field.optional)

    # Date
    else if field.type is 'date'
        return typeof(val) is 'number' and Math.floor(val) is val

    # Color
    else if field.type is 'color'
        if not val?.length is 7 then return false
        if not val.charAt(0) is '#' then return false
        for i in [1..6]
            if not (val.charAt(i).toLowerCase() in ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f']) then return false
        return true

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
