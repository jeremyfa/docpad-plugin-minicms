
module.exports = ->

    coffeescript ->

        window.minicms_form_init = (prefix, form) ->
            data = $('#'+form+'-form').data('fields')
            $('#minicms .well').css 'display', 'block'
            $('#minicms #'+form+'-form-save-button').on 'click', (e) ->
                e.preventDefault()
                if $('#minicms #'+form+'-form-save-button').hasClass('disabled') then return
                $('#minicms #'+form+'-form-save-button').addClass('disabled')
                minicms_form_save prefix, form
            $('#minicms #'+form+'-form-confirm-delete-button').on 'click', (e) ->
                e.preventDefault()
                if $('#minicms #'+form+'-form-confirm-delete-button').hasClass('disabled') then return
                $('#minicms #'+form+'-form-confirm-delete-button').addClass('disabled')
                minicms_form_delete prefix, form
            console.log data

        window.minicms_form_load = (prefix, form, field) ->
            data = $('#'+form+'-form').data('fields')
            loaded = $('#'+form+'-form').data('loaded')
            allLoaded = $('#'+form+'-form').data('all-loaded')
            if allLoaded then return
            if not loaded? then loaded = {}
            loaded[field] = true
            allLoaded = true
            for name, val of data
                if not loaded[name]
                    console.log "NOT LOADED: #{name}"
                    allLoaded = false
                    break
            $('#'+form+'-form').data('loaded', loaded)
            if allLoaded
                $('#'+form+'-form').data('all-loaded', allLoaded)
                minicms_form_update prefix, form


        window.minicms_form_update = (prefix, form) ->
            allLoaded = $('#'+form+'-form').data('all-loaded')
            if not allLoaded
                return

            data = {}
            for name, val of $('#'+form+'-form').data('fields')
                data[name] = val
            keys = $('#'+form+'-form').data('keys')
            for key in keys
                unless data[key]?
                    data[key] = null
            deps = $('#'+form+'-form').data('deps')
            toReload = []
            changed = false
            for name, val of data
                field = $('#field-'+form+'-'+name)
                newVal = field.data('value')
                unless newVal?
                    newVal = null
                unless val?
                    val = null
                unless _.isEqual(val, newVal)
                    changed = true
                    # Look for dependant fields
                    console.log name+" changed"
                    data[name] = newVal
                    for k, v of deps
                        if name in v
                            console.log "should reload "+k
                            unless k in toReload
                                toReload.push k
            if changed
                $('#'+form+'-form-save-button').css 'display', 'inline-block'
            $('#'+form+'-form').data('fields', data)
            if toReload.length > 0
                console.log "update data..."
                xhr = $.ajax(
                    url: document.location.href
                    type: 'POST'
                    data:
                        fields: JSON.stringify(data)
                ).done(->
                    html = xhr.responseText
                    html = html.split("\n").join(' ').split("\r").join(' ')
                    html = html.replace /<script([^>]*)>(.*?)<\/script>/ig, ''
                    bodyMatcher = /<body([^>]*)>(.*)<\/body>/ig
                    bodyMatcher.lastIndex = 0
                    headMatcher = /<head([^>]*)>(.*)<\/head>/ig
                    headMatcher.lastIndex = 0
                    bodyContents = html.match(bodyMatcher)[0].replace(/^<body([^>]*)>/ig, '').replace(/<\/body>$/ig, '')
                    # Create element from parsed html text
                    el = $(bodyContents)
                    for subname in toReload
                        $('#field-'+form+'-'+subname+' .form-field-content').replaceWith($('#field-'+form+'-'+subname+' .form-field-content', el))
                        reload = $('#field-'+form+'-'+subname).data('reload')
                        console.log reload
                        if reload?
                            eval(reload)

                ).fail(-> console.log("fail"))

        window.minicms_form_save = (prefix, form) ->

            data = {}
            for name, val of $('#'+form+'-form').data('fields')
                data[name] = val
            keys = $('#'+form+'-form').data('keys')
            for key in keys
                unless data[key]?
                    data[key] = null
            
            formEl = $ '<form method="post"><input class="input-fields" type="hidden" name="fields" /><input type="hidden" name="do" value="save" /></form>'
            formEl.attr 'action', document.location.href
            $('input.input-fields', formEl).val(JSON.stringify(data))
            formEl[0].submit()

        window.minicms_form_delete = (prefix, form) ->

            formEl = $ '<form method="post"><input type="hidden" name="do" value="delete" /></form>'
            formEl.attr 'action', document.location.href
            formEl[0].submit()

        updateFormLayout = ->
            if $(window).width() < 1180
                $('.main-edit-form').removeClass 'form-horizontal'
                $('.main-edit-form').addClass 'form-not-horizontal'
            else
                $('.main-edit-form').addClass 'form-horizontal'
                $('.main-edit-form').removeClass 'form-not-horizontal'

        $(document).ready ->
            updateFormLayout()
        $(window).on 'resize', ->
            updateFormLayout()



    if @item?
        h2 -> 'Edit '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))
    else
        h2 -> 'Create '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))

    if @item?
        div '#'+@form+'-form-confirm-delete.modal.hide.fade', tabindex: '-1', role: 'dialog', 'aria-hidden': 'true', ->
            div '.modal-header', ->
                h4 -> 'Delete '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))+'?'
            div '.modal-body', ->
                p -> 'Doing this will erase permanently all data related to this content. It cannot be undone.'
            div '.modal-footer', ->
                button '.btn', 'data-dismiss': 'modal', 'aria-hidden': 'true', -> 'Cancel'
                button '#'+@form+'-form-confirm-delete-button.btn.btn-danger', -> 'Delete '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))

    div '.well', style: 'display:none', ->
        unless @model.unique
            a '#'+@form+'-form-list-button.btn.btn-primary.btn-small.form-delete-button', href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/list', ->
                span '.icon-arrow-left.icon-white', ->
                text ' '+h(@model.name[1])
            text ' &nbsp; '
        if @item?
            unless @model.unique
                a '#'+@form+'-form-delete-button.btn.btn-danger.btn-small.form-delete-button', href: '#'+@form+'-form-confirm-delete', 'data-toggle': 'modal', ->
                    span '.icon-trash.icon-white', ->
                    text ' Delete '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))
                text ' &nbsp; '
            a '#'+@form+'-form-save-button.btn.btn-success.btn-small.form-save-button', href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/edit?url='+@item.url, ->
                span '.icon-download-alt.icon-white', ->
                text ' Save '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))
        else
            a '#'+@form+'-form-save-button.btn.btn-success.btn-small.form-save-button', href: '/'+@config.prefix.url+'/'+@slugify(@model.name[0])+'/edit', ->
                span '.icon-download-alt.icon-white', ->
                text ' Save '+h(@model.name[0].charAt(0).toLowerCase()+@model.name[0].substring(1))

    for error in @errors
        div '.alert.alert-error', ->
            a '.close', 'data-dismiss': 'alert', 'data-field': (if error.field? then h(error.field) else ''), -> '×'
            text ' '+h(error.message)

    for success in @successes
        div '.alert.alert-success', ->
            a '.close', 'data-dismiss': 'alert', -> '×'
            text ' '+h(success.message)

    div '.well', style: 'display:none', ->
        form '#'+@form+'-form.form-horizontal.main-edit-form', 'data-model': @slugify(@model.name[0]), 'data-fields': h(JSON.stringify(@data)), 'data-deps': h(JSON.stringify(@deps)), 'data-keys': h(JSON.stringify(@keys)), onsubmit: 'return false;', ->
            for component in @components
                text component

    text '<script type="text/javascript">minicms_form_init("'+@config.prefix.url+'", "'+@form+'");</script>'

