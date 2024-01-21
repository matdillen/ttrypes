library(tidyverse)
library(magrittr)

gbif_raw = read_tsv("data/0001074-230828120925497/verbatim.txt",
                    quote="",
                    col_types = cols(.default = "c"))

gbif_raw %>%
  count(license) %>%
  arrange(desc(n)) %>%
  View()

spec_raw = gbif_raw %>%
  filter(gbifID%in%spec$gbifID)

holo = spec_raw %>%
  mutate(typeL = tolower(typeStatus)) %>%
  filter(grepl("holotype",typeL))

holos = holo %>%
  count(typeStatus)
