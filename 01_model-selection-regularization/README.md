
# Module 01 · Model Selection & Regularization

## Research Question

> Which approach yields the best predictive performance for disease progression: variable selection, regularization, or latent feature extraction?
---

## Dataset

**Diabetes dataset** from the `lars` package (Efron, Hastie, Johnstone & Tibshirani, 2004).

- **442 patients**, 10 standardized clinical predictors
- **Target:** quantitative measure of disease progression one year after baseline
- **Predictors:** age, sex, BMI, mean arterial pressure (MAP), and 6 blood serum measurements (TC, LDL, HDL, TCH, LTG, glucose)
- **Split:** 70% training / 30% validation

---

## Methods

### 1. Variable Selection
Three search strategies evaluated across four criteria (Cp, AIC, BIC, Adjusted R²):

| Method | AIC-optimal predictors |
|--------|----------------------|
| Best Subset Selection | 6 |
| Forward Stepwise | 6 |
| Backward Stepwise | 6 |

AIC and Cp were prioritized over BIC for prediction tasks (minimize out-of-sample error). All three methods converged on the same 6-predictor model: **sex, BMI, MAP, TC, TCH, LTG**.

Best model equation (Backward Stepwise, AIC):
```
ŷ = 152.71 − 179.77(sex) + 592.56(bmi) + 324.60(map) − 294.47(tc) + 278.13(tch) + 513.17(ltg)
```

### 2. Shrinkage Methods
10-fold cross-validation used to select optimal penalty parameter λ:

| Method | λ (min) | Active predictors | Zeroed out |
|--------|---------|-------------------|------------|
| Ridge (α=0) | 8.52 | 10 (all, shrunk) | none |
| Lasso (α=1) | 1.07 | 8 | TCH, glucose |

Ridge retains all predictors with shrunk coefficients. Lasso performs automatic feature selection, zeroing out `tch` and `glu`.

### 3. Dimension Reduction
Cross-validated MSEP used to select optimal number of components:

| Method | Optimal components |
|--------|-------------------|
| Principal Component Regression (PCR) | 7 |
| Partial Least Squares (PLS) | 3 |

PLS achieves a comparable fit using only 3 components vs PCR's 7 — because PLS components are constructed to maximize covariance with the outcome, not just variance in X.

---

## Results — Validation Set Comparison
<img width="396" height="167" alt="image" src="https://github.com/user-attachments/assets/55aa6963-3442-4441-96ff-f5cf8f58af78" />


**Variable selection and shrinkage methods significantly outperformed dimension reduction.** PCR and PLS performed poorly because the diabetes predictors already have relatively direct linear relationships with the outcome — compressing them into latent components introduces information loss rather than removing noise.

---

## PCA Deep-Dive (Kaiser Criterion)

Separate PCA was performed on the 10 predictors to identify dominant variance structure:

- **PC1** (40.24% variance): No single dominant variable — moderate contributions across all 10 predictors in mixed directions. Cannot be given a single clinical interpretation.
- **PC2** (14.92% variance): Driven by **total cholesterol (TC = 0.573)** and **HDL (0.506)** — reflects cholesterol composition and cardiovascular risk.
- **PC3** (12.06% variance): Driven by **mean arterial pressure (MAP = 0.514)** — reflects blood pressure status.

**Total variance explained by PC1–PC3: 67.23%**

---

## Key Takeaways

- For this dataset, **sparse linear models using ~6 predictors** provide the best predictive performance
- Shrinkage methods (Ridge, Lasso) are competitive alternatives when interpretability of individual coefficients is not required
- Dimension reduction (PCR, PLS) is less effective here because the predictors already exhibit relatively direct linear relationships with the outcome — they do not benefit from being compressed into latent components
- **Multicollinearity** is present in the full model but is handled differently across methods: stepwise selection removes redundant variables, Lasso zeros them out, and Ridge shrinks all coefficients proportionally

---

## Files

```
01_model-selection-regularization/
├── model_selection_regularization.R   # Full R script with all methods
└── README.md
```

---

## How to Run

```r
# Install required packages
install.packages(c("lars", "leaps", "glmnet", "pls"))

# Load and run
source("model_selection_regularization.R")
```

> **Note:** The `lars` package provides the diabetes dataset used throughout. Set `set.seed(123)` is included for reproducibility.

---

## References

- Efron, B., Hastie, T., Johnstone, I., & Tibshirani, R. (2004). Least angle regression. *Annals of Statistics*, 32(2), 407–499.
- James, G., Witten, D., Hastie, T., & Tibshirani, R. (2021). *An Introduction to Statistical Learning* (2nd ed.). Springer.
