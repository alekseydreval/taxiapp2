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
        # console.log data.response.GeoObjectCollection.featureMember
        cb(res)
    updater: (item) ->
      window.geo = window.geo_coded[item]
      $('#submit_ticket_form').removeAttr('disabled')
      item

  }
  
  date_picker = $('#pickup_date').pickadate()
  time_picker = $('#pickup_time').pickatime()
  date = date_picker.pickadate('picker')
  time = time_picker.pickatime('picker')

  $('#submit_ticket_form').click ->
    date_time = date.get('select', 'yyyy/mm/dd') + ' ' + time.get('select', 'hh:i')
    $('#ticket_pick_up_time').val(date_time)
    $('#new_ticket').submit()

  