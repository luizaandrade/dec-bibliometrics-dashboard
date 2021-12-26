packages <-
  c(
    "here",
    "tidyverse",
    "fuzzyjoin",
    "scholar",
    "assertthat",
    "readxl",
    "curl",
    "rvest",
    "xlsx"
  )

pacman::p_load(
  packages,
  character.only = TRUE
)
