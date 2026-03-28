load("output/RData/data_paper.RData")
data$Group <- fct_relevel(
  data$Group,
  c("LBD", "PD", "NC")
)
data$Group <- factor(data$Group, levels = c("LBD", "PD", "NC"))

TBR_band_state <- data |>
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
mTBR_band_state <- TBR_band_state |>
  group_by( ROI, hemi, State, Group) |>
  summarise(
    TBR = mean(TBR),
    DAR = mean(DAR),
    TAR = mean(TAR)
  ) |> 
  ungroup() |> 
  distinct()

mTBR_band_state$Group <- fct_relevel(
  mTBR_band_state$Group,
  c("LBD","PD","NC")
)
mTBR_band_state$Group <- factor(mTBR_band_state$Group, levels = c("LBD","PD", "NC"))
TBR_band_state_data <- ROI_Glasser |>
  #group_by(ROI) |>
  #nest(.key = "data") |>
  left_join(mTBR_band_state, relationship = "many-to-many") |>
  #unnest("data") |>
  rename(region = Region)

TBR_band_state_data_Glasser <- glasser52 |>
  left_join(TBR_band_state_data, relationship = "many-to-many")

TBR_band_state_data_Glasser$Group <- fct_relevel(
  TBR_band_state_data_Glasser$Group,
  c("LBD","PD","NC")
)

glasserTBR <- glasser52 |> filter(Group %in% c("LBD","PD","NC")) |> filter(!is.na(Group))
glasserTBR$Group <- factor(glasserTBR$Group, levels = c("LBD","PD", "NC"))
TBR_band_state_data_Glasser $Group <- factor(TBR_band_state_data_Glasser $Group, levels = c("LBD","PD", "NC"))

TBR_plot <- TBR_band_state_data_Glasser |> 
  filter(Group %in% c("LBD","PD","NC")) |>
  # select(
  #   -c(
  #     "p.value",
  #     "q.value",
  #     "method",
  #     "alternative",
  #     "Group",
  #     "statistic",
  #     "LBD",
  #     "NC"
  #   )
  # ) |>
  ggplot() +
  geom_brain(
    atlas = glasserTBR,
    position = position_brain(hemi ~ side),
    aes(fill = TBR)
  ) +
  scale_fill_scico(
    palette = 'lajolla',
    limits = c(
      min(TBR_band_state_data_Glasser$TBR),
      max(TBR_band_state_data_Glasser$TBR)
    )
  ) +
  labs(x = NULL, y = NULL) +
  guides(x = "none", y = "none") +
  facet_grid(cols = vars(State), rows = vars(Group)) +
  #facet_wrap(~State, ncol = 6) +
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
  "output/plots/Paper_TBR_plot.svg",
  plot = TBR_plot,
  width = 20,
  height = 9,
  dpi = 2400
)
