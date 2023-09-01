library(tidyverse)
library(magrittr)

cols = readLines("data/colnames.txt")

gt = read_tsv("data/0001074-230828120925497/occurrence.txt",
              quote="",
              col_select = all_of(cols),
              col_types = cols(.default = "c"))
