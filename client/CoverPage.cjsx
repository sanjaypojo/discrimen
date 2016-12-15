React = require "react"
Radium = require "radium"
reactRouter = require "react-router"
update = require "react-addons-update"
colors = require "./colors.cjsx"
request = require "superagent"
Chart = require "react-chartjs-2"

Link = Radium(reactRouter.Link)

CoverPage = React.createClass
  displayName: "CoverPage"

  getInitialState: () ->
    algorithms:
      status: "LOADING"
      list: []
      chosenKey: ""
      chosenAlgorithm: {}
    showSchema: true
    analysis:
      status: "LOADING"
      data: []

  fetchAlgorithms: () ->
    @setState
      algorithms: update(@state.algorithms, status: {$set: "LOADING"})

    request.get "/api/algorithms"
      .set "Cache-Control", "max-age=0,no-cache,no-store,post-check=0,pre-check=0"
      .end (err, response) =>
        @setState
          algorithms:
            status: "READY"
            list: response.body

  changeAlgorithm: (e) ->
    e.preventDefault()
    chosenAlgorithm = @state.algorithms.list?.filter (item) ->
      item.id is e.target.value

    @setState
      algorithms: update(@state.algorithms,
        chosenKey: {$set: e.target.value}
        chosenAlgorithm: {$set: chosenAlgorithm[0]}
      )

  fetchAnalysis: () ->
    @setState
      analysis: update(@state.algorithms, status: {$set: "LOADING"})

    request.get "/api/algorithms/1"
      .set "Cache-Control", "max-age=0,no-cache,no-store,post-check=0,pre-check=0"
      .end (err, response) =>
        console.log JSON.parse(response.body)
        # @setState
        #   analysis:
        #     status: "READY"
        #     data: response.body
        #
        # @setState showSchema: false

  componentDidMount: () ->
    @fetchAlgorithms()

  render: () ->
    style =
      heading:
        textAlign: "center"
      bodyContainer:
        margin: "0px auto"
        width: "90%"
        maxWidth: "760px"
      headerBar:
        padding: "1rem 0rem"
        textAlign: "center"
      select:
        margin: "0px 10px"
        display: "inline-block"
        width: "250px"
        height: "60px"
        lineHeight: "60px"
        fontSize: "18px"
      button:
        margin: "0px 10px"
        display: "inline-block"
        backgroundColor: "#c0392b"
        width: "250px"
        height: "60px"
        lineHeight: "60px"
        color: "#fff"
        cursor: "pointer"
        overflow: "hidden"
        borderRadius: "5px"
        textAlign: "center"
        boxShadow: "0 0 20px 0 rgba(0, 0, 0, 0.3)"
        fontSize: "18px"
        ":hover":
          backgroundColor: "#a53125"
      schemaContainer:
        padding: "1rem 0rem"
      schemaBlock:
        width: "400px"
        margin: "0px auto"
        padding: "0px 20px"
        fontSize: "10px"
        lineHeight: "12px"
        fontFamily: "Courier, monospace"
        whiteSpace: "pre-wrap"
        display: "block"
        clear: "both"
        color: "#119911"
        background: "#333"
        border: "solid 1px #e1e1e1"
        borderRadius: "5px"

    if @state.algorithms.status is "LOADING"
      placeHolder = <option key="loading" value="">Loading...</option>
    else
      placeHolder = <option key="choose" value="">Choose Algorithm</option>

    if @state.algorithms.list?.length > 0
      optionList = @state.algorithms.list.map (item) ->
        <option key={item.id} value={item.id}>{item.name}</option>

    if @state.algorithms.chosenKey isnt "" && @state.showSchema
      schemaBlock =
        <pre style={style.schemaBlock} className="cf">
          {JSON.stringify(@state.algorithms.chosenAlgorithm?.schema, null, 2)}
        </pre>

    if @state.analysis.status is "READY"
      options =
        scales:
          yAxes: [
            ticks:
              max: 600
              min: 0
              stepSize: 100
          ]
      barChart = <Chart.Bar
        data={@state.analysis.data} width={300} height={100}
        options={options}/>

    <div>
      <h4 style={style.heading}> discrimen </h4>
      <div style={style.bodyContainer}>
        <div style={style.headerBar}>
          <select style={style.select} className="element"
            value={@state.chosenKey} onChange={@changeAlgorithm}>
            {placeHolder}
            {optionList}
          </select>
          <button style={style.button} className="element"
            onClick={@fetchAnalysis}>
            analyze
          </button>
        </div>
        <div style={style.schemaContainer}>
          {schemaBlock}
        </div>
        <div style={style.analysisContainer}>
          {barChart}
        </div>
      </div>
    </div>


module.exports = Radium(CoverPage)
