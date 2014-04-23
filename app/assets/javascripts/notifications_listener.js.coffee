class TaxiApp.NotificationsListener

  # You can add statements inside the class definition
  # which helps establish private scope (due to closures)
  # instance is defined as null to force correct scope

  instance = null

  sendMessage: (message, send_to_id) ->
    obj = {}
    obj.send_to = send_to_id
    obj.message = message
    instance.connection.trigger "chat.new_message", obj

  constructor: (channel)->
    @role = channel
    channel_name = switch channel
                     when 'driver' then "driver_#{$('body').attr('data-user')}"
                     when 'dispatcher' then 'drivers_locations'

    @connection = new WebSocketRails("#{document.location.host}/websocket")
    window.connection = @connection
    console.log @connection
    console.log channel_name, channel
    @channel = @connection.subscribe channel_name
    @chat_channel = @connection.subscribe "user_#{$('body').attr('data-user')}"
    obj = {}
    obj.user_id = $('body').attr('data-user')
    @connection.trigger "chat.set_connection_id", obj
    unless $('body').attr('page') != 'navigation' and @role == 'driver'
      @map = new TaxiApp.Map
    @subscribeToNewMessage()

  subscribeToNewMessage: ->
    @chat_channel.bind 'new_message', (obj) ->
      messages_to = $("#message_user_#{obj.from}")
      messageTemplate = $("<div class='msg' style='color: red'>#{obj.from_name} | #{obj.message}</div>")
      chat_box = messages_to.find('.chat-box')
      chat_box.append(messageTemplate)
      if messages_to.is(':hidden')
        show_unread $("#message_btn_#{obj.from}")
      else
        scrollToLast chat_box

  startGeoLocationTacking: ->
    TaxiApp.Utils.getMyCoords (latlng) =>
      obj = {}
      obj.latlng = latlng
      obj.driver_id = "#{$('body').attr('data-user')}"
      @connection.trigger "tracker.update_location", obj
    , watch : true

  subscribeAllForDriver: ->
    @subscribeToNewSuggestion()
    @subscribeToTicketUpdate()
    @subscribeToTicketAccepted()
    @startGeoLocationTacking()

  subscribeAll: ->
    if @role == 'driver'
      @subscribeAllForDriver()
    else
      @getDriversLocations()
      @subscribeToDriversLocationsUpdates()

  subscribeToNewSuggestion: () ->
    @channel.bind 'new', (obj) ->
      console.log 'Got new suggestion'
      suggestion = obj.suggestion
      ticket = obj.ticket
      $("#C1R1").html JST["new_suggestion"](id : suggestion.id, pickup : ticket.pickup_address, dropoff :  ticket.dropoff_address, ticket_id : ticket.id)
      if $("#map").attr('data-positions')
        positions = $("#map").data('positions').slice()
      for pos in positions
        if pos.type == "start"
          pos.latlng = [ ticket.start_geolat, ticket.start_geolong]
        if pos.type == "stop"
          pos.latlng = [ ticket.stop_geolat, ticket.stop_geolong]
      @taxiMap.showDriverEndpoints()
      @taxiMap.showCurrentLocationRealTime()
      @taxiMap.fitBoundsToMarkers()
    console.log 'listening to new suggestions'

  subscribeToTicketUpdate: () ->
    @channel.bind 'update', (ticket) ->
      alerts = $("#alerts")
      notice = $("<div class = 'alert alert-info'>")
      notice.append $("<div>You recieved an update for  <a href='/tickets/#{ticket.id}'><b>ticket<b></a></div>")
      alerts.append notice
    console.log 'listening to tickets updates'

  subscribeToTicketAccepted: () ->
    @channel.bind 'accepted', (suggestion) ->
      console.log suggestion
      console.log "Sorry, this ticket is already accepted"
    console.log 'listening if this ticket is alreay accepted'
  
  getDriversLocations: () ->
    @connection.trigger('tracker.get_drivers_location', {}, @map.updateDriversPositions )

  subscribeToDriversLocationsUpdates: () ->
    @channel.bind 'update', @map.updateDriversPositions
    console.log 'listening to drivers position'


$ ->
  role = if $('body').attr('data-user-type') == 'driver' then 'driver' else 'dispatcher'
  page = $('body').attr('page')
  if role != 'dispatcher' || (role == 'dispatcher' && page == 'tickets#show')
    listener = new TaxiApp.NotificationsListener(role)
    listener.subscribeAll()
  else
    console.log "This page does not require any socket connection"
