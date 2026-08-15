# 1. Gerekli Paketler
library(nasapower)
library(dplyr)
library(purrr)
library(lubridate)
library(readr)

# --- A. 9 ??L??N MERKEZ KOORD??NATLARI ---
province_coords <- tibble::tribble(
  ~Province,   ~Lat,     ~Lon,
  "Adiyaman",  37.7644,  38.2786,
  "Batman",    37.8812,  41.1351,
  "Diyarbakir", 37.9144, 40.2306,
  "Gaziantep", 37.0662,  37.3833,
  "Kilis",     36.7184,  37.1217,
  "Mardin",    37.3129,  40.7350,
  "Siirt",     37.9333,  41.9500,
  "Sanliurfa", 37.1674,  38.7955,
  "Sirnak",    37.5164,  42.4611
)

# --- B. NASA POWER VER?? ??EKME FONKS??YONU ---
# Analiz Aral??????: 1991 - 2025 (35 y??ll??k tam iklim periyodu)
start_date <- "1991-01-01"
end_date   <- "2025-12-31"

fetch_nasa_power <- function(prov_name, lat, lon) {
  message(paste("Veri indiriliyor:", prov_name, "..."))
  
  get_power(
    community = "ag",
    pars = c("PRECTOTCORR", "T2M_MAX", "T2M_MIN", "T2M"),
    temporal_api = "daily",
    lonlat = c(lon, lat),
    dates = c(start_date, end_date)
  ) %>%
    mutate(Province = prov_name) %>%
    select(
      Province,
      Date = YYYYMMDD,
      Year = YEAR,
      MM,
      DD,
      Precip = PRECTOTCORR, # G??nl??k Ya?????? (mm)
      Tmax = T2M_MAX,       # Maksimum S??cakl??k (??C)
      Tmin = T2M_MIN,       # Minimum S??cakl??k (??C)
      Tmean = T2M           # Ortalama S??cakl??k (??C)
    )
}

# --- C. T??M ??LLER ??????N OTOMAT??K D??NG?? VE B??RLE??T??RME ---
all_provinces_daily <- pmap_dfr(
  list(province_coords$Province, province_coords$Lat, province_coords$Lon),
  fetch_nasa_power
)

# Veriyi diske kaydetme (CSV ve RDS format??nda)
write_csv(all_provinces_daily, "southeast_anatolia_nasa_power_1991_2025.csv")
saveRDS(all_provinces_daily, "southeast_anatolia_nasa_power_1991_2025.rds")