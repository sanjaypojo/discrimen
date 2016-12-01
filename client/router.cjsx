React = require "react"
ReactDOM = require "react-dom"
reactRouter = require "react-router"

CoverPage = require "./CoverPage.cjsx"
AppContainer = require "./AppContainer.cjsx"

Router = reactRouter.Router
Route = reactRouter.Route
browserHistory = reactRouter.browserHistory
IndexRoute = reactRouter.IndexRoute


AppRouter = React.createClass
  render: () ->
    <Router history={browserHistory}>
      <Route path="/" component={AppContainer}>
        <IndexRoute component={CoverPage}/>
      </Route>
    </Router>


ReactDOM.render <AppRouter />, document.getElementById "react-app"
