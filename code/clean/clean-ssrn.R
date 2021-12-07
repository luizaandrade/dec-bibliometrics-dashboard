
ssrn <- 
  read_rds(
    here("data",
         "raw",
         "ssrn.rds")
  ) %>%
  unique

max_ref <-
  ssrn %>%
  mutate(
    n_comma = str_count(reference, ","),
    n_semicolon = str_count(reference, ";")
  ) %>%
  rowwise() %>%
  mutate(
    n_refs = sum(n_comma, n_semicolon, na.rm = TRUE) + 1
  ) %>%
  ungroup() %>%
  summarise(
    max = max(n_refs)
  ) %>%
  unlist
  
prwp_id <-
  ssrn %>%
  select(id, reference) %>%
  mutate(reference = str_replace_all(reference, ", No.", "No")) %>%
  separate(reference,
           into = paste0(rep("ref_"), 1:max_ref), 
           sep = "[,;]") %>%
  pivot_longer(cols = starts_with("ref_"),
               values_to = "reference") %>%
  filter(str_detect(reference, "World Bank Policy Research")) %>%
  mutate(prwp_id = 
           reference %>%
           str_remove_all("[.]") %>%
           parse_number()) %>%
  select(id, prwp_id) %>%
  unique

ssrn_papers <-
  ssrn %>%
  select(
    reference,
    title,
    id,
    downloads,
    url
  ) %>%
  left_join(prwp_id) %>%
  rename(ssrn_id = id,
         ssrn_downalods = downloads,
         ssrn_url = url)

ssrn_authors <-
  ssrn %>%
  select(id, authors) %>% 
  rename(ssrn_id = id) %>%
  unnest(cols = c(authors)) %>%
  rename(ssrn_author_id = id) %>%
  mutate(full_name = paste(first_name, last_name))


write_rds(ssrn_papers,
          here("data",
               "intermediate",
               "ssrn_papers.rds"))

write_csv(ssrn_papers,
          here("data",
               "intermediate",
               "ssrn_papers.csv"))

write_rds(ssrn_authors,
          here("data",
               "intermediate",
               "ssrn_authors.rds"))
