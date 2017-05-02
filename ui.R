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


shinyUI(dashboardPage(
  
  dashboardHeader(title = "Sachin Tendulkar"),
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Performance Against Teams", tabName = "performance_vs_teams", icon = icon("pie-chart")),
      menuItem("Favourite Grounds", tabName = "runs_on_ground", icon=icon("map-marker")),
      menuItem("Runs Scored In Innings", tabName = "runs_scored_in_innings", icon = icon("pie-chart")),
      menuItem("Runs Scored over the Years", tabName = "runs_scored_over_years", icon = icon("area-chart")),
      menuItem("Batting Average over the Years", tabName = "batting_avg_over_years", icon = icon("line-chart")),
      menuItem("Runs Scored at Position", tabName = "runs_scored_at_position", icon = icon("bar-chart-o"))
    )
  ),
  
  dashboardBody(
    
    tabItems(
      
      # First tab content
      tabItem(tabName = "performance_vs_teams",
              
              fluidRow(
                tabBox(
                  title = "",
                  # The id lets us use input$tabset1 on the server to find the current tab
                  id = "tabset1", height = "300px",
                  tabPanel("Overall", "Radial Network Graph", radialNetworkOutput("radial_performance_teams", height = 600)),
                  tabPanel("ODI", "", plotlyOutput("performance_teams_ODI", height = 600)),
                  tabPanel("Test", "", plotlyOutput("performance_teams_Test", height = 600))
                ),
                
                box(
                  dataTableOutput('table_vs_teams_runs')
                )
              )
      ),
      
      
      # Second tab content
      tabItem(tabName = "runs_on_ground",
              
              fluidPage(
                
                fluidRow(
                  
                  tabBox(
                    title = "", id = "tabset2", height = "250px",
                    tabPanel("ODI", "Leaflet Map", leafletOutput("grounds_ODI")),
                    tabPanel("Test", "Leaflet Map", leafletOutput("grounds_Test"))
                  ),
                  
                  
                  fluidRow(
                    fluidRow(
                      box(
                        dataTableOutput('runs_in_grounds_ODI')
                      )
                    ),
                    column(12, offset=6,
                           fluidRow(
                             box(
                               dataTableOutput('runs_in_grounds_Test')
                             )
                           )
                    )
                  )
                )
              )
      ),
      
      
      # Third Tab
      tabItem(tabName = "runs_scored_in_innings",
              
              fluidPage(
                
                fluidRow(
                  
                  tabBox(
                    title = "", id = "tabset2", height = "250px",
                    #tabPanel("Overall", "", grVizOutput("runs_scored_tree", height = 600)),
                    tabPanel("Overall", "Collapsible Tree", collapsibleTreeOutput("runs_scored_tree", height = 600)),
                    tabPanel("ODI", "", plotlyOutput("runs_scored_in_innings_ODI", height = 600)),
                    tabPanel("Test", "", plotlyOutput("runs_scored_in_innings_Test", height = 600))
                  ),
                  
                  
                  fluidRow(
                    fluidRow(
                      box(
                        dataTableOutput('runs_in_innings_ODI')
                      )
                    ),
                    column(12, offset=6,
                           fluidRow(
                             box(
                               dataTableOutput('runs_in_innings_Test')
                             )
                           )
                    )
                  )
                )
              )
      ),
      
      
      # Fourth Tab
      tabItem(tabName = "runs_scored_over_years",
              fluidRow(
                tabBox(
                  title = "", id = "tabset3", height = "250px",
                  tabPanel("ODI", "", plotlyOutput("runs_over_years_ODI", height = 600)),
                  tabPanel("Test", "", plotlyOutput("runs_over_years_Test", height = 600))
                ),
                
                box(
                  dataTableOutput('table_runs_over_years')
                )
              )
      ),
      
      # Fifth Tab
      tabItem(tabName = "batting_avg_over_years",
              fluidRow(
                tabBox(
                  title = "", id = "tabset3", height = "250px",
                  tabPanel("ODI", "", plotlyOutput("avg_over_years_ODI", height = 600)),
                  tabPanel("Test", "", plotlyOutput("avg_over_years_Test", height = 600))
                ),
                
                box(
                  dataTableOutput('table_avg_over_years')
                )
              )
      ),
      
      
      # Sixth Tab
      tabItem(tabName = "runs_scored_at_position",
        fluidRow(
          box(
            plotlyOutput("runs_scored_position", height = 600)
            
          ),
          
          box(
            dataTableOutput('table_runs_at_position')
          )
        )
      )
    )
  )
))