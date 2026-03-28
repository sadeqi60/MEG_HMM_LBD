load("data_grant.RData")
data$Group <- fct_relevel(
  data$Group,
  c("LBD", "NC")
)
data$Group <- factor(data$Group, levels = c("LBD", "NC"))

LBD_NC_band_state <- data |>
  select(
    original,
    State,
    ROI,
    Group,
    Band,
    Power
  ) |>
  mutate(
    hemi = case_when(
      str_detect(ROI, "_lh") ~ "left",
      str_detect(ROI, "_rh") ~ "right",
      TRUE ~ NA_character_
    ),
    ROI = str_replace(ROI, "_[lr]h", "")
  ) |>
  group_by(original, ROI, hemi, State, Group, Band) |>
  summarise(
    Power = mean(Power),
  ) |>
  ungroup() |>
  pivot_wider(
    names_from = Band,
    values_from = Power
  ) |>
  distinct() |>
  mutate(
    TBR = Theta / Beta,
    DAR = Delta / Alpha,
    TAR = Theta / Alpha
  )
LBD_NC_band_state$Group <- fct_relevel(
  LBD_NC_band_state$Group,
  c("LBD", "NC")
)
LBD_NC_band_state$Group <- factor(LBD_NC_band_state$Group, levels = c("LBD", "NC"))
LBD_NC_diff <- LBD_NC_band_state |> 
  group_by(State, ROI, hemi) |>
  group_modify(
    ~ broom::tidy(
      RVAideMemoire::perm.t.test(
        TBR ~ Group,
        data = .x,
        nperm = 100,
      )
    )
  ) |>
  mutate(
    difference = estimate1 - estimate2,
    Group = "LBD v.s. NC"
  ) |>
  mutate(q.value = p.adjust(p.value, method = "fdr")) |>
  rename(NC = estimate2, LBD = estimate1) |>
  mutate(difference = ifelse(q.value > 0.05, NA, difference))
save(LBD_NC_diff, file = "LBD_NC_TBR_diff.RData")
write_csv(LBD_NC_diff, "LBD_NC_TBR_diff.csv")
#load("LBD_NC_TBR_diff.RData")
LBD_NC_diff <- LBD_NC_diff |> mutate(difference = if_else(difference < 3, NA_real_, difference))
LBD_NC_TBR_diff_data <- ROI_Glasser |>
  #group_by(ROI) |>
  #nest(.key = "data") |>
  left_join(LBD_NC_diff, relationship = "many-to-many") |>
  #unnest("data") |>
  rename(region = Region)

LBD_NC_TBR_diff_Glasser <- glasser52 |>
  left_join(LBD_NC_TBR_diff_data, relationship = "many-to-many")

LBD_NC_TBR_diff_Glasser$Group <- fct_relevel(
  LBD_NC_TBR_diff_Glasser$Group,
  c("LBD v.s. NC")
)

glasserTBR <- glasser52 |> filter(Group == "LBD v.s. NC")
LBD_NC_TBR_diff_plot <- LBD_NC_TBR_diff_Glasser |>
  filter(Group == "LBD v.s. NC") |>
  select(
    -c(
      "p.value",
      "q.value",
      "method",
      "alternative",
      "Group",
      "statistic",
      "LBD",
      "NC"
    )
  ) |>
  ggplot() +
  geom_brain(
    atlas = glasserTBR,
    position = position_brain(hemi ~ side),
    aes(fill = difference)
  ) +
  scale_fill_scico(
    palette = 'vik',
    limits = c(
      -max(abs(LBD_NC_TBR_diff_Glasser$difference), na.rm = TRUE),
      max(abs(LBD_NC_TBR_diff_Glasser$difference), na.rm = TRUE)
    )
  ) +
  labs(x = NULL, y = NULL) +
  guides(x = "none", y = "none") +
  #facet_grid(cols = vars(State)) +
  facet_wrap(~State, ncol = 6) +
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
  "Grant_LBD_NC_TBR_diff.svg",
  plot = LBD_NC_TBR_diff_plot,
  width = 20,
  height = 3,
  dpi = 2400
)
