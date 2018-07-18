# Fruit Campfire Library
# by Hannah De los Santos
# Originated on: 7/17/18

# load libraries, data, variables, and misc functions ----

# libraries
library(shiny)
library(ggplot2)
library(reshape2)
library(emojifont)

# data
# data source: https://www.ers.usda.gov/data-products/fruit-and-tree-nut-data/fruit-and-tree-nut-yearbook-tables/#General
retail_fruit <- read.csv("US_Fruit_Avg_Retail_Value_1989_to_2016.csv")
rownames(retail_fruit) <- retail_fruit$Fruit
cash_fruit <- read.csv("US_Fruit_Cash_Receipts_in_1000s_1980_to_2016.csv")
rownames(cash_fruit) <- cash_fruit$Fruit

# creating default data, for startup
{
  begin <- 1989
  end <- 2000
  fruit_def <- c("Apples", "Lemons", "Grapes", "Grapefruits", "Peaches")
  
  # subset the df we care about: retail
  # not all fruit appear in the retail dataset
  fruit_logical <- fruit_def %in% rownames(retail_fruit)
  # fruit in retail
  good_fruit <- fruit_def[fruit_logical]
  # fruit out of retail
  bad_fruit <- fruit_def[!fruit_logical]
  
  sub_fruit <- retail_fruit[good_fruit,c("Fruit",paste0("X",c(begin:end)))]
  
  # make the bar plot data frame (value for each year):
  
  # get into long format, using fruits as the id
  fruit_bar <- melt(sub_fruit, id.vars = "Fruit")
  colnames(fruit_bar)[2:3] <- c("Year", "retail.value")
  # remove all X's from the time column (still a string is ok)
  fruit_bar$Year <- gsub("X","", fruit_bar$Year)
  
  # make the pie chart dataframe (sum total value for all years):
  fruit_pie <- data.frame(matrix(0,nrow(sub_fruit), 2))
  colnames(fruit_pie) <- c("Fruit", "Total.Value")
  fruit_pie$Fruit <- sub_fruit$Fruit
  fruit_pie$Total.Value <- as.numeric(rowSums(sub_fruit[,-1], na.rm = T))
  fruit_pie <- fruit_pie[order(fruit_pie$Fruit),]
  tot_val <- sum(fruit_pie$Total.Value)
}

# variables

color_map <- c("Grapefruits" = "#ea5744", "Lemons" ="#fcf011",
               "Oranges" = "#fc9210", "Tangerines" = "#f7a33d",
               "Apples" = "#ff0000", "Avocados" = "#2da844",
               "Cherries" = "#a80528", "Grapes" = "#6404a0",
               "Nectarines" = "#f7a222", "Olives" = "#191818",
               "Peaches" = "#ef9267", "Pears" = "#b1ef66",
               "Pineapples" = "#fff963", "Plums and prunes" = "#d11be5",
               "Cranberries" = "#751313", "Strawberries" = "#e20047",
               "Blueberries" = "#0010c4", "Almonds" = "#ce9a40",
               "Pecans" = "#fcb250", "Walnuts" = "#331d00",
               "Other fruit and nuts" = "#5e5b57")

# functions

# tweaks, a list object to set up multicols for checkboxGroupInput
# source: https://stackoverflow.com/questions/29738975/how-to-align-a-group-of-checkboxgroupinput-in-r-shiny
tweaks <- list(tags$head(tags$style(HTML("
                                 .multicol { 
                                   height: 150px;
                                   -webkit-column-count: 5; /* Chrome, Safari, Opera */ 
                                   -moz-column-count: 5;    /* Firefox */ 
                                   column-count: 5; 
                                   -moz-column-fill: auto;
                                   -column-fill: auto;
                                 } 
                                 "))
                         )
               )

# adjust campfire edits ----

# In this function, this is where you do the bulk of your
# processing: subsetting data to be passed to visualizations,
# calculations, etc.

campfireApp = function(controller = NA, wall = NA, floor = NA, monitor=NA, serverFunct = NA) {
  ui <- campfireUI(controller, wall, floor, monitor)
  
  # our reactive values that we will pass to our rendering
  serverValues = reactiveValues()
  
  # function where the computation (server) happens
  campfire_server <- shinyServer(function(input, output) {
    
    observeEvent(input$go, {
      # reassign everything from the input to the serverValues
      # from now on, only reference input values with serverValues
      
      for (inputId in names(input)) {
        serverValues[[inputId]] <- input[[inputId]]
      }
      
      # subset the data for the years and fruits we care about
      # column names start with X
      begin <- serverValues$years[1]
      end <- serverValues$years[2]
      
      # subset the df we care about
      if (serverValues$which_dat == "cash"){
        sub_fruit <- cash_fruit[serverValues$fruit,c("Fruit",paste0("X",c(begin:end)))]
        
        # no bad fruit here!
        bad_fruit <- c()
      } else {
        # not all fruit appear in the retail dataset
        fruit_logical <- serverValues$fruit %in% rownames(retail_fruit)
        # fruit in retail
        good_fruit <- serverValues$fruit[fruit_logical]
        # fruit out of retail
        bad_fruit <- serverValues$fruit[!fruit_logical]
        
        # also this dataset has nothing before 1989
        if (begin < 1989) {
          begin <- 1989
        }
        
        sub_fruit <- retail_fruit[good_fruit,c("Fruit",paste0("X",c(begin:end)))]
      }
      
      # make the bar plot data frame (value for each year):
      
      # get into long format, using fruits as the id
      fruit_bar <- melt(sub_fruit, id.vars = "Fruit")
      colnames(fruit_bar)[2:3] <- c("Year", paste0(serverValues$which_dat, ".value"))
      # remove all X's from the time column (still a string is ok)
      fruit_bar$Year <- gsub("X","", fruit_bar$Year)
      
      # make the pie chart dataframe (sum total value for all years):
      fruit_pie <- data.frame(matrix(0,nrow(sub_fruit), 2))
      colnames(fruit_pie) <- c("Fruit", "Total.Value")
      fruit_pie$Fruit <- sub_fruit$Fruit
      fruit_pie$Total.Value <- as.numeric(rowSums(sub_fruit[,-1], na.rm = T))
      fruit_pie <- fruit_pie[order(fruit_pie$Fruit),]
      tot_val <- sum(fruit_pie$Total.Value)
      
      
      # add this to serverValues, which we will use to create the plot
      # if you want to access a value when plotting, add it to serverValues
      serverValues[["fruit_bar"]] <- fruit_bar
      serverValues[["bad_fruit"]] <- bad_fruit
      serverValues[["fruit_pie"]] <- fruit_pie
      serverValues[["tot_val"]] <- tot_val
      serverValues[["color_map"]] <- color_map
      
    })
    
    serverFunct(serverValues, output)
    
  })
  
  options(shiny.port = 5480)
  shinyApp(ui, server = campfire_server)
}

# campfire ui ----

# This is the section that controls what the user sees
# when they load the app. No need to edit anything in 
# this section.

campfireUI = function(controller, wall, floor, monitor) {
  ui <- shinyUI(bootstrapPage(
    HTML('<script type="text/javascript">
         $(function() {
         $("div.Window").hide(); 
         var tokens = window.location.href.split("?");
         if (tokens.length > 1) {
         var shown_window = tokens[1];
         $("div."+shown_window).show();
         } else {
         $("div.WindowSelector").show();
         }
         });
         </script>'),
		div(class="WindowSelector Window",
		    HTML('<h2><a href="?Controller">Controller</a></h2>'),
		    HTML('<h2><a href="?Wall">Wall</a></h2>'),
		    HTML('<h2><a href="?Floor">Floor</a></h2>'),
		    HTML('<h2><a href="?Monitor">External Monitor</a></h2>'),
		    style='position: absolute; 
		    top: 50%; left: 50%; 
		    margin-right: -50%; 
		    transform: translate(-50%, -50%)'
		),
		div(class="Controller Window",
		    controller
		),
		div(class="Wall Window",
		    wall 
		),
		div(class="Floor Window",
		    floor
		),
		div(class="Monitor Window",
		    monitor
		)
		
	))

	return(ui)
}