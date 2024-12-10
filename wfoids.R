wfo = read_csv("data/12171908/015_ipni_to_wfo.csv")
wfo$id = gsub(".*\\:","",wfo$ipni_id)
snames2 = left_join(snames,wfo,by=c("col:nameID"="id")) %>%
  filter(!is.na(wfo_id)) %>%
  mutate(claim = paste0(item,wfo_id)) %>%
  filter(!duplicated(claim))

write_tsv(select(snames2,item,wfo_id),"tre-api/wfo-wbi.tsv")
