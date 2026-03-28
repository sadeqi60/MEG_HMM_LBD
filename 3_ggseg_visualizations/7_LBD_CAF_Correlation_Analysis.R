load("output/RData/data_paper.RData")
LBD_Correlations <- data |>
  filter(
    Group == "LBD"
  ) |>
  separate(
    original,
    into = c(
      "ID",
      "Close",
      "Run",
      "Segment"
    ),
    sep = "_"
  ) |>
  mutate(
    Power = mean(Power),

    .by = c(ID, ROI, State, Band)
  ) |>
  group_by(State, ROI, Band) |>
  correlation(
    select = c(
      # "Fractional Occupancy",
      # "Mean Life Time (s)",
      # "Mean Interval (s)",
      # "Switching Rate (Hz)"
      "Power"
    ),
    select2 = c(
      "CAF",
      "ODF",
      "MFS",
      "MOCA",
      "MSQ_Partner_Q1_RBD",
      "NPI_Q_VH",
      "UPDRS_Part_III",
      "MSQ_Partner_Q8_DoA",
      "CDR_SB"
    ),
    method = "spearman",
    p_adjust = "none"
  ) |>
  filter(
    p < 0.05
  ) |>
  separate(
    col = Group,
    into = c(
      "State",
      "ROI",
      "Band"
    ),
    sep = " - "
  ) |>
  mutate(
    hemi = case_when(
      str_detect(ROI, "_lh") ~ "left",
      str_detect(ROI, "_rh") ~ "right",
      TRUE ~ NA_character_
    ),
    ROI = str_replace(ROI, "_[lr]h", "")
  )


save(LBD_Correlations, file = "output/RData/LBD_Correlations.RData")
write_csv(LBD_Correlations, "output/csv/LBD_Correlations.csv")
#load("LBD_Correlations.RData")
LBD_Correlations <- LBD_Correlations |>
  filter(Parameter2 == "CAF") |>
  select("State", "ROI", "hemi", "Band", "rho", "p")
load("output/RData/res_diff_LBD_NC_NINA_fdr.RData")
mask <- res_diff_LBD_NC_fdr |>
  select("State", "ROI", "hemi", "Band", "difference") |>
  #filter(State %in% c("State 2", "State 6")) |>
  filter(difference != "NA") |>
  # filter(
  #   difference >= quantile(difference, 0.65) |
  #     difference <= quantile(difference, 0.35)
  # )
  mutate(sign = ifelse(difference < 0, "negative", "positive")) %>%
  group_by(sign) %>%
  mutate(
    mean_diff = mean(difference),
    sd_diff = sd(difference)
  ) %>%
  ungroup() %>%
  filter(
    (difference < 0 & difference <= mean_diff - 2 * sd_diff) |
      (difference > 0 & difference >= mean_diff + 0.15 * sd_diff)
  )
LBD_Correlations_filterd <- mask |>
  left_join(LBD_Correlations)
glasser_LBD_CAF <- ROI_Glasser |>
  #group_by(ROI) |>
  #nest(.key = "data") |>
  left_join(LBD_Correlations_filterd, relationship = "many-to-many") |>
  #unnest("data") |>
  rename(region = Region)

LBD_cor <- glasser52 |>
  #filter(Group == "LBD") |>
  left_join(glasser_LBD_CAF, relationship = "many-to-many")


LBD_cor$Band <- fct_relevel(
  LBD_cor$Band,
  c("Delta", "Theta", "Alpha", "Beta") #, "Gamma")
)

LBD_CAF <- LBD_cor |>
  ggplot() +
  geom_brain(
    atlas = glasser52,
    position = position_brain(hemi ~ side),
    aes(fill = rho)
  ) +
  scale_fill_scico(
    palette = 'vik',
    limits = c(
      -max(abs(LBD_cor$rho), na.rm = TRUE),
      max(abs(LBD_cor$rho), na.rm = TRUE)
    )
  ) +
  labs(x = NULL, y = NULL) +
  guides(x = "none", y = "none") +
  facet_grid(cols = vars(State), rows = vars(Band))+
    theme(
      text = element_text(family = "Times New Roman", size = 12),
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
      ),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    )
  


ggsave(
  "output/plots/Paper_LBD_CAF_filtered.svg",
  plot = LBD_CAF,
  width = 9,
  height = 4.5,
  dpi = 2400
)

LBD_Correlations_filterd |> write_csv("output/csv/LBD_Correlations_filtered.csv")
# LBD_Correlations_filterd |>
#   select(-sign) |>
#   gt() |>
#   gtsave(filename = "LBD_Correlations_filtered.docx")
