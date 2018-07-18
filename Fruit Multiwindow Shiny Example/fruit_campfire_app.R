# Larger Multi-Window Shiny Example
# By Hannah De los Santos
# Originated on: 7/16/18

# Description: A larger example, with plots, of multi-window shiny,
# based on Nick's implementation. Meant to also be an example for 
# a good multi-window shiny code workflow.

# Data is from the USDA website:
# https://www.ers.usda.gov/data-products/fruit-and-tree-nut-data/fruit-and-tree-nut-yearbook-tables/#General

# Note: this is the script you should run.

# set up ----

# set working directory, if not already set - only works in RStudio (with rstudioapi)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# script with campfire functionality for floors and wall
source("fruit_campfire_lib.R")

# running app ----

campfireApp(
  
  # controller: where selections and possibly shiny app information reside
  controller = fluidPage(tweaks,
                 fluidRow(column(width = 12, 
                   list(h3("Controller: US Fruit and Nut Data Explorer"), 
                        # checkbox slector for which fruits to look at
                    tags$div(align = 'left', 
                             class = 'multicol', 
                             checkboxGroupInput(inputId = "fruit",
                                                label = "Fruits/Nuts to Examine:",
                                                choices = c("Grapefruits", "Lemons",
                                                            "Oranges", "Tangerines",
                                                            "Apples", "Avocados",
                                                            "Cherries", "Grapes",
                                                            "Nectarines", "Olives",
                                                            "Peaches", "Pears",
                                                            "Pineapples", "Plums and prunes",
                                                            "Cranberries", "Strawberries",
                                                            "Blueberries", "Almonds",
                                                            "Pecans", "Walnuts",
                                                            "Other fruit and nuts"),
                                                inline = F)
                                ) 
                         ))),
                 # slider input for which years to choose
                 fluidRow(column(width = 12, 
                                 tags$div(align = 'left',
                                  sliderInput("years", "Years to Examine:",
                                        min = 1980,
                                        max = 2016,
                                        value = c(1989,2016),
                                        sep = "")))),
                 # select which dataset to look at
                 fluidRow(column(width = 12, 
                                 tags$div(align = 'left',
                                          selectInput("which_dat",
                                                      "Dataset to View:",
                                                      choices = c("Average Retail Value" = "retail",
                                                                  "Cash Receipts" = "cash"))))),
                 # action button to update pictures
                 fluidRow(column(width = 12, 
                                 tags$div(align = 'left',
                                  actionButton("go","Update"))))
  ),
  
  wall = div(
    plotOutput("wall", height = "800px"),
    verbatimTextOutput("wallText"),
    style="background: rgb(255, 255, 255);"
  ),
  
  floor = div(
    plotOutput("floor", height = "800px"),
    style="background: rgb(255, 255, 255);"
  ),
  
  monitor = div(
    plotOutput("monitor", height = "800px"),
    style="background: rgb(255, 255, 255);"
  ),
  
  # render output here ----
  
  serverFunct = function(serverValues, output) {
    # this is where we access the serverValues passed in the library script
    # only plots should be rendered here -- little to no computation.
    
    # on the monitor, we plot an emoji of a random selected fruit, if available
    output$monitor <- renderPlot({ 
      if (length(serverValues$fruit) == 0){
        ggplot() + 
          geom_emoji("fork_and_knife", color="grey", size = 80) + 
          theme_void() 
      } else {
        choose_fruit <- sample(serverValues$fruit,1)
        if (choose_fruit == "Grapes") {
          ggplot() + 
            geom_emoji("grapes", color=color_map["Grapes"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Pears") {
          ggplot() + 
            geom_emoji("pear", color=color_map["Pears"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Peaches") {
          ggplot() + 
            geom_emoji("peach", color=color_map["Peaches"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Tangerines") {
          ggplot() + 
            geom_emoji("tangerine", color=color_map["Tangerines"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Strawberries") {
          ggplot() + 
            geom_emoji("strawberry", color=color_map["Strawberries"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Pineapples") {
          ggplot() + 
            geom_emoji("pineapple", color=color_map["Pineapples"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Cherries") {
          ggplot() + 
            geom_emoji("cherries", color=color_map["Cherries"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Avocados") {
          ggplot() + 
            geom_emoji("avocado", color=color_map["Avocados"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Apples") {
          ggplot() + 
            geom_emoji("apple", color=color_map["Apples"], size = 80) + 
            theme_void() 
        } else if (choose_fruit == "Lemons") {
          ggplot() + 
            geom_emoji("lemon", color=color_map["Lemons"], size = 80) + 
            theme_void() 
        } else {
          ggplot() + 
            geom_emoji("fork_and_knife", color="grey", size = 80) + 
            theme_void() 
        }
      } 
      
      
    })
    
    # on the wall, we render a grouped bar plot of value over time
    output$wall <- renderPlot({ 
      if (!is.null(serverValues$go)){
        suppressWarnings( 
          ggplot(serverValues$fruit_bar, aes_string("Year", paste0(serverValues$which_dat, ".value"))) +
            geom_bar(aes(fill = Fruit), position = "dodge", stat="identity") +
            scale_fill_manual(values = serverValues$color_map[serverValues$fruit]) +
            NULL
        )
      } else {
        suppressWarnings( 
          ggplot(fruit_bar, aes_string("Year", "retail.value")) +
            geom_bar(aes(fill = Fruit), position = "dodge", stat="identity") +
            scale_fill_manual(values = color_map[fruit_def]) +
            NULL
        )
      }
    })
    # also on the wall we render which fruit don't appear in the selected dataset
    output$wallText <- renderText({
      if (!is.null(serverValues$go)){
        return(paste0("The following fruit are not in this dataset: ", 
                    paste(serverValues$bad_fruit, collapse = " ")))
      } else {
        return(paste0("The following fruit are not in this dataset: ", 
                      paste(bad_fruit, collapse = " ")))
      }
    })
    
    # on the floor, we render a pie chart of total value over years
    output$floor <- renderPlot({ 
      suppressWarnings(
        if (!is.null(serverValues$go)){
          ggplot(serverValues$fruit_pie, aes(x = "", y = Total.Value, fill = Fruit)) +
            geom_bar(width = 1, stat = "identity")  +
            coord_polar(theta = "y", start = 0) +
            scale_fill_manual(values = serverValues$color_map[serverValues$fruit]) +
            scale_y_continuous(breaks = round(cumsum(rev(serverValues$fruit_pie$Total.Value)), serverValues$tot_val)) +
            theme(#axis.title.x=element_blank(),
                  # axis.text.x=element_blank(),
                  # axis.ticks.x=element_blank(),
                  axis.title.y=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks.y=element_blank()
                  ) +
            NULL
        } else {
          ggplot(fruit_pie, aes(x = "", y = Total.Value, fill = Fruit)) +
            geom_bar(width = 1, stat = "identity")  +
            coord_polar(theta = "y", start = 0) +
            scale_fill_manual(values = color_map[fruit_def]) +
            scale_y_continuous(breaks = round(cumsum(rev(fruit_pie$Total.Value)), tot_val)) +
            theme(#axis.title.x=element_blank(),
              # axis.text.x=element_blank(),
              # axis.ticks.x=element_blank(),
              axis.title.y=element_blank(),
              axis.text.y=element_blank(),
              axis.ticks.y=element_blank()
            ) +
            NULL
        }
      )
    })
  }
  
  )