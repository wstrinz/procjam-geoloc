module Loctest where

import Html exposing (text, div, br)
--import Graphics.Element exposing (Element, show)
import Task exposing (Task, andThen)
import Native.GeoLocation
import Debug
import Signal exposing ((<~), (~))
import Time exposing (every, second)
import ProcGen exposing (Place, getAPlace)

type alias GeoLoc a =
  { a |
      latitude: Float,
      longitude: Float
  }
type alias GeoLocWithPlace = GeoLoc {timestamp: Int, place: Place}
type alias GeoReading = GeoLoc {timestamp: Int}

type alias GeolocTuple = (Float, Float)

type alias CurrentReading = {lat: Float, lng: Float, ntimes: Int}

geolocModel : GeoLocWithPlace
geolocModel = { latitude = 0.0, longitude = 0.0, timestamp = 0, place = getAPlace}

main : Signal Html.Html
main = view <~ geolocMailbox.signal ~ timeMailbox.signal ~ currentLoc

view : GeoLocWithPlace -> Float -> CurrentReading -> Html.Html
view geoMod t loc = div [] [
                         locToHtml geoMod,
                         timeHtml t,
                         currentLocHtml loc
                       ]

currentLocHtml : CurrentReading -> Html.Html
currentLocHtml loc = div [] [
                              Html.h4 [] [text "Current Loc:"],
                              div [] [text (toString loc)]
                            ]

locToHtml : GeoLocWithPlace -> Html.Html
locToHtml mobel = div [] [
                           Html.h4 [] [text "Location: "],
                           div [] [text ("latitude: " ++ (toString (Debug.watch "lat" mobel.latitude)))],
                           br [] [],
                           div [] [text ("longitude: " ++ (toString mobel.longitude))],
                           br [] [],
                           div [] [text ("timeStamp: " ++ (toString mobel.timestamp))],
                           br [] [],
                           div [] [text ("Place: " ++ mobel.place.name)],
                           br [] [],
                           div [] [text ("With: " ++ mobel.place.people.name)]
                         ]

timeHtml : Time.Time -> Html.Html
timeHtml t = div [] [
                       Html.h4 [] [text "Time: "],
                       text (toString (Debug.watch "time" (Time.inSeconds t)))
                     ]

timeMailbox : Signal.Mailbox Time.Time
timeMailbox = Signal.mailbox Time.second

getLocation : Task x GeoReading
getLocation = Native.GeoLocation.getLocation

clock : Signal Time.Time
clock = every second

sendNewTime : Signal (Task x ())
sendNewTime = Signal.map sendToTimeBox clock

sendToTimeBox : Time.Time -> Task x ()
sendToTimeBox t = Signal.send timeMailbox.address t

geolocMailbox : Signal.Mailbox GeoLocWithPlace
geolocMailbox = Signal.mailbox geolocModel

port fetchGeoLoc : Task x ()
port fetchGeoLoc = getLocation `andThen` updateGeoloc

port currentLoc : Signal CurrentReading

port ticker : Signal (Task x ())
port ticker = sendNewTime

placeForLoc : GeoReading -> GeoLocWithPlace
placeForLoc loc = {loc | place = getAPlace}

updateGeoloc : GeoReading -> Task x ()
updateGeoloc reading = Signal.send geolocMailbox.address (placeForLoc reading)
