###############################################################################
# 04_rq2_chisq_rq3_survival.R — RQ2: Chi-square, RQ3: Survival
###############################################################################

source("Setup.R")
install_if_missing(PKGS)

data <- readRDS(CLEAN_DATA_RDS)

plot_stacked_bar <- function(tbl, xlab, title) {
  df <- as.data.frame(tbl)
  ggplot(df, aes(x = Var1, y = Freq, fill = Var2)) +
    geom_col() +
    theme_minimal() +
    labs(x = xlab, y = "Count", fill = "Subscribed", title = title) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# --- RQ2: Chi-square tests ---
tbl_job <- table(data$job, data$client_subscribed_factor)
tbl_edu <- table(data$education, data$client_subscribed_factor)
tbl_mar <- table(data$marital_status, data$client_subscribed_factor)

chi_job <- chisq.test(tbl_job)
chi_edu <- chisq.test(tbl_edu)
chi_mar <- chisq.test(tbl_mar)

cat("\nChi-square results:\n")
print(chi_job); print(chi_edu); print(chi_mar)

write.csv(
  data.frame(
    test = c("job","education","marital_status"),
    statistic = c(chi_job$statistic, chi_edu$statistic, chi_mar$statistic),
    df = c(chi_job$parameter, chi_edu$parameter, chi_mar$parameter),
    p_value = c(chi_job$p.value, chi_edu$p.value, chi_mar$p.value)
  ),
  file.path(DIR_OUT, "rq2_chisq_summary.csv"),
  row.names = FALSE
)

p_job <- plot_stacked_bar(tbl_job, "Job", "Job vs Subscription Outcome")
p_edu <- plot_stacked_bar(tbl_edu, "Education", "Education vs Subscription Outcome")
p_mar <- plot_stacked_bar(tbl_mar, "Marital Status", "Marital Status vs Subscription Outcome")

ggsave(file.path(DIR_PLOTS, "rq2_job_plot.png"), p_job, width = 10, height = 6)
ggsave(file.path(DIR_PLOTS, "rq2_education_plot.png"), p_edu, width = 10, height = 6)
ggsave(file.path(DIR_PLOTS, "rq2_marital_plot.png"), p_mar, width = 10, height = 6)

cat("\nSaved RQ2 plots in:", DIR_PLOTS, "\n")

# --- RQ3: Survival analysis ---
surv_object <- Surv(
  time  = data$no_of_days_since_last_contact,
  event = data$client_subscribed_bin
)

km_fit <- survfit(surv_object ~ 1, data = data)
km_fit_strat <- survfit(surv_object ~ previous_outcome, data = data)

save_plot_png(file.path(DIR_PLOTS, "rq3_km_overall.png"), {
  print(ggsurvplot(km_fit, data = data, conf.int = TRUE, title = "Kaplan-Meier Survival Curve"))
})

save_plot_png(file.path(DIR_PLOTS, "rq3_km_by_prev_outcome.png"), {
  print(ggsurvplot(km_fit_strat, data = data, title = "Kaplan-Meier by Previous Outcome"))
})

cox_model <- coxph(
  surv_object ~ no_of_days_since_last_contact + previous_no_of_contacts + previous_outcome,
  data = data
)

cat("\nCox model summary:\n")
print(summary(cox_model))

save_plot_png(file.path(DIR_PLOTS, "rq3_cox_forest.png"), {
  print(ggforest(cox_model, data = data))
})

cat("\nSaved RQ3 plots in:", DIR_PLOTS, "\n")
