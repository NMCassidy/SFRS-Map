library(shiny)
library(leaflet)

shinyUI(navbarPage("Risk Assessment", id = "nav", theme = "bootstrap.css",

 
    tabPanel("Interactive Map", div(class = "outer", leafletOutput("newplot", height = 840),
             absolutePanel(id = "controls", class = "panel panel-default" ,fixed = TRUE,
                           draggable = TRUE, top = 70, left = "auto", right = 20, bottom = "auto",
                           width = 320, height = "auto",
                        wellPanel(
                           h2("  Council Area"),
                        
                           selectInput("LA", "  Select a Local Authority", 
                                       c("Scotland",unique(dta$council))
                           ))))),
    tabPanel("Data Explorer", 
             fluidRow(column(4, selectInput("LA2", "Select a Local Authority", 
                                            c("All Scotland" = "",unique(dta$council)), multiple = TRUE)
                             ),
                      column(4, selectInput("domain", "Select a Domain", 
                                            c("All","Income and Employment", 
                                              "Health", "Housing", "Community Safety", 
                                              "Demography and Geography"))
                             )
                      ), 
             dataTableOutput("dataset"))
    
))