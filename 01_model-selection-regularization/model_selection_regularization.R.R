
#--------------------------
#       Model Selection & Regularization
#---------------------------

library(lars)
library(leaps)
library(glmnet)
library(pls)

# load data
data(diabetes)
x <- diabetes$x
y <- diabetes$y

# Split into 70-30 training-validation set
set.seed(123)
train_id <- sample(1:nrow(x), 0.7 * nrow(x))
x_train  <- x[train_id, ]
y_train  <- y[train_id]
x_test   <- x[-train_id, ]
y_test   <- y[-train_id]

# data frames for pls/pcr
train_df <- data.frame(y = y_train, x_train)
test_df  <- data.frame(y = y_test,  x_test)

# Helper functions
mse <- function(actual, predicted) mean((actual - predicted)^2)
subset_aic <- function(regfit, x, y) {
  n <- nrow(x)
  p <- ncol(x)
  aic_vals <- rep(NA, p)
  for (k in 1:p) {
    coefi <- coef(regfit, id = k)
    vars  <- setdiff(names(coefi), "(Intercept)")
    Xk    <- cbind("(Intercept)" = 1, x[, vars, drop = FALSE])
    fit_k <- lm.fit(x = Xk, y = y)
    rss   <- sum(fit_k$residuals^2)
    q     <- ncol(Xk)
    aic_vals[k] <- n * (log(2 * pi) + 1 + log(rss / n)) + 2 * (q + 1)
  }
  aic_vals
}

get_subset_metrics <- function(regfit, x, y) {
  s        <- summary(regfit)
  aic_vals <- subset_aic(regfit, x, y)
  data.frame(
    Size        = 1:ncol(x),
    Cp          = s$cp,
    AIC         = aic_vals,
    BIC         = s$bic,
    Adjusted_R2 = s$adjr2
  )
}

print_selected_sizes <- function(metrics_df, title_text) {
  cp_size    <- metrics_df$Size[which.min(metrics_df$Cp)]
  aic_size   <- metrics_df$Size[which.min(metrics_df$AIC)]
  bic_size   <- metrics_df$Size[which.min(metrics_df$BIC)]
  adjr2_size <- metrics_df$Size[which.max(metrics_df$Adjusted_R2)]
  
  cat("\n", title_text, "\n", sep = "")
  cat("Best size by Cp          :", cp_size,    "\n")
  cat("Best size by AIC         :", aic_size,   "\n")
  cat("Best size by BIC         :", bic_size,   "\n")
  cat("Best size by Adjusted R^2:", adjr2_size, "\n")
  
  invisible(list(cp_size    = cp_size,
                 aic_size   = aic_size,
                 bic_size   = bic_size,
                 adjr2_size = adjr2_size))
}

plot_subset_metrics <- function(metrics_df, main_prefix) {
  old_par <- par(no.readonly = TRUE)
  par(mfrow = c(2, 2))
  
  plot(metrics_df$Size, metrics_df$Cp, type = "b",
       xlab = "Number of predictors", ylab = "Cp",
       main = paste(main_prefix, "- Cp"))
  points(metrics_df$Size[which.min(metrics_df$Cp)],
         min(metrics_df$Cp), pch = 19, col = 2)
  
  plot(metrics_df$Size, metrics_df$AIC, type = "b",
       xlab = "Number of predictors", ylab = "AIC",
       main = paste(main_prefix, "- AIC"))
  points(metrics_df$Size[which.min(metrics_df$AIC)],
         min(metrics_df$AIC), pch = 19, col = 2)
  
  plot(metrics_df$Size, metrics_df$BIC, type = "b",
       xlab = "Number of predictors", ylab = "BIC",
       main = paste(main_prefix, "- BIC"))
  points(metrics_df$Size[which.min(metrics_df$BIC)],
         min(metrics_df$BIC), pch = 19, col = 2)
  
  plot(metrics_df$Size, metrics_df$Adjusted_R2, type = "b",
       xlab = "Number of predictors", ylab = "Adjusted R^2",
       main = paste(main_prefix, "- Adjusted R^2"))
  points(metrics_df$Size[which.max(metrics_df$Adjusted_R2)],
         max(metrics_df$Adjusted_R2), pch = 19, col = 2)
  
  par(old_par)
}

# ============================================================
# 1. VARIABLE SELECTION
# ============================================================

# ---------------------------
# 1A. Best Subset Selection
# ---------------------------
best_fit     <- regsubsets(x = x_train, y = y_train, nvmax = 10, method = "exhaustive")
best_metrics <- get_subset_metrics(best_fit, x_train, y_train)
print(best_metrics)

best_sizes <- print_selected_sizes(best_metrics, "Best subset selection")

cat("\nCoefficients of best subset model selected by Cp:\n")
print(coef(best_fit, id = best_sizes$cp_size))
cat("\nCoefficients of best subset model selected by AIC:\n")
print(coef(best_fit, id = best_sizes$aic_size))
cat("\nCoefficients of best subset model selected by BIC:\n")
print(coef(best_fit, id = best_sizes$bic_size))
cat("\nCoefficients of best subset model selected by Adjusted R^2:\n")
print(coef(best_fit, id = best_sizes$adjr2_size))

plot_subset_metrics(best_metrics, "Best subset")

# ---------------------------
# 1B. Forward Stepwise Selection
# ---------------------------
forward_fit     <- regsubsets(x = x_train, y = y_train, nvmax = 10, method = "forward")
forward_metrics <- get_subset_metrics(forward_fit, x_train, y_train)
print(forward_metrics)

forward_sizes <- print_selected_sizes(forward_metrics, "Forward stepwise selection")

cat("\nCoefficients of forward model selected by Cp:\n")
print(coef(forward_fit, id = forward_sizes$cp_size))
cat("\nCoefficients of forward model selected by AIC:\n")
print(coef(forward_fit, id = forward_sizes$aic_size))
cat("\nCoefficients of forward model selected by BIC:\n")
print(coef(forward_fit, id = forward_sizes$bic_size))
cat("\nCoefficients of forward model selected by Adjusted R^2:\n")
print(coef(forward_fit, id = forward_sizes$adjr2_size))

plot_subset_metrics(forward_metrics, "Forward stepwise")

# ---------------------------
# 1C. Backward Stepwise Selection
# ---------------------------
backward_fit     <- regsubsets(x = x_train, y = y_train, nvmax = 10, method = "backward")
backward_metrics <- get_subset_metrics(backward_fit, x_train, y_train)
print(backward_metrics)

backward_sizes <- print_selected_sizes(backward_metrics, "Backward stepwise selection")

cat("\nCoefficients of backward model selected by Cp:\n")
print(coef(backward_fit, id = backward_sizes$cp_size))
cat("\nCoefficients of backward model selected by AIC:\n")
print(coef(backward_fit, id = backward_sizes$aic_size))
cat("\nCoefficients of backward model selected by BIC:\n")
print(coef(backward_fit, id = backward_sizes$bic_size))
cat("\nCoefficients of backward model selected by Adjusted R^2:\n")
print(coef(backward_fit, id = backward_sizes$adjr2_size))

plot_subset_metrics(backward_metrics, "Backward stepwise")

# ============================================================
# 2. SHRINKAGE METHODS: RIDGE REGRESSION AND LASSO
# ============================================================
#Ridge regression (apha=0), Lasso (alpha=1)

set.seed(123)
cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0)
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1)

cat("\nRidge lambda.min:", cv_ridge$lambda.min, "\n")
cat("Ridge coefficients at lambda.min:\n")
print(as.matrix(coef(cv_ridge, s = "lambda.min")))

cat("\nLasso lambda.min:", cv_lasso$lambda.min, "\n")
cat("Lasso coefficients at lambda.min:\n")
print(as.matrix(coef(cv_lasso, s = "lambda.min")))

plot(cv_ridge); title("Cross-validated Ridge Regression")
plot(cv_lasso); title("Cross-validated Lasso")

pred_ridge <- as.numeric(predict(cv_ridge, s = "lambda.min", newx = x_test))
pred_lasso <- as.numeric(predict(cv_lasso, s = "lambda.min", newx = x_test))
mse_ridge  <- mse(y_test, pred_ridge)
mse_lasso  <- mse(y_test, pred_lasso)

# ============================================================
# 3. DIMENSION REDUCTION: PCR AND PLS
# ============================================================
set.seed(123)
pcr_fit <- pcr(y ~ ., data = train_df, scale = TRUE, validation = "CV")
pls_fit <- plsr(y ~ ., data = train_df, scale = TRUE, validation = "CV")

pcr_ncomp <- which.min(RMSEP(pcr_fit)$val[1, 1, -1])
pls_ncomp <- which.min(RMSEP(pls_fit)$val[1, 1, -1])

cat("\nBest number of components - PCR:", pcr_ncomp, "\n")
cat("Best number of components - PLS:", pls_ncomp, "\n")

validationplot(pcr_fit, val.type = "MSEP"); title("PCR cross-validated MSEP")
validationplot(pls_fit, val.type = "MSEP"); title("PLS cross-validated MSEP")

pred_pcr <- as.numeric(predict(pcr_fit, newdata = test_df, ncomp = pcr_ncomp))
pred_pls <- as.numeric(predict(pls_fit, newdata = test_df, ncomp = pls_ncomp))
mse_pcr  <- mse(y_test, pred_pcr)
mse_pls  <- mse(y_test, pred_pls)

# ============================================================
# 4. VALIDATION SET MSE COMPARISON
# ============================================================

#4A. VARIABLE SELECTION — BIC-selected models

coefi    <- coef(best_fit, id = best_sizes$bic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_best_bic <- mse(y_test, as.numeric(test_mat %*% coefi))

coefi    <- coef(forward_fit, id = forward_sizes$bic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_fwd_bic  <- mse(y_test, as.numeric(test_mat %*% coefi))

coefi    <- coef(backward_fit, id = backward_sizes$bic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_back_bic <- mse(y_test, as.numeric(test_mat %*% coefi))

comparison_bic <- data.frame(
  Method = c("Best Subset (BIC)", "Forward Stepwise (BIC)", "Backward Stepwise (BIC)",
             "Ridge", "Lasso", "PCR", "PLS"),
  MSE    = c(mse_best_bic, mse_fwd_bic, mse_back_bic,
             mse_ridge, mse_lasso, mse_pcr, mse_pls),
  RMSE   = sqrt(c(mse_best_bic, mse_fwd_bic, mse_back_bic,
                  mse_ridge, mse_lasso, mse_pcr, mse_pls))
)
comparison_bic <- comparison_bic[order(comparison_bic$RMSE), ]
rownames(comparison_bic) <- NULL

cat("\nValidation set MSE/RMSE comparison - BIC (sorted by RMSE):\n")
print(comparison_bic, digits = 4)
cat("\n Best model:", comparison_bic$Method[1],
    "(RMSE =", round(comparison_bic$RMSE[1], 4), ")\n")

#4B. VARIABLE SELECTION — AIC-selected models (for prediction)

coefi    <- coef(best_fit, id = best_sizes$aic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_best_aic <- mse(y_test, as.numeric(test_mat %*% coefi))

coefi    <- coef(forward_fit, id = forward_sizes$aic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_fwd_aic  <- mse(y_test, as.numeric(test_mat %*% coefi))

coefi    <- coef(backward_fit, id = backward_sizes$aic_size)
vars     <- names(coefi)[-1]
test_mat <- cbind("(Intercept)" = 1, x_test[, vars, drop = FALSE])
mse_back_aic <- mse(y_test, as.numeric(test_mat %*% coefi))

comparison_aic <- data.frame(
  Method = c("Best Subset (AIC)", "Forward Stepwise (AIC)", "Backward Stepwise (AIC)",
             "Ridge", "Lasso", "PCR", "PLS"),
  MSE    = c(mse_best_aic, mse_fwd_aic, mse_back_aic,
             mse_ridge, mse_lasso, mse_pcr, mse_pls),
  RMSE   = sqrt(c(mse_best_aic, mse_fwd_aic, mse_back_aic,
                  mse_ridge, mse_lasso, mse_pcr, mse_pls))
)
comparison_aic <- comparison_aic[order(comparison_aic$RMSE), ]
rownames(comparison_aic) <- NULL

cat("\nValidation set MSE/RMSE comparison - AIC (sorted by RMSE):\n")
print(comparison_aic, digits = 4)
cat("\n Best model:", comparison_aic$Method[1],
    "(RMSE =", round(comparison_aic$RMSE[1], 4), ")\n")