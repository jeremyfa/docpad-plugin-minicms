
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_file = (prefix, form, field) ->
                fieldEl = $('#field-'+form+'-'+field)
                console.log field+" = "+$('#'+form+'-form').data('fields')[field]
                fieldEl.data 'value', $('#'+form+'-form').data('fields')[field]

                value = $('#field-'+form+'-'+field+' #form-input-'+form+'-'+field+'-hidden').val()
                use = $('#field-'+form+'-'+field).data('use')
                if not value or value is ''
                    value = null

                load = ->

                    id = 'field-'+form+'-'+field

                    # Hide all states
                    $('#'+id+' .state').hide()

                    if not value? or value <= 0
                        # Except "input-file" state
                        $('#'+id+' .state-input-file').show()
                    else
                        [comps..., ext] = value.split('.')
                        if ext in ['jpg', 'jpeg', 'png', 'gif']
                            $('#'+id+' .state').hide()
                            $('#'+id+' .state-image').empty()
                            $('#'+id+' .state-image').append($('<img />'))
                            $('#'+id+' .state-image').append($('<a href="#" class="btn btn-mini btn-danger" />'))
                            $('#'+id+' .state-image a').append($('<span class="icon icon-trash icon-white" />'))
                            $('#'+id+' .state-image a').click (e) =>
                                e.preventDefault()
                                value = null
                                $('#'+id+' .state-image a').remove()
                                $('#'+id+' .state-image img').hide 'fast', =>
                                    $('#'+id+' .state-image img').remove()
                                    fieldEl.data 'value', null
                                    console.log field+" = null"
                                    minicms_form_update(prefix, form)
                                    load()

                            $('#'+id+' .state-image img').attr('src', value+'?nocache='+(new Date().getTime()))
                            $('#'+id+' .state-image img').addClass('img-polaroid')
                            $('#'+id+' .state-image').show()
                        else
                            $('#'+id+' .state').hide()
                            $('#'+id+' .state-unknown').show()
                            $('#'+id+' .state-unknown').text value
                    
                    # Except "loading" state
                    #$('#'+id+' .state-loading').show()
                    
                    ###
                    test ->
                    # Check if file exists
                    #chocolate.Model.findOneBy id: value, 'File', (err, file) => 
                    # TODO load data ->
                        if err?
                            value = null
                            $('#'+id+' .state').hide()
                            $('#'+id+' .state-input-file').show()
                            return

                        id = file.get('id')
                        tn =
                            path: "/files/#{id}"
                            name: "/#{md5(id+'|'+id)}.tn.jpg"
                        
                        if file.isImage()
                            $('#'+id+' .state').hide()
                            $('#'+id+' .state-image').empty()
                            $('#'+id+' .state-image').append($('<img />'))
                            $('#'+id+' .state-image').append($('<a href="#" class="btn btn-mini btn-danger" />'))
                            $('#'+id+' .state-image a').append($('<span class="icon icon-trash icon-white" />'))
                            $('#'+id+' .state-image a').click (e) =>
                                e.preventDefault()
                                value = null
                                $('#'+id+' .state-image a').remove()
                                $('#'+id+' .state-image img').hide 'fast', =>
                                    $('#'+id+' .state-image img').remove()
                                    load()
                                
                            $('#'+id+' .state-image img').attr('src', tn.path+''+tn.name)
                            $('#'+id+' .state-image').show()
                        else
                            $('#'+id+' .state').hide()
                            $('#'+id+' .state-unknown').show()
                            $('#'+id+' .state-unknown').text file.get('name')
                    ###

                upload = (data) ->

                    # Hide all states
                    $('#field-'+form+'-'+field+' .state').hide()
                    # Except "uploading" state
                    $('#field-'+form+'-'+field+' .state-uploading').show()
                    
                    # Perform file upload
                    data.url = '/'+prefix+'/'+$('#'+form+'-form').data('model')+'/'+field+'/upload'
                    req = data.submit()
                    
                    # And handle result
                    req.success (data) =>
                        console.log "UPLOAD SUCCESS"
                        # Do something with: data.result.id
                        value = data.result[use]?.url
                        fieldEl.data 'value', data.result
                        console.log field+" = "+JSON.stringify(data.result)
                        minicms_form_update(prefix, form)
                        checkFile = ->
                            $.ajax
                                url: data.result[use]?.url
                                type: 'HEAD'
                                error: ->
                                    setTimeout checkFile, 1000
                                success: ->
                                    load()
                        setTimeout checkFile, 1000

                    req.error (data) =>
                        console.log "UPLOAD ERROR"
                        try
                            json = JSON.parse(data.responseText)
                            # Error with: json.error
                        catch e
                            # Error with: data.responseText
                        load()

                #$(document).ready ->
                # Init file uploader
                $('#field-'+form+'-'+field+' #form-input-'+form+'-'+field).fileupload
                    type: 'POST'
                    dataType: 'json'
                    singleFileUploads: true
                    add: (e, data) => upload(data)
                $('#field-'+form+'-'+field+' .controls').css
                    position: 'relative'
                $('#field-'+form+'-'+field+' #form-input-'+form+'-'+field).css
                    position: 'absolute'
                    opacity: 0
                    zIndex: 2
                    left: 0
                    top: -5
                    width: 120
                    height: 38

                load()
                minicms_form_load(prefix, form, field)



    div '#field-'+@form+'-'+@field+'.control-group.form-component-file', 'data-use': (if @use? then @use else ''), ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                div '.state.state-loading', -> ''
                div '.state.state-uploading', -> 'uploading...'
                div '.state.state-input-file', ->
                    a '.btn.btn-primary.upload-file', href: '#', -> "Choose file"
                    #input '#form-input-'+@form+'-'+@field+'.widget-input.input-xlarge', type: 'file', name: 'file', ->
                    input '#form-input-'+@form+'-'+@field+'.input-xlarge', type: 'file', name: 'file['+@field+']', ->
                    input '#form-input-'+@form+'-'+@field+'-hidden.form-value', type: 'hidden', value: (if @value? then (if @use? then @value[@use].url else @value) else ''), name: @field, ->
                div '.state.state-image', ->
                div '.state.state-unknown', ->

    text '<script type="text/javascript">minicms_component_file("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'


