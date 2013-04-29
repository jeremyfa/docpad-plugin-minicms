###
layout: default
###

index = @getIndex()

body '#top', ->

    div '#header-wrap', ->
        header ->
            h1 -> a href: '/', -> img src: '/logo.png'

            nav ->
                ul ->
                    li '#current', ->
                        a href: '/', -> 'Blog'
                        span -> ' '

    div '#content-wrap', ->

        div '#content.clearfix', ->

            div '#main', ->

                text @content


            div '#sidebar', ->

                div '.about-me', ->
                    h3 -> 'About me'

                    p ->
                        a href: '/', -> img '.align-left', src: '/asset/coolblue/images/gravatar.jpg', width: 42, height: 42, ->
                        text ''+index.about

                div '.sidemenu', ->
                    h3 -> 'Links'

                    ul ->
                        for link in @getLinks()
                            li -> a href: link.url, -> link.title
    