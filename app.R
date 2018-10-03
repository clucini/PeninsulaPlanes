#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)


raw_data <- read.csv("log.csv")

PlaneData <- filter(raw_data, Transmission.Type == 3)
PlaneData <- arrange(PlaneData, HexIdnet)

m <-leaflet(PlaneData) %>%
  addTiles() 

for(i in unique(PlaneData$HexIdnet))
  {
    m <- m %>% addPolylines(
                 lng = PlaneData[PlaneData$HexIdnet == i,]$Longitude,
                 lat = PlaneData[PlaneData$HexIdnet == i,]$Latitude
                 )
  }



# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "Peninsula Planes"
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map-marker")),
      menuItem("Options", tabname = "options", icon = icon("filter"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
        fluidRow(
          leafletOutput("map")
        ),
        fluidRow(
          checkboxGroupInput("planecheckboxes", "Planes", unique(PlaneData$HexIdnet))
        )
      ),
      tabItem(tabName = "options"
              )
    )
  )
)
# Define server logic required to draw a histogram
server <- function(input, output) {

  
  output$map <- renderLeaflet({
    m
  })
  observe({
    
  })
}



# Run the application 
options(shiny.port = 20000)
options(shiny.host = "192.168.72.112")
shinyApp(ui = ui, server = server)


