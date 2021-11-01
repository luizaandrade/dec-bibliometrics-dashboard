
# Set up ---------------------------------------------------------------
packages <- 
  c(
    "scholar",
    "tidyverse",
    "here",
    "fuzzyjoin"
  )

pacman::p_load(packages,
               character.only = TRUE)

# Load data ---------------------------------------------------------------

okr <-
  read_rds(here("data", "wb_clean.rds")) %>%
  filter(year >= 2000)

rg <-
  read_csv(here("data", "decrg_staff.csv"))

scholar <-
  read_csv(here("data", "citations.csv")) %>%
  rename(full_name = main,
         all_authors = author) %>%
  filter(year >= 2000)

# Process OKR data ------------------------------------------------------------

max_authors <-
  okr %>%
  mutate(n_authors = str_count(authors, ";") + 1) %>%
  summarise(max = max(n_authors)) %>%
  unlist

okr_papers <-
  okr %>%
  mutate(all_authors = authors) %>%
  separate(authors, paste0("author", 1:max_authors), sep = ";") %>%
  pivot_longer(cols = starts_with("author"),
               names_to = "no",
               values_to = "author") %>%
  filter(!is.na(author))

okr_authors <-
  okr_papers %>%
  select(author) %>%
  mutate(clean_name = 
           str_remove(author, ":") %>%
           str_replace("//[.*]", "") %>%
           str_replace("editor", "") %>%
           str_replace(":.*", "") %>%
           str_trim) %>%
  unique %>%
  mutate(first_name = str_replace(clean_name, ".*,", "") %>%
           str_trim,
         last_name = str_replace(clean_name, ",.*", "") %>%
           str_trim) %>%
  mutate(full_name = ifelse(clean_name == first_name,
                       clean_name,
                       paste(first_name, last_name))) %>%
  select(full_name, author)

rg_authors <-
  stringdist_left_join(
    rg, okr_authors, 
    by = "full_name",
    ignore_case = TRUE, 
    method = "jw", 
    max_dist = .15, 
    distance_col = "dist") %>%
  select(upi, author, full_name.x) %>%
  rename(full_name = full_name.x)

rg_okr <-
  okr_papers %>%
  filter(author %in% rg_authors$author | str_detect(origu, "DECRG")) %>%
  left_join(rg_authors) %>%
  select(upi,
         full_name,
         all_authors,
         id,
         title,
         download_count,
         year,
         contains("topic"),
         pdfurl) %>%
  rename(author = full_name,
         okr_id = id) %>%
  filter(!is.na(upi))

# Process scholar data ------------------------------------------------------------

papers <- 
  stringdist_full_join(
    scholar, rg_okr, 
    by = c("upi", "title"),
    ignore_case = TRUE, 
    method = "jw", 
    max_dist = .2, 
    distance_col = "dist") %>%
  mutate(title = coalesce(title.x, title.y),
         all_authors = coalesce(all_authors.x, all_authors.y),
         upi = coalesce(upi.x, upi.y)) %>% # Check why they differ
  rename(year_scholar = year.x,
         year_okr = year.y) %>%
  select(-contains("."))

write_rds(papers,
          here("data", "papers-and-authors.rds"))
