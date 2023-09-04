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
