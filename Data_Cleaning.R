###############################################################################
# 01_data_cleaning.R — load, clean, feature engineer, split, save
###############################################################################

source("Setup.R")
install_if_missing(PKGS)

if (!file.exists(TRAIN_FILE)) stop("train.csv not found in project directory.")
if (!file.exists(TEST_FILE))  stop("test.csv not found in project directory.")

raw_data <- bind_rows(
  read.csv(TEST_FILE,  sep = ";", header = TRUE, stringsAsFactors = FALSE),
  read.csv(TRAIN_FILE, sep = ";", header = TRUE, stringsAsFactors = FALSE)
)

numeric_cols <- c(
  "age","avg_bank_balance","contact_duration",
  "no_of_campaigns","no_of_days_since_last_contact",
  "previous_no_of_contacts"
)

categorical_cols <- c(
  "job","marital_status","education","credit_default",
  "housing_loan","personal_loan","contact_type","month",
  "previous_outcome"
)

data <- raw_data %>%
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  rename(
    marital_status                = marital,
    credit_default                = default,
    avg_bank_balance              = balance,
    housing_loan                  = housing,
    personal_loan                 = loan,
    contact_type                  = contact,
    contact_duration              = duration,
    no_of_campaigns               = campaign,
    no_of_days_since_last_contact = pdays,
    previous_no_of_contacts       = previous,
    previous_outcome              = poutcome,
    client_subscribed             = y
  ) %>%
  mutate(
    previous_contacts  = ifelse(previous_no_of_contacts > 0, 1, 0),
    campaign_intensity = cut(
      no_of_campaigns,
      breaks = c(0, 1, 5, 10, Inf),
      labels = c("Low","Medium","High","Very High"),
      include.lowest = TRUE
    )
  ) %>%
  mutate(across(all_of(numeric_cols), as.numeric)) %>%
  mutate(across(all_of(numeric_cols), zscore)) %>%
  mutate(across(all_of(categorical_cols), as.factor)) %>%
  distinct() %>%
  mutate(
    client_subscribed_factor = factor(client_subscribed, levels = c("no","yes")),
    client_subscribed_bin    = as.integer(client_subscribed == "yes")
  )

cat("\nMissing values (non-zero only):\n")
na_counts <- colSums(is.na(data))
print(na_counts[na_counts > 0])

train_index <- createDataPartition(data$client_subscribed_factor, p = 0.7, list = FALSE)
train_data  <- data[train_index, ]
test_data   <- data[-train_index, ]

saveRDS(data, CLEAN_DATA_RDS)
saveRDS(list(train_data = train_data, test_data = test_data), SPLIT_DATA_RDS)

cat("\nSaved artifacts:\n")
cat("-", CLEAN_DATA_RDS, "\n")
cat("-", SPLIT_DATA_RDS, "\n")
cat("Plots folder:", DIR_PLOTS, "\n")
