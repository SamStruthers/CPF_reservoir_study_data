
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




res_chem <- readRDS("tidyResChem.RDS")

chem_units <- read_xlsx(path = "Units_Cam_Peak.xlsx")%>%
select(param_name = simple, param_units = Units , combined )

chem_parameters  <- c("Turbidity","TSS", "ChlA", "DOC", "DTN", "pH", "ANC","SC",
                       "Na",  "NH4", "K", "Mg",  "Ca",  "F", "Cl", "NO3", "PO4","SO4")
res_chem_long <- res_chem%>%
  pivot_longer(cols = all_of(chem_parameters), names_to = "Parameter")%>%
  filter(!is.na(value))
sites <- readRDS("sites_table.RDS")


####----- UI------ ####
ui <- fluidPage(
  tags$head(
    tags$style(
      HTML("
        .landing-page {
          text-align: center;
          padding: 20px;
        }
        .landing-title {
          font-size: 24px;
          font-weight: bold;
          margin-top: 20px;
        }
        .project-overview {
          font-size: 18px;
          margin-top: 20px;
        }
      ")
    )
  ),
  div(
    class = "landing-page",
    h1(
      class = "landing-title",
      "CPF ROSS Data"
    ),
    p(
      class = "project-overview",
      "Data Available: https://zenodo.org/record/8308733"
    )
  ),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("site", "Select Site(s):",
                     choices = unique(res_chem_long$Site),
                     multiple = TRUE,
                     options = list(
                       placeholder = 'Choose sites...',
                       optgroups = list(
                         Watersheds = c('Site1', 'Site2'),
                         AnotherWatershed = c('Site3', 'Site4')
                       )
                     )
      ),
      selectInput("parameter", "Select Parameter(s):",
                  choices = unique(res_chem_long$Parameter),
                  multiple = TRUE),  
      dateRangeInput("date_range", "Select Date Range:",
                     start = min(res_chem_long$Date),
                     end = max(res_chem_long$Date)),
      downloadButton("downloadData", "Download Highlighted Data")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Individual Parameters", plotOutput("time_series_plot")),
        tabPanel("Multiple Parameters", plotOutput("multiple_parameters_plot"))
      )
    )
  )
)

##### ------SERVER----------####

server <- function(input, output) {
  filtered_data <- reactive({
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    selected_sites <- input$site
    selected_parameters <- input$parameter
    
    res_chem_long %>%
      filter(Date >= start_date, Date <= end_date,
             Site %in% selected_sites,
             Parameter %in% selected_parameters)
  })
  
  output$time_series_plot <- renderPlot({
    data <- filtered_data()
    selected_parameter <- input$parameter[1]  # For individual plot, take the first selected parameter
    unit <- chem_units %>%
      filter(param_name == selected_parameter) %>%
      pull(combined)
    
    gg <- ggplot(data, aes(x = Date, y = value, color = Site)) +
      geom_line() +
      geom_point() +
      labs(x = "Date", y = unit, color = "Site") +
      ggtitle(paste("Time Series Plot for", selected_parameter)) +
      scale_color_discrete(name = "Site")
    
    print(gg)
  })
  
  output$multiple_parameters_plot <- renderPlot({
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    selected_sites <- input$site
    selected_parameters <- input$parameter
    unit_list <- chem_units %>%
      filter(param_name %in% selected_parameters) %>%
      select(param_name, param_units, combined)
    
    data <- res_chem_long %>%
      filter(Date >= start_date, Date <= end_date,
             Site %in% selected_sites,
             Parameter %in% selected_parameters)
    
    gg <- ggplot(data, aes(x = Date, y = value, color = Site)) +
      geom_line() +
      geom_point() +
      facet_wrap(~Parameter, scales = "free_y", ncol = 2, labeller = labeller(Parameter = function(label) {
        unit <- unit_list %>%
          filter(param_name == label) %>%
          pull(combined)
        ylab(paste("Value (", unit, ")"))
        paste(unit)
      })) +
      labs(x = "Date", color = "Site") +
      scale_color_discrete(name = "Site")
    
    print(gg)
  })
  
  

  
  # Download data as a CSV file
  output$downloadData <- downloadHandler(
    filename = function() {
      start_date <- input$date_range[1]
      end_date <- input$date_range[2]
      selected_sites <- input$site
      selected_parameters <- input$parameter
      
      paste0(selected_sites, "_", selected_parameters, "_", start_date, "_", end_date, "_downloaded_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- filtered_data() %>%
        mutate(data_doi = "10.5281/zenodo.8308733")
      write_csv(data, file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

