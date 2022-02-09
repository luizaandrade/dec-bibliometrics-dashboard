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

# Cleaning ---------------------------------------------------------------------

source(here("code", "clean", "clean-dandr.R"))
source(here("code", "clean", "clean-okr.R"))
source(here("code", "clean", "clean-prwp.R"))
source(here("code", "clean", "clean-scholar.R"))
source(here("code", "clean", "clean-ssrn.R"))

# Merging ----------------------------------------------------------------------

source(here("code", "merge", "merge-pwrp.R"))

# Construction -----------------------------------------------------------------

source(
  here(
    "code",
    "construct",
    "prepare-prwp-app-data.R"
  )
)
