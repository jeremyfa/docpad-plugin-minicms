
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_wysiwyg = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]

                editor = null
                $(document).ready ->
                    setTimeout (->
                        $('#form-input-'+form+'-'+name).wysihtml5 'deepExtend',
                            'font-styles': true
                            'emphasis': true
                            'lists': true
                            'html': true
                            'link': true
                            'image': true
                            'color': false
                            events:
                                change: ->
                                    console.log name+" = "+$('#form-input-'+form+'-'+name).val()
                                    field.data('value', $('#form-input-'+form+'-'+name).val())
                                    minicms_form_update(prefix, form)
                            stylesheets: []
                            parserRules:
                                tags:
                                    # Allow iframe in order to handle video from youtube, dailymotion ...
                                    iframe:
                                        check_attributes:
                                            src: 'url'
                                            width: 'numbers'
                                            height: 'numbers'
                                        set_attributes:
                                            frameborder: '0'
                                            seamless: 'seamless'
                        minicms_form_load(prefix, form, name)
                    ), 1

                $('textarea.form-value', field).on 'change', ->
                    if $(@).val() isnt field.data('value')
                        console.log name+" = "+$(@).val()
                        field.data('value', $(@).val())
                        minicms_form_update(prefix, form)

    div '#field-'+@form+'-'+@field+'.control-group.form-component-wysiwyg', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                #input '#form-input-'+@field+'.widget-input.input-xlarge', type: 'text', value: h(@value), placeholder: h(@label), ->
                textarea '#form-input-'+@form+'-'+@field+'.form-value.input-xlarge.no-halo', style: "width:600px;height:#{if @height then @height else 320}px", name: @field, -> h(if @value? then @value else '')

    text '<script type="text/javascript">minicms_component_wysiwyg("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'