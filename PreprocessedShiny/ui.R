library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Convergence Metrics"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput('x', 'X', names(res), "perf.period"),
      selectInput('y', 'Y', names(res), "converged.pct"),
      selectInput('color', 'Color', c('None', names(res))),
      selectInput('threshold', 'Threshold', c('All', unique(res$threshold))),
      selectInput('perf.period', 'Performance Period', c('All', unique(res$perf.period))),
      checkboxInput('average', 'Plot Average?')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("metricsPlot")), #, uiOutput("ggvis_ui"), ggvisOutput("ggvis_plot"))
        tabPanel("Table", dataTableOutput("summaryTable"))
      )
    )
  )
))
