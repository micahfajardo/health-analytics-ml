# Project 04 · Bootstrapping, CLT & Correlation

Statistical inference through simulation: manual bootstrap implementation for 99% confidence intervals, Central Limit Theorem demonstration from a Binomial distribution, and Pearson correlation analysis on a hospital operations dataset.

---

## Research Questions

> 1. What is the 99% bootstrap confidence interval for average patient length of stay, and how does the bootstrap distribution compare to the original sample?
> 2. Does the sample mean of a Binomial(5, 0.3) distribution converge to normality as the number of repetitions increases (CLT)?
> 3. What are the relationships between hospital operational variables — patient volume, wait time, staffing, bed occupancy, and outcomes?

---

## Dataset

**Hospital operations dataset** (n=15 hospital-days):

| Variable | Description |
|----------|-------------|
| Patients | Daily patient volume |
| AvgWaitMin | Average waiting time (minutes) |
| StaffOnDuty | Number of staff on duty |
| BedOccupancyPct | Bed occupancy rate (%) |
| PatientSatisfaction | Satisfaction score (0–100) |
| ReadmissionRatePct | 30-day readmission rate (%) |
| VaccinationCoveragePct | Vaccination coverage (%) |
| AvgLengthOfStayDays | Average patient length of stay (days) |

---

## Methods & Results

### A · Bootstrap Confidence Interval

A manual bootstrap was implemented from scratch (no bootstrap packages) using R=200 resamples of the `AvgLengthOfStayDays` variable.

**Comparison of original vs bootstrap distribution:**

| Metric | Original sample | Bootstrap (R=200) |
|--------|----------------|------------------|
| Mean | 4.547 days | 4.579 days |
| Standard error | 1.204 | 0.320 |
| 99% CI | 3.107 – 6.772 | 3.806 – 5.488 |

**Key findings:**
- The bootstrapped mean closely tracks the original (negligible bias), confirming the sample mean is stable
- The bootstrap SE is dramatically lower (0.32 vs 1.20) because it captures the *sampling distribution of the mean*, not the spread of individual observations
- The 99% bootstrap CI (3.81 – 5.49 days) is substantially narrower than the raw sample quantile range, providing a more precise and reliable estimate of the true population mean
- **Practical interpretation:** We can state with 99% confidence that the true average patient length of stay lies between 3.81 and 5.49 days

---

### B · Central Limit Theorem Simulation

Simulated the distribution of sample means from **Binomial(5, 0.3)** across increasing numbers of repetitions (n = 10, 1000, 10000), with m=30 observations per repetition.

**Theoretical values:** Mean = 1.5, Variance = 1.05

| Repetitions (n) | Approx. mean | Approx. variance |
|----------------|-------------|-----------------|
| 10 | 1.497 | 0.035 |
| 1,000 | 1.487 | 0.033 |
| 10,000 | 1.501 | 0.036 |

**Findings:**
- The approximated mean and variance are stable across all three repetition levels, converging to the theoretical values (mean = 1.5, var ≈ 0.035 = 1.05/30)
- As repetitions increase, the histogram of sample means increasingly resembles a normal curve — a direct visual demonstration of the CLT
- Even with n=10, the distribution shows a roughly bell-shaped tendency; at n=10,000, the normal approximation is nearly exact

---

### C · Pearson Correlation Analysis

Full correlation matrix and corrplot computed across all 8 hospital variables.

**Key finding — the staffing paradox:**

A strong **negative correlation** (R ≈ −0.93) was observed between patient volume (`Patients`) and average wait time (`AvgWaitMin`). This counterintuitive result — *more patients, shorter waits* — is explained by an operational mediator: **hospital administrators proactively increase staffing during high-volume periods**, overcompensating for the load and reducing wait times. The correlation matrix confirms this, showing that `StaffOnDuty` increases with patient volume.

All variables exhibited strong correlational relationships. The corrplot uses:
- **Blue** = positive association
- **Red** = negative association
- **Circle size** = magnitude of correlation

---

## Key Takeaways

- **Bootstrap inference works even with small samples.** With only n=15 observations, traditional parametric CIs are unreliable. Bootstrap resampling (R=200) produces a valid 99% CI without distributional assumptions.
- **Standard error ≠ standard deviation.** The large drop in SE from original (1.20) to bootstrap (0.32) is not a contradiction — it reflects the difference between individual observation variability and mean estimation precision.
- **CLT convergence is rapid for well-behaved distributions.** Even n=10 repetitions shows approximate normality for Binomial(5, 0.3) sample means. By n=1,000, the approximation is effectively exact.
- **Strong correlations do not always have simple causal interpretations.** The negative Patients–WaitTime correlation requires understanding the operational context (adaptive staffing) to interpret correctly.

---

## Files

```
04_bootstrapping-clt/
├── bootstrapping_clt.R   # Full R script: bootstrap CI, CLT simulation, correlation
└── README.md
```

---

## How to Run

```r
install.packages("corrplot")
source("bootstrapping_clt.R")
```

> `set.seed(2026)` and `set.seed(123)` are used in the bootstrap and CLT sections respectively for reproducibility.
