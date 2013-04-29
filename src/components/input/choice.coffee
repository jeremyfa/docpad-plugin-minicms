
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_choice = (prefix, form, name, updated) ->
                field = $('#field-'+form+'-'+name)
                $('#field-'+form+'-'+name).data('reload', 'minicms_component_choice("'+prefix+'", "'+form+'", "'+name+'", true)')
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]
                if updated or not $('#'+form+'-form').data('fields')[name]?
                    if $('input.form-value.first-checked', field).length > 0
                        console.log name+" = "+$('input.form-value.first-checked', field).val()
                        field.data 'value', $('input.form-value.first-checked', field).val()
                    else
                        console.log name+" = "+$('select.form-value', field).val()
                        field.data 'value', $('select.form-value', field).val()
                    minicms_form_update(prefix, form)
                minicms_form_load(prefix, form, name)

                $('input.form-value', field).on 'click', ->
                    if $(@).val() isnt field.data('value')
                        console.log name+" = "+$(@).val()
                        field.data('value', $(@).val())
                        minicms_form_update(prefix, form)
                $('select.form-value', field).on 'change', ->
                    console.log name+" = "+$(@).val()
                    field.data('value', $(@).val())
                    minicms_form_update(prefix, form)

    div '#field-'+@form+'-'+@field+'.control-group.form-component-choice', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                if @expanded
                    div '#form-input-'+@form+'-'+@field, ->
                        for item, i in @data
                            label '.radio.inline', style: 'white-space:nowrap', ->
                                if @value is item or (i is 0 and not @value?)
                                    input '#form-input-'+@form+'-'+@field+'-'+i+'.form-value.first-checked', type: 'radio', name: @field, value: h(item), checked: 'checked', ->
                                else
                                    input '#form-input-'+@form+'-'+@field+'-'+i+'.form-value', type: 'radio', name: @field, value: h(item), ->
                                text h item
                            text ' &nbsp; '
                else
                    select '#form-input-'+@form+'-'+@field+'.input-xlarge.form-value.no-halo', name: @field, ->
                        for item, i in @data
                            label '.inline', style: 'white-space:nowrap', ->
                                if @value is item or (i is 0 and not @value?)
                                    option '#form-input-'+@form+'-'+@field+'-'+i, name: @field, value: h(item), selected: 'selected', -> h(item)
                                else
                                    option '#form-input-'+@form+'-'+@field+'-'+i, name: @field, value: h(item), -> h(item)

    text '<script type="text/javascript">minicms_component_choice("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'

