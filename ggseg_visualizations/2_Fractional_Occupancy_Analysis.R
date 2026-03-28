# Recode 'AD_MCI' group to 'AD' and reorder factor levels for 'Group' variable
fo_lt_intv_sr_tidy <- fo_lt_intv_sr_tidy |>
  # Replace 'AD_MCI' with 'AD' in the 'Group' column
  mutate(Group = if_else(Group == "AD_MCI", "AD", Group))

# Reorder factor levels for the 'Group' column
fo_lt_intv_sr_tidy$Group <- fct_relevel(
  fo_lt_intv_sr_tidy$Group,
  c("LBD", "PD", "NC", "AD") # Levels in desired order
)

# Plot the fractional occupancy data
fo_plot <- fo_lt_intv_sr_tidy |>
  # filter(
  #   # Exclude the following outlierds om the analysis
  #   !ID %in%
  #     c(
  #       "NINA013_C_R3_S1",
  #       "NINA008_C_R1_S1",
  #       "NINA008_C_R2_S1",
  #       #"NINA008_C_R4_S1",
  #       "NINA016_C_R2_S1",
  #       "NINA016_C_R3_S1",
  #       "NINA016_C_R4_S1", #,
  #       #"NINA016_C_R5_S1"
  #       "NINA004_C_R1_S1",
  #       "NINA004_C_R1_S2",
  #       "NINA004_C_R2_S1",
  #       "NINA004_C_R3_S1",
  #       "NINA004_C_R4_S1",
  #       "NINA004_C_R5_S1"
  #     )
  # ) |>
  filter(
    Group %in% c("LBD", "NC", "PD"),
    Variable %in%
      c(
        "Fractional Occupancy"
      ),
    ID %in% selected_id
  ) |>
  ggplot(aes(x = Group, y = Measures, fill = Group)) +
  # facet_grid(cols = vars(State), rows = vars(Variable), scales = "free_y") +
  facet_wrap(~State, ncol = 6) +
  geom_boxplot() +
  scale_fill_manual(
    values = c(
      "LBD" = "#F8766D",
      "PD" = "#619CFF",
      "NC" = "#00BA38"
    )
  ) +
  stat_compare(
    breaks = c(0, 0.001, 0.01, 0.05, 1),
    correction = "bonferroni",
    comparisons = list(
      c("LBD", "NC"),
      c("LBD", "PD"),
      c("NC", "PD")
    ),
    tip_length = 0.01,
    nudge = 0.02,
    family = "Times New Roman"
  ) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    text = element_text(family = "Times New Roman", size = 14),
    strip.text.x = element_text(
      family = "Times New Roman",
      size = 18,
      face = "bold",
      angle = 0
    ),
    strip.text.y = element_text(
      family = "Times New Roman",
      size = 18,
      face = "bold",
      angle = 90
    )
  )

# Save the plot to a file
ggsave(
  "output/plots/Paper_FO.svg",
  plot = fo_plot,
  width = 13.5,
  height = 5,
  dpi = 2000
)



fo_lt_intv_sr_plot <- fo_lt_intv_sr_tidy |>
  # filter(
  #   # Exclude the following outlierds om the analysis
  #   !ID %in%
  #     c(
  #       "NINA013_C_R3_S1",
  #       "NINA008_C_R1_S1",
  #       "NINA008_C_R2_S1",
  #       #"NINA008_C_R4_S1",
  #       "NINA016_C_R2_S1",
  #       "NINA016_C_R3_S1",
  #       "NINA016_C_R4_S1", #,
  #       #"NINA016_C_R5_S1"
  #       "NINA004_C_R1_S1",
  #       "NINA004_C_R1_S2",
  #       "NINA004_C_R2_S1",
  #       "NINA004_C_R3_S1",
  #       "NINA004_C_R4_S1",
  #       "NINA004_C_R5_S1"
  #     )
  # ) |>
  filter(
    Group %in% c("LBD", "NC", "PD"),
    Variable %in%
      c(
        "Fractional Occupancy",
        "Mean Life Time (s)",
        "Mean Interval (s)",
        "Switching Rate (Hz)"
      ),
    ID %in% selected_id
  ) |>
  ggplot(aes(x = Group, y = Measures, fill = Group)) +
  facet_grid(cols = vars(State), rows = vars(Variable), scales = "free_y") +
  #facet_wrap(~State, ncol = 6) +
  geom_boxplot() +
  scale_fill_manual(
    values = c(
      "LBD" = "#F8766D",
      "PD" = "#619CFF",
      "NC" = "#00BA38"
    )
  ) +
  stat_compare(
    breaks = c(0, 0.001, 0.01, 0.05, 1),
    correction = "bonferroni",
    comparisons = list(
      c("LBD", "NC"),
      c("LBD", "PD"),
      c("NC", "PD")
    ),
    tip_length = 0.01,
    nudge = 0.02,
    family = "Times New Roman"
  ) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    text = element_text(family = "Times New Roman", size = 14),
    strip.text.x = element_text(
      family = "Times New Roman",
      size = 18,
      face = "bold",
      angle = 0
    ),
    strip.text.y = element_text(
      family = "Times New Roman",
      size = 18,
      face = "bold",
      angle = 90
    )
  )

# Save the plot to a file
ggsave(
  "output/plots/Paper_FO_LT_INTV_SR.png",
  plot = fo_lt_intv_sr_plot,
  width = 13.5,
  height = 15,
  dpi = 1000
)


