# Remove all objects from the workspace
rm(list=ls())
# Run garbage collection to free up memory
gc()

# Load necessary libraries
library(dplyr) # For data manipulation
library(tidyr) # For data tidying
library(parallel) # For data visualization

ncore = detectCores()

# Load the data
load("~/ARFWSNMRP/Clean Data/data all.rda")

# Get unique and sorted city names
kota = df_final %>% pull(kota) %>% unique() %>% sort()

# Modify the 'df_final' data frame
df_2024 =
  df_final %>%
  # Extract the hour from the 'waktu' column and create a new 'jam' column
  mutate(jam   = lubridate::hour(waktu)) |>
  # Extract the month from the 'waktu' column and create a new 'bulan' column
  mutate(bulan = lubridate::month(waktu)) |>
  # Extract the year from the 'waktu' column and create a new 'tahun' column
  mutate(tahun = lubridate::year(waktu)) |>
  # Filter the data for the year 2024
  filter(tahun == 2024) |> 
  # Filter di jam tertentu
  filter(jam %in% 7:18) |> 
  select(kota,waktu,feel_like)


# ==============================================================================
# sekarang kita ubah yang tahun 2023

setwd("~/ARFWSNMRP/data beli")

files = list.files()

# bikin functio
ambilin = function(input){
  df = read.csv(input) |> janitor::clean_names()
  output = 
    df |> 
    mutate(waktu = lubridate::as_datetime(dt_iso),
           waktu = waktu + lubridate::hours(7),
           jam   = lubridate::hour(waktu)) |> 
    mutate(tahun = lubridate::year(waktu)) |> 
    filter(tahun %in% 2021:2023) |> 
    rename(kota    = city_name,
           kondisi = weather_main) |>  
    # Filter di jam tertentu
    filter(jam %in% 7:18) |> 
    rename(feel_like = feels_like) |> 
    select(kota,waktu,feel_like)
  return(output)
}

temp_2023 = mclapply(files,ambilin,mc.cores = ncore)
df_2023   = data.table::rbindlist(temp_2023) |> as.data.frame()

df_2023 = 
  df_2023 |> 
  mutate(kota = ifelse(kota == "Aceh","Banda Aceh",kota),
         kota = ifelse(kota == "Bali","Denpasar",kota),
         kota = ifelse(kota == "Banten","Tangerang",kota),
         kota = ifelse(kota == "Lampung","Metro",kota),
         kota = ifelse(kota == "Maluku","Ambon City",kota),
         kota = ifelse(kota == "Lampung","Metro",kota),
         kota = ifelse(kota == "Mataram City","Bima",kota),
         kota = ifelse(kota == "Samarinda City","Samarinda",kota),
         kota = ifelse(kota == "Lampung","Metro",kota),
         )

df_2024 = 
  df_2024 |> 
  filter(kota %in% df_2023$kota)

kota_2024 = df_2024 |> pull(kota) |> unique() |> sort()
kota_2023 = df_2023 |> pull(kota) |> unique() |> sort()

df_all = rbind(df_2023,df_2024) |> mutate(tahun = lubridate::year(waktu))

setwd("~/ARFWSNMRP/Report/perbandingan cuaca")
save(df_all,file = "data perbandingan for reg.rda")


df_all |> 
  ggplot(aes(x = waktu,y = feel_like)) +
  geom_smooth(method = "loess") +
  geom_line(aes(group = kota),alpha = .15) +
  facet_wrap(~kota)

df_all |> 
  ggplot(aes(y = feel_like,x = tahun)) +
  geom_boxplot(aes(group = tahun)) +
  facet_wrap(~kota)

t.test(feel_like ~ tahun,data = df_all)




plot = 
  df_all |> 
  ggplot(aes(x = kondisi,y = persen,fill = as.factor(tahun))) +
  geom_col(position = position_dodge(),color = "black") +
  geom_label(aes(label = label,
                 y = persen + 5),
             position = position_dodge(width = .9),size = 1.5,
             alpha = .3) +
  scale_fill_manual(values = c("darkgreen","steelblue")) +
  facet_wrap(~kota) +
  labs(fill = "tahun") +
  theme(axis.text.x = element_text(size = 8),
        legend.position = "bottom") +
  ylim(0,100) +
  scale_x_discrete(guide = guide_axis(n.dodge = 3)) +
  labs(title = "Kondisi Cuaca jam 7-18",
       subtitle = "sumber: openweather.com")




setwd("~/ARFWSNMRP/Report/perbandingan cuaca")
ggsave(plot,dpi = 450,width = 10,height = 6,filename = "pagi sore.png")

