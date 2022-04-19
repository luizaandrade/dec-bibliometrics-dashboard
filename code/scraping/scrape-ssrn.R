packages <-
  c("jsonlite",
    "tidyverse",
    "here")

pacman::p_load(
  packages,
  character.only	= TRUE
)

first_page <- fromJSON("https://api.ssrn.com/content/v1/journals/547001/papers")
n_papers <- first_page$total
n_pages <- floor(n_papers/200)

for (i in 0:n_pages) {
  index <- i * 200
  link <- paste0("https://api.ssrn.com/content/v1/journals/547001/papers?index=", index, "&count=200&sort=0")
  new_papers <- fromJSON(link)$papers
  
  if (i == 0) {
    all_papers <- new_papers
  } else {
    all_papers <-
      all_papers %>%
      bind_rows(new_papers)
  }
}

write_rds(
  all_papers,
  here(
    "data",
    "raw",
    "ssrn.rds"
  )
)
