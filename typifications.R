merg2 = merg %>%
  mutate(uri = ifelse(grepl("http", #extract an external uri
                            occurrenceID),
                      occurrenceID,
                      ifelse(!is.na(references)&grepl("http",references),
                             references,
                             ifelse(!is.na(bibliographicCitation)&grepl("http",bibliographicCitation),
                                    gsub(".*http","http",bibliographicCitation),
                                    NA))),
         occurrenceID = ifelse(!is.na(occurrenceID),
                               occurrenceID,
                               ifelse(!is.na(uri),
                                      uri,
                                      paste0("gbif:",gbifID))))

snames_raw = snames %>%
  select(item,itemLabel) %>%
  filter(!duplicated(item))

typification_tsv = sspec %>%
  mutate(typeSpecimen = gsub(".*/","",typeSpecimen)) %>%
  left_join(merg2,by=c("typeSpecimenLabel" = "occurrenceID")) %>%
  left_join(snames_raw,by=c("fullname" = "itemLabel")) %>%
  filter(!is.na(gbifID)) %>%
  mutate(typeStatusLabel = paste0(typeSpecimenLabel,
                                  ": ",
                                  typeStatus,
                                  " of ",
                                  fullname)) %>%
  filter(!duplicated(typeStatusLabel)) %>%
  left_join(scope_types,by=c("typeStatus" = "status")) %>%
  select(typeStatusLabel,
         typeSpecimen,
         item.x,#to rename
         item.y)

write_tsv(typification_tsv,"tre-api/typifications-wbi.tsv",na="")
