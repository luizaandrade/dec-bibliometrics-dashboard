
# This code is based on work available at https://github.com/RRMaximiliano/wb_citations

# Read IDs ----------------------------------------------------------------

ids <- 
  read_csv(
    here(
      "data",
      "raw",
      "decrg_staff.csv"
    )
  ) %>%
  filter(!is.na(scholar_id)) %>%
  select(scholar_id) %>%
  unique

# Get data ----------------------------------------------------------------

scholar_data <- 
  ids %>% 
  mutate(
    data = map(
      scholar_id, 
      ~ get_publications(.)
    )
  ) %>% 
  unnest(data) %>%
  mutate(
    across(
      where(is.character),
      ~ iconv(.,  to = "ASCII//TRANSLIT")
    )
  )

# Save data ---------------------------------------------------------------

write_rds(
  scholar_data,
  here(
    "data",
    "raw",
    "google_scholar.rds"
  )
)

  