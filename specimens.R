# list specimens to import into the TRE

specimens_tsv = snames %>%
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
  select(item,
         gbifID,
         eventDate,
         locality,
         recordedBy,
         uri,
         occurrenceID,
         scientificName,
         `col:institutionCode`)

sspec = read_tsv("imported/specimensimported.tsv")

specimens_tsv2 = specimens_tsv %>%
  filter(!occurrenceID%in%sspec$typeSpecimenLabel) %>%
  group_by(occurrenceID) %>%
  summarise(item = first(item),
            gbifID = paste(unique(gbifID),collapse="|"),
            eventDate = first(eventDate),
            locality = first(locality),
            recordedBy = first(recordedBy),
            uri = first(uri),
            scientificName = first(scientificName),
            `col:institutionCode` = first(`col:institutionCode`))

write_tsv(specimens_tsv2,"tre-api/specimens-wbi.tsv",na="")