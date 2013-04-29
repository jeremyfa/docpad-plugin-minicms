
module.exports =

    templateData:

        getIndex: ->
            @getCollection('html').findOne(url: '/')?.toJSON()

        getArticles: ->
            @getCollection('html').findAllLive(type: 'article').sortArray(date:-1)

        getLinks: ->
            @getCollection('html').findAllLive(type: 'link').sortArray(name:1)

    plugins:

        # This contains all the configuration of the admin panel of our blog
        minicms:

            #prefix:
            #    url:    'cms'     # Access the admin panel through '/cms' by default
            #    meta:   'cms'     # Store form data of each content into a 'cms' field by default

            secret: 'keyboard cat blog' # Secret, required by signed cookie

            auth: (login, password, callback) ->
                if login is 'admin' and password is 'password'
                    callback null, true
                else
                    callback "Invalid login or password.", false

            models: [
                name:   ['Configuration', 'Configuration']
                unique: true # When unique, there can only be 1 entry, not more, not less
                form:
                    url:    "/index" # Save configuration meta in index file
                    ext:    'html.md'
                    meta:
                        title:      -> @title
                        layout:     'home'
                        about:      -> @about
                    content:    -> @title
                    components: [
                        field:      'title'
                        label:      'Website Title'
                        type:       'text'
                    ,
                        field:      'author'
                        label:      'Website Author'
                        type:       'text'
                    ,
                        field:      'about'
                        label:      'About me'
                        type:       'textarea'
                        height:     100
                    ,
                        field:      'category'
                        label:      'Category'
                        type:       'choice'
                        expanded:   true
                        data:       ->  ['Sport', 'News']
                    ,
                        field:      'subCategory'
                        deps:       ['category'] # This field will update when the category field changes value
                        label:      'Sub-category'
                        type:       'choice'
                        data:       ->
                                        if @category is 'Sport'
                                            return ['Footbal', 'Tennis', 'Handball', 'Swimming']
                                        else if @category is 'News'
                                            return ['Technology', 'Finance', 'Gossip']
                                        else
                                            return []
                    ,
                        field:      'logo'
                        label:      'Website Logo'
                        type:       'file'
                        use:        'standard'
                        optional:   true
                        images:
                            standard:
                                # You can hardcode an extension (png, jpg, gif), or use the @ext value to dynamically generate the right type.
                                # Also works with animated gifs (but a bit experimental)
                                url:        -> "/logo.#{@ext}"
                                width:      220
                                height:     220
                    ,
                        field:      'wysiwygExample'
                        label:      'Wysiwyg example'
                        type:       'wysiwyg'
                        height:     450
                    ,
                        field:      'markdownExample'
                        label:      'Markdown example'
                        type:       'markdown'
                        height:     450
                    ]
            ,
                name:   ['Article', 'Articles']
                list:
                    fields: [
                        name:   'Title'
                        value:  -> @title
                    ,
                        name:   'Image'
                        html:   ->
                            if @image?
                                return '<div style="height:32px"><img src="'+@image.square.url+'" style="width:32px;height:32px" alt="image" /></div>'
                            else
                                return '<div style="height:32px">&nbsp; - &nbsp;</div>'
                    ,
                        name:   'Tags'
                        html:   ->
                            if @tags instanceof Array
                                return @tags.join(', ')
                            else
                                return ''
                    ]
                    filters: [
                        name:   'Tag'
                        data:   ->
                                    tags = []
                                    filter = type: 'article'
                                    for item in @docpad.getCollection('html').findAll(filter).models
                                        itemTags = item.get('tags')
                                        if itemTags instanceof Array
                                            for tag in itemTags
                                                if not (tag in tags)
                                                    tags.push tag
                                    return tags
                    ,
                        name:   'Kind'
                        data:   ->  ['With Image', 'Textual']
                    ]
                    data:   ->
                                filter = type: 'article'

                                # Filter by kind (with image or not)
                                if @kind is 'with-image'
                                    filter.image = $ne: null
                                else if @kind is 'textual'
                                    filter.image = null

                                collection = @docpad.getCollection('html').findAll(filter)

                                if @tag?
                                    # Filter by tags
                                    finalModels = []
                                    if collection.models instanceof Array
                                        for model in collection.models
                                            tags = model.get('tags')
                                            for tag in tags
                                                if @slugify(tag) is @tag
                                                    finalModels.push model.toJSON()
                                                    break
                                    return finalModels
                                else
                                    return collection

                form:
                    url:    -> "/blog/#{@slugify @title}"
                    ext:    'html.md'
                    meta:
                        title:      -> @title
                        type:       'article'
                        layout:     'article'
                        image:      -> @image
                        tags:       -> if @tags instanceof Array then @tags else []
                        date:       -> new Date(@date)
                    content:    -> @content
                    components: [
                        field:      'title'
                        type:       'text'
                    ,
                        field:      'date'
                        type:       'date'
                    ,
                        field:      'tags'
                        type:       'tags'
                        data:       ->
                                        tags = []
                                        for item in @docpad.getCollection('html').findAll().models
                                            itemTags = item.get('tags')
                                            if itemTags instanceof Array
                                                for tag in itemTags
                                                    if not (tag in tags)
                                                        tags.push tag
                                        return tags
                    ,
                        field:      'content'
                        type:       'markdown'
                        validate:   (val) -> typeof(val) is 'string' and val.length > 0
                    ,
                        field:      'image'
                        type:       'file'
                        use:        'thumbnail'
                        optional:   true
                        images:
                            standard:
                                url:       -> "/blog/#{@slugify @title}.#{@ext}"
                                width:      498
                                height:     9999999
                            thumbnail:
                                url:       -> "/blog/#{@slugify @title}.tn.#{@ext}"
                                width:      9999999
                                height:     128
                            square:
                                url:       -> "/blog/#{@slugify @title}.sq.#{@ext}"
                                width:      32
                                height:     32
                                crop:       true
                    ]
            ,
                name:   ['Link', 'Links']
                list:
                    fields: [
                        name:   'Name'
                        value:  -> @title
                    ,
                        name:   'URL'
                        html:   -> @href
                    ]
                    data:   ->
                                filter = type: 'link'
                                return @docpad.getCollection('html').findAll(filter)

                form:
                    url:    -> "/link/#{@slugify @name}"
                    ext:    'html.md'
                    meta:
                        title:      -> @name
                        type:       'link'
                        layout:     'link'
                        href:       -> @url
                    content:    -> @url
                    components: [
                        field:      'name'
                        type:       'text'
                    ,
                        field:      'url'
                        label:      'URL'
                        type:       'text'
                    ]
            ]




