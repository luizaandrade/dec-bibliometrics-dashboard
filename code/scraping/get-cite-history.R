library(tidyverse)
library(scholar)
library(fedmatch)
library(stringdist)
library(here)
library(rvest)

# Inputs -----------------------------------------------------------------------

id <- "fcQenm4AAAAJ"


# Get scholar data -------------------------------------------------------------

publications <- get_publications(id)

citations_history <-
  map(
    publications$pubid, 
    ~ get_cite_history(id, .)
  ) %>%
  bind_rows %>%
  arrange(year) %>%
  pivot_wider(
    values_from = cites,
    names_from = year,
    names_prefix = "cites"
  ) %>%
  right_join(
    publications
  )

# Merge with list of prwp papers -----------------------------------------------

prwp <- 
  read_rds(
    here(
      "data",
      "intermediate",
      "prwp_master.rds"
    )
  ) %>% 
  filter(
    str_detect(author, "Aart"),
    str_detect(author, "Kraay")
  )

# merge_plus(
#   data1 = prwp,
#   data2 = publications,
#   by.x = "title",
#   by.y = "title",
#   match_type = "fuzzy",
#   unique_key_1 = "prwp_id",
#   unique_key_2 = "pubid",
#   fuzzy_settings = build_fuzzy_settings(maxDist = .15)
# )$matches %>%
#   mutate(
#     score = stringsim(title_1, title_2)
#   ) %>%
#   rename(title = title_1) %>%
#   right_join(prwp) %>%
#   write_csv(
#     here(
#       "data",
#       "intermediate",
#       paste0(id, "_merge.csv")
#     ),
#     na = ""
#   )

ids <-
  read_csv(
    here(
      "data",
      "intermediate",
      paste0(id, "_merge.csv")
    )
  )

prwp <-
  ids %>%
  select(
    pubid,
    prwp_id
  ) %>%
  full_join(
    prwp
  ) %>%
  left_join(
    citations_history %>%
      select(
        cites,
        pubid,
        journal,
        number,
        cid,
        starts_with("cites")
      ),
    by = "pubid"
  )

write_csv(
  prwp,
  here(
    "data",
    "final",
    paste0(id, "_citations.csv")
  ),
  na = ""
)
