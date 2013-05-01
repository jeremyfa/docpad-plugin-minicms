
# Copy the 'input' object and replace each function by the value it returns after applying 'context'
applyContext = (input, context) ->
    if input instanceof Array
        res = []
        for item in input
            res.push applyContext(item, context)
        return res
    else if typeof(input) is 'function'
        return input.apply(context)
    else if typeof(input) is 'object'
        res = {}
        for key, val of input
            res[key] = applyContext(val, context)
        return res
    else
        return input

module.exports = applyContext
