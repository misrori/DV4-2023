library(shiny)

# keycode values
#  https://docstore.mik.ua/orelly/webprog/DHTML_javascript/0596004672_jvdhtmlckbk-app-b.html
prev_js <- '
$(document).on("keyup", function(e) {
  if(e.keyCode == 37){
    Shiny.onInputChange("prev_key", Math.random());
  }
});
'
next_js <- '
$(document).on("keyup", function(e) {
  if(e.keyCode == 39){
    Shiny.onInputChange("next_key", Math.random());
  }
});
'


ui <- fluidPage(
  tags$script(prev_js),
  tags$script(next_js),
  textOutput('counter_out')

)

server <- function(input, output, session) {
  rv <- reactiveValues('counter' = 0)
  
  observeEvent(input$prev_key,{
    rv$counter <- rv$counter - 1
  })
  
  
  observeEvent(input$next_key,{
    rv$counter <- rv$counter + 1
  })
  output$counter_out <- renderText({rv$counter})
}

shinyApp(ui, server)