rm(list=ls())

setwd("~/ARFWSNMRP")

library(dplyr)
library(parallel)
library(tidyr)

n_core = detectCores()

files  = list.files(pattern = "2024*",full.names = T)

ambil_dat = function(file){
  read.csv(file)
}

temp  = mclapply(files,ambil_dat,mc.cores = n_core)
final = data.table::rbindlist(temp) |> as.data.frame()
# final = do.call(rbind,temp)

write.csv(final,"~/ARFWSNMRP/Agregat/agregat 17 Mar 2025.csv")

unlink(files)