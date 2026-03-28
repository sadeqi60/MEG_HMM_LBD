# Load necessary libraries and data
source("libraries/libraries.R")

# Load the Glasser parcellation
load("data/glasser52.RData")
load("data/ROI_Glasser.RData")

# Load the power spectral density data
load("data/melted_psd.RData")

# Load the frequency interval data
load("data/fo_lt_intv_sr_tidy.RData")

# Load the summary data
load("data/summary_data.RData")

# Load the Glasser states with differences

load("data/glasser_states_df_dif_tidy.RData")

# Load the Glasser states
load("data/glasser_states_df_tidy.RData")

# Load the power spectral density data
load("data/psd.RData")

# Load the demographic data
load("data/psd_demo.RData")

# Create output directories
dir.create("output/RData", recursive = TRUE, showWarnings = FALSE)
dir.create("output/csv", recursive = TRUE, showWarnings = FALSE)
dir.create("output/plots", recursive = TRUE, showWarnings = FALSE)



# Select the the closed-eyes resting-state data
pattern <- paste(c("_C_","sub"), collapse = "|")
selected_subjects <- psd_demo |>
  dplyr::filter(stringr::str_detect(original, pattern))

# Select the IDs of the selected subjects
selected_id <- selected_subjects$original

# Exlude the following subjects from the analysis
# The following subjects are outliers:
# NINA013_C_R3_S1, NINA008_C_R1_S1, NINA008_C_R2_S1, NINA016_C_R2_S1,
# NINA016_C_R3_S1, NINA016_C_R4_S1, NINA004_C_R1_S1, NINA004_C_R1_S2,
# NINA004_C_R2_S1, NINA004_C_R3_S1, NINA004_C_R4_S1, NINA004_C_R5_S1
# selected_id <- selected_id[
#   !selected_id %in%
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
# ]


# Clean up the PSD data
psd_data <- psd[selected_id, , , , drop = FALSE]

# Melt the PSD data
melted_psd <- melt(psd_data)

# Standardize the column names
colnames(melted_psd) <- c("original", "State", "ROI", "Frequency", "Power")

# Assign bands to the PSD data
melted_psd$Band <- case_when(
  melted_psd$Frequency < 4 ~ "Delta",
  melted_psd$Frequency >= 4 & melted_psd$Frequency < 8 ~ "Theta",
  melted_psd$Frequency >= 8 & melted_psd$Frequency < 13 ~ "Alpha",
  melted_psd$Frequency >= 13 & melted_psd$Frequency < 30 ~ "Beta",
  melted_psd$Frequency >= 30 ~ "Gamma"
)

# Select relevant demographic data and filter by selected IDs
demo_data <- psd_demo %>%
  select(
    ID,
    Age,
    Group,
    original,
    EDU,
    Duration,
    Sex,
    CAF,
    MFS,
    ODF,
    MOCA,
    UPDRS_Part_III,
    MSQ_Partner_Q1_RBD,
    MSQ_Partner_Q8_DoA,
    MSQ_Patient_HC_Q1_RBD,
    MSQ_Patient_HC_Q8_DoA,
    NPI_Q_VH,
    CDR_SB
  ) %>%
  mutate(NPI_Q_VH = sign(NPI_Q_VH)) %>%
  filter(original %in% selected_id)

# Save the cleaned demographic data
save(demo_data, file = "output/RData/demo_paper.RData")
write_csv(demo_data, "output/csv/demo_paper.csv")

# Load and filter dynamic data by selected IDs
dyn_data <- fo_lt_intv_sr_tidy %>%
  rename(original = ID) %>%
  filter(original %in% selected_id)

# Calculate the mean power for each group, state, ROI, and band
# This is used for the power spectral density analysis
data1 <- melted_psd |>
  # Join the demographic data to the PSD data
  left_join(demo_data) |>
  # Group the data by the relevant variables
  group_by(original, State, ROI, Group, Band) |>
  # Calculate the mean power for each group
  summarise(
    Power = mean(Power),
  ) |>
  # Ungroup the data
  ungroup()

# Calculate the mean power for each group, state, ROI, and band
# This is used for the power spectral density analysis
data2 <- dyn_data |>
  # Join the demographic data to the dynamic data
  left_join(demo_data) |>
  # Pivot the data to have separate columns for each variable
  pivot_wider(names_from = Variable, values_from = Measures) |>
  # Select only the relevant columns
  select(
    "original",
    "ID",
    "Age",
    "Sex",
    "Group",
    "State",
    "Fractional Occupancy",
    "Mean Life Time (s)",
    "Mean Interval (s)",
    "Switching Rate (Hz)",
    "CAF",
    "MFS",
    "ODF",
    "MOCA",
    "UPDRS_Part_III",
    "MSQ_Partner_Q1_RBD",
    "MSQ_Partner_Q8_DoA",
    "MSQ_Patient_HC_Q1_RBD",
    "MSQ_Patient_HC_Q8_DoA",
    "NPI_Q_VH",
    "CDR_SB"
  )

# Combine the dynamic data with the demographic data
data <- data1 |>
  left_join(data2)

# Recode the group column to replace AD_MCI with AD
data <- data |> mutate(Group = if_else(Group == "AD_MCI", "AD", Group))

# Save the data to a file
save(data, file = "output/RData/data_paper.RData")

# Write the data to a CSV file
write_csv(data, "output/csv/data_paper.csv")
