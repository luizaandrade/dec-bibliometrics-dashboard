get_cite_history <-

function (id, article) {
  
  site <- getOption("scholar_site")
  id <- tidy_id(id)
  url_base <- paste0(site, "/citations?", "view_op=view_citation&hl=en&citation_for_view=")
  url_tail <- paste(id, article, sep = ":")
  url <- paste0(url_base, url_tail)
  res <- get_scholar_resp(url)
  
  if (is.null(res)) 
    return(NA)
  httr::stop_for_status(res, "get user id / article information")
  
  doc <- read_html(res)
  
  years <- doc %>% html_nodes(".gsc_oci_g_t") %>% html_text() %>% 
    as.numeric()
  
  vals  <- doc %>% html_nodes("#gsc_oci_graph_bars") %>% html_nodes("a")
  years <- vals %>% html_attr('href') %>% sapply(function(x) str_sub(x,-4,-1)) %>% as.numeric()
  cites <- vals %>% html_text() %>% as.numeric()
  
  df <- data.frame(year = years, cites = cites)
  if (nrow(df) > 0) {
    df <- merge(data.frame(year = min(years):max(years)), 
                df, all.x = TRUE)
    df[is.na(df)] <- 0
    df$pubid <- article
  }
  else {
    df$pubid <- vector(mode = mode(article))
  }
  return(df)

}

get_titles <-
  function (cid) {
    
    site <- getOption("scholar_site")
    
    url <- paste0(site, "/scholar?oi=bibs&hl=en&cluster=", cid)
    res <- get_scholar_resp(url)
    
    if (is.null(res)) {
      return(NA)
    }
    else {
      doc <- read_html(res)
      
      titles <- 
        doc %>% 
        html_nodes(".gs_rt") %>% 
        html_nodes("a") %>% 
        html_text()
      
      if (is_empty(titles)) {
        titles <- 
          doc %>% 
          html_nodes(".gs_rt") %>% 
          html_text() %>%
          str_remove_all("\\[CITATION\\]")%>%
          str_remove_all("\\[C\\]")
      }
      
      info <- 
        doc %>% 
        html_nodes(".gs_a") %>% 
        html_text() %>%
        as.data.frame() %>%
        separate(
          col = ".",
          sep = "-",
          into = c("author")
        ) 
      
      cites <-
        doc %>% 
        html_nodes(".gs_fl") %>% 
        html_text() %>%
        as.data.frame() %>%
        filter(
          str_detect(., "Cite")
        ) %>%
        transmute(
          cites = parse_number(.)
        )
      
      attributes(cites) <- NULL
      
      data <-
        bind_cols(
          titles, 
          info,
          cites
        )
      
      names(data) <- c("title", "author", "cites")
      
      data <-
        data %>%
        mutate(cid = cid) %>%
        mutate_all(
          ~ str_trim(.)
        )
      
    }
  }
