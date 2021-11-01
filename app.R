require(shiny)
require(shinythemes)
library(shinyWidgets)
require(DT)
require(here)
require(plotly)
require(tidyverse)


papers <- 
  read_rds(here("data", "papers-and-authors.rds"))


ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      
      width = 2,
      
      sliderTextInput(
        "years", 
        "Period",
        choices = seq(min(papers$year_scholar, na.rm = TRUE),
                      max(papers$year_scholar, na.rm = TRUE),
                      1),
        selected = c(min(papers$year_scholar, na.rm = TRUE),
                     max(papers$year_scholar, na.rm = TRUE))
      ),
      
      checkboxGroupButtons(
        "unit",
        "Unit",
        choices = papers$unit %>% unique %>% na.omit,
        selected = papers$unit %>% unique %>% na.omit,
        status = "primary",
        individual = TRUE,
        checkIcon = list(
          yes = icon("ok",
                     lib = "glyphicon"),
          no = icon("remove",
                    lib = "glyphicon"))
      ),
      
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
    
    mainPanel(
      width = 9,
      
      fluidRow(
                column(
                  width = 6,
                  plotlyOutput("citation_graph")
                ),
                column(
                  width = 6,
                  plotlyOutput("download_graph")
                )
              ),
              
              fluidRow(
                dataTableOutput('table')
              )
    )
  )
  
)

server <- function(input, output, session) {
  
  
  
  data <-
    reactive(
      papers %>%
          filter(
            unit %in% input$unit,
            year_scholar %in% as.numeric(input$years[1]):as.numeric(input$years[2])
          )
    )
  

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

  output$citation_graph <-
    renderPlotly({
      
      data <-
        data() %>%
        group_by(year_scholar) %>%
        mutate(year_id = order(title),
               total_cites = sum(cites),
               year_scholar = as.factor(year_scholar)) %>%
        arrange(year_scholar) %>%
        mutate(end = cumsum(cites),
               start = end - cites) %>%
        filter(cites != 0,
               !is.na(cites))
      
      graph <-
        ggplot(data,
               aes(x = year_scholar,
                   y = start,
                   yend = end,
                   xend = year_scholar,
                   label = total_cites,
                   text = paste0(title, "<br>",
                                 all_authors, "<br>",
                                 journal, "<br>",
                                 "Citations: ", cites)
        )) +
        geom_segment(
          data = data %>% filter(cites < 1000),
          aes(color = year_id),
          size = 5, 
          lineend = "butt"
        ) +
        geom_segment(
          data = data %>% filter(cites >= 1000),
          aes(alpha = title),
          size = 5, 
          lineend = "butt",
          color = "red"
        ) +
        geom_text(aes(y = total_cites + 1000),
                  size = 2.5) +
        scale_color_gradient(low = "gray30",
                             high = " gray90") +
        labs(x = NULL,
             y = NULL,
             title = "Number of citations") +
        theme_minimal() +
        theme(legend.position = "none",
              axis.text = element_text(size = 8),
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank()) 
      
      ggplotly(graph,
               tooltip = "text")
    })

  output$download_graph <-
    renderPlotly({

      data <-
        data() %>%
        group_by(year_scholar) %>%
        mutate(year_id = order(title),
               download_count = download_count/1000,
               total_downloads = sum(download_count, na.rm = TRUE),
               year_scholar = as.factor(year_scholar)) %>%
        arrange(year_scholar) %>%
        mutate(end = cumsum(download_count),
               start = end - download_count) %>%
        filter(download_count != 0,
               !is.na(download_count))

      graph <-
        ggplot(data,
               aes(y = start,
                   yend = end,
                   x = year_scholar,
                   xend = year_scholar,
                   label = round(total_downloads, 1) %>% paste0("k"),
                   text = paste0(title, "<br>",
                                 all_authors, "<br>",
                                 journal, "<br>",
                                 "Downloads: ", download_count)
               )) +
        geom_segment(
          aes(color = year_id),
          data = data %>% filter(download_count < 10),
          size = 5,
          lineend = "butt"
        ) +
        geom_segment(
          data = data %>% filter(download_count >= 10),
          aes(alpha = title),
          size = 5,
          lineend = "butt",
          color = "orange"
        ) +
        geom_text(aes(y = total_downloads + 10),
                  size = 2.5) +
        scale_color_gradient(low = "gray30",
                             high = " gray90") +
        labs(x = NULL,
             y = NULL,
             title = "Number of downloads") +
        scale_y_continuous(labels = function(x) paste0(x, "k")) +
        theme_minimal() +
        theme(legend.position = "none",
              panel.grid.minor.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.y = element_blank())

      ggplotly(graph,
               tooltip = "text")
    })

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
      options = list(
        pageLength = 7,
        lengthMenu = c(5, 10, 25, 50, 100)
      )
      
    )
  
  
}


shinyApp(ui = ui, server = server)