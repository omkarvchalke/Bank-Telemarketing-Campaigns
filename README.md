**📞 Bank Telemarketing Campaign Analysis**

This project analyzes a bank’s telemarketing campaign data to understand **what drives term deposit subscriptions** and to build models that support **better targeting and campaign efficiency**.

---

**📂 Project Structure**

├── Setup.R # Packages, helper functions, output folders  
├── Data_Cleaning.R # Load + clean + feature engineering + train/test split  
├── Data_Analysis.R # Quick EDA + baseline plots  
├── RQ1_Logistic.R # RQ1: Logistic regression + odds ratios + ROC/AUC  
├── RQ2_ChiSq_RQ3_Survival.R # RQ2: Chi-square + RQ3: Survival analysis  
├── RQ4_Rf_RQ5_Clustering.R # RQ4: Random Forest + RQ5: Clustering  
├── train.csv # Input 
├── test.csv # Input 
└── outputs/  
    └── PLOTS/ # All saved plots (.png)

---

**🔬 Research Questions**

1. RQ1 — Logistic Regression: Identify key predictors of subscription, interpret via odds ratios, and evaluate using ROC/AUC.  
2. RQ2 — Chi-square Tests: Test association between demographic variables (job, education, marital status) and subscription outcome.  
3. RQ3 — Survival Analysis: Kaplan–Meier and Cox models using time since last contact and prior campaign outcomes.  
4. RQ4 — Random Forest: Predict subscription outcome and rank important features.  
5. RQ5 — Clustering: Segment customers using K-means (and compare with hierarchical clustering) to support targeted strategies.

---

**🧪 Techniques Used**
- Data cleaning & feature engineering (`dplyr`, `tidyverse`)  
- Logistic regression + odds ratios + VIF + confusion matrix + ROC/AUC  
- Chi-square tests (`chisq.test`)  
- Survival analysis (`survival`, `survminer`)  
- Random Forest (`randomForest`, `caret`, `pROC`)  
- Clustering (`kmeans`, `hclust`, `factoextra`)

