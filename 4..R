# ------------------------------------------------------------------------------
# FIGURE 7: SPATIAL DISTRIBUTION OF EXTREMES (CORRECTED)
# ------------------------------------------------------------------------------
if (file.exists("SE_Anatolia_Trend_Pettitt_Results_1990_2025.csv")) {
  trend_res <- read.csv("SE_Anatolia_Trend_Pettitt_Results_1990_2025.csv")
  
  spatial_df <- trend_res %>%
    filter(Variable %in% c("Min_SPI12", "Rx1day", "TXx")) %>%
    left_join(prov_coords, by = "Province") %>%
    st_as_sf(coords = c("Lon", "Lat"), crs = 4326)
  
  # 1. SPI-12 Trend Haritas??
  p7a <- ggplot(spatial_df %>% filter(Variable == "Min_SPI12")) +
    geom_sf(aes(color = Sen_Slope, size = abs(MK_Tau))) +
    geom_sf_text(aes(label = Province), nudge_y = 0.12, fontface = "bold", size = 2.8) +
    scale_color_gradient2(low = "#d7191c", mid = "#ffffbf", high = "#2b8cbe", midpoint = 0, name = "Slope") +
    theme_bw(base_size = 10) +
    labs(title = "(a) Min SPI-12 Trend", size = "|MK Tau|")
  
  # 2. Rx1day Trend Haritas??
  p7b <- ggplot(spatial_df %>% filter(Variable == "Rx1day")) +
    geom_sf(aes(color = Sen_Slope, size = abs(MK_Tau))) +
    geom_sf_text(aes(label = Province), nudge_y = 0.12, fontface = "bold", size = 2.8) +
    scale_color_viridis_c(option = "mako", name = "mm/yr") +
    theme_bw(base_size = 10) +
    labs(title = "(b) Rx1day Trend", size = "|MK Tau|")
  
  # 3. TXx Trend Haritas??
  p7c <- ggplot(spatial_df %>% filter(Variable == "TXx")) +
    geom_sf(aes(color = Sen_Slope, size = abs(MK_Tau))) +
    geom_sf_text(aes(label = Province), nudge_y = 0.12, fontface = "bold", size = 2.8) +
    scale_color_viridis_c(option = "inferno", name = "??C/yr") +
    theme_bw(base_size = 10) +
    labs(title = "(c) TXx Trend", size = "|MK Tau|")
  
  # Patchwork ile Birle??tirme
  fig7 <- (p7a | p7b | p7c) + 
    plot_annotation(
      title = "Figure 7: Spatial Distribution of Climate Extreme Trends Across Southeastern T??rkiye (1990???2025)",
      subtitle = "Coloring indicates Sen's Slope magnitude; point size represents Mann-Kendall Tau strength."
    )
  
  print(fig7)
}