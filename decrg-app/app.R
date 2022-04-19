# GLOBAL ---------------------------------------------------------------

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


papers <- 
  read_rds(here("data", "papers-and-authors.rds"))

# USER INTERFACE ------------------------------------------------------

ui <- 
  
  dashboardPage(
    skin = "black",
    freshTheme = create_theme(bs4dash_layout(sidebar_width = "350px")),

    dashboardHeader(
  
      title = dashboardBrand(
        title = "DECRG bibliometrics",
        color = "info"
      ),
      skin = "light",
      status = "white",
      border = TRUE,
      sidebarIcon = icon("bars"),
      controlbarIcon = icon("th"),
      fixed = FALSE
      
    ),
    
## Side bar -------------------------------------------------------------------- 
    
    dashboardSidebar(
      
      width = 450,
      status = "info", 
      skin = "light", 
      elevation = 5, 
              
### Menu ------------------------------------------------------------------
     
     sidebarMenu(
       menuItem("Home", tabName = "home", icon = icon("bookmark")),
       menuItem("Visualization", tabName = "viz", icon = icon("chart-bar")),
       menuItem("Data", tabName = "data", icon = icon("table"))
     ),
     
 ### Filters --------------------------------------------------------------
 
    hr(),

 #### Years -------------------------------------------------------------- 

     sliderTextInput(
       "years",
       "Period",
       choices = seq(min(papers$year_scholar, na.rm = TRUE),
                     max(papers$year_scholar, na.rm = TRUE),
                     1),
       selected = c(min(papers$year_scholar, na.rm = TRUE),
                    max(papers$year_scholar, na.rm = TRUE))
     ),

#### Unit ---------------------------------------------------------------
     

      checkboxGroupButtons(
        inputId = "unit",
        label = "Unit",
        choices = papers$unit %>% unique %>% na.omit,
        selected = papers$unit %>% unique %>% na.omit,
        individual= TRUE,
        checkIcon = list(
          yes = icon("ok",
                     lib = "glyphicon"),
          no = icon("remove",
                    lib = "glyphicon")
          )
      ),
     
#### People  ------------------------------------------------------------------
     pickerInput(
       "staff",
       label = "Staff",
       choices = list(
         `DECFP` = papers %>% filter(unit == "DECFP") %>% select(full_name) %>% unique %>% unlist %>% unname,
         `DECTI` = papers %>% filter(unit == "DECTI") %>% select(full_name) %>% unique %>% unlist %>% unname,
         `DECPI` = papers %>% filter(unit == "DECPI") %>% select(full_name) %>% unique %>% unlist %>% unname,
         `DECHD` = papers %>% filter(unit == "DECHD") %>% select(full_name) %>% unique %>% unlist %>% unname,
         `DECSI` = papers %>% filter(unit == "DECSI") %>% select(full_name) %>% unique %>% unlist %>% unname,
         `DECMG` = papers %>% filter(unit == "DECMG") %>% select(full_name) %>% unique %>% unlist %>% unname
       ),
       selected = papers %>% select(full_name) %>% unique %>% unlist %>% unname,
       multiple = TRUE,
       options = list(
         `live-search` = TRUE,
         size = 25,
         title = "Select names"
       ),
       width = "100%"
     )
    ),
    
## Body -------------------------------------------------------------------------
    
    dashboardBody(
      
      tabItems(

### Home  -----------------------------------------------------------------------
        
        tabItem(
          tabName = "home",
          
          fluidRow(
            
            box(
              width = 12, 
              status = "info", 
              collapsible = FALSE,
              solidHeader = TRUE,
              title = h2("DECRG BIBLIOMETRICS DASHBOARD"),
                    
              p("This dashboard presents information about publications about publications from authors affiliated 
                with the Development Research Group of the World Bank, including number of downloads and citations.
                The data used was collected from the World Banks' Documents and Reports page and from Google Scholar."
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
                "The data in this dashboard was obtained by scraping the internet, and is not exhaustive.
                In particular, only staff with valid Google Scholar accounts was included in the calculation of 
                citations, and downloads from SSRN and OKR are not currently taken into account.
                To have your Google Scholar page added to the dashboard sources or correct information listed, 
                please contact",
                tags$a(href = "mailto:dimeanalytics@worldbank.org", "DIME Analytics"),
                "."
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
                "This dashboard was developed by Luiza Cardoso de Andrade and 
                Rony Rodrigo Maximiliano Rodriguez-Ramirez.
                Roula Yazigi and Ryan Hahn contributed with data and background information on the publications."
              )
            )
            
          )
        ),

### Graphs ----------------------------------------------------------------------

        tabItem(
          tabName = "viz",
          
          fluidRow(
            box(
              width = 10,
              title = "Number of citations",
              plotlyOutput("citation_graph", height = "350px")
            )
          ),
            
          fluidRow(
            box(
              width = 10,
              title = "Number of downloads",
              plotlyOutput("download_graph", height = "350px")
            )
          )
        ),

### Data table ------------------------------------------------------------------        

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

# SERVER  ----------------------------------------------------------------------

server <- function(input, output, session) {
  
  
  ## Filter data -------------------------------------------------------------
  
  data <-
    reactive(
      papers %>%
          filter(
            unit %in% input$unit,
            year_scholar %in% as.numeric(input$years[1]):as.numeric(input$years[2])
          )
    )
  

  ## List only relevant staff ------------------------------------------------
  observeEvent(
    input$unit,

    {

      updatePickerInput(
        session = session,
        inputId = "staff",
        selected = data() %>%
          select(full_name) %>%
          unlist %>%
          unique %>%
          unname
      )


    }
  )

  ## Graph with number of citations -----------------------------------------
  output$citation_graph <-
    renderPlotly({
      
      graph <-
        data() %>%
        mutate(fill = ifelse(cites < 1000,
                             "less",
                             "more")) %>%
        filter(cites != 0,
               !is.na(cites)) %>%
        ggplot(
          aes(
            x = year_scholar,
            fill = fill,
            text = paste0(title, "<br>",
                          all_authors, "<br>",
                          journal, "<br>",
                          "Citations: ", cites)
          )
        ) +
        geom_col(
          aes(
            y = cites
          )
        ) +
        scale_fill_manual(values = c("less" = "gray60",
                                     "more" = "#EA4C46")) +
        labs(x = NULL,
             y = NULL) +
        theme_minimal() +
        theme(legend.position = "none",
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank()) 
      
      ggplotly(graph,
               tooltip = "text")
      
    })

  ## Graph with number of downloads --------------------------------------------
  output$download_graph <-
    renderPlotly({
      
      graph <-
        data() %>%
        mutate(
          download_count = download_count/1000,
          label = paste0(download_count, "k"),
          fill = ifelse(download_count < 10,
                             "less",
                             "more")) %>%
        filter(download_count != 0,
               !is.na(download_count)) %>%
        ggplot(
          aes(
            x = year_scholar,
            fill = fill,
            text = paste0(title, "<br>",
                          all_authors, "<br>",
                          journal, "<br>",
                          "Downloads: ", label)
          )
        ) +
        geom_col(
          aes(
            y = cites
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

  ## Browse full data ----------------------------------------------------------
  output$table <-
    renderDataTable(
      
      {
        data() %>%
          mutate(Journal = paste(journal, number)) %>%
          select(title,
                 all_authors,
                 year_scholar,
                 Journal,
                 cites,
                 download_count) %>%
          rename(
            Title = title,
            Authors = all_authors,
            Year = year_scholar,
            Citations = cites,
            Downloads = download_count
          ) %>%
          arrange(Year,
                  desc(Citations))
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

# COMPILE APP -----------------------------------
shinyApp(ui = ui, server = server)