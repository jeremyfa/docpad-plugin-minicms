###
layout: page
###

months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'NOV', 'DEC']

for item in @getArticles()

    article '.post', ->

        div '.primary', ->

            h2 -> a href: item.url, -> item.title

            if item.tags?.length
                p '.post-info', ->
                    span -> 'tags: <a href="/">'+item.tags.join('</a>, <a href="/">')+'</a>'

            if item.image?
                div '.image-section', ->
                    img src: item.image.standard.url, width: item.image.standard.width, height: item.image.standard.height, ->

            text ''+item.contentRenderedWithoutLayouts

        aside ->

            p '.dateinfo', ->
                text months[item.date.getMonth()]
                span -> ''+item.date.getDate()

