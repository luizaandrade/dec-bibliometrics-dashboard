

library(httr)
library(here)
library(tidyverse)


files <- list.files(path = "C:/Users/wb501238/Downloads", pattern = ".xlsx")

data <-
  lapply(
    files,
    FUN = function(x) read_xlsx(file.path("C:/Users/wb501238/Downloads", x))
  )

data <- bind_rows(data)

write_rds(
  data,
  here(
    "data",
    "raw",
    "dandr.rds"
  )
)


dandr <-
  read_rds(
    here(
      "data",
      "raw",
      "dandr.rds"
    )
  )


get_downloads <-
  function(x) {
    url <- 
      paste0("https://pubdocdata.worldbank.org/PubDataSourceAPI/DownloadStatsMonth?&SortBy=&Guid=", x, "&Year=ALL")
    
    req <- GET(url)
    
    i <- sample(1:10, 1)
    print(i)
    
    return(req)
    
  }

req <-
  lapply(
    dandr$`Digital Object Identifier`,
    get_downloads
  )
  