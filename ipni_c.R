library(tidyverse)
library(magrittr)

cols = readLines("data/colnames_min.txt",warn=F)

gtj = read_tsv("data/0018972-240626123714530/occurrence.txt",
               quote="",
               col_select = all_of(cols),
               col_types = cols(.default = "c"))

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

ipni %<>%
  mutate(typeStatus = ifelse(is.na(`col:citation`),
                             `col:status.x`,
                             gsub(" .*","",`col:citation`)))
#count(ipni,typeStatus) %>% View()

spec = gtj %>%
  filter(basisOfRecord == "PRESERVED_SPECIMEN") %>%
  filter(kingdom == "Plantae")

scope_types = c("isotype",
                "holotype",
                "lectotype",
                "isolectotype",
                "neotype",
                "isoneotype")
ipni2 = ipni %>%
  filter(typeStatus%in%scope_types)

#count(spec,typeStatus.y) %>% arrange(desc(n)) %>% View()

spec %<>%
  mutate(typeStatus = tolower(typeStatus))
merg = inner_join(ipni2,spec,by=c("fullname"="possible_name"))

#count(merg,fullname) %>% arrange(desc(n)) %>% View()

#dief = filter(merg,fullname=="Dieffenbachia tonduzii Croat & Grayum")

namelist = count(merg,fullname)
names_to_import = count(merg,taxonKey) %>%
  pull(taxonKey) %>%
  writeLines("gbif taxonkeys to import.txt")
#tre_export = response from querying wikibase for names taken from latest gbif backbone export
#tre_export2 = response from querying wikibase for specimens imported using first qs
qs = "INIT"
qs_ta = "INIT"
for (i in 1:60) {
#for (i in 1:dim(namelist)[1]) {
  subset = filter(merg,fullname==namelist$fullname[i])
  
  specimens = subset %>%
    count(gbifID)
  #some of these specimens may be duplicates; could be vetted by matching to
  # a dump from GBIF's clustering data
  for (j in 1:dim(specimens)[1]) {
    subset2 = filter(subset,gbifID==specimens$gbifID[j])
    if (exists("tre_export")) {
      tre_id = filter(tre_export,
                      IPNI_plant_name_ID==subset$`col:nameID`[1])
    } else {
      tre_id = subset$`col:nameID`[1]
    }
    if (exists("tre_export2")) {
      tre_id2 = filter(tre_export2,
                       gbifID==specimens$gbifID[j])
    } else {
      tre_id2 = specimens$gbifID[j]
    }
    qs = c(qs,
           "CREATE",
           paste0("LAST\\tLen\\t\"",
                  subset2$occurrenceID[1],
                  "\""),
           paste0("LAST\\tDen\\t\"a plant specimen known as ",
                  subset2$fullname[1],
                  ifelse(!is.na(subset2$recordedBy[1]),
                         paste0(" collected by ",
                                subset2$recordedBy[1]),
                         ""),
                  ifelse(!is.na(subset2$eventDate[1]),
                         paste0(" in ",
                                toString(subset2$eventDate[1])),
                         ""),
                  ifelse(!is.na(subset2$locality[1]),
                         paste0(" at ",
                                subset2$locality[1]),
                         ""),
                  "\""),
           "LAST\\tP1\\tQ4",
           paste0("LAST\\tP34\\t\"",
                  subset2$gbifID[1],
                  "\""),
           paste0("LAST\\tP29\\t\"",
                  tre_id,
                  "\""))
    qs_ta = c(qs_ta,
              "CREATE",
              paste0("LAST\\tLen\\t\"Typification assertion: ",
                     subset2$typeStatus.y[1],
                     " of ",
                     subset2$fullname[1],
                     "\""),
              "LAST\\tDen\\t\"link between a specimen and the name it is a type for\"",
              "LAST\\tP1\\tQ47338",
              paste0("LAST\\tP30\\t",
                     gsub(";.*","",subset2$typeStatus.y[1])),
              paste0("LAST\\tP29\\t\"",
                     tre_id,
                     "\""),
              paste0("LAST\\tP36\\t\"",
                     tre_id2,
                     "\""))
  }
}

writeLines(qs,"qs_specimens.txt")
writeLines(qs_ta,"qs_type_assertions.txt")
