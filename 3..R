# ==============================================================================
# COMPOUND CLIMATE EXTREMES IN SOUTHEASTERN T??RKIYE (1990???2025)
# Full Data Retrieval, Index Calculation, Compound Analysis & Trend Pipeline
# ==============================================================================

# 1. GEREKL?? PAKETLER??N Y??KLENMES??
suppressPackageStartupMessages({
  library(nasapower)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(lubridate)
  library(readr)
  library(SPEI)
  library(trend)
})

# ------------------------------------------------------------------------------
# MOD??L 1: 9 ??L??N KOORD??NAT TANIMLAMASI VE NASA POWER VER?? ??ND??RME (1990???2025)
# ------------------------------------------------------------------------------

province_coords <- tibble::tribble(
  ~Province,    ~Lat,      ~Lon,
  "Adiyaman",   37.7644,   38.2786,
  "Batman",     37.8812,   41.1351,
  "Diyarbakir", 37.9144,   40.2306,
  "Gaziantep",  37.0662,   37.3833,
  "Kilis",      36.7184,   37.1217,
  "Mardin",     37.3129,   40.7350,
  "Siirt",      37.9333,   41.9500,
  "Sanliurfa",  37.1674,   38.7955,
  "Sirnak",     37.5164,   42.4611
)

start_date <- "1990-01-01"
end_date   <- "2025-12-31"

fetch_province_data <- function(prov, lat, lon) {
  cat("Fetching data for:", prov, "...\n")
  
  get_power(
    community = "ag",
    pars = c("PRECTOTCORR", "T2M_MAX", "T2M_MIN", "T2M"),
    temporal_api = "daily",
    lonlat = c(lon, lat),
    dates = c(start_date, end_date)
  ) %>%
    mutate(Province = prov) %>%
    select(
      Province,
      Date = YYYYMMDD,
      Year = YEAR,
      MM,
      DD,
      Precip = PRECTOTCORR, # G??nl??k Toplam Ya?????? (mm)
      Tmax   = T2M_MAX,     # Maksimum S??cakl??k (??C)
      Tmin   = T2M_MIN,     # Minimum S??cakl??k (??C)
      Tmean  = T2M          # Ortalama S??cakl??k (??C)
    )
}

# 9 ??l i??in Veri ??ekme D??ng??s??
raw_daily_df <- pmap_dfr(
  list(province_coords$Province, province_coords$Lat, province_coords$Lon),
  fetch_province_data
)

# Ham g??nl??k veriyi kaydetme
write_csv(raw_daily_df, "SE_Anatolia_Daily_1990_2025.csv")

# ------------------------------------------------------------------------------
# MOD??L 2: ??L BAZINDA SPI-12 HESAPLANMASI
# ------------------------------------------------------------------------------

# Monthly Aggregation
monthly_df <- raw_daily_df %>%
  group_by(Province, Year, MM) %>%
  summarise(Monthly_Precip = sum(Precip, na.rm = TRUE), .groups = "drop") %>%
  arrange(Province, Year, MM)

# ??l baz??nda gruplayarak SPI-12 hesaplama
monthly_spi_df <- monthly_df %>%
  group_by(Province) %>%
  group_modify(~ {
    spi_res <- spi(.x$Monthly_Precip, scale = 12)
    .x$SPI12 <- as.vector(spi_res$fitted)
    .x
  }) %>%
  ungroup()

# Y??ll??k bazda en ??iddetli kurakl??k seviyesini (Min SPI-12) alma
annual_spi12 <- monthly_spi_df %>%
  group_by(Province, Year) %>%
  summarise(Min_SPI12 = min(SPI12, na.rm = TRUE), .groups = "drop")

# ------------------------------------------------------------------------------
# MOD??L 3: TEK??L A??IRI YA??I?? VE SICAKLIK ??NDEKLER?? (ETCCDI)
# ------------------------------------------------------------------------------

annual_extremes <- raw_daily_df %>%
  group_by(Province, Year) %>%
  summarise(
    # Ya?????? Ekstremleri
    Rx1day = max(Precip, na.rm = TRUE),
    R20mm  = sum(Precip >= 20, na.rm = TRUE),
    CDD    = max(rle(Precip < 1)$lengths[rle(Precip < 1)$values == TRUE], default = 0),
    PRCPTOT= sum(Precip, na.rm = TRUE),
    
    # S??cakl??k Ekstremleri
    TXx    = max(Tmax, na.rm = TRUE),
    SU35   = sum(Tmax >= 35, na.rm = TRUE),
    SU40   = sum(Tmax >= 40, na.rm = TRUE),
    .groups = "drop"
  )

# SPI-12 ile Ekstrem ??ndeksleri Birle??tirme
compound_master_df <- left_join(annual_extremes, annual_spi12, by = c("Province", "Year"))

# ------------------------------------------------------------------------------
# MOD??L 4: B??LE????K EKSTREM (COMPOUND EXTREMES) SINIFFLANDIRMASI
# ------------------------------------------------------------------------------

compound_master_df <- compound_master_df %>%
  group_by(Province) %>%
  mutate(
    # E??ik De??erler (??l Bazl?? 75. Y??zdelikler)
    TXx_q75    = quantile(TXx, 0.75, na.rm = TRUE),
    CDD_q75    = quantile(CDD, 0.75, na.rm = TRUE),
    Rx1day_q75 = quantile(Rx1day, 0.75, na.rm = TRUE),
    
    # Bile??ik Kurakl??k - S??cakl??k (Compound Drought-Heat)
    Is_CDH = ifelse(Min_SPI12 <= -1.5 & TXx >= TXx_q75, 1, 0),
    
    # ??klimsel Kam???? / Kurakl??ktan Sele Ge??i?? (Hydro-Climatic Whiplash)
    Is_Whiplash = ifelse(CDD >= CDD_q75 & Rx1day >= Rx1day_q75, 1, 0)
  ) %>%
  ungroup()

write_csv(compound_master_df, "SE_Anatolia_Annual_Compound_Indices_1990_2025.csv")

# ------------------------------------------------------------------------------
# MOD??L 5: MANN-KENDALL, SEN'S SLOPE VE PETTITT CHANGE-POINT ??STAT??ST??KLER??
# ------------------------------------------------------------------------------

run_stat_tests <- function(df, target_var) {
  provinces <- unique(df$Province)
  
  map_dfr(provinces, function(p) {
    sub_df <- df %>% filter(Province == p) %>% arrange(Year)
    vec <- sub_df[[target_var]]
    
    # Testlerin Uygulanmas??
    mk <- mk.test(vec)
    sen <- sens.slope(vec)
    pet <- pettitt.test(vec)
    
    tibble(
      Province = p,
      Variable = target_var,
      MK_Tau = round(as.numeric(mk$estimates["tau"]), 3),
      MK_p_value = round(mk$p.value, 4),
      Sen_Slope = round(as.numeric(sen$estimates), 4),
      Pettitt_K = pet$statistic,
      Pettitt_Change_Year = sub_df$Year[pet$estimate],
      Pettitt_p_value = round(pet$p.value, 4)
    )
  })
}

# Analiz Edilecek ??ndeks Listesi
index_vars <- c("Min_SPI12", "CDD", "Rx1day", "R20mm", "TXx", "SU35", "SU40", "Is_CDH", "Is_Whiplash")

# T??m ??ller ve ??ndeksler ????in Trend ??zeti
trend_summary_df <- map_dfr(index_vars, ~ run_stat_tests(compound_master_df, .x))

# ??statistik Sonu??lar??n?? Kaydetme
write_csv(trend_summary_df, "SE_Anatolia_Trend_Pettitt_Results_1990_2025.csv")

cat("\n--- ????LEM TAMAMLAMDI ---\n")
cat("Olu??turulan Dosyalar:\n")
cat("1. SE_Anatolia_Daily_1990_2025.csv (Ham G??nl??k Veri)\n")
cat("2. SE_Anatolia_Annual_Compound_Indices_1990_2025.csv (Y??ll??k ??ndeksler)\n")
cat("3. SE_Anatolia_Trend_Pettitt_Results_1990_2025.csv (Trend ve K??r??lma Testleri)\n")