library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Convergence Metrics"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("limit", "Limit", -0.1, 0.1, 0, 0.005),
      sliderInput("epsilon", "Epsilon", 0, 0.05, 0.01, 0.001),
      sliderInput("threshold", "Threshold", 0, 0.25, 0.05, 0.005),
      sliderInput("perf.period", "Performance Period (Days)", 1, 50, 10, 1),
      actionButton("updateButton", "Update"),
      br(),
      uiOutput("uiFolders"),
      uiOutput("uiSeries")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Convergence",
                 h4("Summary Table"),
                 tableOutput("summaryTable"),
                 h4("Disjoint Values vs. Reversion"),
                 plotOutput("scatterPlot"),
                 h4("Disjoint Value Distribution"),
                 plotOutput("disjointHistPlot"),
                 h4("Absolute Reversion Distribution"),
                 plotOutput("reversionHistPlot")
                 ),
        tabPanel("Series Plots", 
                 plotOutput("seriesPlot"))
      )
    )
  )
))
