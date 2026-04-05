# Applied Machine Learning on Clinical and Healthcare Data

## Overview

This repository demonstrates end-to-end implementations of core machine learning and statistical learning methods applied  to clinical and health datasets. Each module discusses the clinical problems, modeling decisions, and interpretion of the model results.

## Repository Structure

```
health-analytics-ml/
├── 01_model-selection-regularization/
│   ├── model_selection_regularization.R
│   └── README.md
├── 02_classification/
│   ├── classification.R
│   └── README.md
├── 03_regression/
│   ├── regression.R
│   └── README.md
├── 04_bootstrapping-clt/
│   ├── bootstrapping_clt.R
│   └── README.md
└── README.md
```

---

## Projects

### [01 · Model Selection & Regularization](./01_model-selection-regularization/)

Predicting diabetes disease progression from 10 clinical measurements using five competing approaches. Full validation-set RMSE comparison across all methods.

- **Variable selection:** Best Subset, Forward Stepwise, Backward Stepwise (AIC/BIC/Cp/Adjusted R²)
- **Shrinkage:** Lasso (α=1) and Ridge (α=0) regression with 10-fold cross-validated λ
- **Dimension reduction:** Principal Component Regression (PCR) and Partial Least Squares (PLS)
- **PCA:** Kaiser Criterion, scree plot, PC loadings — identifying dominant clinical variance structure

`leaps` · `glmnet` · `pls` · `lars`

---

### [02 · Classification](./02_classification/)

Multi-method classification pipeline on two clinical datasets, with full evaluation using confusion matrices, sensitivity, specificity, and cross-validation.

- **Binary logistic regression:** Diabetes prediction with train-test split and 10-fold CV comparison
- **Multinomial logistic regression:** 3-class health state transition modeling with odds ratio interpretation
- **Linear Discriminant Analysis (LDA):** Discriminant function derivation, hit ratio, per-class sensitivity/specificity
- **KNN vs Naïve Bayes:** Hyperparameter tuning (k=5 to 23), Kappa comparison, clinical error analysis

`nnet` · `MASS` · `caret` · `e1071` · `mlbench` · `hesim`

---

### [03 · Regression](./03_regression/)

Regression modeling series across three clinical research questions, with residual diagnostics, multicollinearity checks, and model comparison throughout.

- **Multiple linear regression:** AIC stepwise selection, interaction terms, log vs standard specification comparison
- **Polynomial regression:** Quadratic modeling of BMI–SBP nonlinearity, curvature interpretation
- **Poisson GLM:** Count outcome modeling with population offset, VIF diagnosis, stepwise refinement

`MASS` · `stats` · GLM · Shapiro-Wilk · VIF

---

### [04 · Bootstrapping & CLT](./04_bootstrapping-clt/)

Statistical inference through simulation on a hospital operations dataset.

- **Bootstrap CI:** Manual implementation (no packages) of 99% bootstrap confidence interval for average length of stay (R=200 resamples)
- **CLT simulation:** Sample mean convergence from Binomial(5, 0.3) across n=10, 1,000, 10,000 repetitions
- **Correlation analysis:** Pearson correlation matrix and corrplot across 8 hospital operational variables

`base R` · `corrplot`

---

## Tools & Environment

| Tool | Purpose |
|------|---------|
| R (base) | Core language |
| `glmnet` | Lasso & Ridge regression |
| `leaps` | Subset & stepwise selection |
| `pls` | PCR & PLS regression |
| `caret` | Cross-validation framework |
| `MASS` | LDA, stepwise AIC |
| `nnet` | Multinomial logistic regression |
| `e1071` · `klaR` | Naïve Bayes |
| `mlbench` | Pima Indians Diabetes dataset |
| `hesim` | Health state transition data |
| `lars` | Diabetes dataset (Efron et al.) |
| `corrplot` | Correlation visualization |

---

## Datasets

| Dataset | Source | Project |
|---------|--------|--------|
| Diabetes (442 patients, 10 clinical predictors) | `lars` package — Efron et al. (2004) | 01 |
| Pima Indians Diabetes (768 patients) | `mlbench` — UCI ML Repository | 02 |
| Health state transitions | `hesim` package | 02 |
| Hospital operations (8 operational metrics) | Clinical dataset | 04 |
