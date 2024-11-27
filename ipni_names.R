library(tidyverse)
library(magrittr)
library(ini)

# data files to load, specified in config.ini
config = read.ini("config.ini")

# select subset of column names to read from the gbif occurrence file
cols = readLines("data/colnames_min.txt",warn=F)

# read gbif occurrence file with type specimen data
gtj = read_tsv(config$tre$gbiffile,
               quote="",
               col_select = all_of(cols),
               col_types = cols(.default = "c"))

# read ipni type info data
ipni = read_tsv(paste0(config$tre$ipnipath,"TypeMaterial.tsv"))

# read ipni names data
# this script may not work with older checklistbank downloads
# which still use the Name.tsv file
namefile = paste0(config$tre$ipnipath,"NameUsage.tsv")
if (file.exists(namefile)) {
  ipnin = read_tsv(namefile,
                   col_types = cols(.default = "c"))
} else {
  ipnin = namefile %>%
    gsub("Usage","",.) %>%
    read_tsv(col_types = cols(.default = "c"))
}

# join ipni name to ipni type data
ipni = left_join(ipni,ipnin,by=c("col:nameID"="col:ID"))

# subset colnames of the ipni data
icols = readLines("data/ipni_colnames.txt",warn=F)
ipni %<>% select(all_of(icols))

# concatenate scientificName
ipni %<>%
  mutate(fullname = paste(`col:scientificName`,
                          `col:authorship`))

# guess typifiedName for gbif data
gtj %<>%
  mutate(possible_name = ifelse(is.na(typifiedName),
                                scientificName,
                                typifiedName)) #%>%
  # mutate(possible_short = sub("^((\\S+\\s+\\S+)).*",
  #                             "\\1",
  #                             possible_name),
  #        verbatim_short = sub("^((\\S+\\s+\\S+)).*",
  #                             "\\1",
  #                             verbatimScientificName))

# infer typeStatus for old IPNI typification data
# should no longer be needed
if (dim(filter(ipni,is.na(`col:status.x`)))[1]>0) {
  ipni %<>%
    mutate(typeStatus = ifelse(is.na(`col:citation`),
                               `col:status.x`,
                               gsub(" .*","",`col:citation`)))
} else {
  ipni$typeStatus = ipni$`col:status.x`
}

# subset of typestatuses to consider in scope
scope_types = read_csv("data/typestatus.txt")

# filter GBIF data on plant specimens and only selected typestatuses
spec = gtj %>%
  filter(basisOfRecord == "PRESERVED_SPECIMEN") %>%
  filter(kingdom == "Plantae") %>%
  mutate(typeStatus = tolower(typeStatus)) %>%
  filter(typeStatus%in%scope_types$status)

ipni2 = ipni %>%
  filter(typeStatus%in%scope_types$status)

# match names based on name and typeStatus, as well as collection code
merg = inner_join(ipni2,spec,by=c("fullname" = "possible_name",
                                  "typeStatus" = "typeStatus")) %>%
  filter(is.na(`col:institutionCode`)|
           (`col:institutionCode`==institutionCode|
              `col:institutionCode`==collectionCode))

## summarise the names to be imported

# taxon rank items in the TRE
taxonranks = read_csv("data/taxonranks.txt")

names_tsv = merg %>%
  group_by(fullname) %>%
  summarise(ipni = paste(unique(`col:nameID`),collapse="|"),
            authorship = paste(unique(`col:authorship`),collapse="|"),
            taxonKey = paste(unique(taxonKey),collapse="|"),
            taxonRank = paste(unique(`col:rank`),collapse="|")) %>%
  left_join(taxonranks,by=c("taxonRank"="rankLabel")) %>%
  filter(!is.na(rank))

# omit names already imported in the TRE
snames = read_tsv("imported/namesimported.tsv") %>%
  mutate(item = gsub(".*/","",item)) %>%
  left_join(merg,by=c("itemLabel" = "fullname"))

names_tsv %<>%
  filter(!fullname%in%snames$itemLabel)

# names to import
write_tsv(names_tsv,"tre-api/names-wbi.tsv",na="")