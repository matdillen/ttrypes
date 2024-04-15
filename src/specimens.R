spec = gt %>%
  filter(basisOfRecord == "PRESERVED_SPECIMEN") %>%
  filter(kingdom == "Plantae")

# spec_c = spec %>%
#   count(scientificName)
# 
 type_count = spec %>%
   count(typeStatus)
# 
# multi = spec %>%
#   filter(grepl(";",typeStatus,fixed=T))
# 
# holo = spec %>%
#   filter(grepl("HOLOTYPE",typeStatus))
# 
# dpl_types = holo %>%
#   count(scientificName) %>%
#   arrange(desc(n))

ipnilj = ipni %>%
  left_join(spec,by=c("fullname"="possible_name"))

count(ipnilj,`col:citation`) %>% arrange(desc(n)) %>% View()


ipnilj %>%
  filter(!is.na(`col:date`)) %>%
  View()
# > 50%

ipnilj %>%
  filter(!is.na(year)) %>%
  View()
# > 740k

ipnilj_date = ipnilj %>%
  filter(!is.na(`col:date`),
         !is.na(year))

ipnilj_date_match = ipnilj_date %>%
  filter(substr(`col:date`,1,4)==year)
