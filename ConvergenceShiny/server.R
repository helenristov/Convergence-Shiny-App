library(shiny)
library(ggplot2)
library(xts)
library(knitr)

source("../ConvergenceMetricsCpp.R")

app.env <- new.env()

convergenceSummary <- function(x) {
  data.frame(
    Obs           = format(nrow(x), big.mark = ","),
    Mean          = mean(x$WMP),
    Std.Dev       = sd(x$WMP),
    Min           = min(x$WMP),
    Max           = max(x$WMP),
    Disjoint.Obs  = format(sum(!is.na(x$disjoint)), big.mark = ","),
    Disjoint.Pct  = sprintf("%.3f%%", 100 * length(na.omit(x$disjoint)) / nrow(x)),
    Exp.Shortfall = mean(abs(na.omit(x$disjoint))),
    Converge.Pct  = sprintf("%.3f%%", 100 * sum(na.omit(x$cm1)) / length(na.omit(x$disjoint)))
  )
}

shinyServer(function(input, output, session) {

  files.path <- reactive({
    validate(
      need(!is.null(input$instrument), "")
    )
    
    paste0("/data/shared/", input$instrument, "/DF/")
  })
  
  observe({
    for(ds in input$dataset) {
      if(!exists(ds, envir = app.env)) {
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = "Loading data...")
        
        load(paste0(files.path(), ds, ".RData"), app.env)
      }
    }
  })
  
  cm <- reactive({
    input$updateButton
    input$dataset

    isolate({
      validate(
        need(!is.null(input$dataset), "Please select at least 1 series"),
        need(input$epsilon < input$threshold, "Epsilon must be less than the threshold")
      )
      
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Calculating convergence metrics...")
      
      res <- data.frame()
      
      for(ds in input$dataset) {
        temp <- ConvergenceMetricsCpp(subset(get(ds, envir = app.env), select = "WMP"),
                                      limit      = input$limit,
                                      epsilon    = input$epsilon,
                                      threshold  = input$threshold,
                                      perfPeriod = input$perf.period * 1141,
                                      step       = 1)
        
        temp$WMP    <- subset(get(ds, envir = app.env), select = "WMP")
        temp$Series <- ds
        res         <- rbind(res, temp)
      }
      
      res
    })
  })
  
  plot.height <- function() {
    length(input$dataset) * 300
  }
  
  output$uiFolders <- renderUI({
    folders <- list.dirs("/data/shared/", full.names = FALSE, recursive = FALSE)
    
    selectInput("instrument", label = "Instrument", choices = folders, folders[1])
  })
  
  output$uiSeries <- renderUI({
    files <- gsub(".RData", "", list.files(files.path(), pattern = "*.RData"))
    load(paste0(files.path(), files[1], ".RData"))
    checkboxGroupInput("dataset", 
                       label    = "Double-Fly Series", 
                       choices  = files,
                       selected = files[1])
  })
  
  output$seriesPlot <- renderPlot({
    plot.data <- cm()[seq(nrow(cm())) %% 120 == 1,]

    ggplot(data = plot.data, aes(x = DateTime)) +
      geom_line(aes(y = WMP)) +
      geom_hline(yintercept = input$limit, col = "red") +
      geom_hline(yintercept = input$limit + input$threshold, col = "blue") +
      geom_hline(yintercept = input$limit - input$threshold, col = "blue") + 
      facet_wrap(~ Series, ncol = 1, scales = "free")
  }, height = plot.height)
  
  output$summaryTable <- function(){
    if (is.null(input$dataset)) return()
    
    df.summary <- data.frame()
    
    for (ds in input$dataset) {
      temp       <- data.frame(Series = ds, convergenceSummary(cm()[cm()$Series == ds,]))
      df.summary <- rbind(df.summary, temp)
    }
    
    if (length(input$dataset) > 1) df.summary <- rbind(df.summary, data.frame(Series = "TOTAL", convergenceSummary(cm())))
    
    knitr::kable(
      df.summary,
      format     = "html", 
      output     = FALSE,
      digits     = c(0, 0, 4, 4, 4, 4, 0, 4, 4),
      table.attr = "class='data table table-bordered table-condensed'"
    )
  }
  
  output$scatterPlot <- renderPlot({
    ggplot(data = na.omit(cm()), aes(x = disjoint, y = cm2)) + 
      geom_point(aes(color = factor(Series)), alpha = 0.5) +
      xlab("Disjoint Value") +
      ylab("Reversion") +
      labs(color = "Series")
  })
  
  output$disjointHistPlot <- renderPlot({
    ggplot(data = na.omit(cm()), aes(x = disjoint, fill = factor(Series))) + 
      geom_histogram() + 
      xlab("Disjoint Value") + 
      labs(fill = "Series")
  })
  
  output$reversionHistPlot <- renderPlot({
    ggplot(data = na.omit(cm()), aes(x = cm3, fill = factor(Series))) + 
      geom_histogram() + 
      xlab("Absolute Value of Reversion") + 
      labs(fill = "Series")
  })
  
  outputOptions(output, "scatterPlot",       suspendWhenHidden = FALSE)
  outputOptions(output, "disjointHistPlot",  suspendWhenHidden = FALSE)
  outputOptions(output, "reversionHistPlot", suspendWhenHidden = FALSE)
  outputOptions(output, "seriesPlot",        suspendWhenHidden = FALSE)
  outputOptions(output, "summaryTable",      suspendWhenHidden = FALSE)
})