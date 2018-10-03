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
library(RODBC)


if(FALSE)
{
  dbconnection <- odbcDriverConnect("Driver=SQL Server Native Client 11.0;Server=192.168.11.34;Database=fdata;Uid=fdata;Pwd=eagleone")
  initdata <<- sqlQuery(dbconnection,paste("select * from ds1;"))
  odbcCloseAll()
}


if(TRUE)
{
  raw_data <- read.csv("log.csv")
  
  initdata <- initdata %>% rename_all(funs(colnames(raw_data)))
  
  com_data <- rbind(raw_data, initdata, na.rm=FALSE)
  
  PlaneData <<- filter(com_data, Transmission.Type == 3)
  PlaneData <<- arrange(PlaneData, HexIdnet)
}

m <-leaflet(PlaneData) %>%
  addTiles() 

for(i in levels(PlaneData$HexIdnet))
  {
    m <- m %>% addPolylines(
                  PlaneData[PlaneData$HexIdnet == i,],
                  lng = ~Longitude,
                  lat = ~Latitude,
                  #popup = ~HexIdnet
                  #col = ~c()
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
          leafletOutput("map", height = "75vh"),
          checkboxGroupInput("planecheckboxes", "Planes", levels(PlaneData$HexIdnet), selected = levels(PlaneData$HexIdnet))
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
  
  observeEvent(input$planecheckboxes, {
    leafletProxy("map") %>% 
      clearShapes()
      
    for(i in input$planecheckboxes)
    {
      leafletProxy("map") %>% addPolylines(
        lng = PlaneData[PlaneData$HexIdnet == i,]$Longitude,
        lat = PlaneData[PlaneData$HexIdnet == i,]$Latitude
      )
    }
  })
}



# Run the application 
options(shiny.port = 20000)
options(shiny.host = "192.168.72.112")
shinyApp(ui = ui, server = server)


