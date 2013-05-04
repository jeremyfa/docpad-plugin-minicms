
# Default sanitizer for all fields
module.exports = (field, val) ->

    # Text
    if field.type is 'text'
        if not val? then return ''
        return val.trim()

    # Textarea
    if field.type is 'textarea'
        if not val? then return ''
        return val.trim()

    # Wysiwyg
    if field.type is 'wysiwyg'
        if not val? then return ''
        return val.split("\n").join(' ').split("\r").join(' ').trim()

    # Choice
    else if field.type is 'choice'
        if not val? then return null
        return val.trim()

    # Date
    else if field.type is 'date'
        if not val? then return Math.floor(new Date().getTime() / 1000) * 1000
        return Math.floor(val / 1000) * 1000

    # Color
    else if field.type is 'color'
        if not val? then return '#ffffff'
        return val.toLowerCase()

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
