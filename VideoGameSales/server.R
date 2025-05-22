library(shiny)
library(shinyjs)
library(DT)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(ggplot2)

# Load the dataset
game_titles <- read.csv("video game sales titles.csv", stringsAsFactors = FALSE)
all_games <- sort(unique(game_titles$Title))
all_developers <- sort(unique(na.omit(game_titles$Developer)))

# Server logic
function(input, output, session) {
  current_tab <- reactiveVal("tab1")
  
  session$onFlushed(function() {
    shinyjs::addClass("tab1_button", "active-tab")
    updateSelectizeInput(session, "favorite_game", choices = all_games, server = TRUE)
    updateSelectizeInput(session, "selected_developer", choices = all_developers, server = TRUE)
  }, once = TRUE)
  
  observeEvent(input$tab1_button, {
    current_tab("tab1")
    shinyjs::addClass("tab1_button", "active-tab")
    shinyjs::removeClass("tab2_button", "active-tab")
    shinyjs::removeClass("tab3_button", "active-tab")
    shinyjs::removeClass("tab4_button", "active-tab")
    shinyjs::removeClass("tab5_button", "active-tab")
  })
  observeEvent(input$tab2_button, {
    current_tab("tab2")
    shinyjs::addClass("tab2_button", "active-tab")
    shinyjs::removeClass("tab1_button", "active-tab")
    shinyjs::removeClass("tab3_button", "active-tab")
    shinyjs::removeClass("tab4_button", "active-tab")
    shinyjs::removeClass("tab5_button", "active-tab")
  })
  observeEvent(input$tab3_button, {
    current_tab("tab3")
    shinyjs::addClass("tab3_button", "active-tab")
    shinyjs::removeClass("tab1_button", "active-tab")
    shinyjs::removeClass("tab2_button", "active-tab")
    shinyjs::removeClass("tab4_button", "active-tab")
    shinyjs::removeClass("tab5_button", "active-tab")
  })
  observeEvent(input$tab4_button, {
    current_tab("tab4")
    shinyjs::addClass("tab4_button", "active-tab")
    shinyjs::removeClass("tab1_button", "active-tab")
    shinyjs::removeClass("tab2_button", "active-tab")
    shinyjs::removeClass("tab3_button", "active-tab")
    shinyjs::removeClass("tab5_button", "active-tab")
  })
  observeEvent(input$tab5_button, {
    current_tab("tab5")
    shinyjs::addClass("tab5_button", "active-tab")
    shinyjs::removeClass("tab1_button", "active-tab")
    shinyjs::removeClass("tab2_button", "active-tab")
    shinyjs::removeClass("tab3_button", "active-tab")
    shinyjs::removeClass("tab4_button", "active-tab")
  })
  
  output$current_tab <- reactive({ current_tab() })
  outputOptions(output, "current_tab", suspendWhenHidden = FALSE)
  
  # --- General Tab ---
  output$game_stats <- DT::renderDataTable({
    req(input$favorite_game)
    selected <- game_titles[game_titles$Title == input$favorite_game, ]
    selected <- selected[, !(names(selected) %in% "Rank")]
    sales_cols <- c("Total.Sales", "PAL.Sales", "NA.Sales", "EU.Sales", "Japan.Sales", "Other.Sales")
    for (col in sales_cols) {
      if (col %in% names(selected)) {
        selected[[col]] <- ifelse(is.na(selected[[col]]), NA,
                                  format(as.numeric(selected[[col]]), big.mark = ",", scientific = FALSE))
      }
    }
    selected[is.na(selected)] <- "Not Available"
    colnames(selected) <- gsub("\\.", " ", colnames(selected))
    dt <- datatable(selected, options = list(scrollX = TRUE, dom = 't'), rownames = FALSE)
    for (col in colnames(selected)) {
      dt <- dt %>%
        formatStyle(columns = col, valueColumns = col,
                    backgroundColor = styleEqual("Not Available", "#b0b0b0"),
                    color = styleEqual("Not Available", "#1a1a1a"))
    }
    dt
  })
  
  # --- World Map Tab ---
  region_sales <- reactive({
    req(input$favorite_game)
    matches <- game_titles[game_titles$Title == input$favorite_game, ]
    region_names <- c("North America", "PAL Region", "Japan", "Other")
    sales_columns <- c("NA.Sales", "PAL.Sales", "Japan.Sales", "Other.Sales")
    sales <- sapply(sales_columns, function(col) {
      col_data <- matches[[col]]
      if (all(is.na(col_data))) NA else sum(col_data, na.rm = TRUE)
    })
    data.frame(region = region_names, sales = sales, stringsAsFactors = FALSE)
  })
  
  output$world_map <- renderPlot({
    sales_data <- region_sales()
    world_sf <- ne_countries(scale = "medium", returnclass = "sf") %>%
      filter(name != "Antarctica") %>%
      st_transform(crs = "+proj=robin")
    
    na_countries <- c("United States of America", "Canada", "Mexico")
    pal_countries <- c("United Kingdom", "France", "Germany", "Italy", "Spain", "Australia",
                       "New Zealand", "Brazil", "Argentina", "India", "South Africa", "Russia",
                       "Sweden", "Norway", "Denmark", "Finland", "Poland", "Netherlands", "Portugal",
                       "Austria", "Belgium", "Ireland", "Greece", "Turkey", "Ukraine", "Israel")
    japan_country <- c("Japan")
    
    world_sf <- world_sf %>%
      mutate(region_group = case_when(
        name %in% na_countries ~ "North America",
        name %in% pal_countries ~ "PAL Region",
        name %in% japan_country ~ "Japan",
        TRUE ~ "Other"
      ))
    
    regions_sf <- world_sf %>%
      group_by(region_group) %>%
      summarize(geometry = st_union(geometry), .groups = "drop") %>%
      st_make_valid() %>%
      st_buffer(0) %>%
      left_join(sales_data, by = c("region_group" = "region"))
    
    regions_sf$region_group <- factor(
      regions_sf$region_group,
      levels = c("North America", "PAL Region", "Japan", "Other")
    )
    
    label_data <- st_centroid(regions_sf)
    label_data$label <- ifelse(
      is.na(label_data$sales),
      "Not Available",
      paste0(round(label_data$sales / 1e6, 1), "M")
    )
    
    label_coords <- st_coordinates(label_data)
    label_coords[label_data$region_group == "PAL Region", "X"] <- 7000000
    label_coords[label_data$region_group == "PAL Region", "Y"] <- 6500000
    label_coords[label_data$region_group == "Other", "X"] <- label_coords[label_data$region_group == "Other", "X"] - 1500000
    label_coords[label_data$region_group == "Japan", "X"] <- label_coords[label_data$region_group == "Japan", "X"] + 1000000
    label_coords[label_data$region_group == "Japan", "Y"] <- label_coords[label_data$region_group == "Japan", "Y"] - 1000000
    
    st_geometry(label_data) <- st_sfc(
      mapply(function(x, y) st_point(c(x, y)),
             label_coords[, "X"], label_coords[, "Y"], SIMPLIFY = FALSE),
      crs = st_crs(label_data)
    )
    
    ggplot(regions_sf) +
      geom_sf(aes(fill = region_group), color = NA) +
      geom_sf_text(data = label_data, aes(label = label), fontface = "bold", size = 5) +
      scale_fill_manual(
        values = c(
          "North America" = "#2ecc71",
          "PAL Region" = "#3498db",
          "Japan" = "#9b59b6",
          "Other" = "#95a5a6"
        ),
        guide = guide_legend(title.position = "top", title.hjust = 0.5)
      ) +
      theme_void() +
      theme(
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14)
      ) +
      labs(
        title = paste("Sales by Region for:", input$favorite_game),
        fill = "Region"
      )
  })
  
  # --- Developer Tab ---
  observeEvent(input$random_developer, {
    random_pick <- sample(all_developers, 1)
    updateSelectizeInput(session, "selected_developer", choices = all_developers, selected = random_pick, server = TRUE)
    showNotification(paste("Random developer picked:", random_pick))
  })
  
  output$developer_games_title <- renderUI({
    req(input$selected_developer)
    h4(paste("All Games by:", input$selected_developer))
  })
  
  output$developer_games_table <- DT::renderDataTable({
    req(input$selected_developer)
    dev_games <- game_titles %>%
      filter(trimws(tolower(Developer)) == trimws(tolower(input$selected_developer)))
    req(nrow(dev_games) > 0)
    dev_games <- dev_games[, !(names(dev_games) %in% "Rank")]
    sales_cols <- c("Total.Sales", "PAL.Sales", "NA.Sales", "EU.Sales", "Japan.Sales", "Other.Sales")
    for (col in sales_cols) {
      if (col %in% names(dev_games)) {
        dev_games[[col]] <- ifelse(is.na(dev_games[[col]]), NA,
                                   format(as.numeric(dev_games[[col]]), big.mark = ",", scientific = FALSE))
      }
    }
    dev_games[is.na(dev_games)] <- "Not Available"
    colnames(dev_games) <- gsub("\\.", " ", colnames(dev_games))
    dt <- datatable(dev_games, options = list(scrollX = TRUE, dom = 't'), rownames = FALSE)
    for (col in colnames(dev_games)) {
      dt <- dt %>%
        formatStyle(columns = col, valueColumns = col,
                    backgroundColor = styleEqual("Not Available", "#b0b0b0"),
                    color = styleEqual("Not Available", "#1a1a1a"))
    }
    dt
  })
  
  # --- Genre Tab ---
  output$genre_barplot <- renderPlot({
    genre_counts <- game_titles %>%
      count(Genre) %>%
      arrange(desc(n))
    
    par(mar = c(8, 4, 4, 2))
    
    barplot(
      genre_counts$n,
      names.arg = genre_counts$Genre,
      las = 2,
      col = "steelblue",
      main = "Number of Games by Genre",
      ylab = "Number of Titles",
      cex.names = 0.8
    )
  })
  
  output$genre_sales_boxplot <- renderPlot({
    df <- game_titles %>%
      filter(!is.na(`Total.Sales`), !is.na(Genre))
    
    par(mar = c(9, 5, 4, 2))
    stat_max <- max(boxplot.stats(df$`Total.Sales`)$stats)
    y_max <- stat_max * 1.1
    yticks <- pretty(c(0, y_max), n = 5)
    
    boxplot(
      `Total.Sales` ~ Genre,
      data = df,
      las = 2,
      col = "lightgreen",
      main = "Total Sales by Genre",
      ylab = "",
      ylim = c(0, max(yticks)),
      outline = FALSE,
      xaxt = "n", yaxt = "n",
      cex.axis = 0.8
    )
    
    axis(1, at = 1:length(unique(df$Genre)),
         labels = unique(df$Genre),
         las = 2, cex.axis = 0.8)
    
    axis(2, at = yticks,
         labels = paste0(formatC(yticks / 1e6, format = "f", digits = 1), "M"),
         las = 1, cex.axis = 0.9)
    
    mtext("Sales (Millions)", side = 2, line = 3)
  })
  
  # --- Scoreboard Tab ---
  output$top_games <- renderTable({
    game_titles %>%
      filter(!is.na(Total.Sales)) %>%
      group_by(Title) %>%
      summarise(Total_Sales = sum(Total.Sales, na.rm = TRUE)) %>%
      arrange(desc(Total_Sales)) %>%
      slice_head(n = 10) %>%
      mutate(Total_Sales = paste0(round(Total_Sales / 1e6, 1), "M"))
  })
  
  output$top_publishers <- renderTable({
    game_titles %>%
      filter(!is.na(Total.Sales), !is.na(Publisher)) %>%
      group_by(Publisher) %>%
      summarise(Total_Sales = sum(Total.Sales, na.rm = TRUE)) %>%
      arrange(desc(Total_Sales)) %>%
      slice_head(n = 10) %>%
      mutate(Total_Sales = paste0(round(Total_Sales / 1e6, 1), "M"))
  })
}




