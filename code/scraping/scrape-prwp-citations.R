prwp <-
  read_rds(
    here(
      "data",
      "intermediate",
      "prwp_master.rds"
    )
  )

prwp <-
  prwp %>%
  mutate(
    url = 
     paste0(
       "https://scholar.google.com/scholar_lookup?title=",
       str_replace_all(title, " ", "%20")
     )
  )

get_cites <-
  function (x) {
    
    print(x)
    
    curl <-
      prwp[x, "url"] %>%
      unlist %>%
      curl(handle = new_handle("useragent" = "PRWP Google Scholar Scraping"))
    
    element <-
      curl %>%
      read_html %>%
      html_nodes(xpath = '//*[@id="gs_res_ccl_mid"]/div/div/div[3]/a[3]') %>%
      html_text
    
    print(element)
    
    if (is_empty(element)) {
      citations <- NA
    } else if (element == "Artigos relacionados") {
      citations <- 0
    } else {
      citations <- parse_number(element)
    }
    
    if (length(citations) > 1) {
      citations <- sum(citations, na.rm = TRUE)
    }
    
    print(citations)
    
    wait <- runif(1, min = 0, max = 10)
    Sys.sleep(wait)
    
    df <-
      data.frame(
        "prwp_id" = prwp[x, "prwp_id"],
        "scholar_citations" = citations
      )
    
    return(df)
  }

citations_df <-
  map(c(1:73), get_cites)
