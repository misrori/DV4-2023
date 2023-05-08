library(shiny)
library(ne)

#http://christophergandrud.github.io/networkD3/
  
ui <- dashboardPage(
  dashboardHeader(title = 'Network'),
  dashboardSidebar(),
  dashboardBody(

  )
)

server <- function(input, output, session) {
  # Load data
  data(MisLinks)
  data(MisNodes)
  
  # Plot
  output$force_network_out <- renderfo
  forceNetwork(Links = MisLinks, Nodes = MisNodes,
               Source = "source", Target = "target",
               Value = "value", NodeID = "name",
               Group = "group", opacity = 0.8)
}

shinyApp(ui, server)