window.TaxiApp = {}
window.TaxiApp.Utils = {}

TaxiApp.Utils.getMyCoords = (callback, opts = {}) ->
  if tracker = navigator.geolocation
    if cached_coords = TaxiApp.Utils.cachedCoords
      console.log 'returning cached coords'
      console.log cached_coords
      callback cached_coords
    else
      tracker.getCurrentPosition (position) ->
        console.log position
        coords = [ position['coords']['latitude'], position['coords']['longitude'] ]
        TaxiApp.Utils.cachedCoords = coords
        console.log "My location is #{coords}"
        callback coords
      if opts['watch']
        tracker.watchPosition (position) ->
          coords = [ position['coords']['latitude'], position['coords']['longitude'] ]
          callback coords
