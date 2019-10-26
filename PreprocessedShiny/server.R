library(shiny)
library(ggplot2)

shinyServer(function(input, output, session) {
  
  cm <- reactive({
    if(input$threshold == 'All' & input$perf.period == 'All')
      res
    else if(input$threshold == 'All' & input$perf.period != 'All')
      res[res$perf.period == input$perf.period,]
    else if(input$threshold != 'All' & input$perf.period == 'All')
      res[res$threshold == input$threshold,]
    else
      res[res$threshold == input$threshold & res$perf.period == input$perf.period,]
  })
  
  output$summaryTable <- renderDataTable(cm(), options = list(pageLength = 25))
  
  output$metricsPlot <- renderPlot({
    p <- ggplot(cm(), aes_string(x = input$x, y = input$y)) + geom_point(alpha = 0.25)
    
    if (input$color != 'None')
      p <- p + aes_string(color = input$color)
    
    if (input$average)
      p <- p + stat_summary(fun.y = "mean", geom = "line") # color = paste("mean", threshold) group = 1 , aes(group = 1)
    
    p <- p  + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    print(p)
  }, height = 800)    
})