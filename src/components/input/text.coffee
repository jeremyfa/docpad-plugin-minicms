
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_text = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]
                minicms_form_load(prefix, form, name)

                $('input.form-value', field).on 'change', ->
                    if $(@).val() isnt field.data('value')
                        console.log name+" = "+$(@).val()
                        field.data('value', $(@).val())
                        minicms_form_update(prefix, form)

    div '#field-'+@form+'-'+@field+'.control-group.form-component-text', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                #input '#form-input-'+@field+'.widget-input.input-xlarge', type: 'text', value: h(@value), placeholder: h(@label), ->
                input '#form-input-'+@form+'-'+@field+'.form-value.input-xlarge.no-halo', type: 'text', value: h(if @value? then @value else ''), placeholder: h(if @label? then @label else ''), name: @field, ->

    text '<script type="text/javascript">minicms_component_text("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'