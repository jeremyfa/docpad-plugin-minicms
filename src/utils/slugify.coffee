
# Convert any string into a slug that can only have alphanumeric lowercase characters and - character.
urlify = require('urlify').create(addEToUmlauts: false, szToSs: true, spaces: '-', nonPrintable: '-', trim: true)
slug = require('slug')
slugs = {}
slugify = (str) ->
    res = slugs[str]
    unless res?
        res = urlify(slug(str)).toLowerCase()
        slugs[str] = res
    return res

module.exports = slugify
