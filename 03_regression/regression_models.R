#---------------------------------------------
#         Multiple Linear Regression
#---------------------------------------------

library("MASS")

df <- data.frame(
  y = c(79.30, 200.10, 163.20, 200.10, 146.00, 177.70, 30.90, 291.90, 160.00, 339.40, 159.60, 86.30, 237.50, 107.20, 155.00),
  x1 = c(5.50, 2.50, 8.00, 3.00, 3.00, 2.90, 8.00, 9.00, 4.00, 6.50, 5.50, 5.00, 6.00, 5.00, 3.50),
  x2 = c(31.00, 55.00, 67.00, 50.00, 38.00, 71.00, 30.00, 56.00, 42.00, 73.00, 60.00, 44.00, 50.00, 39.00, 55.00),
  x3 = c(10.00, 8.00, 12.00, 7.00, 8.00, 12.00, 12.00, 5.00, 8.00, 5.00, 11.00, 12.00, 6.00, 10.00, 10.00),
  x4 = c(8.00, 6.00, 9.00, 16.00, 15.00, 17.00, 8.00, 10.00, 4.00, 16.00, 7.00, 12.00, 6.00, 4.00, 4.00)
)

#full model
full.model<- lm(y~., data=df)
#stepwise regression model
step.model <- stepAIC(full.model, direction="both", trace = "FALSE")
summary(step.model)
#selecting model with lowest AIC (variables + interactions)
new.stepmodel<- step(lm(y ~ (x1 + x2 + x3)^2, data=df), direction = "both")
summary(new.stepmodel)


#---------------------------------------------
#         Polynomial Regression
#---------------------------------------------

df <- data.frame(
  bmi = c(18.0, 19.5, 20.8, 21.7, 22.9, 24.0, 24.8, 25.6, 26.5, 27.2, 
          28.1, 29.0, 30.2, 31.0, 32.1, 33.0, 34.2, 35.1, 36.3, 37.5),
  sbp = c(108, 110, 112, 114, 116, 118, 120, 121, 123, 125, 
          128, 131, 135, 138, 142, 147, 153, 159, 166, 174)
)

#linear model
linear.model <- lm(sbp~bmi, data=df)
summary(linear.model)

#quadratic polynomial model
quadratic.model <- lm(sbp ~ bmi + I(bmi^2), data=df)
summary(quadratic.model)

# Plot the base data
plot(df$bmi, df$sbp, 
     main="SBP vs BMI", 
     xlab="BMI (kg/m2)", 
     ylab="SBP (mmHg)")

lines(df$bmi, predict(linear.model), col="blue")
lines(df$bmi, predict(quadratic.model), col="red")

legend("topleft", 
       legend=c("Linear Model", "Quadratic Model"), 
       col=c("blue", "red"), 
       lty=1,   
       bty="n")
#---------------------------------------------
#         Poisson Regression
#---------------------------------------------
df <- data.frame(
  visits = c(6, 5, 7, 8, 9, 12, 11, 7, 6, 8, 10, 13, 14, 9),
  pm25 = c(18, 14, 22, 25, 28, 35, 33, 20, 16, 24, 30, 38, 40, 26),
  heat = c(31, 30, 32, 33, 34, 35, 34, 32, 31, 33, 34, 36, 36, 33),
  weekend = c(0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1),
  population = 120000
)

# Poisson model
asthma_model <- glm(visits ~ pm25 + heat + weekend + offset(log(population)), 
                    family = poisson, 
                    data = df)
summary(asthma_model)

#Is there multicollinearity?
library(MASS)
vif(asthma_model)

#Finding best model
new.model <- stats::step(asthma_model, direction = "both")
summary(new.model)