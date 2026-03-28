# List of CRAN packages to install
cran_packages <- c(
  "tidyverse",
  "plotly",
  "ggimage",
  "ggcompare",
  "gginference",
  "reshape",
  "patchwork",
  "grid",
  "gggrid",
  "rsvg",
  "tidyr",
  "stringr",
  "ggsegGlasser",
  "ggseg",
  "gt",
  "ggpointless",
  "brainconn",
  "psych",
  "igraph",
  "ggraph",
  "tidygraph",
  "cowplot",
  "GGally",
  "ggpubr",
  "gtExtras",
  "ggthemes",
  "ggforce",
  "ggtext",
  "gtsummary",
  "Hmisc",
  "viridisLite",
  "viridis",
  "hrbrthemes",
  "deldir",
  "bslib",
  "broom",
  "purrr",
  "RVAideMemoire",
  "correlation",
  "pals",
  "paletteer",
  "parsnip",
  "scico",
  "caret",
  "randomForest",
  "ordinalForest",
  "flextable",
  "pROC",
  "MLmetrics",
  "ROCR",
  "precrec",
  "plotROC",
  "combiroc",
  "groupdata2"
)

# Install missing packages from CRAN
install_if_missing <- function(p) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
}

invisible(lapply(cran_packages, install_if_missing))

if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")

# Install from GitHub if needed
remotes::install_github("ggseg/ggseg") # for ggseg
remotes::install_github("ggseg/ggsegGlasser") # for ggsegGlasser
remotes::install_github("ericmjl/brainconn") # for brainconn (or another repo if needed)
