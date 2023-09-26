
## App to make CPF data app
#WORK IN PROGRESS


library(bslib)
library(leaflet)
library(plotly)
library(readr)
library(shinyWidgets)
library(shiny)
library(readxl)
library(tidyverse)


#### SAM
setwd("/Users/samstruthers/Documents/fork_yeah/CPF_reservoir_study_data")
#chem_meta <- read_excel("data/metadata/Units_Cam_Peak.xlsx")
#chem_vals <- chem_meta$Parameters

res_chem <- readRDS("data/tidyResChem.RDS")

chem_parameters  <- c("Turbidity","TSS", "ChlA", "DOC", "DTN", "pH", "ANC","SC",
                       "Na",  "NH4", "K", "Mg",  "Ca",  "F", "Cl", "NO3", "PO4","SO4")
res_chem_long <- res_chem%>%
  pivot_longer(cols = all_of(chem_parameters), names_to = "Parameter")%>%
  filter(!is.na(value))
sites <- readRDS("data/sites_table.RDS")
#### V2


# Load your data (assuming you already have 'res_chem_long' and 'sites' loaded)

# UI
ui <- fluidPage(
  titlePanel("Time Series Plot"),
  sidebarLayout(
    sidebarPanel(
      selectInput("site", "Select Site(s):",
                  choices = unique(res_chem_long$Site),
                  multiple = TRUE),
      selectInput("parameter", "Select a Parameter:",
                  choices = unique(res_chem_long$Parameter)),
      dateRangeInput("date_range", "Select Date Range:",
                     start = min(res_chem_long$Date),
                     end = max(res_chem_long$Date)),
      downloadButton("downloadData", "Download Selected Data")
    ),
    mainPanel(
      plotOutput("time_series_plot")
    )
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    selected_sites <- input$site
    selected_parameter <- input$parameter
    
    res_chem_long %>%
      filter(Date >= start_date, Date <= end_date,
             Site %in% selected_sites, Parameter == selected_parameter)
  })
  
  output$time_series_plot <- renderPlot({
    data <- filtered_data()
    gg <- ggplot(data, aes(x = Date, y = value, color = Site)) +
      geom_line() +
      geom_point() +
      labs(x = "Date", y = "Value", color = "Site") +
      ggtitle(paste("Time Series Plot for", input$parameter)) +
      scale_color_discrete(name = "Site")
    
    print(gg)
  })
  
  # Download data as a CSV file
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("highlighted_data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      data <- filtered_data()
      write.csv(data, file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

