library("readr")
data <- read.csv("5 Data Logistic regression 0226.csv", header=TRUE, sep=",")

set.seed(123)

#splitting the data to training and test set (75:25)
n <- nrow(data)
train_idx<-sample(1:n, size =0.75*n)
train_data <-data[train_idx,]
test_data <-data[-train_idx,]

#logistic regression fitting
log_model <-glm(Y~ X1+X2+X3+X4+X5+X6+X7+X8, 
                data=train_data, family="binomial")

summary(log_model)
#significant coefficents only (p<0.05)
log_model2 <-glm(Y~ X1, data=train_data, family="binomial")
summary(log_model2)
#odds of variables
exp(coef(log_model2))


#-------------------------------
#Predictions on Training set
#-------------------------------
train_probs <- predict(log_model2, newdata=train_data, type="response") #returns probability prediction (0-1)
train_pred <-ifelse(train_probs>=0.5,1,0) #If probability >0.5, predict 1 (true), if not, predict 0(false)

#confusion matrix (evaluate performance of classification model)
train_conf_mat <-table(Predicted=train_pred, Actual=train_data$Y)
train_accuracy <- mean(train_pred==train_data$Y)

print(train_conf_mat)
print (train_accuracy)

#-------------------------------
#Predictions on Test set
#-------------------------------
test_probs <- predict(log_model2, newdata=test_data, type="response")
test_pred <- ifelse(test_probs >=0.5, 1, 0)

#confusion matrix (evaluate performance of classification model)
test_conf_mat <-table(Predicted=test_pred, Actual=test_data$Y)
test_accuracy <- mean(test_pred==test_data$Y)

print(test_conf_mat)
print (test_accuracy)


#-------------------------------
#10-fold cross validation
#-------------------------------

library(caret)
train_control <- trainControl(method="cv", number=10)

cv_model <- train(as.factor(Y)~ X1,
                  data = data,
                  method = "glm",
                  family = "binomial",
                  trControl = train_control)

summary(cv_model)

# Predictions from cv model
cv_pred <- predict(cv_model, newdata = data)

# confusion matrix
confusionMatrix(as.factor(cv_pred), as.factor(data$Y))

#accuracy
cv_accuracy <- mean(cv_pred == data$Y)
print(cv_accuracy)




