var Elm = Elm || {}

Elm.Native.GeoLocation = {}

Elm.Native.GeoLocation.make = function (localRuntime) {
  localRuntime.Native = localRuntime.Native || {}
  localRuntime.Native.GeoLocation = localRuntime.Native.GeoLocation || {}
  if (localRuntime.Native.GeoLocation.values) {
    return localRuntime.Native.GeoLocation.values
  }

  var Task = Elm.Native.Task.make(localRuntime)

  var getLocation = Task.asyncFunction(function (cb) {
    navigator.geolocation.getCurrentPosition(function (loc) {
      return cb(Task.succeed({ctor: '_GeoReading', longitude: loc.coords.longitude, latitude: loc.coords.latitude, timestamp: loc.timestamp}))
    })
  })

  localRuntime.Native.GeoLocation.values = {
    getLocation: getLocation
  }

  return localRuntime.Native.GeoLocation.values
}
