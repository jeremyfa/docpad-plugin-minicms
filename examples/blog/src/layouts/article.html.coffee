###
layout: page
###

months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'NOV', 'DEC']

article '.post', ->

    div '.primary', ->

        h2 -> a href: @document.url, -> @document.title

        if @document.tags?.length
            p '.post-info', ->
                span -> 'tags: <a href="/">'+@document.tags.join('</a>, <a href="/">')+'</a>'

        if @document.image?
            div '.image-section', ->
                img src: @document.image.standard.url, width: @document.image.standard.width, height: @document.image.standard.height, ->

        text ''+@content

    aside ->

        p '.dateinfo', ->
            text months[@document.date.getMonth()]
            span -> ''+@document.date.getDate()
