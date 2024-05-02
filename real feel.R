#setwd("~/ARFWSNMRP")
rm(list=ls())

library(dplyr)
#library(tidyr)
library(jsonlite)

# set kotanya
city = readLines("kota.txt")
# city = c("ambon","bima")

# api key
API_key = "15bf60709629b9e58a377841ff80480b"

# tempel kota dan api key ke dalam link API
api = paste0("http://api.openweathermap.org/data/2.5/weather?q=",
             city,
             "&appid=",
             API_key,
             "&units=metric")

# baca datanya
cuaca_kota = function(i){
    # baca data
    data = fromJSON(api[i])

    # kita akan buat datanya
    lon       = data$coord$lon
    lat       = data$coord$lat
    suhu      = data$main$temp
    suhu_min  = data$main$temp_min
    suhu_max  = data$main$temp_max
    humidity  = data$main$humidity
    feel_like = data$main$feels_like
    kota      = data$name
    kondisi   = data$weather$main
    kondisi_d = data$weather$description
    negara    = data$sys$country

    # kita buat outputnya
    output = data.frame(negara,
                        kota,kondisi,detail_kondisi = kondisi_d,
                        suhu,suhu_min,suhu_max,feel_like,
                        humidity,lon,lat,
                        time = Sys.time())

    # membuat output
    label = Sys.time() |> as.character()
    output |> write.csv(paste0(label,"-",
                               city[i],
                               ".csv"))
}

# uji coba dulu per menit
# cuaca_kota(1)

# kita mulai pencarian cuacanya
for(ikanx in 1:length(api)){
    # scrape cuaca
    cuaca_kota(ikanx)
    Sys.sleep(runif(1,.2,.5))
}
