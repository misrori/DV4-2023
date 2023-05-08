library(shiny)
library(shinydashboard)
library(DT)
library(plotly)

# https://yihui.shinyapps.io/DT-selection/

ui <- dashboardPage(
  dashboardHeader(title = 'DT row selected'),
  dashboardSidebar(),
  dashboardBody(
    dataTableOutput('dtout'),
    textOutput('selected_rows'),
    plotlyOutput('car_plot')
  )
)

server <- function(input, output, session) {
  
  output$dtout = DT::renderDataTable(mtcars)
  output$selected_rows = renderPrint(input$dtout_rows_selected)
  
  df <- reactive(mtcars[input$dtout_rows_selected,])
  
  output$car_plot <- renderPlotly({
    p <- plot_ly(df(), x=df()$wt, y=df()$mpg, z=df()$hp, 
                 type="scatter3d", mode="markers", 
                 color=df()$drat, size=df()$qsec) %>%
      layout(scene=list(
        xaxis = list(title = "Weight (1000 lbs)"),
        yaxis = list(title = "miles per gallon"),
        zaxis = list(title = "Gross horsepower)"))
      )
  })
  
}

shinyApp(ui, server)