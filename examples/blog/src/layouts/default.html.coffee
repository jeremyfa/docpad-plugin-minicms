
index = @getIndex()

doctype 5
html ->

    head ->
        # Standard
        meta charset: 'utf-8'
        #meta 'http-equiv': 'X-UA-Compatible', content: 'IE=edge,chrome=1'
        meta 'http-equiv': 'content-type', content: 'text/html; charset=utf-8'
        meta name: 'viewport', content: 'width=device-width, initial-scale=1.0'

        # Document
        title (if @document.title then "#{@document.title} | #{index.title}" else index.title)
        meta name: 'description', content: @document.description or ''
        meta name: 'author', content: @document.author or ''
        text @getBlock('meta').toHTML()

        # Styles
        link rel: 'stylesheet', href: '/asset/coolblue/css/coolblue.css'
        link rel: 'stylesheet', href: '/asset/style.css'
        text @getBlock('styles').toHTML()

        # Scripts
        script type: 'text/javascript', src: '/asset/coolblue/js/jquery-1.6.1.min.js'
        script type: 'text/javascript', src: '/asset/coolblue/js/scrollToTop.js'
        text @getBlock('scripts').toHTML()

    body '.layout-'+(@document.layout.split('.')[0]), ->
        text @content
