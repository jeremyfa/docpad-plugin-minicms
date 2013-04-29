
module.exports = ->

    h2 -> @model.name[1]
    
    if @model.list.filters?.length
        div '.navbar.navbar-static', ->
            div '.navbar-inner', ->
                div '.container', ->
                    ul '.nav', ->
                        for filter, i in @model.list.filters
                            data = @filterData[i]
                            name = @slugify(filter.name)
                            li '.dropdown', ->
                                a '.dropdown-toggle', 'data-toggle': 'dropdown', href: '#', ->
                                    if @filters[name]?
                                        for item in data
                                            if @slugify(item) is @filters[name]
                                                text filter.name+': '
                                                strong -> item
                                                break
                                    else
                                        text h(filter.name)
                                    text ' '
                                    b '.caret', ->
                                ul '.dropdown-menu', role: 'menu', ->
                                    li (if @filters[name]? then '' else '.active'), role: 'presentation', -> a href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/list'+@makeFilter(filter.name, null), -> 'Any'
                                    li '.divider', role: 'presentation', ->
                                    for item in data
                                        li (if @slugify(item) is @filters[name] then '.active' else ''), role: 'presentation', -> a href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/list'+@makeFilter(filter.name, item), -> h item

    if @model.form?
        div '.well', ->
            a '.btn.btn-primary.btn-small', href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/edit', ->
                span '.icon-plus.icon-white', ->
                text ' Create '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))

    table '#list.list-'+@slugify(@model.name[1])+'.table.table-hover', ->
        thead ->
            tr ->
                for field in @model.list.fields
                    td '.item-'+@slugify(field.name), -> h field.name
                td ->
        tbody ->
            # Invert list
            list = @data
            if list.length
                for i in [list.length-1..0]
                    item = list[i]
                    tr ->
                        for field in @model.list.fields
                            td '.field-'+@slugify(field.name), ->
                                if field.value?
                                    h field.value.apply(item) ? ''
                                else if field.html?
                                    text field.html.apply(item) ? ''
                        td ->
                            if item[@config.prefix.meta]?
                                a '.btn.btn-primary.btn-small', href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/edit?url='+item.url, ->
                                    span '.icon-pencil.icon-white', ->
                                    text ' Edit'
                                text ' '

