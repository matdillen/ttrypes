spec = gt %>%
  filter(basisOfRecord == "PRESERVED_SPECIMEN") %>%
  filter(kingdom == "Plantae")

spec_c = spec %>%
  count(scientificName)

type_count = spec %>%
  count(typeStatus)

multi = spec %>%
  filter(grepl(";",typeStatus,fixed=T))

holo = spec %>%
  filter(grepl("HOLOTYPE",typeStatus))

dpl_types = holo %>%
  count(scientificName) %>%
  arrange(desc(n))
