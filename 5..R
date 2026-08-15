# ==============================================================================
# MANN-KENDALL VE SEN'S SLOPE TREND MATRIX HEATMAP
# ==============================================================================

library(ggplot2)
library(dplyr)
library(readr)

# 1. Sonu?? Verisini Y??kleme
if (!exists("mk_sen_results")) {
  mk_sen_results <- read_csv("SE_Anatolia_MannKendall_SenSlope_Full.csv")
}

# 2. ??ndeks ??simlerini Yay??n Standard??nda Etiketleme
mk_sen_results <- mk_sen_results %>%
  mutate(
    Var_Label = case_when(
      Variable == "Min_SPI12"  ~ "SPI-12 (Drought)",
      Variable == "CDD"        ~ "CDD (Dry Spells)",
      Variable == "Rx1day"     ~ "Rx1day (Max 1-Day Precip)",
      Variable == "R20mm"      ~ "R20mm (Heavy Rain Days)",
      Variable == "TXx"        ~ "TXx (Max Temp)",
      Variable == "SU35"       ~ "SU35 (Hot Days >=35??C)",
      Variable == "SU40"       ~ "SU40 (Extreme Hot Days >=40??C)",
      Variable == "Is_CDH"     ~ "Compound Drought-Heat",
      Variable == "Is_Whiplash"~ "Hydro-Climatic Whiplash",
      TRUE ~ Variable
    )
  )

# ------------------------------------------------------------------------------
# GRAF??K 1: MANN-KENDALL Z-SCORE & SEN'S SLOPE HEATMAP
# ------------------------------------------------------------------------------
fig_trend_matrix <- ggplot(mk_sen_results, aes(x = Var_Label, y = Province)) +
  # H??cre Renklendirmesi (Sen's Slope De??eri)
  geom_tile(aes(fill = Sen_Slope), color = "white", size = 0.5) +
  # Anlaml??l??k Y??ld??zlar?? Overlay
  geom_text(aes(label = ifelse(Significance != "ns", Significance, "")), 
            color = "black", size = 5, vjust = 0.8) +
  # Renk Paletleri
  scale_fill_gradient2(
    low = "#2b8cbe", mid = "#f7f7f7", high = "#d7191c", midpoint = 0,
    name = "Sen's Slope\n(Per Year)"
  ) +
  theme_bw(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", color = "black"),
    axis.text.y = element_text(face = "bold", color = "black"),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "right"
  ) +
  labs(
    title = "Mann-Kendall Trend Strength & Sen's Slope Magnitude (1990???2025)",
    subtitle = "Color fill represents Sen's Slope; stars indicate statistical significance (*p < 0.05, **p < 0.01, ***p < 0.001)",
    x = "Climate Extreme Index",
    y = "Province"
  )

print(fig_trend_matrix)

# ------------------------------------------------------------------------------
# GRAF??K 2: ??L BAZLI SICAKLIK VE YA??I?? SLOPE KAR??ILA??TIRMA (DODGED BAR CHART)
# ------------------------------------------------------------------------------
temp_precip_trends <- mk_sen_results %>%
  filter(Variable %in% c("TXx", "Rx1day", "CDD"))

fig_slope_bars <- ggplot(temp_precip_trends, aes(x = Province, y = Sen_Slope, fill = Variable)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray30") +
  scale_fill_manual(
    values = c("TXx" = "#e31a1c", "Rx1day" = "#1f78b4", "CDD" = "#ff7f00"),
    labels = c("CDD (Days/yr)", "Rx1day (mm/yr)", "TXx (??C/yr)")
  ) +
  theme_bw(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1, face = "bold"),
    legend.position = "bottom",
    legend.title = element_blank()
  ) +
  labs(
    title = "Annual Rate of Change (Sen's Slope) by Province",
    x = "Province",
    y = "Sen's Slope Estimate"
  )

print(fig_slope_bars)