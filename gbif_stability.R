library(tidyverse)
library(magrittr)

cols = readLines("data/colnames_min.txt",warn=F)

data = read_csv("data/gbif_dates.txt",col_names = F)

occ = list()
for (i in 1:dim(data)[1]) {
  occ[[i]] = read_tsv(paste0("data/",data$X1[i],"/occurrence.txt"),
                      quote="",
                      col_select = all_of(cols),
                      col_types = cols(.default = "c"))
}
for (i in 1:length(occ)) {
  occ[[i]] %<>%
    mutate(occuq = paste0(occurrenceID,datasetKey)) %>%
    filter(basisOfRecord!="HUMAN_OBSERVATION",
           basisOfRecord!="MACHINE_OBSERVATION",
           basisOfRecord!="OBSERVATION")
  print(count(occ[[i]],basisOfRecord))
}

full4 = occ[[4]] %>%
  select(gbifID) %>%
  filter(gbifID%in%occ[[3]]$gbifID,
         gbifID%in%occ[[2]]$gbifID,
         gbifID%in%occ[[1]]$gbifID)

not = occ[[4]] %>%
  select(gbifID) %>%
  filter(!gbifID%in%occ[[3]]$gbifID|
         !gbifID%in%occ[[2]]$gbifID|
         !gbifID%in%occ[[1]]$gbifID)

classify_ids <- function(curr, prev = NULL, nextt = NULL,colname="gbifID") {
  data.frame(
    Snapshot = paste("Snapshot", seq_along(curr)),
    Retained = sapply(seq_along(curr), function(i) {
      if (i == 1) return(0)  # No previous snapshot for the first one
      length(intersect(curr[[i]][[colname]], prev[[i - 1]][[colname]]))
    }),
    New = sapply(seq_along(curr), function(i) {
      if (i == 1) return(nrow(curr[[i]]))  # All are new in the first snapshot
      length(setdiff(curr[[i]][[colname]], prev[[i - 1]][[colname]]))
    }),
    Missing = sapply(seq_along(curr), function(i) {
      if (i == length(curr)) return(0)  # No next snapshot for the last one
      length(setdiff(curr[[i]][[colname]], nextt[[i + 1]][[colname]]))
    })
  )
}

# Apply the classification function
snapshots_classified <- classify_ids(occ, occ, occ)
snapshots_classified2 <- classify_ids(occ, occ, occ,"occuq")

# Reshape data for ggplot2
snapshots_long <- snapshots_classified %>%
  pivot_longer(cols = c(Retained, New, Missing), 
               names_to = "Category", 
               values_to = "Count")

# Create the ggplot
ggplot(snapshots_long, aes(x = Snapshot, y = Count, fill = Category)) +
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  labs(title = "Changes Between Snapshots", x = "Snapshot", y = "Count") +
  scale_fill_brewer(palette = "Set3")

for (i in 1:4) {
  if (i==1) {
    typeids = select(occ[[i]],gbifID)
  } else {
    typeids = rbind(typeids,
                    select(occ[[i]],gbifID))
  }
}
typeids %<>%
  filter(!duplicated(gbifID))

typegone = typeids %>%
  filter(!gbifID%in%occ[[4]]$gbifID)

missd = list.dirs("data/missing/", recursive = F)

missl = list()
for (i in 1:length(missd)) {
  missl[[i]] = read_tsv(paste0(missd[i],"/occurrence.txt"),
                        quote="")
}
missdf = rbind(missl[[1]],missl[[2]])
missdf = rbind(missdf,missl[[3]])

yettype = missdf %>%
  filter(!is.na(typeStatus))

occ2 = list()
for (i in 1:4) {
  occ2[[i]] = occ[[i]] %>%
    filter(gbifID%in%typegone2$gbifID)
}
