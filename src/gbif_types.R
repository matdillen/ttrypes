library(tidyverse)
library(magrittr)

cols = readLines("data/colnames_min.txt",warn=F)

gt = read_tsv("data/0142065-240321170329656/occurrence.txt",
              quote="",
              col_select = all_of(cols),
              col_types = cols(.default = "c"))

gtv = read_tsv("data/0142065-240321170329656/verbatim.txt",
               quote="",
               #col_select = all_of(cols),
               col_types = cols(.default = "c"))

gtnt = read_tsv("data/0005724-240425142415019/occurrence.txt",
                quote="",
                col_select = all_of(cols),
                col_types = cols(.default = "c"))

gtnt2 = read_tsv("data/0005642-240425142415019/occurrence.txt",
                quote="",
                col_select = all_of(cols),
                col_types = cols(.default = "c"))

gtj = read_tsv("data/0018972-240626123714530/occurrence.txt",
                 quote="",
                 col_select = all_of(cols),
                 col_types = cols(.default = "c"))



err = filter(gtnt,!is.na(typeStatus))

na_columns <- function(df) {
  df %>%
    select(where(~ all(is.na(.)))) %>%
    names()
}

gt2 = read_tsv("data/0001074-230828120925497/occurrence.txt",
              quote="",
              col_select = all_of(cols),
              col_types = cols(.default = "c"))

miss = gt2 %>%
  filter(!gbifID%in%gt$gbifID)

new = gt %>%
  filter(!gbifID%in%gt2$gbifID)

#how to differentiate tombstone and no longer a type records?
#how to scale big diffs?

ipni = read_tsv("data/00ipni/TypeMaterial.tsv")
ipnin = read_tsv("data/00ipni/Name.tsv")

ipni = left_join(ipni,ipnin,by=c("col:nameID"="col:ID"))

ipni %<>%
  mutate(fullname = paste(`col:scientificName`,
                          `col:authorship`))

gtj %<>%
  mutate(possible_name = ifelse(is.na(typifiedName),
                                scientificName,
                                typifiedName))

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
