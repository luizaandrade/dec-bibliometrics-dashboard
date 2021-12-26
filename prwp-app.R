library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(bs4Dash)
library(fresh)
require(DT)
require(here)
require(plotly)
require(tidyverse)


prwp <- 
  read_rds(here("data", "final", "prwp_downloads.rds")) %>%
  filter(year <= 2021)


ui <- 
  
  dashboardPage(
    skin = "black",
    freshTheme = create_theme(bs4dash_layout(sidebar_width = "350px")),
    
    dashboardHeader(
      
      title = dashboardBrand(
        title = "Policy Research Working Paper Series: Bibliometrics",
        color = "info"
      ),
      skin = "light",
      status = "white",
      border = TRUE,
      sidebarIcon = icon("bars"),
      controlbarIcon = icon("th"),
      fixed = FALSE
      
    ),
    
    # Side bar -------------------------------------------------------------------- 
    
    dashboardSidebar(
      
      width = 450,
      status = "info", 
      skin = "light", 
      elevation = 5, 
      
      ## Menu ------------------------------------------------------------------
      
      sidebarMenu(
        menuItem("Home", tabName = "home", icon = icon("bookmark")),
        menuItem("Visualization", tabName = "viz", icon = icon("chart-bar")),
        menuItem("Data", tabName = "data", icon = icon("table"))
      ),
      
      ## Filters --------------------------------------------------------------
      
      hr(),
      
      ### Years -------------------------------------------------------------- 
      
      sliderTextInput(
        "years",
        "Period",
        choices = seq(min(prwp$year, na.rm = TRUE),
                      max(prwp$year, na.rm = TRUE),
                      1),
        selected = c(min(prwp$year, na.rm = TRUE),
                     max(prwp$year, na.rm = TRUE))
      )
    ),
    
    # Body -------------------------------------------------------------------------
    
    dashboardBody(
      
      tabItems(
        
        ## Home  -----------------------------------------------------------------------
        
        tabItem(
          tabName = "home",
          
          fluidRow(
            
            box(
              width = 12, 
              status = "info", 
              collapsible = FALSE,
              solidHeader = TRUE,
              title = h2("POLICY RESEARCH WORKING PAPER BIBLIOMETRICS DASHBOARD"),
              
              p("This dashboard presents information about publications from the World Bank's Policy Research
                Working Paper Series. 
                The data used was harvested from the SSRN, the World Bank's Open Knowledge Repository,
                and the World Bank's Documents and Reports webpage.
                Only the data that was already labeled in these sources in included, and the data set may be
                incomplete."
              ),
              
              h3("How to use this dashboard"),
              
              p(
                "Use the icons in the sidebar to navigate through different pages. The ",
                tags$b("Visualization"),
                "page contains interactive plots with the evolution of the total number of downloads and citations
                over time. The ",
                tags$b("Data"),
                "page allows users to browse and download the data feeding into the graphs."
              )
            ),
            
            box(
              width = 12, 
              status = "warning", 
              collapsible = TRUE,
              title = "Disclaimer",
              solidHeader = TRUE,
              
              p(
                "The data in this dashboard was obtained by scraping the internet, and is not exhaustive."
              )
            ),
            
            box(
              width = 12, 
              status = "secondary", 
              collapsible = TRUE,
              collapsed = TRUE,
              title = "Contributors",
              solidHeader = TRUE,
              
              p(
                "This dashboard was developed by Luiza Cardoso de Andrade. 
                Rony Rodrigo Maximiliano Rodriguez-Ramirez and Leonardo Viotti contributed with webscraping code.
                Roula Yazigi and Ryan Hahn contributed with data and background information on the publications."
              )
            )
            
          )
        ),
        
        ## Graphs ----------------------------------------------------------------------
        
        tabItem(
          tabName = "viz",
          
          fluidRow(
            box(
              width = 10,
              title = "Papers published",
              plotlyOutput("published", height = "700px"),
              collapsed = TRUE
            )
          ),
          
          fluidRow(
            box(
              width = 10,
              title = "Downloads",
              
              fluidRow(
                tags$b("Source: "),
                pickerInput(
                  "source",
                  label = NULL,
                  choices = c("Total downloads",
                              "SSRN",
                              "Documents & Reports",
                              "Open Knowledge Repository"),
                  selected = "Total downloads",
                  width = "80%",
                  inline = TRUE
                )
                
              ),
              
              plotlyOutput("downloads", height = "700px")
            )
          )
        ),
        
        ## Data table ------------------------------------------------------------------        
        
        tabItem(
          
          tabName = "data",
          
          fluidRow(
            box(
              title = "Browse data",
              collapsible = FALSE,
              width = 12,
              dataTableOutput('table')
            )
          )
          
        )
      )
      
    )
  )


server <- function(input, output, session) {
  
  
  
  data <-
    reactive(
      prwp %>%
        filter(
          year %in% as.numeric(input$years[1]):as.numeric(input$years[2])
        )
    )
  
  output$downloads <-
    renderPlotly({
      
      var <-
        case_when(
          input$source == "Total downloads" ~ "total_downloads",
          input$source == "SSRN" ~ "ssrn_downloads",
          input$source == "Documents & Reports" ~ "dandr_downloads",
          input$source == "Open Knowledge Repository" ~ "okr_downloads"
        ) 

      graph <-
        data() %>%
        mutate(
          download_count = get(var)/1000,
          label = paste0(round(download_count, 1), "k"),
          fill = ifelse(download_count < 10,
                        "less",
                        "more")) %>%
        filter(download_count != 0,
               !is.na(download_count)) %>%
        ggplot(
          aes(
            x = year,
            fill = fill,
            text = paste0(title, "<br>",
                          author, "<br>",
                          input$source, " downloads: ", label)
          )
        ) +
        geom_col(
          aes(
            y = download_count
          )
        ) +
        scale_fill_manual(values = c("less" = "gray60",
                                     "more" = "orange")) +
        theme_minimal() +
        theme(legend.position = "none",
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank()) +
        labs(x = NULL,
             y = NULL) +
        scale_y_continuous(labels = function(x) paste0(x, "k"))

      ggplotly(graph,
               tooltip = "text")
    })
  
  output$published <-
    renderPlotly({
      
      graph <-
        data() %>%
        group_by(year) %>%
        summarise(count = n_distinct(prwp_id)) %>%
        ggplot(
          aes(
            x = year,
            y = count,
            label = count
          )
        ) +
        geom_col() +
        geom_text() +
        theme_minimal() +
        theme(legend.position = "none",
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank()) +
        labs(x = NULL,
             y = NULL)
      
      ggplotly(graph,
               tooltip = NULL)
    })

  output$table <-
    renderDataTable(

      {
        data() %>%
          transmute(
            Title = title,
            Authors = author,
            `Date published` = date,
            Year = year,
            `WPS#` = prwp_id,
            `Total downloads` = total_downloads,
            `Downloads from SSRN` = ssrn_downloads,
            `SSRN ID` = ssrn_id,
            `Downloads from OKR` = okr_downloads,
            `Abstract views in OKR` = okr_abstract_views,
            `OKR handle` = okr_handle,
            `Downloads from D&R` = dandr_downloads
          ) %>%
          arrange(`WPS#`)
      },

      rownames = FALSE,
      filter = 'top',
      extensions = 'Buttons',
      options = list(
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf'),
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100)
      )

    )

  
}


shinyApp(ui = ui, server = server)