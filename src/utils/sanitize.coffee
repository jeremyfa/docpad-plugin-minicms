
# Default sanitizer for all fields
module.exports = (field, val) ->

    # Text
    if field.type is 'text'
        return val.trim()

    # Textarea
    if field.type is 'textarea'
        return val.trim()

    # Wysiwyg
    if field.type is 'wysiwyg'
        return val.split("\n").join(' ').split("\r").join(' ').trim()

    # Choice
    else if field.type is 'choice'
        return val.trim()

    # Date
    else if field.type is 'date'
        return Math.floor(val / 1000) * 1000

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
