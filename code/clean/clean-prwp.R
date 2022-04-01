library(readxl)
library(tidyverse)
library(lubridate)
library(here)

prwp <-
  read_xlsx(
    here(
      "data",
      "raw",
      "PRWP master list.xlsx"
    ),
    sheet = "1-500"
  )
  
prwp <-
  prwp %>%
  transmute(
    prwp_id = parse_number(`WPS#`),
    date = as_date(DATE),
    author = str_replace_all(AUTHOR, ",", ";"),
    title = TITLE,
    year = year(date)
  ) %>%
  filter(!is.na(id))

write_rds(
  prwp,
  here(
    "data",
    "intermediate",
    "prwp_master.rds"
  )
)
