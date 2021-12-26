okr <-
  read_csv(
    here(
      "data",
      "raw",
      "scrapingokr_results.csv"
    )
  )

okr <-
  okr %>%
  rename(
    okr_handle = handle,
    okr_downloads = downloads,
    okr_abstract_views = abstract_views
  ) %>%
  mutate(line_id = row_number())

tidy_okr <-
  okr %>%
  mutate(citation = citation %>%
           str_replace_all("no\\.", "no") %>%
           str_replace_all("NO\\.", "NO") %>%
           str_replace_all("No\\.", "No") %>%
           str_replace_all("Policy", "\\.Policy") %>%
           str_replace_all("Impact Evaluation", "\\.Impact Evaluation")) %>%
  select(citation) %>%
  unlist %>%
  str_split(
    "[.]",
    20,
    simplify = TRUE) %>%
  as_tibble() %>%
  mutate(line_id = row_number()) %>%
  pivot_longer(
    cols = starts_with("V")
  )

okr_prwp <-
  tidy_okr %>%
  filter(
    (str_detect(tolower(value), "policy") & str_detect(tolower(value), "research working")) |
      (str_detect(tolower(value), "policy") & str_detect(tolower(value), "research workding"))
    | str_detect(tolower(value), "wps")
  ) %>%
  mutate(
    prwp_id = parse_number(value)
  ) %>%
  select(ends_with("id"))

okr <-
  okr %>%
  left_join(okr_prwp) %>%
  select(-line_id)

okr$prwp_id[okr$okr_handle == "10986/36308"] <- 9781
okr$prwp_id[okr$okr_handle == "10986/35634"] <- 9673
okr$prwp_id[okr$okr_handle == "10986/35823"] <- 9703
okr$prwp_id[okr$okr_handle == "10986/9252"] <- 4023
okr$prwp_id[okr$okr_handle == "10986/14190"] <- 3191
okr$prwp_id[okr$okr_handle == "10986/19204"] <- 2930
okr$prwp_id[okr$okr_handle == "10986/9092"] <- 3463
okr$prwp_id[okr$okr_handle == "10986/4075"] <- 4881
okr$prwp_id[okr$okr_handle == "10986/15761"] <- 2844
okr$prwp_id[okr$okr_handle == "10986/18199"] <- 2664
okr$prwp_id[okr$okr_handle == "10986/12066"] <- 6221
okr$prwp_id[okr$okr_handle == "10986/33876"] <- 9274
okr$prwp_id[okr$okr_handle == "10986/14307"] <- 3222
okr$prwp_id[okr$okr_handle == "10986/14307"] <- 6086
okr$prwp_id[okr$okr_handle == "10986/6294"] <- 4778
okr$prwp_id[okr$okr_handle == "10986/23480"] <- 7516
okr$prwp_id[okr$okr_handle == "10986/4285"] <- 5093
okr$prwp_id[okr$okr_handle == "10986/15762"] <- 3195
okr$prwp_id[okr$okr_handle == "10986/14113"] <- 3283
okr$prwp_id[okr$okr_handle == "10986/23903"] <- 7564
okr$prwp_id[okr$okr_handle == "10986/16042"] <- 6591
okr$prwp_id[okr$okr_handle == "10986/12024"] <- 6178
okr$prwp_id[okr$okr_handle == "10986/9088"] <- 4025
okr$prwp_id[okr$okr_handle == "10986/4285"] <- 5093
okr$prwp_id[okr$okr_handle == "10986/23480"] <- 7516
okr$prwp_id[okr$okr_handle == "10986/26355"] <- 8013
okr$prwp_id[okr$okr_handle == "10986/34129"] <- 9320
okr$prwp_id[okr$okr_handle == "10986/9317"] <- 6086
okr$prwp_id[okr$okr_handle == "10986/22154"] <- 7281
okr$prwp_id[okr$okr_handle == "10986/6565"] <- 4559
okr$prwp_id[okr$okr_handle == "10986/22203"] <- 7317
okr$prwp_id[okr$okr_handle == "10986/21375"] <-2419
okr$prwp_id[okr$okr_handle == "10986/25822"] <- 7923
okr$prwp_id[okr$okr_handle == "10986/14774"] <- 3215
okr$prwp_id[okr$okr_handle == "10986/14174"] <- 3335
okr$prwp_id[okr$okr_handle == "10986/6041"] <- 6039
okr$prwp_id[okr$okr_handle == "10986/3717"] <-	5227
okr$prwp_id[okr$okr_handle == "10986/4003"] <-	NA
okr$prwp_id[okr$okr_handle == "10986/3260"] <-	NA
okr$prwp_id[okr$okr_handle == "10986/9331"] <-	6078
okr$prwp_id[okr$okr_handle == "10986/9340"] <-	6082
okr$prwp_id[okr$okr_handle == "10986/14307"] <-	3222
okr$prwp_id[okr$okr_handle == "10986/9325"] <-	6105
okr$prwp_id[okr$okr_handle == "10986/12153"] <-	6330
okr$prwp_id[okr$okr_handle == "10986/16324"] <-	6427
okr$prwp_id[okr$okr_handle == "10986/15603"] <-	6465
okr$prwp_id[okr$okr_handle == "10986/17340"] <-	6784
okr$prwp_id[okr$okr_handle == "10986/18822"] <-	6231
okr$prwp_id[okr$okr_handle == "10986/20700"] <-	7130
okr$prwp_id[okr$okr_handle == "10986/24655"] <-	7738
okr$prwp_id[okr$okr_handle == "10986/28912"] <-	8251
okr$prwp_id[okr$okr_handle == "10986/34939"] <- 9495


okr <-
  okr %>% 
  unique 

write_rds(
  okr,
  here(
    "data",
    "intermediate",
    "clean_okr.rds"
  )
)