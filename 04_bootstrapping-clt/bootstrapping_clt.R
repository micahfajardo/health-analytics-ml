
health_df <- data.frame( 
  Patients = c(120, 145, 98, 110, 160, 135, 90, 175, 150, 105, 130, 165, 115, 140, 100), 
  AvgWaitMin = c(22, 18, 35, 28, 16, 20, 40, 14, 15, 32, 24, 17, 26, 19, 38), 
  StaUOnDuty = c(12, 14, 10, 11, 16, 13, 9, 18, 15, 10, 12, 17, 11, 14, 9), 
  BedOccupancyPct = c(72, 80, 58, 65, 83, 76, 52, 88, 85, 60, 74, 90, 68, 79, 55), 
  PatientSatisfaction = c(85, 88, 74, 80, 92, 86, 70, 94, 91, 76, 84, 93, 82, 87, 72), 
  ReadmissionRatePct = c(9.5, 8.2, 13.0, 11.4, 7.8, 9.0, 14.5, 7.2, 7.6, 12.2, 9.8, 6.9, 10.5,  8.6, 13.8), 
  VaccinationCoveragePct = c(68, 75, 52, 60, 82, 70, 48, 85, 80, 55, 66, 88, 62, 73, 50), 
  AvgLengthOfStayDays = c(4.2, 3.8, 6.1, 5.0, 3.5, 4.0, 6.8, 3.2, 3.4, 5.7, 4.3, 3.1, 4.8, 3.9,  6.4) 
) 

plot(x=health_df$Patients,
     y=health_df$AvgWaitMin,
     xlab="No. of Patients",
     ylab="Avg. Waiting Time (min.)",
     col="blue")
abline(lm(AvgWaitMin ~ Patients, data=health_df), lwd=2)
r_coeff <-cor(x=health_df$Patients, y=health_df$AvgWaitMin, method="pearson")
legend("topright", 
       legend = bquote(R^2 == .(r_coeff)),
       bty = "n")
cor_mat <- cor(health_df,method="pearson")

corrplot(cor_mat, method = "cirle", tl.col = "black",tl.srt=45, number.cex = 0.7)

#----------------------------------
# BOOTSTRAPPING
#-----------------------------------

set.seed(2026)
x<-health_df$AvgLengthOfStayDays
#original mean and sd
mean(x)
sd(x)

#bootstrapped parameters
n <- length(x)
R <- 200
bootstrap_means<-numeric(R)

#Repeat sampling for R times
for (i in 1:R){
  #create vector for bootstrap dataset
  resample <- numeric(n)
  #Pick a data in dataset for n times
  for (j in 1:n){
    resample[j]=sample(x, size=1, replace=TRUE)
  }
  #Record the mean per new bootstrap dataset
  bootstrap_means[i]<-mean(resample)
}
#Calculate mean of bootstrap means
avg_bootstrap_mean <- mean(bootstrap_means)
avg_bootstrap_mean
#Calculate bootstrap std
bootstrap_se=sd(bootstrap_means)
bootstrap_se
#Calculate confidence interval
ci_99 <- quantile(bootstrap_means, probs = c(0.005, 0.995))
ci_99

ci_99_orig<-quantile(x,probs = c(0.005, 0.995))
ci_99_orig
#Histogram 
hist(bootstrap_means, breaks = 50, col = "darkseagreen", 
     main = "Bootstrapped Sample (99% CI)",
     xlab = "Average Length of Stay (Days)")
abline(v = ci_99[1], col = "red", lwd = 2, lty = 2) # Lower bound
abline(v = ci_99[2], col = "red", lwd = 2, lty = 2) # Upper bound
abline(v = mean(x), col = "blue", lwd = 2)         # Original mean

#----------------------------------
# Central Limit Theorem
#-----------------------------------

set.seed(123)
size <-5
prob <-0.3
n_vec <-c(10,1000,10000) #number of repetitions
m<-30 #sample size per repetition

mean_clt<- size*prob
var_clt<-size*prob* (1 - prob)

simulate_means <- function(n, m, size, prob) {
  replicate(n, mean(rbinom(m, size, prob)))
}

par(mfrow = c(1, 3))

for (n in n_vec) {
  xbar <- simulate_means(n, m, size, prob)
  #simulation mean and variance
  sim_mean <- mean(xbar)
  sim_var  <- var(xbar)
  
  #histogram
  hist(xbar, breaks = 30, probability = TRUE, col = "lightblue", border = "white",
       main = paste("n =", n), xlab = "Sample Means")
  
  curve(dnorm(x, mean = mean_clt, sd = sqrt(var_clt / m)), 
        add = TRUE, col = "darkblue", lwd = 2)
  abline(v = mean_clt, col = "red", lwd = 2, lty = 2)
  
  cat(paste("\nResults for n =", n, ":\n"))
  cat("Approx. Mean:", round(sim_mean, 4), "\n")
  cat("Approx. Variance:", round(sim_var, 4), "\n")
}