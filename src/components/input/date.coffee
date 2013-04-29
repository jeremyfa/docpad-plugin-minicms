
module.exports = ->
    if @shouldLoadScript
        coffeescript ->
            window.minicms_component_date = (prefix, form, name) ->
                field = $('#field-'+form+'-'+name)
                console.log name+" = "+$('#'+form+'-form').data('fields')[name]
                field.data 'value', $('#'+form+'-form').data('fields')[name]

                $(document).ready ->
                    format = $('#form-input-'+form+'-'+name+' input').data('format')

                    $('#form-input-'+form+'-'+name).datetimepicker
                        pickTime: (if format is 'yyyy-MM-dd' then false else true)

                    # Fill date
                    picker = $('#form-input-'+form+'-'+name).data('datetimepicker')
                    val = $('#'+form+'-form').data('fields')[name]
                    unless val
                        val = new Date().getTime()
                    picker.setLocalDate(new Date(val))
                    minicms_form_load(prefix, form, name)

                    setInterval (->
                        current = $('#'+form+'-form').data('fields')[name]
                        date = picker.getLocalDate().getTime()
                        if current isnt date
                            console.log name+" = "+date
                            field.data('value', date)
                            minicms_form_update(prefix, form)
                    ), 250

    div '#field-'+@form+'-'+@field+'.control-group.form-component-date', ->
        div '.form-field-content', ->
            label '.control-label', for: "form-input-#{@form}-#{@field}", -> h @label
            div '.controls', ->
                div '#form-input-'+@form+'-'+@field+'.input-append.date', ->
                    input '.no-halo', type: 'text', 'data-format': (if @time? and not @time then 'yyyy-MM-dd' else 'yyyy-MM-dd hh:mm:ss'), ->
                    span '.add-on', ->
                        i 'data-time-icon': 'icon-time', 'data-date-icon': 'icon-calendar', ->

    text '<script type="text/javascript">minicms_component_date("'+@config.prefix.url+'", "'+@form+'", "'+@field+'");</script>'