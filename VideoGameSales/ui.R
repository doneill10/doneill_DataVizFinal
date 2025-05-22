library(shiny)
library(dplyr)
library(shinyjs)

fluidPage(
  useShinyjs(),
  
  tags$head(
    tags$link(
      href = "https://fonts.googleapis.com/css2?family=Baloo+2&display=swap",
      rel = "stylesheet"
    ),
    tags$style(HTML("
      html, body {
        margin: 0;
        padding: 0;
        font-family: 'Baloo 2', cursive;
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
        margin-left: 120px;
        font-family: 'Baloo 2', cursive;
      }

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
        font-family: 'Baloo 2', cursive;
      }

      .tab-button:hover {
        background-color: #666;
        color: white;
      }

      .active-tab {
        background-color: #1abc9c !important;
        color: white !important;
      }
    "))
  ),
  
  tags$img(
    class = "header-img",
    src = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/steamworks_docs/english/Header_1.jpg"
  ),
  
  tags$div(
    class = "side-tabs",
    actionButton("tab1_button", "General", class = "tab-button"),
    actionButton("tab2_button", "→ World Map", class = "tab-button"),
    actionButton("tab3_button", "Developers", class = "tab-button"),
    actionButton("tab4_button", "Genres", class = "tab-button"),
    actionButton("tab5_button", "Scoreboard", class = "tab-button")
  ),
  
  tags$div(
    class = "main-content",
    
    conditionalPanel(
      condition = "output.current_tab == 'tab1'",
      h3("Let's explore your favorite game!"),
      selectizeInput(
        inputId = "favorite_game",
        label = "What is your favorite video game?",
        choices = NULL,
        selected = NULL,
        multiple = FALSE,
        options = list(
          placeholder = 'Start typing a game name...',
          maxOptions = 10
        )
      ),
      tags$hr(),
      div(style = "max-width: 100%; overflow-x: auto;",
          DT::dataTableOutput("game_stats"))
    ),
    
    conditionalPanel(
      condition = "output.current_tab == 'tab2'",
      h3("Sales by region for your selected game"),
      plotOutput("world_map", height = "500px")
    ),
    
    conditionalPanel(
      condition = "output.current_tab == 'tab3'",
      h3("Explore by Developer"),
      selectizeInput(
        inputId = "selected_developer",
        label = "Choose a developer:",
        choices = NULL,
        selected = NULL,
        multiple = FALSE,
        options = list(
          placeholder = 'Start typing a developer...',
          maxOptions = 10
        )
      ),
      actionButton("random_developer", "Pick a Random Developer"),
      tags$hr(),
      uiOutput("developer_games_title"),
      div(style = "max-width: 100%; overflow-x: auto;",
          DT::dataTableOutput("developer_games_table"))
    ),
    
    conditionalPanel(
      condition = "output.current_tab == 'tab4'",
      h3("Game Genres"),
      plotOutput("genre_barplot"),
      tags$hr(),
      plotOutput("genre_sales_boxplot")
    ),
    
    conditionalPanel(
      condition = "output.current_tab == 'tab5'",
      h3("Scoreboard: Top 10 Leaders"),
      
      h4("Top 10 Games by Total Sales"),
      tableOutput("top_games"),
      
      tags$hr(),
      
      h4("Top 10 Publishers by Total Sales"),
      tableOutput("top_publishers")
    )
  )
)











