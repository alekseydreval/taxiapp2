$ ->
  $('.address-picker').typeahead {
    matcher: () -> true,
    source : (query, cb) ->
      console.log(query)
      window.geo = null;
      $('#submit_ticket_form').attr('disabled', true)
      $.getJSON "http://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург" + query, (data) ->
        window.geo_coded = _.object(_.map data.response.GeoObjectCollection.featureMember, (object) -> [object.GeoObject.name, object.GeoObject.boundedBy.Envelope.lowerCorner])
        res = _.map data.response.GeoObjectCollection.featureMember, (object) -> object.GeoObject.name
        cb(res)
    updater: (item) ->
      window.geo = window.geo_coded[item]
      if /pick_up/.test(@.$element[0].id)
        $('#ticket_pick_up_latlon').val(window.geo)
      else
        $('#ticket_drop_off_latlon').val(window.geo)

      $('#submit_ticket_form').removeAttr('disabled')
      item

  }
  
  date_picker = $('#pickup_date').pickadate {
    onStart: ->
      if pick_up_time = $('#ticket_pick_up_time').val()
        date = pick_up_time.replace('T', ' ').split(' ')[0]
        this.set('select', date, { format : 'yyyy-mm-dd' });
      else
        date = new Date()
        this.set('select', [date.getFullYear(), date.getMonth(), date.getDate()]);
  }

  time_picker = $('#pickup_time').pickatime {
    interval: 15,
    onStart: ->
      if pick_up_time = $('#ticket_pick_up_time').val()
        time = pick_up_time.replace('T', ' ').split(' ')[1]
        this.set('select', [time.split(':')[0], time.split(':')[1]])
      else
        date = new Date()
        this.set('select', [date.getHours(), date.getMinutes()])
    format: 'HH:i'
  }

  date = date_picker.pickadate('picker')
  time = time_picker.pickatime('picker')

  $('#submit_ticket_form').click ->
    date_time = date.get('select', 'yyyy/mm/dd') + ' ' + time.get('select', 'hh:i')
    $('#ticket_pick_up_time').val(date_time)
    $('#ticket_form').submit()
