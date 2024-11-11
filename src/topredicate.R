library(jsonlite)

query = list(creator = "mdillen",
             notificationAddresses = list("mathias.dillen@plantentuinmeise.be"),
             sendNotification = "true",
             format = "DWCA",
             predicate = list(
               type = "in",
               key = "GBIF_ID"
             ))

miss1 = miss[1:100000,]
miss2 = miss[100001:200000,]
miss3 = miss[200001:214033,]
misst = miss3[1:3,]
query$predicate$values = pull(misst,gbifID)

j = toJSON(query,pretty=T,auto_unbox = T)
write(j,"query.json")
