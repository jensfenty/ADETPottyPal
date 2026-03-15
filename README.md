# PottyPal

PottyPal is a Flutter restroom finder app. For Milestone 3, the app now uses
the `http` package to request restroom data from a real OpenStreetMap Overpass
API endpoint, parses the JSON response, and converts each result into a
`Restroom` model with `fromJson()`.

## RESTful API Short Explanation

A RESTful API is a web service that lets an app communicate with data through
standard HTTP methods such as `GET`, `POST`, `PUT`, and `DELETE`. In this
project, PottyPal uses an HTTP `GET` request to ask an API for restroom data,
receives the result as JSON, and then maps that JSON into Dart model objects so
the app can display the data correctly.

## Milestone 3 API Flow

- Send a `GET` request using the `http` package
- Receive restroom/location data from the Overpass API
- Decode the JSON response with `jsonDecode`
- Convert each restroom entry into a `Restroom` object through `fromJson()`
- Show loading, success, and error states in the app UI

## Beyond The Minimum

PottyPal now includes basic offline support. When a restroom request succeeds,
the raw JSON response is cached locally using `shared_preferences`. If a later
request fails because the device is offline or the API is unavailable, the app
falls back to the most recently cached restroom list instead of showing an
empty screen immediately.

The project also now includes unit tests for:

- API fetching and JSON parsing
- Offline cache fallback behavior
- `Restroom.fromJson()` model mapping

## Still Needed For Google Maps / Google Places

The current project does not yet integrate the Google Places API or Google Maps
SDK. That part needs:

- a Google Cloud project
- an API key
- the chosen Flutter package and platform setup for Android/iOS

Until those are added, the map tab remains a placeholder screen rather than a
live Google map.
