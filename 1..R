# 1. Gerekli Paketler
library(SPEI)
library(trend)
library(dplyr)
library(lubridate)
library(ggplot2)
library(gridExtra)

# --- A. VER?? SET?? (Kendi verinizle de??i??tirin) ---
set.seed(21)
dates <- seq(as.Date("1991-01-01"), as.Date("2020-12-31"), by = "day")
daily_data <- data.frame(
  Date = dates,
  Precip = rgamma(length(dates), shape = 0.4, scale = 6) * (runif(length(dates)) > 0.75)
)

# --- B. INDEKS HESAPLAMALARI ---
daily_data <- daily_data %>%
  mutate(Year = year(Date), Month = month(Date))

annual_extremes <- daily_data %>%
  group_by(Year) %>%
  summarise(
    CDD = max(rle(Precip < 1)$lengths[rle(Precip < 1)$values == TRUE], default = 0),
    CWD = max(rle(Precip >= 1)$lengths[rle(Precip >= 1)$values == TRUE], default = 0),
    R10mm = sum(Precip >= 10, na.rm = TRUE),
    Rx1day = max(Precip, na.rm = TRUE),
    .groups = "drop"
  )

monthly_data <- daily_data %>%
  group_by(Year, Month) %>%
  summarise(Monthly_Precip = sum(Precip, na.rm = TRUE), .groups = "drop")

spi3_res <- spi(monthly_data$Monthly_Precip, scale = 3)
monthly_data$SPI3 <- as.vector(spi3_res$fitted)

annual_spi <- monthly_data %>%
  group_by(Year) %>%
  summarise(Min_SPI3 = min(SPI3, na.rm = TRUE), .groups = "drop")

compound_df <- left_join(annual_extremes, annual_spi, by = "Year")

# --- C. E????K DE??ERLER VE B??LE????K YILLAR ---
cdd_q75 <- quantile(compound_df$CDD, 0.75)
rx1day_q75 <- quantile(compound_df$Rx1day, 0.75)

compound_df <- compound_df %>%
  mutate(
    Compound_Class = case_when(
      CDD >= cdd_q75 & Rx1day >= rx1day_q75 ~ "Compound Extreme Year",
      CDD >= cdd_q75 ~ "High CDD Only",
      Rx1day >= rx1day_q75 ~ "High Rx1day Only",
      TRUE ~ "Normal / Moderate"
    )
  )

# --- D. ??NG??L??ZCE GRAF??KLER (ENGLISH PLOTS) ---

# Plot 1: Dual-Axis Time Series (CDD vs Rx1day)
p1 <- ggplot(compound_df, aes(x = Year)) +
  geom_line(aes(y = CDD, color = "Consecutive Dry Days (CDD)"), size = 1) +
  geom_point(aes(y = CDD, color = "Consecutive Dry Days (CDD)"), size = 2) +
  geom_line(aes(y = Rx1day * 2, color = "Max 1-Day Precipitation (Rx1day)"), size = 1, linetype = "dashed") +
  geom_point(aes(y = Rx1day * 2, color = "Max 1-Day Precipitation (Rx1day)"), size = 2) +
  scale_y_continuous(
    name = "CDD (Days)",
    sec.axis = sec_axis(~./2, name = "Rx1day (mm)")
  ) +
  scale_color_manual(
    values = c("Consecutive Dry Days (CDD)" = "#d95f02", "Max 1-Day Precipitation (Rx1day)" = "#2b8cbe")
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 14)
  ) +
  labs(
    title = "Co-variation of Drought and Extreme Rainfall (1991???2020)",
    subtitle = "Southeastern Anatolia Region - Compound Climate Extremes Analysis",
    x = "Year"
  )

# Plot 2: Scatter Plot for Compound Extreme Identification (75th Percentile Thresholds)
p2 <- ggplot(compound_df, aes(x = CDD, y = Rx1day)) +
  geom_vline(xintercept = cdd_q75, linetype = "dashed", color = "gray40") +
  geom_hline(yintercept = rx1day_q75, linetype = "dashed", color = "gray40") +
  geom_point(aes(color = Compound_Class, shape = Compound_Class), size = 3) +
  scale_color_manual(
    values = c(
      "Compound Extreme Year" = "#e41a1c",
      "High CDD Only" = "#ff7f00",
      "High Rx1day Only" = "#377eb8",
      "Normal / Moderate" = "gray60"
    )
  ) +
  scale_shape_manual(
    values = c(
      "Compound Extreme Year" = 17,
      "High CDD Only" = 16,
      "High Rx1day Only" = 16,
      "Normal / Moderate" = 1
    )
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 13)
  ) +
  labs(
    title = "Compound Extreme Events Classification",
    subtitle = "Dashed lines represent the 75th percentile thresholds",
    x = "Consecutive Dry Days - CDD (Days)",
    y = "Max 1-Day Precipitation - Rx1day (mm)"
  )

# Ekran ????kt??s??
print(p1)
print(p2)