# library(dygraphs)
# lungDeaths <- cbind(mdeaths, fdeaths)
# dygraph(lungDeaths)
# 
# source('functions.R')
# library(data.table)
# library(TTR)
# library(httr)
# library(rtsdata)
# library(DT)
# df <- get_data_by_ticker_and_date('TSLA', Sys.Date()-360, Sys.Date())
# 
# lungDeaths <- cbind('close'=ts(df$close), 'open'= ts(df$open))
# dygraph(lungDeaths)

library(shiny)
library(dygraphs)

ui <- fluidPage(
  
  titlePanel("Predicted Deaths from Lung Disease (UK)"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("months", label = "Months to Predict", 
                   value = 72, min = 12, max = 144, step = 12),
      selectInput("interval", label = "Prediction Interval",
                  choices = c("0.80", "0.90", "0.95", "0.99"),
                  selected = "0.95"),
      checkboxInput("showgrid", label = "Show Grid", value = TRUE),
      hr(),
      div(strong("From: "), textOutput("from", inline = TRUE)),
      div(strong("To: "), textOutput("to", inline = TRUE)),
      div(strong("Date clicked: "), textOutput("clicked", inline = TRUE)),
      div(strong("Nearest point clicked: "), textOutput("point", inline = TRUE)),
      br(),
      helpText("Click and drag to zoom in (double click to zoom back out).")
    ),
    mainPanel(
      dygraphOutput("dygraph")
    )
  )
)

server <- function(input, output, session) {
  predicted <- reactive({
    hw <- HoltWinters(ldeaths)
    predict(hw, n.ahead = input$months, 
            prediction.interval = TRUE,
            level = as.numeric(input$interval))
  })
  
  output$dygraph <- renderDygraph({
    dygraph(predicted(), main = "Predicted Deaths/Month") %>%
      dySeries(c("lwr", "fit", "upr"), label = "Deaths") %>%
      dyOptions(drawGrid = input$showgrid)
  })
}

shinyApp(ui, server)