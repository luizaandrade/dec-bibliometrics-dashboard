
rg_staff <-
  read_csv(
    here(
      "data",
      "raw",
      "decrg_staff.csv"
    )
  )


ssrn_authors <-
  read_rds(
    here(
      "data",
      "intermediate",
      "ssrn_authors.rds"
    )
  ) %>%
  select(
    full_name,
    ssrn_author_id,
  ) %>%
  unique
          

rg_staff <-
  stringdist_left_join(
    rg_staff, 
    ssrn_authors, 
    by = "full_name",
    ignore_case = TRUE, 
    method = "jw", 
    max_dist = .15, 
    distance_col = "dist"
  )

write_csv(
  rg_staff,
  here(
    "data",
    "intermediate",
    "decrg_staff.csv"
  )
)
