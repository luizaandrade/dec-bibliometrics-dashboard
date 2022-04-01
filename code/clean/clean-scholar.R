
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
  group_by(title) %>%
  filter(n() > 1) %>%
  arrange(title) %>%
  view

write_rds(
  scholar_paper,
  here(
    "data",
    "intermediate",
    "clean_scholar_papers.rds"
  )
)