google.load("visualization", "1", {packages:["corechart"]})

docReady = ->
    drawChart = (url, stat, title) ->
      $('#stats').append("<div id='#{stat}' class='stat-chart'>")

      $.getJSON '/stats/'+url, (d) ->
        data = new google.visualization.DataTable()
        data.addColumn('datetime', 'Run At')
        data.addColumn('number', title)

        data.addRows $.map(d, (build) ->
          [[
            new Date(build.runAt)
            build[stat] #/ 1000.00 / 60.0
          ]]
        )

        options =
          colors: ['#A30E0E']
          title: title
          titleTextStyle: {color: '#666'}
          hAxis:
            textStyle: {color: '#666'}
            baselineColor: '#666'
          vAxis:
            textStyle: {color: '#666'}
            baselineColor: '#666'
          animation:
            duration: 2
          backgroundColor: 'none'
          legend:
            position: 'none'

        chart = new google.visualization.LineChart(document.getElementById(stat))
        chart.draw(data, options)

    drawChart('build-time', 'buildTime', 'Build Time')
    drawChart('number-of-tests', 'numberOfTests', 'Number of Tests')

google.setOnLoadCallback(docReady,true)
 
