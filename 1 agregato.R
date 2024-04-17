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
final = do.call(rbind,temp)

write.csv(final,"agregat 13 Mar - 17 Apr 24.csv")

unlink(files)