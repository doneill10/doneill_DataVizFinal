library(shiny)
library(dplyr)

### Loaded Data
### ==========================

allData <- read.csv('C:/Users/donei/Desktop/Data_Viz/doneill_DataVizFinal/Data/video game sales all platforms.csv', na.strings = "")
seriesData <- read.csv('C:/Users/donei/Desktop/Data_Viz/doneill_DataVizFinal/Data/video game sales series.csv', na.strings = "")

### Variables/Functions

icky <- c("Last.Update", "NA.Sales", "PAL.Sales", "Japan.Sales", "Other.Sales", "VGChartz.Score", "Rank")

### Cleaning Data
### ==========================

# Removing unnecessary columns
allData <- allData %>% select(-any_of(icky))
seriesData <- seriesData %>% select(-any_of(icky))

# Lowercasing Chr columns
allData <- allData %>% mutate(across(where(is.character), tolower))
seriesData <- seriesData %>% mutate(across(where(is.character), tolower))






fluidPage(
  
  tags$head(
    tags$style(HTML("
      html, body {
        margin: 0;
        padding: 0;
      }

      .header-img {
        width: 150%;
        max-height: 150px;  /* adjust as needed */
        object-fit: fill;
        display: block;
        margin: -20px;
        padding: 0px;
      }

      .main-content {
        padding: 20px;
      }
    "))
  ),
  
  # Image Header
  tags$img(
    class = "header-img",
    src = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/steamworks_docs/english/Header_1.jpg"
  ),
  
  # Main App UI
  tags$div(
    class = "main-content",
    titlePanel("Video Game Sales from 1979 to 2008"),
    sidebarLayout(
      sidebarPanel(
        sliderInput("bins", "Number of bins:", min = 1, max = 50, value = 30)
      ),
      mainPanel()
    )
  )
)








