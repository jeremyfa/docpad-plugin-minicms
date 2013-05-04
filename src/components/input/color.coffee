
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_color = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]
                minicms_form_load(prefix, form, name)

                update = ->
                    newVal = $('.input-append.color input.form-value', field).val()
                    if newVal isnt field.data('value')
                        console.log name+" = "+newVal
                        field.data('value', newVal)
                        minicms_form_update(prefix, form)

                $('.input-append.color', field).colorpicker()
                setInterval update, 250

    div '#field-'+@form+'-'+@field+'.control-group.form-component-color', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                div '.input-append.color', 'data-color': h(if @value?.length then @value else '#ffffff'), 'data-color-format': 'hex', ->
                    input '#form-input-'+@form+'-'+@field+'.form-value.input-xlarge.no-halo.span1', type: 'text', value: h(if @value?.length then @value else '#ffffff'), name: @field, ->
                    span '.add-on', ->
                        i style: 'background-color:'+h(if @value?.length then @value else '#ffffff'), ->

    text '<script type="text/javascript">minicms_component_color("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'
