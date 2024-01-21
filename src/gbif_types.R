library(tidyverse)
library(magrittr)

cols = readLines("data/colnames_min.txt")

gt = read_tsv("data/0001074-230828120925497/occurrence.txt",
              quote="",
              col_select = all_of(cols),
              col_types = cols(.default = "c"))

ipni = read_tsv("data/00ipni/TypeMaterial.tsv")
ipnin = read_tsv("data/00ipni/Name.tsv")

ipni = left_join(ipni,ipnin,by=c("col:nameID"="col:ID"))

ipni %<>%
  mutate(fullname = paste(`col:scientificName`,
                          `col:authorship`))

# gt_ipni = gt %>%
#   filter(scientificName%in%ipni$fullname)
# gt_ipni_c = gt_ipni %>%
#   count(scientificName)
# 
# gt_max= gt %>%
#   filter(scientificName == "Amorimia pellegrinii R.F.Almeida")
# 
# ipni_c = ipni %>%
#   count(`col:citation`)
# 
# ipni_c_status = ipni %>%
#   count(`col:status.x`)
# 
# ipni_c %>% filter(!is.na(`col:citation`)) %>% pull(n) %>% sum()
# 
# gt %>% count(basisOfRecord) %>% mutate(perc = n/sum(n))

gt %<>%
  mutate(possible_name = ifelse(is.na(typifiedName),
                                scientificName,
                                typifiedName))

ipnilj = ipni %>%
  left_join(gt,by=c("fullname"="possible_name"))
