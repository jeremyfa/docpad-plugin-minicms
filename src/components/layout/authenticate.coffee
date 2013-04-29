
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

            # Scripts
            script src: '/'+@prefix+'/js/jquery.js'
            script src: '/'+@prefix+'/js/bootstrap.js'

        body '#minicms', 'data-prefix': @prefix, ->

            div '#navbar.navbar.navbar-inverse.navbar-fixed-top', ->
                div '.navbar-inner', ->
                    div '.container', ->
                        ul '.nav', ->
                            li -> a href: '/', ->
                                span '.icon-home.icon-white', ->
                                text ' '
                                span '.text', -> 'Site'
                            li '.active', -> a href: '/'+@prefix, ->
                                span '.icon-pencil.icon-white', ->
                                text ' '
                                span '.text', -> 'Admin'

            div '#content.layout-'+@layout, ->

                div '#authenticate-page', ->
                    form '.form-inline', action: h(@url), method: 'POST', ->
                        input '.input-small', type: 'text', placeholder: 'Login', name: 'login', ->
                        text ' '
                        input '.input-small', type: 'password', placeholder: 'Password', name: 'password', ->
                        text ' '
                        button '.btn', type: 'submit', -> 'Sign in'

