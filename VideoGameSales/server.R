library(shiny)




function(input, output, session) {
  current_tab <- reactiveVal("tab1")
  
  observeEvent(input$show_tab1, {
    current_tab("tab1")
  })
  
  observeEvent(input$show_tab2, {
    current_tab("tab2")
  })
  
  output$tabContent <- renderUI({
    if (current_tab() == "tab1") {
      tagList(
        sliderInput("bins", "Number of bins:", min = 1, max = 50, value = 30),
        h3("Welcome to Tab 1"),
        p("Content for Tab 1 goes here.")
      )
    } else {
      tagList(
        h3("Welcome to Tab 2"),
        p("Content for Tab 2 goes here.")
      )
    }
  })
}






















