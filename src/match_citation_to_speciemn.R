names = ipnilj_date_match %>%
  count(`col:nameID`) %>% 
  arrange(desc(n))

ipnilj_date_match %<>%
  unite(`col:status.x`,
        `col:institutionCode`,
        `col:catalogNumber`,
        col = "citation2",
        sep = " ",
        remove = F,
        na.rm = T) %>%
  mutate(citation = ifelse(is.na(`col:citation`),
                           citation2,
                           `col:citation`))

test = ipnilj_date_match %>%
  filter(`col:nameID`==names$`col:nameID`[1])

citations = test %>%
  count(citation)

specimens = test %>%
  count(gbifID)

for (i in 1:dim(specimens)[1]) {
  #set up a decision tree here that tries to match a specimen to a certain citation
  #based on institution info, barcode
}