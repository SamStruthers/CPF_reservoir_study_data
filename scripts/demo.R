# Demo download and plotting in R
#Install and library needed packages `tidyverse` and `arrow`
install.packages(c("tidyverse", "arrow"))
library(tidyverse)
library(arrow)

# Download the entire folder from Zenodo DOI as a zipped folder in your working directory
download.file('https://zenodo.org/record/8308733/files/rossyndicate/CPF_reservoir_study_data-latest.zip?download=1',destfile = 'ross_cpf.zip') 
# unzip this file
unzip('ross_cpf.zip') 
 # Grab the name of the download file from current R project   
CPF_download_file <- list.files() %>%
  keep(~ grepl("rossyndicate", .))
 # Grab the most recent cleaned and collated chemistry dataset
# For the current release that file is `CPF_reservoir_chemistry_up_to_071023.csv`
most_recent_chem <- read_csv_arrow(paste0(CPF_download_file,'/data/cleaned/CPF_reservoir_chemistry_up_to_071023.csv'))

#Example plot of NO3 over time at three sites
no3_ex_plot <- most_recent_chem %>% 
  filter(site_code %in% c("JOEI","CBRR", "JWC" )& Year > 2020)%>%
  ggplot(aes(x = Date, y = NO3, color = site_code)) + 
  geom_point(size = 2)+
    labs(x = "Date", y = "NO3 (mg/L)")+
    theme_bw(base_size = 15)
no3_ex_plot
