###############################################################################
# 02_data_analysis.R — EDA / sanity checks
###############################################################################

source("Setup.R")
install_if_missing(PKGS)

data <- readRDS(CLEAN_DATA_RDS)

cat("\nDataset shape:\n")
print(dim(data))

cat("\nTarget distribution:\n")
print(table(data$client_subscribed_factor))
print(prop.table(table(data$client_subscribed_factor)))

cat("\nSummary (numeric variables):\n")
print(summary(select(data, where(is.numeric))))

p1 <- ggplot(data, aes(x = client_subscribed_factor)) +
  geom_bar() +
  theme_minimal() +
  labs(title = "Subscription Outcome Distribution", x = "Subscribed", y = "Count")

ggsave(file.path(DIR_PLOTS, "eda_target_dist.png"), p1, width = 7, height = 5)
cat("\nSaved plot:", file.path(DIR_PLOTS, "eda_target_dist.png"), "\n")
