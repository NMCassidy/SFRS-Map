require(dplyr)        #Data manipulation
require(rgdal)        #To read and alter shapefiles
require(RColorBrewer) #For colour scheme
require(leaflet)      #To make the Maps
require(sp)           #To deal with shapefiles

#Indicators to view when clicking the map, if order is changed the
#popups will also need to be changed below
impinds<-c("Emergency admissions rate per 100,000 2012", "Deliberate fire rate per 100,000 people 2012-2013", "Accidental fire rate per 100,000 people 2012-2013", "Number of SIMD crimes per 10,000 people 2010/2011", "Accident admissions rate per 100,000 2012", "Coronary heart disease rate per 100,000 2012", "SIMD ranking 2012")

shinyServer(
  function(input, output){
    
  #read the required data and shape files from internet and shared drive
    dta_simd12_dz <- read.csv(file = "http://www.isdscotland.org/Products-and-Services/GPD-Support/Deprivation/SIMD/_docs/SIMD_2012/datazone_simd2012.csv")[,c(1,5)]
    SpPolysDF<-readRDS("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/LeafletPolygons.rds")
    map_dzs<-readRDS(file = "S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/data/dzs01_fort.rds")
  
    
  #merge map_dzs and simd deciles to set for colours later
  #create colour function for leaflet
    frclrs<-merge(x = map_dzs[!duplicated(map_dzs$id), c(6,7)], y = dta_simd12_dz, by.x = "id", by.y = "Datazone", all = TRUE)   
    SpPolysDF@data$scsimd2012decile<-frclrs$scsimd2012decile
    #Only needed this line if colorNumeric does not work
#SpPolysDF@data$scsimd2012decile<-factor(as.character(SpPolysDF@data$scsimd2012decile))
   clrs<-brewer.pal(10, "RdYlGn")
   pal<- colorNumeric(clrs, SpPolysDF@data$scsimd2012decile)
    
  
  #create dataset to allow map clicking to work
      cols_keep<-c("datazone_2001","council", impinds)
      dta1 <- dta[,(names(dta) %in% cols_keep)]
      dta1<-merge(x = map_dzs, y = dta1,
                 by.x = "id", by.y = "datazone_2001", all.x = TRUE)
      
  #subset to get only shapes for selected council area (or not)
  #and create a colour scheme
    data<-reactive({
      if(input$LA != "Scotland"){
        descncl<-SpPolysDF@data$council == input$LA
        Cnc_dzs<-SpPolysDF[descncl,]
      }
      else{
        SpPolysDF<-SpPolysDF
      }
    })
    
   #create the map
    output$newplot<-renderLeaflet({
        p<-leaflet(data())%>%
        addTiles()%>%
        addPolygons(smoothFactor = 0.5, weight = 1.5, fillOpacity = 0.7,
                    layerId = ~group, fillColor = ~pal(scsimd2012decile), color = "black")
      return(p)
    })
    
  #Add popups when clicking a datazone- if adding new data, need to change impinds 
  #above and add a new tag below
    showDZPopup <- function(group, lat, lng) {
      selectedDZ <- dta1[dta1$id == group,]
      content <- as.character(tagList(
        tags$h4(as.character(unique(selectedDZ$id))),
        sprintf("%s: %s\n",
                   "Emergency Admissions Rate 2012", unique(selectedDZ[impinds[[1]]])), tags$br(),
        sprintf("%s: %s\n",
                   "Deliberate Fires Rate 2012-13", unique(selectedDZ[impinds[[2]]])),tags$br(),
        sprintf("%s: %s\n",
                   "Accidental Fires Rate 2012-13", unique(selectedDZ[impinds[[3]]])), tags$br(), 
        sprintf("%s: %s\n",
                "SIMD Crime Rate 2010-11", unique(selectedDZ[impinds[[4]]])), tags$br(),
        sprintf("%s: %s\n",
                "Accident Rate 2012", unique(selectedDZ[impinds[[5]]])), tags$br(),
        sprintf("%s: %s\n",
                "Coronary Heart Disease Rate 2012", unique(selectedDZ[impinds[[6]]])), tags$br(),
        sprintf("%s:%s\n",
                "SIMD Ranking", unique(selectedDZ[impinds[[7]]])), tags$br()
        ))
      leafletProxy("newplot") %>% addPopups(lng, lat, content, layerId = group)
    }
    
  #Makes the popups appear and clears old popups
    observe({
      leafletProxy("newplot") %>% clearPopups()
      event <- input$newplot_shape_click
      if (is.null(event))
        return()
      isolate({
        showDZPopup(event$id, event$lat, event$lng)
      })
    })
    
  #Subsets the dataset based on selected local authority
  #and data zone(s)  
    dataset<-reactive({if(is.null(input$LA2)){
      dta<-dta
    }else{
             dta<-subset(dta, council == input$LA2)
    }
    })

    
  #Subsets dataset based on selected domain
    output$dataset<-renderDataTable({
      if(input$domain == "All"){
        dta<-dataset()
      } else if(input$domain == "Income and Employment"){
        dta<-dataset()[Econ]
      } else if (input$domain == "Health"){
        dta<-dataset()[Hea]
      } else if (input$domain == "Housing"){
        dta<-dataset()[Hous]
      } else if (input$domain == "Community Safety"){
        dta<-dataset()[ComSft]
      } else if (input$domain == "Demography and Geography"){
        dta<-dataset()[Dem]
      }
    })

  #Download Button (not in UI at the minute- might not work with leaflet?)
   # output$download <- downloadHandler(
  #    filename = function() { paste(input$png, '.png', sep='') },
  #    content = function(file) {
  #      device <- function(..., width, height) {
  #        grDevices::png(..., width = width, height = height,
  #                       res = 300, units = "in")
  #      }
  #      ggsave(file, plot = plotInput(), device = device,width = 8, height = 4, dpi = 300)
  #  #})
  })