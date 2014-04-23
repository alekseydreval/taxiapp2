taxiapp2
========

### Stubbing positions changes of a driver:
```javascript
window.connection.trigger("tracker.update_location", {latlng: [61, 30], driver_id: 4})
```
