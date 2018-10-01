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
rename(PlaneData,
       X.6 = Latitude,
       X.7 = Longitude
)
PlaneData <- arrange(PlaneData, HexIdnet)

# UI
ui <- dashboardPage(
  dashboardHeader(

  ),
  dashboardSidebar(
    
   
  ),
  dashboardBody(
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
    leafletOutput("map",height = "50"),
    checkboxGroupInput("planecheckboxes", "Planes", unique(PlaneData$HexIdnet))
  )
)
# Define server logic required to draw a histogram
server <- function(input, output) {

  
  output$map <- renderLeaflet({
    m <-leaflet(PlaneData) %>%
      addTiles()
  })
  observe({
    
  })
}



# Run the application 
options(shiny.port = 20000)
options(shiny.host = "192.168.72.112")
shinyApp(ui = ui, server = server)


