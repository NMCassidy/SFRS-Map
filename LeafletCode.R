SpPolysDF<-readRDS("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny Tool/LeafletPolygons.rds")

descncl<-SpPolysDF@data$council == "West Lothian"
Cnc_dzs<-SpPolysDF[descncl,]
cfact<-as.factor(SpPolysDF@data$council)
cf<-colorFactor(topo.colors(16), cfact)

m<-leaflet(SpPolysDF)%>%
  addTiles()%>%
  addPolygons(smoothFactor = 0.5, weight = 1.5, opacity = 1)

##Below here is some of the code used to put together the polygons
dta<-readRDS("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/Shiny Tool/dataset")
map_dzs<-readRDS(file = "S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/data/dzs01_fort.rds")
polys<-list()
polyss<-list()

dta<-dta[1:2]
map_dzs<-merge(map_dzs, dta, by.x = "id", by.y = "datazone_2001")
cncdta<-map_dzs[7:8]
cncdta<-unique(cncdta)
rownames(cncdta)<-c(levels(map_dzs$group))

for(i in 1:nlevels(map_dzs$group)){
  lv<-levels(map_dzs$group)[i]
  coordins<-map_dzs[map_dzs$group == lv,2:3]
  coordins<-as.matrix(coordins)
  polys[i]<-Polygon(coords = coordins)
}

for(i in 1:6720){
  polyss[i]<-Polygons(srl = list(polys[[i]]), ID = levels(map_dzs$group)[i])
}

##Add on area sizes to reorder the data frame
tmp_df<-data.frame()
tmp_df<-map_dzs[c(1,7)]
tmp_df<-unique(tmp_df)
areas<-read.csv("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/dz_area_size.csv")
tmp_df<-merge(tmp_df, areas, by.x = "id", by.y = "GeographyCode")
cncdta[[3]]<-tmp_df$X2005
cncdta<-cncdta[order(cncdta$V3),,drop = FALSE]
rm(tmp_df)

SpPolys<-SpatialPolygons(Srl = polyss)
SpPolysDF<-SpatialPolygonsDataFrame(data = cncdta, Sr = SpPolys)

SpPolysDF@data$council<-cncdta$council


##Possibly better way of doing this by using already existant shapefiles - 
#Will need to add on council areas
sns_geo_urls <- c("http://sedsh127.sedsh.gov.uk/Atom_data/ScotGov/ZippedShapefiles/SG_DataZoneBdry_2011.zip", "http://sedsh127.sedsh.gov.uk/Atom_data/ScotGov/ZippedShapefiles/SG_IntermediateZoneBdry_2011.zip", "http://sedsh127.sedsh.gov.uk/Atom_data/ScotGov/ZippedShapefiles/SG_DataZoneBdry_2001.zip", "http://sedsh127.sedsh.gov.uk/Atom_data/ScotGov/ZippedShapefiles/SG_IntermediateZoneBdry_2001.zip")
dta<-readRDS("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/Shiny Tool/dataset")
# Libs
library(rgdal)    # R to read shapefiles
library(ggplot2)  # for general plotting
library(ggmap)    # for fortifying shapefiles
require(tools)    # to clean the file name
require(plyr)     # To join the maps

# Download the selected shapefile from the net
tmp_fl <- tempfile(fileext = ".zip")
download.file(url = sns_geo_urls[3], destfile = tmp_fl)
# Unzip the file to the working directory
temp_dr <- normalizePath(tempdir(), mustWork = TRUE)
unzip(zipfile = tmp_fl, exdir = temp_dr, overwrite = TRUE)
# Get shapefile name
shpfl_path <- file_path_sans_ext(temp_dr)
# Read shapefile and fortify shapefile
SpPolysDF <- readOGR(dsn = shpfl_path, layer = "SG_DataZone_Bdry_2001")
# Change projections
proj4string(SpPolysDF)
SpPolysDF <- spTransform(SpPolysDF, CRS("+proj=longlat +datum=WGS84 +no_defs"))
#Adds council areas
SpPolysDF@data$council<-dta$council
#Add in group to allow data linkage
SpPolysDF@data$group<-unique(dta$datazone_2001)

saveRDS(SpPolysDF, file = "S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/LeafletPolygons.rds")
