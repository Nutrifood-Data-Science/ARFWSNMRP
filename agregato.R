rm(list=ls())

library(dplyr)
library(parallel)
library(tidyr)

n_core = detectCores()

folder = "~/ARFWSNMRP/Results"
files  = list.files(folder,full.names = T)

ambil_dat = function(file){
  read.csv(file)
}

temp  = mclapply(files,ambil_dat,mc.cores = n_core)
final = do.call(rbind,temp)

write.csv(final,"agregat 14 -20 Feb 24.csv")

unlink(files)