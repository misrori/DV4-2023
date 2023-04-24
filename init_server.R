
server <- function(input, output, session) {
  sp500 <-data.table(get_sp500())
  
  setorder(sp500, -market_cap_basic)
  # sum(sp500$market_cap_basic)/1000000000
  # sum(sp500$change>0)/nrow(sp500) 
  
  
  output$my_ticker <- renderUI({
    selectInput('ticker', label = 'Select a ticker', choices = setNames(sp500$name, sp500$description), multiple = FALSE)
  })
  
  
  my_reactive_df <- reactive({
    df<- get_data_by_ticker_and_date(input$ticker, input$my_date[1], input$my_date[2])
    return(df)
  })
  
  
  # go to https://rstudio.github.io/DT/shiny.html
  output$my_data <- DT::renderDataTable({
    my_reactive_df()
  })
  
  

  output$data_plot <- renderPlotly({
    get_plot_of_data(my_reactive_df())
  })
  
}