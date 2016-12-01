React = require "react"
Radium = require "radium"
reactRouter = require "react-router"
colors = require "./colors.cjsx"

Link = Radium(reactRouter.Link)

CoverPage = React.createClass
  render: () ->
    style =
      heading:
        textAlign: "center"

    <div>
      <h1 style={style.heading}> discrimen </h1>
    </div>


module.exports = Radium(CoverPage)
