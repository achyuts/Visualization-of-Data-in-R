library(shiny)
library(shinydashboard)
library(plotly)
library(knitr)
library(RCurl)
library(DT)
library(leaflet)
library(networkD3)
library(data.tree)
library(DiagrammeR)
library(collapsibleTree)

shinyServer(function(input, output) {
  
  # Tab-1
  opposition_runs = read.csv("opposition_vs_runs.csv")
  
  opposition_runs_radial <- read.csv("opposition_vs_runs_network.csv", stringsAsFactors = FALSE)
  opposition_runs_radial$pathString <- paste("Sachin", opposition_runs_radial$Opposition, opposition_runs_radial$Runs, sep=",")
  opposition_runs_radial_tree <- as.Node(opposition_runs_radial, pathDelimiter = ",")
  opposition_runs_radial_List <- ToListExplicit(opposition_runs_radial_tree, unname = TRUE)
  
  
  output$radial_performance_teams <- renderRadialNetwork({
    radialNetwork(opposition_runs_radial_List)
  })
  
  output$performance_teams_ODI <- renderPlotly({
    
    plot_ly(opposition_runs, labels = ~Opposition, values = ~Runs_in_ODI) %>%
      add_pie(hole = 0.6) %>%
      layout(title = "Runs Scored Against Countries",  
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
  output$performance_teams_Test <- renderPlotly({
    plot_ly(opposition_runs, labels = ~Opposition, values = ~Runs_in_Test, type = 'pie') %>%
      layout(title = 'Runs Scored Against Countries',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  col_names = c('Opposition','Runs in ODI', 'Runs in Test')
  output$table_vs_teams_runs <- DT::renderDataTable({datatable(opposition_runs, colnames = col_names)}) 
  
  
  #Tab-2
  ODI_cities <- read.csv("ODI_Grounds.csv")
  
  output$grounds_ODI <- renderLeaflet({
    leaflet(ODI_cities) %>% addTiles() %>%
      addCircles(lng = ~Long, lat = ~Lat, weight = 1,
                 radius = ~Runs * 300, popup = ~City
      )
  })
  
  Test_cities <- read.csv("Test_Grounds.csv")
  
  output$grounds_Test <- renderLeaflet({
    leaflet(Test_cities) %>% addTiles() %>%
      addCircles(lng = ~Long, lat = ~Lat, weight = 1,
                 radius = ~Runs * 220, popup = ~City
      )
  })
  
  ODI_cities_1 = ODI_cities[,c("City","Runs")]
  Test_cities_1 = Test_cities[,c("City","Runs")]
  
  output$runs_in_grounds_ODI <- DT::renderDataTable({datatable(ODI_cities_1, colnames = c('ODI City', 'Runs'))})
  output$runs_in_grounds_Test <- DT::renderDataTable({datatable(Test_cities_1, colnames = c('Test City', 'Runs'))})
  
  
  #Tab-3
  innings_runs_ODI = read.csv("inns_runs_ODI.csv")
  innings_runs_Test = read.csv("inns_runs_Test.csv")
  
  
  # runs_T <- Node$new("Runs Scored")
  #   ODI_T <- runs_T$AddChild("ODI")
  #     ODI_1_T <- ODI_T$AddChild("1st Innings")
  #       ODI_1_T_Runs <- ODI_1_T$AddChild("9706\n52.7%")
  #     ODI_2_T <- ODI_T$AddChild("2nd Innings")
  #       ODI_2_T_Runs <- ODI_2_T$AddChild("8720\n47.3%")
  #   Test_T <- runs_T$AddChild("Test")
  #     Test_1_T <- Test_T$AddChild("1st Innings")
  #       Test_1_T_Runs <- Test_1_T$AddChild("5682\n35.7%")
  #     Test_2_T <- Test_T$AddChild("2nd Innings")
  #       Test_2_T_Runs <- Test_2_T$AddChild("5618\n35.3%")
  #     Test_3_T <- Test_T$AddChild("3rd Innings")
  #       Test_3_T_Runs <- Test_3_T$AddChild("2992\n18.8%")
  #     Test_4_T <- Test_T$AddChild("4th Innings")
  #       Test_4_T_Runs <- Test_4_T$AddChild("1625\n10.2%")
  # 
  # #plot(runs_T)
  # output$runs_scored_tree <- renderGrViz({
  #   SetGraphStyle(runs_T, rankdir = "TB")
  #   SetEdgeStyle(runs_T, arrowhead = "vee", color = "grey35", penwidth = 2)
  #   SetNodeStyle(runs_T, style = "filled,rounded", shape = "box", fillcolor = "GreenYellow",
  #                fontname = "helvetica", tooltip = GetDefaultTooltip)
  #   Do(runs_T$leaves, function(node) SetNodeStyle(node, shape = "egg"))
  #   grViz(DiagrammeR::generate_dot(ToDiagrammeRGraph(runs_T)))})
  
  typeOfMatch = c("ODI", "Test", "Test")
  Innings_no = c("1","1","2","2","3","4")
  runs_scr = c("9706","5682","5618","8720","2992","1625")
  Runs = data.frame(typeOfMatch,Innings_no, runs_scr)
  
  output$runs_scored_tree <- renderCollapsibleTree({
    collapsibleTree(
      Runs,
      hierarchy = c("typeOfMatch", "Innings_no","runs_scr"),
      width = 800,
      fill = c(
        # The root
        "yellow",
        rep("firebrick", length(unique(Runs$typeOfMatch))),
        rep("steelblue", length(unique(paste(Runs$typeOfMatch, Runs$Innings_no)))),
        rep("green", length(unique(Runs$runs_scr)))
      )
    )
  })

  
  output$runs_scored_in_innings_ODI <- renderPlotly({
    plot_ly(innings_runs_ODI, labels = ~ODI_Inns, values = ~Runs, type = 'pie') %>%
      layout(title = 'Runs Scored In Innings',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
  output$runs_scored_in_innings_Test <- renderPlotly({
    
    plot_ly(innings_runs_Test, labels = ~Test_Inns, values = ~Runs, type = 'pie') %>%
      layout(title = 'Runs Scored In Innings',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
  output$runs_in_innings_ODI <- DT::renderDataTable({datatable(innings_runs_ODI, colnames = c('ODI Inns', 'Runs'))})
  output$runs_in_innings_Test <- DT::renderDataTable({datatable(innings_runs_Test, colnames = c('Test Inns', 'Runs'))})
  
  
  
  #Tab-4
  runs_over_years = read.csv("Runs_by_Year.csv")
  
  output$runs_over_years_ODI <- renderPlotly({
    
    plot_ly(runs_over_years, x = ~Year, y = ~ODI_Runs, type = 'scatter', mode = 'markers',
            marker = list(size = ~ODI_Runs/22, opacity = 0.7)) %>%
      layout(title = 'Runs Scored Over the Years',
             xaxis = list(showgrid = FALSE),
             yaxis = list(showgrid = FALSE))
  })
  
  output$runs_over_years_Test <- renderPlotly({
    
    plot_ly(runs_over_years, x = ~Year, y = ~Test_Runs, type = 'scatter', mode = 'markers',
            marker = list(size= ~Test_Runs/22, opacity = 0.7)) %>%
      layout(title = 'Runs Scored Over the Years',
             xaxis = list(showgrid = FALSE),
             yaxis = list(showgrid = FALSE))
  })
  
  output$table_runs_over_years <- DT::renderDataTable({datatable(runs_over_years, colnames = c('Year','ODI Runs', 'Test Runs'))})
  
  
  
  #Tab-5
  avg_runs_over_years = read.csv("Avg_by_Year.csv")
  output$avg_over_years_ODI <- renderPlotly({
    
    plot_ly(avg_runs_over_years, x = ~Year, y = ~ODI_Avg, type = 'scatter', mode = 'lines')
    
  })
  output$avg_over_years_Test <- renderPlotly({
    
    plot_ly(avg_runs_over_years, x = ~Year, y = ~Test_Avg, type = 'scatter', mode = 'lines')
    
  })
  output$table_avg_over_years <- DT::renderDataTable({datatable(avg_runs_over_years, colnames = c('Year','ODI Avg', 'Test Avg'))})
  
  
  #Tab-6
  position_runs = read.csv("batting_position_runs.csv")
  output$runs_scored_position <- renderPlotly({
    
    plot_ly(position_runs, x = ~Position, y = ~ODI_Runs, type = 'bar', name = 'ODI Runs') %>%
      add_trace(y = ~Test_Runs, name = 'Test Runs') %>%
      layout(yaxis = list(title = 'Count'), barmode = 'group')
    
    
  })
  
  output$table_runs_at_position <- DT::renderDataTable({datatable(position_runs, colnames = c('Position','ODI Runs', 'Test Runs'))})
  
})