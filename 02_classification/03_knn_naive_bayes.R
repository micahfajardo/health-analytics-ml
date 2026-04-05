if (!require(mlbench)) install.packages("mlbench")
if (!require(caret)) install.packages("caret")
if (!require(e1071)) install.packages("e1071")
if (!require(klaR)) install.packages("klaR")

library(mlbench)
library(e1071)
library(tm)
library(caret)

data(PimaIndiansDiabetes)
df <- PimaIndiansDiabetes

#Splitting dataset for 10-fold cross-validation
train_control <- trainControl(method = "cv", number = 10)

#-------------------------------
#             KNN
#---------------------------------
#Training dataset with KNN
set.seed(123)
knn_model <- train(diabetes ~ ., 
                   data = df, 
                   method = "knn", 
                   trControl = train_control, 
                   preProcess = c("center", "scale"),
                   tuneLength = 10)
print(knn_model) 
print(confusionMatrix(knn_model))

#-------------------------------
#           Naive Bayes
#---------------------------------
#Training dataset with Naive Bayes
set.seed(123)
nb_model <- train(diabetes ~ ., 
                  data = df, 
                  method = "nb", 
                  trControl = train_control)
print(nb_model)
print(confusionMatrix(nb_model))


