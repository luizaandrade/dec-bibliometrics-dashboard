# Individual papers downloads and citations
paper_indicators <-
  papers %>%
  select(title,
         all_authors,
         year.y,
         download_count,
         year.x,
         journal, 
         cites) %>%
  filter(year.x >= (2021 - 5) | year.y >= (2021 - 5))%>%
  mutate(cites = ifelse(is.na(year.x) & cites == 0 | 
                          is.na(journal) & cites == 0 ,
                        NA,
                        cites)) %>%
  rename(Title = title,
         Authors = all_authors, 
         `PRWP downloads` = download_count,
         `Google scholar year` = year.x,
         `Google scholar journal` = journal,
         `Google scholar citations` = cites) %>%
  unique %>%
  arrange(`Google scholar year`,
          Title) 
           
write_csv(paper_indicators,
         here("output", "Papers.csv"))

# By author
researchers_scholar <-
  papers %>%
  group_by(upi.x) %>%
  mutate(full_name = first(full_name)) %>%
  filter(year.x >= (2021 - 5)) %>%
  group_by(year.x, upi.x) %>%
  summarise(Citations = sum(cites, na.rm = TRUE),
            full_name = first(full_name)) %>%
  rename(Year = year.x,
         UPI = upi.x)

researchers_okr <-
  papers %>%
  group_by(upi.y) %>%
  mutate(full_name = first(full_name)) %>%
  group_by(year.y, upi.y) %>%
  filter(year.y >= (2021 - 5),
         !is.na(full_name)) %>%
  summarise(`PRWP downloads` = sum(download_count, na.rm = TRUE),
            full_name = first(full_name)) %>%
  rename(Year = year.y,
         UPI = upi.y,
         Name = full_name)


researcher_indicators <-
  researchers_okr %>%
  full_join(researchers_scholar) %>%
  select(UPI, Name, Year, `PRWP downloads`, Citations) %>%
  arrange(UPI, Year)

write_csv(researcher_indicators,
          here(onedrive, "output", "Researchers.csv"))
