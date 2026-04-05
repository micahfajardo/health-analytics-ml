# Project 03 · Regression

A regression modeling series covering multiple linear regression with AIC stepwise selection and interaction terms, polynomial regression for nonlinear effects, and Poisson GLM for count outcomes.

---

## Research Questions

> 1. What factors drive annual physician compensation, and does log-transformation improve model fit? *(Multiple Linear Regression)*
> 2. Does BMI have a nonlinear (quadratic) effect on systolic blood pressure? *(Polynomial Regression)*
> 3. How do air pollution, heat, and weekend status predict daily asthma ER visits? *(Poisson GLM)*

---

## Datasets

| Dataset | n | Target | Predictors |
|---------|---|--------|------------|
| Physician compensation | 33 | Annual compensation (USD) | Patient volume (x1), operating surplus (x2), employment size (x3) |
| BMI–SBP clinical | 20 | Systolic BP (mmHg) | BMI (kg/m²) |
| Asthma ER visits | 14 | Daily ER visit count | PM2.5, heat index, weekend indicator, population offset |

---

## Methods & Results

### A · Multiple Linear Regression — Physician Compensation

**Full model (log-transformed predictors):**
```
ŷ = −261.19 − 6.32·ln(x1) + 56.04·ln(x2) + 42.69·ln(x3)
```

No significant coefficients detected in the full model due to **high multicollinearity** (VIF > 5.3 for all variables). The F-test remained significant (F = 10.15, p < 0.0001), meaning the variables *jointly* predict compensation — but their individual effects cannot be isolated.

**After stepwise selection (removing x1 and x2):**
```
ŷ = −418.35 + 81.97·(x3)
```
Employment size (x3) is the only significant predictor (p < 0.05). Interpretation: as employment size increases, annual physician compensation increases proportionally. R² = 0.469 — employment size alone explains ~46.9% of compensation variance.

**Log vs standard regression comparison:**

| Criterion | Log-transformed | Standard |
|-----------|----------------|----------|
| Residuals vs fitted | Scattered (better) | Left-skewed (worse) |
| Scale-location | More homoscedastic | Funnel-shaped |
| Shapiro-Wilk normality | Both p > 0.05 ✓ | Both p > 0.05 ✓ |
| Multicollinearity (full) | VIF > 5.3 (present) | VIF > 5.3 (present) |
| Multicollinearity (reduced) | None | None |

**Conclusion:** Log-transformed models provide better residual behavior and are preferred for this dataset.

---

### B · Multiple Linear Regression — Vaccination Uptake (AIC + Interactions)

**AIC stepwise selection** applied to a vaccination uptake dataset (n=15) with 4 predictors.

**Base model (R² = 0.997, F = 1200, p < 10⁻¹⁴):**
```
ŷ = 178.52 + 2.11·(x1) + 3.56·(x2) − 22.19·(x3)
```

- x1 (outreach events) and x2 (active enrollees): positive drivers of uptake
- x3 (competing providers): strong negative driver

**Model with interaction terms (R² = 0.999, AIC = 38.78):**
```
ŷ = 153.22 + 6.38·x1 + 3.20·x2 − 17.15·x3 + 0.048·(x1·x2) − 0.781·(x1·x3)
```

Key interaction finding: the **x1 × x3 interaction** is significantly negative — outreach programs are *less effective* in areas with competing vaccine providers, an operationally meaningful result.

---

### C · Polynomial Regression — BMI and Systolic Blood Pressure

Physicians suspected a nonlinear relationship: SBP rises slowly at moderate BMI but accelerates at higher BMI values.

**Linear model:**
```
SBP = 41.23 + 3.26·BMI
```

**Quadratic model:**
```
SBP = 153.32 − 5.12·BMI + 0.150·BMI²
```

| Metric | Linear | Quadratic |
|--------|--------|-----------|
| R² | high | higher |
| F-statistic p-value | < 0.05 | < 0.05 (lower) |
| Fit | Underestimates at extremes | Follows curvature |

The positive coefficient on BMI² confirms a **convex (accelerating) relationship**: hypertensive risk compounds as patients move into higher BMI brackets — confirming the clinical hypothesis.

---

### D · Poisson GLM — Asthma ER Visits

**Model with population offset (rate per 120,000 population):**
```
log(λ) = −12.80 + 0.017·PM2.5 + 0.084·Heat + 0.067·Weekend + log(Population)
```

All predictors show positive associations with ER visits: each unit increase in heat index is associated with an ~8.8% increase in visit rate (e^0.084). However, **none reached statistical significance (p > 0.05)** due to the small sample (n=14) and multicollinearity between PM2.5 and heat (VIF > 5.3).

**After AIC stepwise selection:**
```
log(λ) = −15.05 + 0.166·Heat + log(Population)
```

Removing PM2.5 (which was collinear with heat) results in a lower AIC and heat becoming statistically significant. This reduced model is preferred for interpretation and deployment.

---

## Key Takeaways

- **Multicollinearity is the most common failure mode** in multiple regression. All three datasets showed VIF issues in the full model — resolved by stepwise variable elimination or collinear variable removal.
- **Log transformation improves model assumptions** when predictors are right-skewed, producing more homoscedastic residuals and better Q-Q plot behavior.
- **Interaction terms reveal operational insights** that main effects miss. The negative x1×x3 interaction (outreach × competition) is a finding that would not appear in a main-effects-only model.
- **Polynomial regression is appropriate when subject-matter expertise suggests nonlinearity.** The quadratic BMI–SBP result confirms a clinically hypothesized curvature — this should be standard practice in health data modeling.
- **Poisson GLM requires careful handling of offsets** when modeling rates rather than raw counts. Population size must be included as an offset (not a predictor) to correctly model the rate per person.

---

## Files

```
03_regression/
├── regression_models.R
└── README.md
```

---

## How to Run

```r
install.packages("MASS")
source("regression.R")
```
