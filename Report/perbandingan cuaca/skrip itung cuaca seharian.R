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
df_final =
  df_final %>%
  # Extract the hour from the 'waktu' column and create a new 'jam' column
  mutate(jam   = lubridate::hour(waktu)) |>
  # Extract the month from the 'waktu' column and create a new 'bulan' column
  mutate(bulan = lubridate::month(waktu)) |>
  # Extract the year from the 'waktu' column and create a new 'tahun' column
  mutate(tahun = lubridate::year(waktu)) |>
  # Filter the data for the year 2024
  filter(tahun == 2024)


# Create a new data frame 'df_2024' by summarizing and calculating percentages
df_2024 =
  df_final |>
  # gabung kondisi cuaca
  mutate(kondisi = case_when(
    kondisi == "Clear" ~ "Clear",
    kondisi == "Rain" ~ "Rain",
    kondisi == "Clouds" ~ "Clouds"
  )) |> 
  mutate(kondisi = ifelse(is.na(kondisi),"Others",kondisi)) |> 
  # Group the data by city and condition
  group_by(kota,kondisi) |>
  # Count the occurrences of each combination
  tally() |>
  # Ungroup the data
  ungroup() |>
  # Group the data by city
  group_by(kota) |>
  # Calculate the percentage for each condition within each city
  mutate(persen = n / sum(n) * 100,
         # Round the percentage to 2 decimal places
         persen = round(persen,2),
         # Create a label with the percentage value and "%" symbol
         label  = paste0(persen,"%")) |>
  # Ungroup the data
  ungroup() |>
  # Add a 'tahun' column with the value 2024
  mutate(tahun = 2024)


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
           waktu = waktu + lubridate::hours(7)) |> 
    mutate(tahun = lubridate::year(waktu)) |> 
    filter(tahun == 2023) |> 
    rename(kota    = city_name,
           kondisi = weather_main) |> 
    # gabung kondisi cuaca
    mutate(kondisi = case_when(
      kondisi == "Clear" ~ "Clear",
      kondisi == "Rain" ~ "Rain",
      kondisi == "Clouds" ~ "Clouds"
    )) |> 
    mutate(kondisi = ifelse(is.na(kondisi),"Others",kondisi)) |> 
    group_by(kota,kondisi) |> 
    tally() |> 
    ungroup() |> 
    # Group the data by city
    group_by(kota) |>
    # Calculate the percentage for each condition within each city
    mutate(persen = n / sum(n) * 100,
           # Round the percentage to 2 decimal places
           persen = round(persen,2),
           # Create a label with the percentage value and "%" symbol
           label  = paste0(persen,"%")) |>
    # Ungroup the data
    ungroup() |>
    # Add a 'tahun' column with the value 2024
    mutate(tahun = 2023)
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

df_all = rbind(df_2023,df_2024)

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
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  labs(title = "Kondisi Cuaca Seharian",
       subtitle = "sumber: openweather.com")

setwd("~/ARFWSNMRP/Report/perbandingan cuaca")
ggsave(plot,dpi = 450,width = 10,height = 6,filename = "seharian.png")

