#this file contains all the packages,metadata, groupings and color palettes that are used in downstream scripts

### ----- Load packages ----- ###
package_load <- function(package_names){
  for(i in 1:length(package_names)){
    if(!package_names[i] %in% installed.packages()){
      install.packages(package_names[i])
    }
    library(package_names[i],character.only = TRUE)
  }
}

#vector of packages
pack_req <- c( 
  # data wrangling packages
  "tidyverse","lubridate","padr","janitor","padr", "broom","arrow","readxl",
  #spatial packages
  "sf","terra","nhdplusTools", "tigris","raster", "leaflet","tmap",
  # plotting
  "ggpubr","ggthemes","scales","corrplot","gghighlight", "geomtextpath", "ggbeeswarm","plotly", "ggpmisc","flextable",
  # web scrapping
  "rjson", "rvest", "dataRetrieval", "httr", "jsonlite",
  #extra
  "devtools", "trend")
package_load(pack_req)


remove(pack_req, package_load)
#Simple function to negate %in%
`%nin%` = Negate(`%in%`)


#------ Metadata Files ------#


#buffer_sbs:Indices based on burn severity directly around the reservoir
buffer_sbs <- read_csv('data/metadata/sbs_buffer.csv') %>%
  mutate(Buffer_Level=((Unburned*0)+(V_Low*0.1)+(Low*0.4)+(Moderate*0.7)+(High*1))/(Unburned+V_Low+Low+Moderate+High))
# watershed_sbs: within each reservoirs watershed.
watershed_sbs <- read_csv('data/metadata/sbs_watershed.csv') %>%
  mutate(Watershed_Level=((Unburned*0)+(V_Low*0.1)+(Low*0.4)+(Moderate*0.7)+(High*1))/(Unburned+V_Low+Low+Moderate+High))
# site_meta: Locations of each site, includes grouping and type of body of water
site_meta <- read.csv('data/metadata/cpf_sites.csv')
#dist_from_pbd: distance from PBD (mouth of canyon) using NHD flowline
dist_from_pbd <- read.csv('data/metadata/distance_from_pbd.csv')