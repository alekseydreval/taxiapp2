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
      date = new Date()
      this.set('select', [date.getFullYear(), date.getMonth(), date.getDate()]);
  }

  time_picker = $('#pickup_time').pickatime {
    interval: 15,
    onStart: ->
      date = new Date()
      this.set('select', [date.getHours(), date.getMinutes()]);
  }
  date = date_picker.pickadate('picker')
  time = time_picker.pickatime('picker')

  $('#submit_ticket_form').click ->
    date_time = date.get('select', 'yyyy/mm/dd') + ' ' + time.get('select', 'hh:i')
    $('#ticket_pick_up_time').val(date_time)
    $('#new_ticket').submit()

  