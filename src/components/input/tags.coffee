
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_tags = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]

                $(document).ready ->
                    $('#form-input-'+form+'-'+name+'--tagit').css 'visibility', 'hidden'
                    setTimeout (->
                        $('#form-input-'+form+'-'+name+'--tagit').css 'visibility', 'visible'
                        $('#form-input-'+form+'-'+name+'--tagit').tagit
                            availableTags: field.data('available-tags')
                            allowSpaces: true
                            caseSensitive: false
                            preprocessTag: (val) ->
                                if not val?.length
                                    return ''
                                else
                                    result = []
                                    for subresult in val.split(' ')
                                        if subresult.length
                                            result.push subresult.charAt(0).toUpperCase()+subresult.substring(1)
                                    return result.join(' ')
                            afterTagAdded: (ev, ui) ->
                                val = $('#form-input-'+form+'-'+name+'--tagit').tagit('assignedTags')
                                console.log name+" = "+val
                                field.data 'value', val
                                minicms_form_update(prefix, form)
                            afterTagRemoved: (ev, ui) ->
                                val = $('#form-input-'+form+'-'+name+'--tagit').tagit('assignedTags')
                                console.log name+" = "+val
                                field.data 'value', val
                                minicms_form_update(prefix, form)
                        minicms_form_load(prefix, form, name)
                    ), 100

    div '#field-'+@form+'-'+@field+'.control-group.form-component-tags', 'data-available-tags': (if @data instanceof Array then h(JSON.stringify(@data)) else '[]'), ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                #input '#form-input-'+@field+'.widget-input.input-xlarge', type: 'text', value: h(@value), placeholder: h(@label), ->
                #input '#form-input-'+@form+'-'+@field+'.form-value.input-xlarge', type: 'text', value: h(if @value? then @value else ''), placeholder: h(if @label? then @label else ''), name: @field, ->
                ul '#form-input-'+@form+'-'+@field+'--tagit.tagit-minicms', ->
                    if @value instanceof Array
                        for val in @value
                            li -> h(val)



    text '<script type="text/javascript">minicms_component_tags("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'