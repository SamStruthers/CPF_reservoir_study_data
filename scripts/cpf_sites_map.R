#This script will output cpf_sites_map.html so folks can view where sites are located


source("scripts/00_analysis_setup.R")
#00_analysis_setup reads in location data from 'data/metadata/cpf_sites.csv' into object Sites

cpf_sites <- site_meta%>%
  #remove sites with no location data
  filter(!is.na(Lat)&!is.na(Long))%>%
  #make into a spatial object
  st_as_sf(coords=c("Long","Lat"), crs=4326)%>%
#remove extra info
  select(-c(Q.source, DO, DO.source))%>%
  #grab only ROSS sites
  filter(data_owner == "ROSS")

#Make map of each type of site that ROSS samples and owns the data for
mapview::mapview(filter(cpf_sites, watershed == "CLP Mainstem-Canyon"), layer.name="Mainstem CLP",col.regions="blue")+
  mapview::mapview(filter(cpf_sites, location %in%c("Outflow", "Inflow","Reservoir" ) ), layer.name="CLP Reservoir Sites",col.regions="green")+
  mapview::mapview(filter(cpf_sites, watershed == "CLP Tributary"), layer.name="CLP Tributary Sites" ,col.regions="red")+
  mapview::mapview(filter(cpf_sites, watershed == "CLP  Mainstem-Fort Collins"), layer.name="Mainstem CLP in City of Fort Collins",col.regions="grey" )
