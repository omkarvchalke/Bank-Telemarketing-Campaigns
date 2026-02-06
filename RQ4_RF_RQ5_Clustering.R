###############################################################################
# 05_rq4_rf_rq5_clustering.R — RQ4: Random Forest, RQ5: Clustering
###############################################################################

source("Setup.R")
install_if_missing(PKGS)

splits <- readRDS(SPLIT_DATA_RDS)
train_data <- splits$train_data
test_data  <- splits$test_data

# --- RQ4: Random Forest ---
rf_model <- randomForest(
  client_subscribed_factor ~ age + avg_bank_balance + no_of_campaigns +
    previous_no_of_contacts + previous_outcome + month + day +
    contact_type + campaign_intensity + previous_contacts + contact_duration,
  data = train_data,
  ntree = 500,
  importance = TRUE
)

rf_class <- predict(rf_model, test_data)
rf_prob  <- predict(rf_model, test_data, type = "prob")[, "yes"]

rf_cm <- confusionMatrix(rf_class, test_data$client_subscribed_factor)
cat("\nConfusion Matrix (RF):\n")
print(rf_cm)

rf_roc <- roc(test_data$client_subscribed_factor, rf_prob, levels = c("no","yes"))
rf_auc <- auc(rf_roc)
cat("\nAUC (RF):", round(rf_auc, 3), "\n")

save_plot_png(file.path(DIR_PLOTS, "rq4_roc_rf.png"), {
  plot(rf_roc, main = "ROC Curve (Random Forest)")
  abline(a = 0, b = 1, lty = 2)
  text(0.5, 0.5, paste("AUC =", round(rf_auc, 3)))
})

imp_df <- as.data.frame(importance(rf_model))
imp_df$feature <- rownames(imp_df)

p_imp <- ggplot(imp_df, aes(x = reorder(feature, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(title = "RF Feature Importance", x = "Feature", y = "Mean Decrease Gini")

ggsave(file.path(DIR_PLOTS, "rq4_feature_importance.png"), p_imp, width = 10, height = 7)
write.csv(imp_df, file.path(DIR_OUT, "rq4_feature_importance.csv"), row.names = FALSE)

cat("\nSaved RQ4 outputs:\n")
cat("- CSV:", file.path(DIR_OUT, "rq4_feature_importance.csv"), "\n")
cat("- Plots:", DIR_PLOTS, "\n")

# --- RQ5: Clustering ---
data <- readRDS(CLEAN_DATA_RDS)

cluster_features <- c("age","avg_bank_balance","no_of_campaigns","previous_no_of_contacts","contact_duration")
cluster_data <- scale(data[, cluster_features])

# Elbow
wss <- sapply(1:10, function(k) kmeans(cluster_data, centers = k, nstart = 10)$tot.withinss)
save_plot_png(file.path(DIR_PLOTS, "rq5_elbow.png"), {
  plot(1:10, wss, type = "b", xlab = "k", ylab = "Within-cluster SS", main = "Elbow Method")
})

# K-means
set.seed(123)
k <- 6
km <- kmeans(cluster_data, centers = k, nstart = 25)
data$kmeans_cluster <- factor(km$cluster)

save_plot_png(file.path(DIR_PLOTS, "rq5_kmeans_clusters.png"), {
  print(fviz_cluster(km, data = cluster_data, geom = "point",
                     ellipse.type = "convex", ggtheme = theme_minimal()))
})

# Hierarchical clustering
hc <- hclust(dist(cluster_data), method = "ward.D2")
save_plot_png(file.path(DIR_PLOTS, "rq5_hc_dendrogram.png"), {
  plot(hc, main = "Hierarchical Clustering Dendrogram", xlab = "", sub = "")
})

hc_clusters <- cutree(hc, k = k)
data$hc_cluster <- factor(hc_clusters)

save_plot_png(file.path(DIR_PLOTS, "rq5_hc_clusters.png"), {
  print(fviz_cluster(list(data = cluster_data, cluster = hc_clusters),
                     geom = "point", ellipse.type = "convex", ggtheme = theme_minimal()))
})

# Cluster subscription rates
cluster_rates <- data %>%
  group_by(kmeans_cluster) %>%
  summarise(subscription_rate = mean(client_subscribed_bin), .groups = "drop")

write.csv(cluster_rates, file.path(DIR_OUT, "rq5_cluster_subscription_rates.csv"), row.names = FALSE)

p_rates <- ggplot(cluster_rates, aes(x = kmeans_cluster, y = subscription_rate, fill = kmeans_cluster)) +
  geom_col() +
  geom_text(aes(label = scales::percent(subscription_rate, accuracy = 0.1)), vjust = -0.3) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal() +
  labs(title = "Subscription Rates by K-means Cluster",
       x = "Cluster", y = "Subscription Rate")

ggsave(file.path(DIR_PLOTS, "rq5_cluster_subscription_rates.png"), p_rates, width = 8, height = 5)

cat("\nSaved RQ5 outputs:\n")
cat("- CSV:", file.path(DIR_OUT, "rq5_cluster_subscription_rates.csv"), "\n")
cat("- Plots:", DIR_PLOTS, "\n")
