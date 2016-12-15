React = require "react"
Radium = require "radium"
reactRouter = require "react-router"
update = require "react-addons-update"
colors = require "./colors.cjsx"
request = require "superagent"
Chart = require "react-chartjs-2"

Link = Radium(reactRouter.Link)

Chart.defaults.global.defaultFontColor = colors.chartFg

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
            chosenKey: ""
            chosenAlgorithm: {}

  changeAlgorithm: (e) ->
    e.preventDefault()
    chosenAlgorithm = @state.algorithms.list?.filter (item) ->
      item.id is e.target.value

    @setState
      algorithms: update(@state.algorithms,
        chosenKey: {$set: e.target.value}
        chosenAlgorithm: {$set: chosenAlgorithm[0]}
      )
      analysis:
        status: "LOADING"
        data: []

  fetchAnalysis: () ->
    @setState
      analysis: update(@state.algorithms, status: {$set: "LOADING"})

    request.get "/api/algorithms/#{@state.algorithms.chosenAlgorithm.id}"
      .set "Cache-Control", "max-age=0,no-cache,no-store,post-check=0,pre-check=0"
      .end (err, response) =>
        if err
          console.log err
        else
          console.log response.body
          charts = []
          for chart in response.body
            charts.push JSON.parse(chart)

          @setState
            analysis:
              status: "READY"
              data: charts

          @setState showSchema: false

  componentDidMount: () ->
    @fetchAlgorithms()

  render: () ->
    style =
      heading:
        textAlign: "center"
      headerContainer:
        margin: "0px auto"
        width: "90%"
        maxWidth: "760px"
      bodyContainer:
        backgroundColor: colors.bodyBg
        width: "100%"
      analysisContainer:
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
        backgroundColor: colors.buttonBg
        width: "250px"
        height: "60px"
        lineHeight: "60px"
        color: colors.buttonFg
        cursor: "pointer"
        overflow: "hidden"
        borderRadius: "5px"
        textAlign: "center"
        boxShadow: "0 0 20px 0 rgba(0, 0, 0, 0.3)"
        fontSize: "18px"
        ":hover":
          backgroundColor: colors.buttonBgHover
      schemaContainer:
        padding: "1rem 0rem"
      schemaBlock:
        width: "700px"
        margin: "0px auto"
        padding: "0px 20px"
        fontSize: "16px"
        lineHeight: "24px"
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
        <div style={style.schemaContainer}>
          <pre style={style.schemaBlock} className="cf">
            {JSON.stringify(@state.algorithms.chosenAlgorithm?.schema, null, 2)}
          </pre>
        </div>

    if @state.analysis.status is "READY"
      barCharts = []
      for comparison, idx in @state.analysis.data
        index = 0
        xAxis = null
        datasets = []
        for seriesKey, series of comparison
          index += 1
          if index is 1
            xAxis =
              name: seriesKey
              data: Object.values(series).map (e) -> Math.round(e)
          else
            datasets.push {
              name: seriesKey
              data: Object.values(series)
            }
        barData =
          labels: xAxis.data
          datasets: for item, i in datasets
            {
              label: item.name
              backgroundColor: colors.barBg[i%5]
              borderColor: colors.barBorders[i%5]
              borderWidth: 1
              data: item.data
            }

        barOptions =
          scales:
            yAxes: [
              scaleLabel:
                display: true
                labelString: @state.algorithms?.chosenAlgorithm?.output
            ]
            xAxes: [
              scaleLabel:
                display: true
                labelString: xAxis.name
            ]

        barCharts.push(
          <div style={{padding: "30px 0px"}} key={idx}>
            <Chart.Bar data={barData} width={300} height={100} options={barOptions} />
          </div>
        )

    <div>
      <h4 style={style.heading}> Bias Detector </h4>
      <div style={style.headerContainer}>
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
        {schemaBlock}
      </div>
      <div style={style.bodyContainer}>
        <div style={style.analysisContainer}>
          {barCharts}
        </div>
      </div>
    </div>


module.exports = Radium(CoverPage)
