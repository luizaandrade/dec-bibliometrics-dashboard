
prwp <- 
  read_rds(here("data", "final", "prwp_downloads.rds")) %>%
  filter(year <= 2021)

simplify_downloads <-
  function(x) {
    oi<-
    prwp %>%
      mutate(download_count = get(x)) %>%
      filter(
        download_count != 0,
        !is.na(download_count)
      ) %>%
      mutate(
        downloads = download_count/1000,
        fill = ifelse(downloads < 25,
                      "less",
                      "more"),
        text = paste0(title, "<br>",
                      author, "<br>",
                      "Downloads: ", round(downloads, 1), "k")
      ) %>%
      group_by(year) %>%
      mutate(
        count_year = sum(downloads, na.rm = TRUE),
        label_year = paste0(round(count_year, 1), "k")
      ) %>%
      select(year, downloads, fill, text, count_year, label_year) %>%
      write_rds(
        here(
          "prwp-app",
          "data",
          paste0(x, ".rds")
        )
      )
  }


simplify_downloads("total_downloads")
simplify_downloads("okr_downloads")
simplify_downloads("ssrn_downloads")
simplify_downloads("dandr_downloads")

prwp <-
  prwp %>%
  mutate(
    age = 2022 - year,
    downloads_per_year = round(total_downloads/age, 1),
    total_downloads_bin = floor(total_downloads/2000),
    downloads_per_year_bin = floor(downloads_per_year/500),
    downloads_per_year_more = downloads_per_year > 5000,
    total_downloads_more = total_downloads > 25000
    ) %>%
  group_by(total_downloads_bin) %>%
  mutate(count = n()) %>%
  ungroup %>%
  mutate(total_downloads_height = runif(count, 0, count)) %>%
  group_by(downloads_per_year_bin) %>%
  mutate(count = n()) %>%
  ungroup %>%
  mutate(downloads_per_year_height = runif(count, 0, count))
         
write_rds(
  prwp,
 here(
   "prwp-app",
   "data",
   "prwp_downloads.rds"
 )
)

prwp_table <-
  prwp %>%
  transmute(
    Title = title,
    Authors = author,
    `Date published` = date,
    Year = year,
    `WPS#` = prwp_id,
    `Total downloads` = total_downloads,
    `Average number of downloads per year` = downloads_per_year,
    `Downloads from SSRN` = ssrn_downloads,
    `Downloads from OKR` = okr_downloads,
    `Abstract views in OKR` = okr_abstract_views,
    `Downloads from D&R` = dandr_downloads
  ) %>%
  arrange(`WPS#`)

write_rds(
  prwp_table,
  here(
    "prwp-app",
    "data",
    "prwp_table.rds"
  )
)

prwp_year <-
  prwp %>%
  group_by(year) %>%
  summarise(count = n_distinct(prwp_id))

write_rds(
  prwp_year,
  here(
    "prwp-app",
    "data",
    "prwp_year.rds"
  )
)