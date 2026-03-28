psd_plot_data <- melted_psd |>
  left_join(demo_data) |>
  mutate(Group = if_else(Group == "AD_MCI", "AD", Group)) |>
  mutate(
    hemi = case_when(
      str_detect(ROI, "_lh") ~ "Left",
      str_detect(ROI, "_rh") ~ "Right",
      TRUE ~ NA_character_
    ),
    ROI = str_replace(ROI, "_[lr]h", "")
  )
psd_plot_data$Group <- fct_relevel(
  psd_plot_data$Group,
  c("LBD", "NC", "PD") #, "Gamma")
)
psd_plot <- psd_plot_data |>
  #filter(hemi == "Left") |>
  group_by(original, State, Frequency, Group) |>
  summarise(
    Power = mean(Power, na.rm = TRUE)
  ) |>
  ungroup() |>
  group_by(State, Frequency, Group) |>
  summarise(
    SE = sd(Power) / sqrt(n()),
    Power = mean(Power, na.rm = TRUE)
  ) |>
  ungroup() |>
  filter(Group %in% c("LBD", "NC", "PD")) |>
  ggplot(aes(x = Frequency, y = Power, fill = Group)) +
  #facet_grid(cols = vars(State), scales = "free_y") + #rows = vars(ROI),
  facet_wrap(~State, ncol = 6, scales = "free_y") +
  geom_ribbon(aes(ymin = Power - SE, ymax = Power + SE), alpha = 0.4) +
  geom_line(aes(y = Power, color = Group)) +
  xlab("Frequency (Hz)") +
  ylab("PSD (a.u.)") +
  theme(
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
    ),
    axis.text.y = element_blank(), # Removes y-axis text (numbers)
    axis.ticks.y = element_blank()
  )

# Save the power spectral density (PSD) plot to a file
# The plot is saved as "Grant_PSD.png" with specified dimensions and resolution
# - width: 11.69 inches
# - height: 2 inches
# - dpi: 500
# - limitsize: FALSE allows saving larger plots without size restrictions

ggsave(
  filename = "output/plots/Paper_PSD.svg",  # File name for saving the plot
  plot = psd_plot,             # The plot object to be saved
  width = 11.69,               # Width of the saved plot in inches
  height = 2,                  # Height of the saved plot in inches
  dpi = 500,                   # Resolution of the plot in dots per inch
  limitsize = FALSE            # Allow saving of plots larger than the default size limits
)


