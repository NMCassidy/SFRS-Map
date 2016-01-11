#Read Dataset
dta<-readRDS("S:/G - Governance & Performance Mngmt/Research Team/Fire Research/Assessments-Rproject/Shiny -Leaflet/Shiny Tool/dataset")


#Create domains by grouping indicators
econ_vars<-c("deprived", "SIMD ranking for income", "SIMD ranking 2", "claiming", "claimant")
Econ<-c("datazone_2001", "council", grep(paste(econ_vars, collapse = "|"), names(dta), value = TRUE))
health_vars<-c("admission", "disease", "NHS")  
Hea<-c("datazone_2001", "council",grep(paste(health_vars, collapse = "|"), names(dta), value = TRUE))
housing_vars<-c("dwellings", "housing")
Hous<-c("datazone_2001", "council",grep(paste(housing_vars, collapse = "|"), names(dta), value =TRUE))  
cmsft_vars<- c("fire", "crime") 
ComSft<-c("datazone_2001", "council",grep(paste(cmsft_vars, collapse = "|"), names(dta), value = TRUE))
demo_vars<-c("Total population", "Total people", "number of people", "number of working age", "Average age", "Median age", "services domain", "Percentage of population of pensionable age", "Urban/rural", "density", "area size", "e population over the age of")  
Dem<-c("datazone_2001", "council",grep(paste(demo_vars, collapse = "|"), names(dta), value = TRUE))
rm(econ_vars, health_vars, housing_vars, cmsft_vars, demo_vars)  