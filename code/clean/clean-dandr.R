dandr <-
  read_xlsx(
    here(
      "data",
      "raw",
      "Documents and Reports data.xlsx"
    )
  )

dandr <-
  dandr %>%
  transmute(prwp_id = parse_number(REP_NO),
            d_and_r_downloads = TOTAL_DOWNLOADS,
            title = DOC_NAME)

dandr$prwp_id[dandr$prwp_id == 115004] <- 7110
dandr$prwp_id[dandr$prwp_id == 9602 & dandr$title == "Credit Cycles in Countries in the MENA Region -- Do They Exist ? Do They Matter?"] <- 9062

write_rds(
  dandr,
  here(
    "data",
    "intermediate",
    "clean_dandr.rds"
  )
)