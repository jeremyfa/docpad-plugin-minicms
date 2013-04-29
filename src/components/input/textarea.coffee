
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_textarea = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]
                minicms_form_load(prefix, form, name)

                $('textarea.form-value', field).on 'change', ->
                    if $(@).val() isnt field.data('value')
                        console.log name+" = "+$(@).val()
                        field.data('value', $(@).val())
                        minicms_form_update(prefix, form)

    div '#field-'+@form+'-'+@field+'.control-group.form-component-textarea', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                #input '#form-input-'+@field+'.widget-input.input-xlarge', type: 'text', value: h(@value), placeholder: h(@label), ->
                textarea '#form-input-'+@form+'-'+@field+'.form-value.input-xlarge.no-halo', style: "width:600px;height:#{if @height then @height else 320}px", name: @field, -> h(if @value? then @value else '')

    text '<script type="text/javascript">minicms_component_textarea("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'