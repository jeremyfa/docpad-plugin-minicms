
module.exports = ->
    doctype 5
    html ->

        head ->
            # Standard
            meta charset: 'utf-8'
            meta 'http-equiv': 'content-type', content: 'text/html; charset=utf-8'
            meta name: 'viewport', content: 'width=device-width, initial-scale=1.0'

            # Document
            title @title

            # Styles
            link rel: 'stylesheet', href: '/'+@prefix+'/css/bootstrap.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/minicms.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/jquery-ui/custom.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/tag-it.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/datetimepicker.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/bootstrap-wysihtml5.css'
            link rel: 'stylesheet', href: '/'+@prefix+'/css/wysiwyg-color.css'

            # Scripts
            script src: '/'+@prefix+'/js/underscore.js'
            script src: '/'+@prefix+'/js/jquery.js'
            script src: '/'+@prefix+'/js/jquery-ui.js'
            script src: '/'+@prefix+'/js/jquery-file-upload.js'
            script src: '/'+@prefix+'/js/jquery-file-upload-iframe-transport.js'
            script src: '/'+@prefix+'/js/bootstrap.js'
            script src: '/'+@prefix+'/js/tag-it.js'
            script src: '/'+@prefix+'/js/datetimepicker.js'
            script src: '/'+@prefix+'/js/wysihtml5.js'
            script src: '/'+@prefix+'/js/bootstrap-wysihtml5.js'
            script src: '/'+@prefix+'/vendor/epiceditor/js/epiceditor.js'

        body '#minicms', 'data-prefix': @prefix, ->
            div '#navbar.navbar.navbar-inverse.navbar-fixed-top', ->
                div '.navbar-inner', ->
                    div '.container', ->
                        ul '.nav', ->
                            li '.other-button', -> a href: '/', ->
                                span '.icon-home.icon-white', ->
                                text ' '
                                span '.text', -> 'Site'
                            li '.other-button.active', -> a href: '/'+@prefix, ->
                                span '.icon-pencil.icon-white', ->
                                text ' '
                                span '.text', -> 'Admin'
                        ul '.nav.pull-right', ->
                            li '#docpad-reload-button', -> a href: '/'+@prefix, ->
                                span '.icon-refresh.icon-white', ->
                                text ' '
                                span '.text', -> 'Reload'
                            li '#docpad-logout-button.other-button', -> a href: '/'+@prefix+'/logout', ->
                                span '.icon-circle-arrow-left.icon-white', ->
                                text ' '
                                span '.text', -> 'Log out'

            div '#content.layout-'+@layout, ->
                div '#menu.well.well-small', ->
                    ul '.nav.nav-list', ->
                        li '.nav-header', -> 'Content'
                        for item in @config.models
                            if item.unique
                                if @model?.name[0] is item.name[0]
                                    li '.active', -> a href: '/'+@prefix+'/'+@slugify(item.name[0])+'/edit?url='+item.form.url, -> h item.name[1]
                                else
                                    li -> a href: '/'+@prefix+'/'+@slugify(item.name[0])+'/edit?url='+item.form.url, -> h item.name[1]
                            else if @model?.name[0] is item.name[0]
                                li '.active', -> a href: '/'+@prefix+'/'+@slugify(item.name[0])+'/list', -> h item.name[1]
                            else
                                li -> a href: '/'+@prefix+'/'+@slugify(item.name[0])+'/list', -> h item.name[1]

                div '#page', ->
                    p -> text @content

    coffeescript ->

        $(document).ready ->
            prefix = $('#minicms').data('prefix')

            $('#navbar .other-button').click (e) ->
                if $('#docpad-reload-button').hasClass('active')
                    e.preventDefault()

            $('#docpad-reload-button').click (e) ->
                e.preventDefault()
                if $('#docpad-reload-button').hasClass('active')
                    return

                $('#content').empty()
                $('#navbar .other-button').css
                    visibility: 'hidden'
                    position:   'relative'
                    left:       '-9999px'
                    top:        '-9999px'

                $('#docpad-reload-button').addClass('active')
                $('#docpad-reload-button span.icon-refresh').css
                    backgroundImage:    'url("/'+prefix+'/img/loader-inverted.gif")'
                    backgroundPosition: 'center'
                    backgroundRepeat:   'no-repeat'
                    opacity:            1
                $('#docpad-reload-button span.text').html '&nbsp;Reloading...'

                $.ajax
                    url: '/'+prefix+'/generate'
                    type: 'POST'
                    error: ->
                        document.location.reload()
                    success: ->
                        document.location.reload()

