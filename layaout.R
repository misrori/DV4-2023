library(shiny)
library(shinydashboard)
library(DT)
library(data.table)
library(rgdal)
library(leaflet)
library(dygraphs)
library(TTR)
library(rtsdata)
library(httr)
# https://fontawesome.com/search?q=network&o=r&m=free
ui <-dashboardPage(
  dashboardHeader(title = 'Warm up'),
  dashboardSidebar(
    sidebarMenu(
      menuItem("DT", tabName = "dt", icon = icon("dashboard")),
      menuItem("MAP", tabName = "map", icon = icon("map")),
      menuItem("Network", tabName = "network", icon = icon("circle-nodes")),
      menuItem("Dygraph", tabName = "dygraph", icon = icon("circle-nodes"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dt", 
              dataTableOutput('dtout'),
              textOutput('rows_out'),
              plotlyOutput('mtcars_plotly_out')
      ),
      tabItem(tabName = "map", 
              leafletOutput('austriamap'),
              textOutput('yourmouseon'),
              textOutput('yourlastclick'), 
              textOutput('mapzoomlevel')
      ),
      tabItem(tabName = "network", h1('Network')),
      tabItem(tabName = "dygraph", 
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
                  dygraphOutput("dygraph"),
                  dygraphOutput('tsla_out')
                )
              )
              
      )
    )
  )
)


server <- function(input, output, session) {
  source('functions.R')
  
  output$dtout <- DT::renderDataTable(mtcars)
  output$rows_out <- renderPrint(input$dtout_rows_selected)
  
  df <- reactive(data.table(mtcars[input$dtout_rows_selected,]))
  
  output$mtcars_plotly_out <- renderPlotly({
    fig <- plot_ly(df(), x = ~df()$wt, y = ~df()$hp, z = ~df()$qsec, color = ~df()$am, colors = c('#BF382A', '#0C4B8E'))
    fig <- fig %>% add_markers()
    fig <- fig %>% layout(scene = list(xaxis = list(title = 'Weight'),
                                       yaxis = list(title = 'Gross horsepower'),
                                       zaxis = list(title = '1/4 mile time')))
    
    fig
  })
  
  
  
  # map ---------------------------------------------------------------------
  
  austria <- rgdal::readOGR("austria-with-regions_.geojson")
  
  output$austriamap <- renderLeaflet({
    leaflet(austria) %>%
      addPolygons(label=~name, layerId = ~name) %>%
      addTiles()
  })
  
  output$yourmouseon <- renderText( paste0('Your mouse on: ', input$austriamap_shape_mouseover$id ))
  output$yourlastclick <- renderText( paste0('Your last click was: ', input$austriamap_shape_click$id))
  output$mapzoomlevel <- renderText(paste0('the zoom level of your map is:', input$austriamap_zoom ))
  
  
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
  
  

  output$tsla_out <- renderDygraph({
    tsla <- get_data_by_ticker_and_date('TSLA', Sys.Date()-360, Sys.Date())
    to_plot <- cbind("high"= xts(tsla$high, order.by = tsla$date), 
                     "low"=xts(tsla$low, order.by = tsla$date))
    dygraph(to_plot)
  })
  
}

shinyApp(ui, server)