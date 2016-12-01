React = require "react"
Radium = require "radium"
colors = require "./colors.cjsx"

AppContainer = React.createClass
  render: () ->
    <div style={{backgroundColor: colors.mainBg, minHeight: "100vh"}} className="cf">
      <Radium.StyleRoot>
        {this.props.children}
      </Radium.StyleRoot>
    </div>

module.exports = Radium(AppContainer)
