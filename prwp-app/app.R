library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(bs4Dash)
library(fresh)
library(DT)
library(here)
library(plotly)
library(tidyverse)

here::i_am("app.R")

prwp <- 
  read_rds(here("data", "final", "prwp_downloads.rds")) %>%
  filter(year <= 2021)


ui <- 
  
  dashboardPage(
    skin = "black",
    freshTheme = create_theme(bs4dash_layout(sidebar_width = "350px")),
    
    dashboardHeader(
      
      title = dashboardBrand(
        title = "PRWP Bibliometrics",
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
      
      tags$style(
        ".irs--shiny .irs-bar {
          border-top-color: #c2eaf1;
          border-bottom-color: #c2eaf1;
          background: #c2eaf1;
        }
        
        .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single {
          background-color: #6c757d;
        }

        " 
      ),
      
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
              title = h2("Policy Research Working Paper Series: Bibliometrics"),
              
              p("This dashboard presents information about publications from the World Bank's Policy Research
                Working Paper Series. 
                The data used was harvested from the",
                tags$a("SSRN",
                       href = "https://www.ssrn.com/"),
                "the World Bank's",
                tags$a("Open Knowledge Repository,",
                       href = "https://openknowledge.worldbank.org/"),
                "and the World Bank's",
                tags$a("Documents and Reports",
                       href = "https://documents.worldbank.org/en/publication/documents-reports"),
                "webpage.
                Only the data that was already labeled in these sources in included.
                Therefore, this data set is not exhaustive."
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
                tags$style(
                  type = "text/css", 
                  "#label {text-align: center; font-size: 16px; padding-top:5px; vertical-align: middle;}"),
                tags$div(
                  id = "label",
                  tags$b("Source: ")
                ),
                pickerInput(
                  "source",
                  label = NULL,
                  choices = c("Total downloads (SSRN, D&R, OKR)",
                              "SSRN",
                              "Documents & Reports",
                              "Open Knowledge Repository"),
                  selected = "Total downloads (SSRN, D&R, OKR)",
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
          input$source == "Total downloads (SSRN, D&R, OKR)" ~ "total_downloads",
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
        group_by(year) %>%
        mutate(
          count_year = sum(download_count, na.rm = TRUE),
          label_year = paste0(round(count_year, 1), "k")
        ) %>%
        ggplot(
          aes(
            x = year,
            fill = fill,
            label = label,
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
        geom_text(
          aes(
            y = count_year + 10,
            label = label_year
          ),
          size = 2.5,
        ) +
        scale_fill_manual(values = c("less" = "gray60",
                                     "more" = "#ecb05a")) +
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
            label = count,
            text = paste(
              "Year:", year, "<br>",
              "Papers published:", count
            )
          )
        ) +
        geom_col(fill = "#ecb05a") +
        geom_text(
          aes(
            y = count + 5
          ),
          size = 3
        ) +
        theme_minimal() +
        theme(legend.position = "none",
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank()) +
        labs(x = NULL,
             y = NULL)
      
      ggplotly(graph,
               tooltip = "text")
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