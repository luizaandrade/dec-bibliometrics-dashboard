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
