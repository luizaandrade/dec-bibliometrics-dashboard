
scholar <-
  read_rds(
    here(
      "data",
      "raw",
      "google_scholar.rds"
    )
  ) %>%
  select(-c(pubid, cid))

scholar_paper <-
  scholar %>%
  group_by(title, author, journal, number, year, cites) %>%
  nest() %>%
  ungroup

scholar_paper %>%
  filter(duplicated(title)) %>%
  arrange(title) %>%
  view
