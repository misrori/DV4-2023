

# https://cartographyvectors.com/map/1414-austria-with-regions
# austria <- rgdal::readOGR("austria-with-regions_.geojson")
# 
# leaflet(austria) %>%
#   addPolygons(label=~name) %>%
#   addTiles()
# 
# 
# 
# geo_df <- rgdal::readOGR("https://raw.githubusercontent.com/ginseng666/GeoJSON-TopoJSON-Austria/master/2021/siedlungseinheiten/siedlungseinheiten_75_geo.json")
# 
# leaflet(geo_df) %>%
#   addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.6, label=~name) %>%
#   addTiles()


library(leaflet)
library(rgdal)
library(shiny)

ui <- dashboardPage(
  dashboardHeader(title = 'Leaflet'),
  dashboardSidebar(),
  dashboardBody(
   leafletOutput('austriamap'),
   textOutput('yourmouseon'),
   textOutput('yourlastclick'), 
   textOutput('mapzoomlevel')
  )
)

server <- function(input, output, session) {
  
  austria <- rgdal::readOGR("austria-with-regions_.geojson")
  
  output$austriamap <- renderLeaflet({
    leaflet(austria) %>%
      addPolygons(label=~name, layerId = ~name) %>%
      addTiles()
  })
  
  output$yourmouseon <- renderText( paste0('Your mouse on: ', input$austriamap_shape_mouseover$id ))
  output$yourlastclick <- renderText( paste0('Your last click was: ', input$austriamap_shape_click$id))
  output$mapzoomlevel <- renderText(paste0('the zoom level of your map is:', input$austriamap_zoom ))

}

shinyApp(ui, server)


