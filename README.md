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
