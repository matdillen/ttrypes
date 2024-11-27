specimens_tsv = merg %>%
  filter(!is.na(`col:nameID`),
         !duplicated(gbifID)) %>%
  mutate(uri = ifelse(grepl("http", #extract an external uri
                            occurrenceID),
                      occurrenceID,
                      ifelse(!is.na(references)&grepl("http",references),
                             references,
                             ifelse(!is.na(bibliographicCitation)&grepl("http",bibliographicCitation),
                                    gsub(".*http","http",bibliographicCitation),
                                    NA)))) %>%
  mutate(occurrenceID = ifelse(!is.na(occurrenceID),
                               occurrenceID,
                               ifelse(!is.na(uri),
                                      uri,
                                      paste0("gbif:",gbifID)))) %>%
  select(gbifID,
         eventDate,
         locality,
         recordedBy,
         uri,
         occurrenceID,
         scientificName,
         `col:institutionCode`)

specimens_tsv %<>%
  mutate(uriclass = str_extract(uri,"(?<=https?://)[^/]+"))

count(specimens_tsv,uriclass) %>% 
  arrange(desc(n)) %>% 
  mutate(perc = 100*n/sum(n)) %>%
  View()

count(specimens_tsv,`col:institutionCode`) %>% 
  arrange(desc(n)) %>% 
  mutate(perc = 100*n/sum(n)) %>%
  View()
