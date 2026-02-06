###############################################################################
# 00_setup.R — packages, helpers, config
###############################################################################

set.seed(123)

PKGS <- c(
  "dplyr","tidyr","readr","caret","pROC","ggplot2","car",
  "survival","survminer","randomForest",
  "cluster","factoextra","NbClust","fpc","scales"
)

install_if_missing <- function(pkgs) {
  missing <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
  if (length(missing) > 0) {
    install.packages(missing, repos = "https://cloud.r-project.org")
  }
  invisible(lapply(pkgs, library, character.only = TRUE))
}

zscore <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

# Output folders
DIR_OUT   <- "outputs"
DIR_PLOTS <- file.path(DIR_OUT, "PLOTS")

if (!dir.exists(DIR_OUT)) dir.create(DIR_OUT, recursive = TRUE)
if (!dir.exists(DIR_PLOTS)) dir.create(DIR_PLOTS, recursive = TRUE)

# Input files expected in project root
TRAIN_FILE <- "train.csv"
TEST_FILE  <- "test.csv"

# Output artifacts
CLEAN_DATA_RDS <- file.path(DIR_OUT, "clean_data.rds")
SPLIT_DATA_RDS <- file.path(DIR_OUT, "split_data.rds")

save_plot_png <- function(filename, plot_expr, width = 900, height = 700) {
  png(filename, width = width, height = height)
  on.exit(dev.off(), add = TRUE)
  force(plot_expr)
}
