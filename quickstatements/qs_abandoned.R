#namelist = count(merg,fullname)

# names_to_import = count(merg,taxonKey) %>%
#   pull(taxonKey) %>%
#   writeLines("gbif taxonkeys to import.txt")
# #tre_export = response from querying wikibase for names taken from latest gbif backbone export
# #tre_export2 = response from querying wikibase for specimens imported using first qs
# qn = "INIT"
# qs = "INIT"
# qs_ta = "INIT"
# for (i in 101:102) {
# #for (i in 1:dim(namelist)[1]) {
#   subset = filter(merg,fullname==namelist$fullname[i])
#   ipni_ids = count(subset,`col:nameID`) %>%
#     mutate(qs = paste0("LAST\\tP32\\t\"",
#                        `col:nameID`,
#                        "\""))
#   
#   qn = c(qn,
#          "CREATE",
#          paste0("LAST\\tLen\\t\"",
#                 subset$fullname[1],
#                 "\""),
#          paste0("LAST\\tDen\\t\"a botanical taxonomic name of rank ",
#                 subset$`col:rank`[1],
#                 "\""),
#          "LAST\\tP1\\tQ1",
#          "LAST\\tP5\\tQ16",
#          "LAST\\tP16\\t\"Plantae\"",
#          paste0("LAST\\tP14\\t\"",
#                 subset$fullname[1],
#                 "\""),
#          paste0("LAST\\tP15\\t\"",
#                 subset$`col:authorship`[1],
#                 "\""),
#          ipni_ids$qs,
#          paste0("LAST\\tP7\\t\"",
#                 subset$taxonKey[1],
#                 "\""))
# }


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
  status_item = scope_types %>%
    filter(status == gsub(";.*","",subset2$typeStatus.y[1])) %>%
    pull(item)
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
                   status_item),
            paste0("LAST\\tP29\\t\"",
                   tre_id,
                   "\""),
            paste0("LAST\\tP36\\t\"",
                   tre_id2,
                   "\""))
}
}

writeLines(qn,"qs_names_test.txt")
writeLines(qs,"qs_specimens.txt")
writeLines(qs_ta,"qs_type_assertions.txt")
