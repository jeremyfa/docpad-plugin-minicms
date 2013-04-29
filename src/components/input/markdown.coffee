
module.exports = ->
    if @shouldLoadScript
        coffeescript ->

            window.minicms_component_markdown = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]

                editor = field.data 'epiceditor'
                unless editor?
                    field.data 'epiceditor', true
                    $(document).ready ->
                        defaultVal = field.data('value')
                        if typeof defaultVal isnt 'string'
                            defaultVal = ''
                        setTimeout (->
                            editor = new EpicEditor
                                container: 'form-input-'+form+'-'+name+'--epiceditor'
                                basePath: '/'+prefix+'/vendor/epiceditor'
                                clientSideStorage: false
                                #useNativeFullscreen: false
                                file:
                                    defaultContent: defaultVal
                                button:
                                    preview: true
                                    #fullscreen: true
                                    fullscreen: false
                                theme:
                                    base: '/themes/base/epiceditor.css'
                                    preview: '/../../css/epic-preview-minicms.css'
                                    editor: '/../../css/epic-editor-minicms.css'
                            field.data 'epiceditor', editor

                            # Sanitize on paste (requires patched epic editor)
                            editor.load ->
                                $(@getElement('editor').body).bind 'paste', ->
                                    setTimeout (->
                                        editor.sanitize()
                                    ), 1

                            $('#form-input-'+form+'-'+name+'--epiceditor iframe').css 'visibility', 'hidden'
                            setTimeout (->
                                $('#form-input-'+form+'-'+name+'--epiceditor iframe').css 'visibility', 'visible'
                                minicms_form_load(prefix, form, name)
                            ), 250
                            editor.on 'update', ->
                                text = editor.exportFile()
                                console.log name+" = "+text
                                field.data 'value', text
                                minicms_form_update(prefix, form)
                        ), 100

    div '#field-'+@form+'-'+@field+'.control-group.form-component-markdown', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                div '#form-input-'+@form+'-'+@field+'--epiceditor.input-xlarge.fake-field', style: "width:600px;height:#{if @height then @height else 320}px", ->

    text '<script type="text/javascript">minicms_component_markdown("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'