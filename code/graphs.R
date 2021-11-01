
# Set up ---------------------------------------------------------------
packages <- 
  c(
    "tidyverse",
    "here",
    "plotly"
  )

pacman::p_load(packages,
               character.only = TRUE)

papers <- 
  read_rds(here("data", "papers-and-authors.rds"))

data <-
papers %>%
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
data %>%
  ggplot(aes(x = year_scholar,
         y = total_cites,
         label = total_cites,
         text = paste0(title, "<br>",
                       all_authors, "<br>",
                       journal, "<br>",
                       "Citations: ", cites)
         )) +
  geom_segment(
    data = data %>% filter(cites < 1000),
    aes(y = start,
                   yend = end,
                   xend = year_scholar,
                   color = year_id),
      size = 10, 
    lineend = "butt"
  ) +
  geom_segment(
    data = data %>% filter(cites >= 1000),
    aes(y = start,
        yend = end,
        xend = year_scholar,
        alpha = title),
    size = 10, 
    lineend = "butt",
    color = "red"
  ) +
  geom_text(aes(y = total_cites,
                label = total_cites),
            size = 2.5) +
  scale_color_gradient(low = "gray30",
                       high = " gray90") +
  labs(x = "Year of publication",
       y = "Number of citations") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.text.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank()) 

ggplotly(graph,
         tooltip = "text") %>%
  style(
    segment.line.width = 0
  )
