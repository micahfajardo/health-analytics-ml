
# Project 02 · Classification Models

A multi-method classification pipeline applied to two clinical datasets, comparing Binary Logistic Regression, Multinomial Logistic Regression, Linear Discriminant Analysis (LDA), K-Nearest Neighbors (KNN), and Naïve Bayes.

---

## Research Questions

> 1. What patient characteristics predict Type 2 Diabetes diagnosis? *(Binary)*
> 2. Among healthy patients, how do treatment strategy, sex, age, and follow-up period affect the probability of transitioning to a Healthy, Sick, or Dead state? *(Multiclass)*

---

## Datasets

| Dataset | Source | Task | n |
|---------|--------|------|---|
| Logistic regression dataset | Course-provided (clinical) | Binary classification | 145 |
| Pima Indians Diabetes | `mlbench` (UCI ML Repo) | Binary classification (KNN, NB) | 768 |
| hesim multinom3 transitions | `hesim` package | 3-class classification | ~15,000 |

---

## Methods & Results

### A · Binary Logistic Regression — Diabetes Prediction

**Data split:** 75% training / 25% test set. Variables with p < 0.05 retained in final model.

**Final model (significant predictor only: Age):**

```
Logit:  ln[p/(1−p)] = 9.083 − 0.209(Age)
Odds:   p/(1−p) = e^(9.083 − 0.209·Age)
```

**Interpretation:** Each additional year of age decreases the odds of being diabetes-free by ~18.8%, meaning older patients face meaningfully higher diabetes risk.

| Metric | Train-test split | 10-fold CV |
|--------|-----------------|------------|
| Accuracy | 83.78% | 81.38% |
| True negatives (correct "no diabetes") | 43.24% | 42.76% |
| True positives (correct "has diabetes") | 40.54% | 38.62% |
| False negatives (missed diabetes cases) | 10.81% | 9.66% |

The 10-fold CV accuracy is slightly lower but uses all 145 observations, making it a more reliable estimate of generalization. The 2.4% gap confirms the model is stable. Critical note: **false negatives** (missed diabetes cases) are the highest-risk error in clinical settings — patients go undiagnosed and untreated.

---

### B · Multinomial Logistic Regression — Health State Transitions

**Data:** Patients starting in a Healthy state; predicting transition to Healthy, Sick, or Dead. **70/30 train-test split.**

**Multinomial equations (Healthy as reference class):**

```
log[P(Sick)/P(Healthy)]  = −0.244 − 0.306(Intervention) − 0.173(Female)
                           + 0.280(Age≥60) + 0.085(Year 3–6) ...

log[P(Dead)/P(Healthy)]  = −0.176 − 0.271(Intervention) − 0.204(Female)
                           + 0.387(Age≥60) + 0.119(Year 3–6) ...
```

**Significant predictors and their odds effects:**

| Predictor | Effect on Sick | Effect on Dead |
|-----------|---------------|----------------|
| Intervention strategy | −26.3% odds vs standard | −23.7% odds vs standard |
| Female sex | −15.9% odds vs male | −18.5% odds vs male |
| Age ≥ 60 | +32.3% odds vs younger | not significant |
| Follow-up years 3–6 | +8.9% odds vs year 1–2 | not significant |

**Test set accuracy: ~42%** — both multinomial logistic regression and LDA struggled to separate the three classes. The predictor variables (strategy, sex, age, follow-up period) are insufficient to distinguish health states, suggesting additional clinical variables are needed.

---

### C · Linear Discriminant Analysis — Health State Transitions

**Two discriminant functions extracted:**

```
LD1 = −1.284(Intervention) − 0.814(Female) + 0.609(Age 40–60)
      + 1.563(Age≥60) + 0.539(Year 3–6) + 0.673(Year≥7)

LD2 = 1.059(Intervention) + 0.102(Female) + 1.479(Age 40–60)
      + 1.191(Age≥60) + 1.098(Year 3–6) − 4.626(Year≥7)
```

**LD1 accounts for 99.24% of between-group variance** — yet the histograms and scatterplot show heavy distributional overlap across all three health states. The model is biased toward predicting the majority (Healthy) class and almost entirely ignores the Sick class.

| Class | Sensitivity | Specificity |
|-------|------------|-------------|
| Healthy | 92.96% | 10.34% |
| Sick | 0% | 100% |
| Dead | 10.23% | 91.59% |

**Hit ratio: 41.49%** — consistent with the multinomial logistic result, confirming that the available predictors are not sufficient to meaningfully separate health states.

---

### D · KNN vs Naïve Bayes — Pima Indians Diabetes (10-fold CV)

Both models trained on the full 768-patient Pima Indians Diabetes dataset using 10-fold cross-validation.

| Metric | KNN (k=21) | Naïve Bayes |
|--------|-----------|-------------|
| Accuracy | 76.04% | 76.04% |
| Kappa | 0.4421 | 0.4585 |
| Correctly predicted: no diabetes | 58.6% | slightly lower |
| Correctly predicted: has diabetes | 17.4% | 20.8% |

**KNN:** Tested k = 5 to 23; k=21 yielded the highest accuracy. Accuracy drops for k > 21, confirming this as the optimal neighborhood size.

**Naïve Bayes:** Identical overall accuracy but higher Kappa, indicating predictions are less attributable to chance. Also outperforms KNN in detecting true diabetic patients (20.8% vs 17.4%).

**Conclusion:** Naïve Bayes is the better model for this clinical task. Equal accuracy but higher Kappa and better sensitivity to the positive class (diabetes), which matters most in a healthcare setting where false negatives carry higher risk than false positives.

---

## Key Takeaways

- **Feature quality matters more than model complexity.** Both LDA and multinomial logistic regression achieved ~42% accuracy on health state prediction, not because the algorithms are weak, but because strategy, sex, age, and follow-up period are insufficient discriminators. Additional clinical biomarkers would likely improve performance significantly.
- **Kappa is a better metric than accuracy for imbalanced clinical data.** Both KNN and Naïve Bayes showed 76% accuracy, but Naïve Bayes's higher Kappa reveals it is actually making more meaningful predictions.
- **10-fold CV vs train-test split:** For the logistic regression task, both approaches gave comparable accuracy (~2.4% difference), confirming model stability. CV is generally preferred as it uses all available data.
- **Clinical context shapes what "good" looks like.** In all three tasks, false negatives (missed disease cases) are the highest-risk errors. Sensitivity to the positive class should be prioritized over overall accuracy when deploying clinical classifiers.

---

## Files

```
02_classification/
├── 01_logistic_regression.R
├── 02_multinomial_lda.R
├── 03_knn_naive_bayes.R
└── README.md
```

---

## How to Run

```r
install.packages(c("nnet", "MASS", "caret", "e1071", "klaR", "mlbench", "hesim"))
source("classification.R")
```

> The hesim dataset requires the `hesim` package. Set `set.seed(123)` included for reproducibility across all models.
