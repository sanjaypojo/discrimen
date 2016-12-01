tinyColor = require "tinycolor2"

lighten = (colorString, percent) ->
  tinyColor(colorString).lighten(percent).toString()

darken = (colorString, percent) ->
  tinyColor(colorString).darken(percent).toString()

brighten = (colorString, percent) ->
  tinyColor(colorString).brighten(percent).toString()

palette =
  black: "#383E40"
  white: "#f1f1f1"
  purple: "#4a4090"

module.exports =
  navBg: darken palette.purple, 8
  navFg: palette.white
  mainFg: palette.black
  mainBg: palette.white
  dropzoneBg: palette.purple
  dropzoneFg: palette.white
  buttonBg: palette.purple
  buttonFg: palette.white
  tableHeadings: palette.white
  tableBody: palette.black
  tableHeaderBg: darken palette.purple, 20
  tableBorder: palette.black
  types: palette.purple
  coverHeading: palette.white
  coverButtonFg: palette.white
  coverButtonBg: palette.purple
  coverButtonBgHover: lighten palette.purple, 10
  coverButtonSeparator: darken palette.purple, 8
