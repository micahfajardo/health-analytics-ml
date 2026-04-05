#------------------------------------
# Multinomial Logistic Regression
#------------------------------------

library(hesim)
library(nnet)
library(summarytools)

data(multinom3_exdata)
df <- multinom3_exdata$transitions

# Filter for Healthy state
df <- df[df$state_from == "Healthy", ]

# Convert to factors inside the dataframe
df$state_to        <- as.factor(df$state_to)
df$strategy_name   <- as.factor(df$strategy_name)
df$female          <- as.factor(df$female)
df$age_cat         <- as.factor(df$age_cat)
df$year_cat        <- as.factor(df$year_cat)

# Data splitting
set.seed(123)
n <- nrow(df)
train_idx  <- sample(seq_len(n), size = 0.7 * n)
train_data <- df[train_idx, ]
test_data  <- df[-train_idx, ]

# Model fitting
multinom_model <- multinom(state_to ~ strategy_name + female + age_cat + year_cat,
                           data = train_data)
#Model Results
summary(multinom_model)
exp(summary(multinom_model)$coefficients) #for odds ratio
percent_odds<-(exp(summary(multinom_model)$coefficients) - 1) * 100
percent_odds

#Compute p-values
z <- summary(multinom_model)$coefficients/summary(multinom_model)$standard.errors
p_values<-(1-pnorm(abs(z),0,1))*2
p_values

#Predictions on train and test sets
pred_train <-predict(multinom_model,newdata=train_data)
pred_test <-predict(multinom_model,newdata=test_data)

#confusion tables
ctable_train <-table(Actual=train_data$state_to, Predicted=pred_train)
ctable_test <-table(Actual=test_data$state_to, Predicted=pred_test)

ctable_train
ctable_test

#accuracy of model
acc_train<-mean(pred_train==train_data$state_to)
acc_test<-mean(pred_test==test_data$state_to)

acc_train
acc_test

#------------------------------------
# Discriminant Analysis
#------------------------------------

#keep only complete cases
df2 <- na.omit(df)

# Convert to factors 
df2$state_to      <- as.factor(df2$state_to)
df2$strategy_name <- as.factor(df2$strategy_name)
df2$female        <- as.factor(df2$female)
df2$age_cat       <- as.factor(df2$age_cat)
df2$year_cat      <- as.factor(df2$year_cat)

# Data splitting using stratified sampling 
set.seed(123)
train_idx2 <- unlist(lapply(split(seq_len(nrow(df2)), df2$state_to), function(ix) {
  sample(ix, size = ceiling(0.70 * length(ix)))
}))

train_data2 <- df2[train_idx2, ]
test_data2  <- df2[-train_idx2, ]

#LDA on training set
library(MASS)
fit_lda <- lda(state_to ~ strategy_name + female + age_cat + year_cat,
               data = train_data2)
fit_lda

#Linear discriminant scores on train/test
pred_train2 <- predict(fit_lda, newdata=train_data2)
pred_test2 <- predict(fit_lda, newdata=test_data2)

#histogram of discriminants (k-1 where k is the number of y categ)
par(mar = c(4, 4, 4, 1)) #bottom,left,top, right

ldahist(pred_train2$x[,1], g = train_data2$state_to, 
        main = "LD1 Histogram by Health Status")
ldahist(pred_train2$x[,2], g = train_data2$state_to, 
        main = "LD2 Histogram by Health Status")

# Extract discriminant scores
lda_scores <- pred_train2$x

#plot
par(mfrow=c(1,1), mar=c(4, 4, 2, 4))
colors <- c("Dead" = "red", "Healthy" = "green", "Sick" = "blue")

plot(lda_scores[,1], lda_scores[,2],
     xlab = "LD1", ylab = "LD2",
     main = "LDA by Health Status",
     col = colors[train_data2$state_to],
     pch = 19)

legend(x = "right",                  
       inset = -0.25,              # pushes legend above the plot
       legend = names(colors),
       col = colors,
       pch = 19,
       xpd = TRUE,                 # allows drawing outside plot area
       horiz = FALSE,               # makes legend horizontal (one line)
       bty = "n")                  # removes legend box border

# Confusion matrix 
cm_test <- table(Truth = test_data2$state_to, 
                 Predicted = pred_test2$class)
cm_test

# Hit ratio (overall accuracy)
hit_ratio <- mean(pred_test2$class == test_data2$state_to)
cat("Hit Ratio:", round(hit_ratio * 100, 2), "%\n")

# Sensitivity and Specificity per class

for(class in levels(test_data2$state_to)) {
  actual_pos    <- test_data2$state_to == class
  predicted_pos <- pred_test2$class == class
  
  sensitivity <- sum(actual_pos & predicted_pos) / sum(actual_pos)
  specificity <- sum(!actual_pos & !predicted_pos) / sum(!actual_pos)
  
  cat("\nClass:", class,
      "\nSensitivity:", round(sensitivity * 100, 2), "%",
      "\nSpecificity:", round(specificity * 100, 2), "%\n")
}
