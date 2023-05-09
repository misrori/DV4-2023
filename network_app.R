library(shiny)
library(networkD3)
library(shinydashboard)


ui <- dashboardPage(
  dashboardHeader(title = 'Network'),
  dashboardSidebar(),
  dashboardBody(
    textOutput('selected_node_out'),
    forceNetworkOutput('forcenetwork_out'),
    sankeyNetworkOutput('sankey_out')
  )
)

server <- function(input, output, session) {
  data(MisLinks)
  data(MisNodes)
  MisNodes$name <- as.character(MisNodes$name)
  MyClickScript <- 'Shiny.onInputChange("selected_node",d.index)'
  
  my_links <- data.table(read.csv('network_2/linkes.txt'))
  my_nodes <- data.table(read.csv('network_2/nodes.txt'))
  
  
  # Load energy projection data
  URL <- paste0(
    "https://cdn.rawgit.com/christophergandrud/networkD3/",
    "master/JSONdata/energy.json")
  Energy <- jsonlite::fromJSON(URL)
  
  output$forcenetwork_out <- renderForceNetwork({
    forceNetwork(Links = my_links, Nodes = my_nodes,
                 Source = "source", Target = "target", 
                 Value = "value", NodeID = "Name",arrows = T,
                 Group = "group", opacity = 0.8, clickAction = MyClickScript, zoom = T, fontSize =20, opacityNoHover = 0.9)
  })
  # zoom = T,fontSize = 20,opacityNoHover = 0.9
  
  
  output$selected_node_out <- renderText(MisNodes$name[input$selected_node])
  
  
  output$sankey_out <- renderSankeyNetwork({
    sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
                  Target = "target", Value = "value", NodeID = "name",
                  units = "TWh", fontSize = 12, nodeWidth = 30)
  })
  
}

shinyApp(ui, server)