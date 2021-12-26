prwp <-
  read_rds(
    here(
      "data",
      "intermediate",
      "prwp_master.rds"
    )
  )


n_prwp <- nrow(prwp)

# Merge SSRN donwloads ---------------------------------------------------------

ssrn_papers <- 
  read_rds(here("data",
                "intermediate",
                "ssrn_papers.rds")) %>%
  filter(!is.na(prwp_id),
         str_detect(reference, "World Bank")) %>%
  group_by(prwp_id) %>%
  summarise(
    ssrn_downloads = sum(ssrn_downloads, na.rm = TRUE),
    ssrn_id = paste(ssrn_id, collapse = "; ")
  )

prwp <-
  prwp %>%
  left_join(ssrn_papers, by = "prwp_id") 

assert_that(nrow(prwp) == n_prwp)

# Merge OKR downloads ----------------------------------------------------------

okr <- 
  read_rds(here("data",
                "intermediate",
                "clean_okr.rds")) %>%
  select(okr_handle, okr_abstract_views, okr_downloads, prwp_id) %>%
  filter(!is.na(prwp_id)) %>%
  group_by(prwp_id) %>%
  summarise(
    across(
      c(okr_downloads, okr_abstract_views),
      ~ sum(., na.rm = TRUE)
    ),
    okr_handle = paste(okr_handle, collapse = "; ")
  )



prwp <-
  prwp %>%
  left_join(okr, by = "prwp_id")

assert_that(nrow(prwp) == n_prwp)

# Merge D&R downloads ----------------------------------------------------------

dandr <-
  read_rds(
    here(
      "data",
      "intermediate",
      "clean_dandr.rds"
    )
  ) %>%
  filter(!(prwp_id == 7245 & title == "Dataset")) %>%
  group_by(prwp_id) %>%
  summarise(dandr_downloads = sum(d_and_r_downloads, na.rm = TRUE))

prwp <-
  prwp %>%
  left_join(dandr, by = "prwp_id")

assert_that(nrow(prwp) == n_prwp)


# Merge scholar citations ------------------------------------------------------
# 
# scholar <- 
#   read_rds(here("data",
#                 "intermediate",
#                 "clean_scholar_papers.rds")) %>%
#   filter(str_detect(tolower(journal), "policy research working")) %>%
#   group_by(title) %>%
#   summarise(title = title %>% na.omit %>% first,
#             author = author %>% na.omit %>% first,
#             year = year %>% na.omit %>% first,
#             cites = sum(cites, na.rm = TRUE))
# 
# 

# Calculate total downloads ----------------------------------------------------

prwp <- 
  prwp %>%
  rowwise %>%
  mutate(
    total_downloads = sum(ssrn_downloads,
                          okr_downloads,
                          dandr_downloads,
                          na.rm = TRUE)
  )

# Save dataset -----------------------------------------------------------------

write_rds(
  prwp,
  here(
    "data",
    "final",
    "prwp_downloads.rds"
  )
)

write_csv(
  prwp,
  here(
    "data",
    "final",
    "prwp_downloads.csv"
  )
)

