library(plotly)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(bs4Dash)
library(fresh)
library(here)
library(DT)

prwp_table <- 
  read_rds(
    here(
      "data",
      "prwp_table.rds"
    )
  )

prwp_year <- 
  read_rds(
    here(
      "data",
      "prwp_year.rds"
    )
  )

prwp <- 
  read_rds(
    here(
      "data",
      "prwp_downloads.rds"
    )
  )

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
        choices = seq(min(prwp_year$year, na.rm = TRUE),
                      max(prwp_year$year, na.rm = TRUE),
                      1),
        selected = c(min(prwp_year$year, na.rm = TRUE),
                     max(prwp_year$year, na.rm = TRUE))
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
              
              h4("How to use this dashboard"),
              
              p(
                "Use the icons in the sidebar to navigate through different pages. The ",
                tags$b("Visualization"),
                "page contains interactive plots with the evolution of the total number of downloads and citations
                over time hover over data points to see information about each paper. The ",
                tags$b("Data"),
                "page allows users to browse and download the data feeding into the graphs."
              ),
              
              h4("Highlights"),
              
              p(
                tags$b(
                  'Most downloaded paper of all time:'
                ),
                tags$a(
                  '"The Role of Education Quality for Economic Growth", by Eric Hanushek and Ludger Woessman',
                  href = "https://openknowledge.worldbank.org/handle/10986/7154"
                )
              ),
              
              p(
                tags$b(
                  "Most downloaded paper, adjusting for age:"
                ),
                tags$a(
                  '"Elite Capture of Foreign Aid: Evidence from Offshore Bank Accounts", by Jorgen Juel Andersen, Niels Johannesen, and Bob Rijkers',
                  href = "https://openknowledge.worldbank.org/handle/10986/33355"
                )
              )
            ),
            
            box(
              width = 12, 
              status = "secondary", 
              collapsible = TRUE,
              title = "Contributors",
              solidHeader = FALSE,
              
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
              title = "Total number of downloads for a paper",
              plotlyOutput("total_downloads", height = "600px"),
              collapsed = FALSE
            )
          ),
          
          fluidRow(
            box(
              width = 10,
              title = "Average number of downloads for a paper per year since publication",
              plotlyOutput("downloads_per_year", height = "600px"),
              collapsed = TRUE
            )
          ),
          
          fluidRow(
            box(
              width = 10,
              title = "Number of papers published by year",
              plotlyOutput("published", height = "600px"),
              collapsed = TRUE
            )
          ),
        
          fluidRow(
            box(
              width = 10,
              collapsed = TRUE,
              title = "Number of download by year of publication",
              
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
              
              plotlyOutput("downloads", height = "600px")
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

  
  downloads_reactive <-
    eventReactive(
      input$years,
      {
        prwp %>%
          filter(year %in% as.numeric(input$years[1]):as.numeric(input$years[2]))
      }
    )
  
  output$downloads <-
    renderPlotly({
      
      source <-
        case_when(
          input$source == "Total downloads (SSRN, D&R, OKR)" ~ "total_downloads",
          input$source == "SSRN" ~ "ssrn_downloads",
          input$source == "Documents & Reports" ~ "dandr_downloads",
          input$source == "Open Knowledge Repository" ~ "okr_downloads"
        ) 

      data <- 
        read_rds(
          here(
            "data",
            paste0(source, ".rds")
          )
        )
      
      graph <-
        data %>%
        filter(
          year %in% as.numeric(input$years[1]):as.numeric(input$years[2])
        ) %>%
        ggplot(
          aes(
            x = year,
            fill = fill,
            label = label_year,
            text = text
          )
        ) +
        geom_col(
          aes(
            y = downloads
          )
        ) +
        geom_text(
          aes(
            y = count_year + 10
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
        scale_y_continuous(labels = function(x) ifelse(x > 0, paste0(x, "k"), x))

      ggplotly(graph,
               tooltip = "text")
    })
  
  output$published <-
    renderPlotly({
      
      graph <-
        prwp_year %>%
        filter(
          year %in% as.numeric(input$years[1]):as.numeric(input$years[2])
        ) %>%
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
  
  output$total_downloads <-
    renderPlotly({
      
      data <-
        downloads_reactive() %>%
        mutate(
          bin = floor(total_downloads/1000),
          threshold = quantile(total_downloads, .995),
          more = total_downloads > threshold
        ) %>%
        group_by(bin) %>%
        mutate(count = n()) %>%
        ungroup %>%
        mutate(height = runif(count, 0, count)) 
      
      graph <-
        data %>%
        ggplot(
          aes(
            x = total_downloads,
            y = height,
            text = paste(
              "Title:", title, "<br>",
              "Authors:", author, "<br>",
              "Date published:", date, "<br>",
              "Total downloads:", total_downloads
            )
          )
        ) + 
        geom_jitter(
          data = 
            data %>% 
            filter(
              more
            ),
          color = "#ecb05a",
          size = 2,
          alpha = .5
        ) + 
        geom_jitter(
          data = data %>% 
            filter(
              !more
            ),
          color = "grey",
          size = .5,
          alpha = .2
        ) +
        theme_minimal() +
        labs(
          y = "Number of papers",
          x = "Total downloads"
        ) +
        scale_x_continuous(labels = function(x) ifelse(x > 0, paste0(x/1000, "k"), x)) +
        scale_y_continuous(labels = function(x) ifelse(x > 0, paste0(x/1000, "k"), x))
      
      ggplotly(graph,
               tooltip = "text")
    })
  
  output$downloads_per_year <-
    renderPlotly({
      
      data <-
        downloads_reactive() %>%
        mutate(
          bin = floor(downloads_per_year/500),
          threshold = quantile(downloads_per_year, .995),
          more = downloads_per_year > threshold
        ) %>%
        group_by(bin) %>%
        mutate(count = n()) %>%
        ungroup %>%
        mutate(height = runif(count, 0, count)) 
      
      graph <-
        data %>%
        ggplot(
          aes(
            x = downloads_per_year,
            y = height,
            text = paste(
              "Title:", title, "<br>",
              "Authors:", author, "<br>",
              "Date published:", date, "<br>",
              "Average number of downloads per year:", downloads_per_year
            )
          )
        ) + 
        geom_jitter(
          data = data %>% 
            filter(more),
          aes(
            y = 0
          ),
          color = "#ecb05a",
          size = 2,
          alpha = .5
        ) + 
        geom_jitter(
          data = data %>% 
            filter(!more),
          color = "grey",
          size = .5,
          alpha = .2
        ) +
        theme_minimal() +
        labs(
          y = "Number of papers",
          x = "Average number of downloads per year"
        ) +
        scale_x_continuous(labels = function(x) ifelse(x > 0, paste0(x/1000, "k"), x))
      
      ggplotly(graph,
               tooltip = "text")
    })

  output$table <-
    renderDataTable(
      
      server = FALSE,
      
      {
        prwp_table  %>%
          filter(
            Year %in% as.numeric(input$years[1]):as.numeric(input$years[2])
          )
      },

      rownames = FALSE,
      filter = 'top',
      extensions = 'Buttons',
      options = list(
        dom = 'Bfrtip',
        buttons = list(
          list(extend = "csv", text = "Download Current Page", filename = "page",
               exportOptions = list(
                 modifier = list(page = "current")
               )
          ),
          list(extend = "csv", text = "Download Full Data Set", filename = "data",
               exportOptions = list(
                 modifier = list(page = "all")
               )
          )
        ),
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100)
      )

    )

  
}


shinyApp(ui = ui, server = server)