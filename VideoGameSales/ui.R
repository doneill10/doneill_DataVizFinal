library(shiny)
library(dplyr)
library(shinyjs)

fluidPage(

#Activates shiny JS
  useShinyjs(),

#Tag head
  tags$head(
    tags$style(HTML("
    
      html, body {
        margin: 0;
        padding: 0;
      }

      .header-img {
        width: 150%;
        max-height: 150px;
        object-fit: fill;
        display: block;
        margin: -20px;
        padding: 0px;
      }

      .main-content {
        padding: 20px;
        margin-left: 120px; /* make room for side tabs */
      }

      /* Side Tab Container */
      .side-tabs {
        position: fixed;
        top: 200px;
        left: 0;
        display: flex;
        flex-direction: column;
        z-index: 1000;
      }

      .tab-button {
      background-color: white;
      color: #444;
      padding: 10px 15px;
      margin: 2px 0;
      cursor: pointer;
      border: none;
      font-weight: bold;
      text-align: left;
      width: 100px;
    }

      .tab-button:hover {
        background-color: #666;
      }

    "))
  ),

#Tag Img
  tags$img(
    class = "header-img",
    src = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/steamworks_docs/english/Header_1.jpg"
  ),
  
  # Side Tab Buttons
  tags$div(
    class = "side-tabs",
    actionButton("show_tab1", "Tab 1", class = "tab-button"),
    actionButton("show_tab2", "Tab 2", class = "tab-button")
  ),
  
  # Main UI Content
  tags$div(
    class = "main-content",
    uiOutput("tabContent")
  )
)



