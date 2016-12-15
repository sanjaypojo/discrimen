tinyColor = require "tinycolor2"

lighten = (colorString, percent=5) ->
  tinyColor(colorString).lighten(percent).toString()

darken = (colorString, percent=5) ->
  tinyColor(colorString).darken(percent).toString()

brighten = (colorString, percent=5) ->
  tinyColor(colorString).brighten(percent).toString()

palette =
  black: "#383E40"
  white: "#f1f1f1"
  red: "#c0392b"

module.exports =
  mainBg: palette.white
  bodyBg: palette.black
  chartFg: darken(palette.white, 20)
  buttonFg: palette.white
  buttonBg: palette.red
  buttonBgHover: darken palette.red
  barBg: [
    "rgba(31, 138, 112, 0.7)"
    "rgba(190, 219, 57, 0.7)"
    "rgba(0, 67, 88, 0.7)"
    "rgba(255, 225, 26, 0.7)"
    "rgba(253, 116, 0, 0.7)"
  ]
  barBorders: [
    "rgba(31, 138, 112, 1)"
    "rgba(190, 219, 57, 1)"
    "rgba(0, 67, 88, 1)"
    "rgba(255, 225, 26, 1)"
    "rgba(253, 116, 0, 1)"
  ]
