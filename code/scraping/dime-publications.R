library(tidyverse)
library(scholar)
library(here)

dime_ids <-
  read_csv(
    here(
      "data",
      "raw",
      "dime_staff.csv"
    )
  )

publications <-
  dime_ids %>%
  select(scholar_id) %>%
  apply(1, get_publications) %>%
  bind_rows()

publications_recent <-
  publications %>%
  filter(year >= 2018)

write_csv(
  publications_recent,
  here(
    "data",
    "final",
    "dime_recent_publications.csv"
  )
)
