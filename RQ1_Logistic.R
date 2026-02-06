###############################################################################
# 03_rq1_logistic.R — RQ1: Logistic Regression + OR + ROC/AUC
###############################################################################

source("Setup.R")
install_if_missing(PKGS)

splits <- readRDS(SPLIT_DATA_RDS)
train_data <- splits$train_data
test_data  <- splits$test_data

logit_model <- glm(
  client_subscribed_bin ~ age + job + marital_status + education + credit_default +
    avg_bank_balance + housing_loan + personal_loan + contact_type +
    contact_duration + no_of_campaigns + no_of_days_since_last_contact +
    previous_no_of_contacts + previous_outcome,
  data = train_data,
  family = binomial()
)

cat("\nLogistic regression summary:\n")
print(summary(logit_model))

odds_ratios <- exp(coef(logit_model))
conf_int    <- exp(confint(logit_model))

odds_df <- data.frame(
  Variable   = names(odds_ratios),
  Odds_Ratio = odds_ratios,
  CI_Lower   = conf_int[, 1],
  CI_Upper   = conf_int[, 2],
  row.names  = NULL
)

write.csv(odds_df, file.path(DIR_OUT, "rq1_odds_ratios.csv"), row.names = FALSE)
cat("\nSaved:", file.path(DIR_OUT, "rq1_odds_ratios.csv"), "\n")

probs <- predict(logit_model, newdata = test_data, type = "response")
pred  <- ifelse(probs > 0.5, 1, 0)

cm <- confusionMatrix(
  factor(pred, levels = c(0, 1)),
  factor(test_data$client_subscribed_bin, levels = c(0, 1))
)
cat("\nConfusion Matrix:\n")
print(cm)

cat("\nVIF:\n")
print(vif(logit_model))

roc_curve <- roc(test_data$client_subscribed_bin, probs)
auc_value <- auc(roc_curve)
cat("\nAUC:", round(auc_value, 3), "\n")

save_plot_png(file.path(DIR_PLOTS, "rq1_roc_logit.png"), {
  plot(roc_curve, main = "ROC Curve (Logistic Regression)")
  text(0.8, 0.2, paste("AUC =", round(auc_value, 3)))
})

cat("\nSaved plot:", file.path(DIR_PLOTS, "rq1_roc_logit.png"), "\n")
