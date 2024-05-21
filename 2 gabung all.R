setwd("~/ARFWSNMRP/Agregat")

library(dplyr)
library(tidyr)
library(parallel)

# ambil nama file
n_core = detectCores()
files  = list.files(full.names = T)

# ambil data dengan function
ambil_data = function(input){
  temp = read.csv(input) %>% janitor::clean_names() %>% select(-x_1,-x)
  temp = 
    temp %>% 
    mutate(waktu = lubridate::as_datetime(time),
           waktu = waktu + lubridate::hours(7))
  return(temp)
}

# kita ambil semaunya
df_temp  = mclapply(files,ambil_data,mc.cores = n_core)
df_final = do.call(rbind,df_temp) %>% distinct() %>% arrange(kota,waktu) %>% select(-time)
df_final = df_final |> mutate(waktu = waktu + lubridate::hours(7))

setwd("~/ARFWSNMRP/Clean Data")
save(df_final,file = "data all.rda")

df_final %>% openxlsx::write.xlsx("Data All per 21 May 2024.xlsx")
