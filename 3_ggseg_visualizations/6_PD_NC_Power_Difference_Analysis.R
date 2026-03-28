load("output/RData/data_paper.RData")
PD_NC_state_data_for_diff <- data |>
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
  mutate(
    Power = mean(Power),
    .by = c(original, ROI, hemi, State, Band)
  ) |>
  distinct()
PD_NC_state_data_for_diff$Group <- factor(
  PD_NC_state_data_for_diff$Group,
  levels = c("PD", "NC")
)
res_diff_PD_NC <- PD_NC_state_data_for_diff |>
  filter(Group %in% c("PD", "NC")) |>
  group_by(State, ROI, hemi, Band) |>
  group_modify(
    ~ broom::tidy(
      RVAideMemoire::perm.t.test(
        Power ~ Group,
        data = .x,
        nperm = 200,
      )
    )
  ) |>
  mutate(
    difference = estimate1 - estimate2,
    Group = "PD v.s. NC"
  ) |>
  rename(PD = estimate1, NC = estimate2)
# |>
# mutate(difference = ifelse(q.value > 0.05, NA, difference))

res_diff_PD_NC_fdr <- res_diff_PD_NC |>
  ungroup() |>
  mutate(
    q.value = p.adjust(p.value, method = "fdr")
  ) |>
  mutate(difference = ifelse(q.value > 0.05, NA, difference))
save(res_diff_PD_NC_fdr, file = "output/RData/res_diff_PD_NC_fdr_NINA.RData")
#load("res_diff_AD_LBD_fdr_NINA.RData")
write_csv(res_diff_PD_NC_fdr, "output/csv/res_diff_PD_NC_fdr_NINA.csv")
glasser_state_diff_PD_NC_fdr <- ROI_Glasser |>
  left_join(res_diff_PD_NC_fdr, relationship = "many-to-many") |>
  rename(region = Region)

state_gdata_PD_NC_fdr <- glasser52 |>
  left_join(glasser_state_diff_PD_NC_fdr, relationship = "many-to-many")

g52 <- glasser52 |>
  filter(Band != "Gamma")
g52$Band <- fct_relevel(
  g52$Band,
  c("Delta", "Theta", "Alpha", "Beta")
)
state_gdata_PD_NC_fdr$Band <- fct_relevel(
  state_gdata_PD_NC_fdr$Band,
  c("Delta", "Theta", "Alpha", "Beta")
)
state_PD_NC_fdr <- state_gdata_PD_NC_fdr |>
  filter(Band != "Gamma") |>
  filter(Group == "PD v.s. NC") |>
  select(
    -c(
      "p.value",
      "q.value",
      "method",
      "alternative",
      "Group",
      "statistic",
      "PD",
      "NC"
    )
  ) |>

  ggplot() +
  geom_brain(
    atlas = g52,
    position = position_brain(hemi ~ side),
    aes(fill = difference)
  ) +
  # 
scale_fill_gradient2(
  low = "#2874a6", 
  mid = "white",
  high = "#cb4335",
  midpoint = 0,
  limits = c(
        -max(abs(state_gdata_PD_NC_fdr$difference), na.rm = TRUE),
        max(abs(state_gdata_PD_NC_fdr$difference), na.rm = TRUE)
      ),
  space = "Lab",          # Color space
  na.value = "grey50",    # Color for NA values
  guide = "colorbar"      # Type of legend
)+
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
  "output/plots/Paper_PD_NC_power_diff.svg",
  plot = state_PD_NC_fdr,
  width = 11.69,
  height = 5,
  dpi = 2400
)

write.csv(state_gdata_PD_NC_fdr, "output/csv/state_gdata_PD_NC_NINA_fdr.csv")
