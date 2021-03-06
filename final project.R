---
title: "final prject"
output: html_document
---

```{r}
# Load data
library(NHANES)
library(tidyverse)
library(glmnet)
small.nhanes <- na.omit(NHANES[NHANES$SurveyYr=="2011_12"
                               & NHANES$Age > 17,c(1,3,4,8:11,13,17,20,21,25,46,50,51,52,61)])
small.nhanes <- as.data.frame(small.nhanes %>%
  group_by(ID) %>% filter(row_number()==1) )
nrow(small.nhanes)

## Checking whether there are any ID that was repeated. If not ##
## then length(unique(small.nhanes$ID)) and nrow(small.nhanes) are same ##
length(unique(small.nhanes$ID))

## Create training and test set ##
set.seed(1003928039)
train <- small.nhanes[sample(seq_len(nrow(small.nhanes)), size = 400),]
nrow(train)
length(which(small.nhanes$ID %in% train$ID))
test <- small.nhanes[!small.nhanes$ID %in% train$ID,]
nrow(test)

# Fit the model with all predictors
model <- lm(train$BPSysAve ~ ., data = train[, -c(1)])
summary(model)  

# Diagnostic check
## The hat values ###
h <- hatvalues(model)
thresh <- 2 * 36/nrow(train)
w <- which(h > thresh)
w

### The Influential Observations ####
D <- cooks.distance(model)
which(D > qf(0.5, 36, 400-36))

## DFFITS ##
dfits <- dffits(model)
which(abs(dfits) > 2*sqrt(36/400))

## DFBETAS ##
dfb <- dfbetas(model)
which(abs(dfb[,1]) > 2/sqrt(400))

resid <- rstudent(model)
fitted <- predict(model)

par(family = 'serif', mfrow = c(2,2))
qqnorm(resid)
qqline(resid)
plot(resid ~ fitted, type = "p", xlab = "Fitted Values", 
     ylab = "Standardized Residual", cex.lab = 1.2,
     col = "red")
lines(lowess(fitted, resid), col = "blue")
plot(train$BPSysAve ~ fitted,type='p', xlab = "Fitted Values", 
     ylab = "BPSysAve", cex.lab = 1.2,
     col = "red")
abline(lm(train$BPSysAve ~ fitted), lwd = 2, col = "blue")
lines(lowess(fitted,train$BPSysAve), col = "red")


# Check if the predictors should be transformed
library(car)
mult <- lm(cbind(train$BPSysAve, train$Gender, train$Age, train$Race3,train$Education, train$MaritalStatus,train$HHIncome, train$Poverty, train$Weight, train$Height, train$BMI, train$Depressed, train$SleepHrsNight, train$SleepTrouble, train$PhysActive,train$SmokeNow) ~ 1)
bc <- powerTransform(mult, family = yjPower)
summary(bc)
library(car)

# Check multicollinearity among the predictors 
vif(model.6) 
anova(model)

# Check variable criteria according to AIC, AICc, BIC, R2
criteria <- function(model){
    n <- length(model$residuals)
    p <- 15
    RSS <- sum(model$residuals^2)
    R2 <- summary(model)$r.squared
    R2.adj <- summary(model)$adj.r.squared
    AIC <- n*log(RSS/n) + 2*p
    AICc <- AIC + (2*(p+2)*(p+3))/(n-p-1)
    BIC <- n*log(RSS/n) + (p+2)*log(n)
    res <- c(R2, R2.adj, AIC, AICc, BIC)
    names(res) <- c("R Squared", "Adjsuted R Squared", "AIC", "AICc", "BIC")
    return(res)
}

crit <- criteria(model = model)
crit

# Stepwise variable selections
sel.var.bic <- step(model, trace = 0, k = log(400), direction = "both") 
select_var_b<-attr(terms(sel.var.bic), "term.labels")   
select_var_b

sel.var.bic6 <- step(model, trace = 0, k = log(400), direction = "forward") 
select_var6<-attr(terms(sel.var.bic6), "term.labels")   
select_var6

sel.var.bic2 <- step(model, trace = 0, k = log(400), direction = "backward") 
select_var2<-attr(terms(sel.var.bic2), "term.labels")   
select_var2

sel.var.aic <- step(model, trace = 0, k = 2, direction = "both") 
select_var<-attr(terms(sel.var.aic), "term.labels")   
select_var

sel.var.aic4 <- step(model, trace = 0, k = 2, direction = "forward") 
select_var4<-attr(terms(sel.var.aic4), "term.labels")   
select_var4

sel.var.aic5 <- step(model, trace = 0, k = 2, direction = "backward") 
select_var5<-attr(terms(sel.var.aic5), "term.labels")   
select_var5

# Select the final model according to those criteria 
model.2 <- lm(train$BPSysAve ~ train$Gender + train$Age, data = train)
crit2 <- criteria(model = model.2)
crit2

model.3 <- lm(train$BPSysAve ~ train$Gender + train$Age+train$Poverty+train$Weight+train$SleepTrouble, data = train)
crit3 <- criteria(model = model.3)
crit3

model.1 <- lm(train$BPSysAve ~ train$Age , data = train)
crit1 <- criteria(model = model.1)
crit1

model.4 <- lm(train$BPSysAve ~ train$Age + train$SmokeNow , data = train)
crit4 <- criteria(model = model.4)
crit4

model.5 <- lm(train$BPSysAve ~ train$Gender + train$Age+ train$SmokeNow , data = train)
crit5 <- criteria(model = model.5)
crit5

model.6 <- lm(train$BPSysAve ~ train$Gender + train$Age+ train$Poverty+ train$Weight+ train$SleepTrouble+ train$SmokeNow , data = train)
crit6 <- criteria(model = model.6)
crit6

model.7 <- lm(test$BPSysAve ~ test$Gender + test$Age+test$Poverty+test$Weight+test$SleepTrouble, data = test)
crit7 <- criteria(model = model.7)
crit7

summary(model.3)

# Final model diagnostic check
h1 <- hatvalues(model.1)
thresh1 <- 2 * 36/nrow(train)
w1 <- which(h1 > thresh1)
w1

### The Influential Observations ####
D1 <- cooks.distance(model.1)
which(D1 > qf(0.5, 36, 400-36))

## DFFITS ##
dfits1 <- dffits(model.3=1)
which(abs(dfits1) > 2*sqrt(36/400))

## DFBETAS ##
dfb1 <- dfbetas(model.1)
which(abs(dfb1[,1]) > 2/sqrt(400))

resid1 <- rstudent(model.1)
fitted1<- predict(model.1)

par(family = 'serif', mfrow = c(2,2))
qqnorm(resid1)
qqline(resid1)
plot(resid1 ~ fitted1, type = "p", xlab = "Fitted Values", 
     ylab = "Standardized Residual", cex.lab = 1.2,
     col = "red")
lines(lowess(fitted1, resid1), col = "blue")
plot(train$BPSysAve ~ fitted1,type='p', xlab = "Fitted Values", 
     ylab = "BPSysAve", cex.lab = 1.2,
     col = "red")
abline(lm(train$BPSysAve ~ fitted1), lwd = 2, col = "blue")
lines(lowess(fitted1,train$BPSysAve), col = "red")

# Produce the criteria comparision table
rbind(crit,crit1, crit2, crit3, crit4, crit5, crit6)
summary(model)
summary(model.1)

tapply(train$BPSysAve, train$Race3, mean)
 db_e <- train[train$Gender == "Male",]
 table(db_e$BPSysAve)
 
## Perform Prediction ##
pred.y <- predict(model, newdata = test, type = "response")

## Prediction error ##
mean((test$BPSysAve - pred.y)^2)
# the oringal model is the best

library(glmnet)
## Fit a ridge penalty ##
model.ridge <- glmnet(x = model.matrix( ~ ., data = train[,-c(1,12)]), y = train$BPSysAve, 
                      standardize = T, alpha = 0)

## Perform Prediction ##
pred.y.ridge <- predict(model.ridge, newx = model.matrix( ~ ., data = test[,-c(1,12)]), type = "response")

## Prediction error ##
mean((test$BPSysAve - pred.y.ridge)^2)


## Perform cross validation to choose lambda ##
cv.out <- cv.glmnet(x = model.matrix( ~ ., data = train[,-c(1,12)]), y = train$BPSysAve
                      , standardize = T, alpha = 1)
plot(cv.out)
best.lambda <- cv.out$lambda.1se
best.lambda
co<-coef(cv.out, s = "lambda.1se")

#Selection of the significant features(predictors)

## threshold for variable selection ##

thresh <- 0.00
# select variables #
inds<-which(abs(co) > thresh )
variables<-row.names(co)[inds]
sel.var.lasso<-variables[!(variables %in% '(Intercept)')]
sel.var.lasso

## Step wise regression ###
library(rms)
set.seed(1003928039)
### Cross Validation and prediction performance of AIC based selection ###
ols.aic1 <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c(select_var, "BPSysAve"))], 
               x=T, y=T, model = T)
ols.aic2 <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c("Gender", "Age","SmokeNow","Poverty","Weight","SleepTrouble", "BPSysAve"))], 
               x=T, y=T, model = T)
ols.aic <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c(select_var4, "BPSysAve"))], 
               x=T, y=T, model = T)
## 10 fold cross validation ##    
aic.cross <- calibrate(ols.aic, method = "crossvalidation", B = 10)
aic.cross1 <- calibrate(ols.aic1, method = "crossvalidation", B = 10)
aic.cross2 <- calibrate(ols.aic2, method = "crossvalidation", B = 10)
## Calibration plot ##
 mfrow = c(2,2) 
plot(aic.cross, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration for original model")
plot(aic.cross1, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration for model.1")
plot(aic.cross2, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration for model.1 + SmokeNow")
dev.off()


## Test Error ##
pred.aic <- predict(ols.aic, newdata = test[,which(colnames(train) %in% c("Gender", "Age","SmokeNow","Poverty","Weight","SleepTrouble", "BPSysAve"))])
## Prediction error ##
pred.error.AIC <- mean((test$BPSysAve - pred.aic)^2)
pred.error.AIC

set.seed(1003928039)
### Cross Validation and prediction performance of BIC based selection ###
ols.bic <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c(select_var_b, "BPSysAve"))], 
               x=T, y=T, model = T)
ols.bic2 <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c("Age", "BPSysAve"))], 
               x=T, y=T, model = T)
ols.bic1 <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c("Gender","Age","SmokeNow", "BPSysAve"))], 
               x=T, y=T, model = T)
ols.bic3 <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c("Age","SmokeNow", "BPSysAve"))], 
               x=T, y=T, model = T)

## 10 fold cross validation ##    
bic.cross <- calibrate(ols.bic, method = "crossvalidation", B = 10)
bic.cross1 <- calibrate(ols.bic1, method = "crossvalidation", B = 10)
bic.cross2 <- calibrate(ols.bic2, method = "crossvalidation", B = 10)
bic.cross3 <- calibrate(ols.bic3, method = "crossvalidation", B = 10)
## Calibration plot ##
 mfrow = c(2,2) 
plot(bic.cross, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration with BIC")
plot(bic.cross1, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration with BIC + SmokeNow")
plot(bic.cross2, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration with Lasso")
plot(bic.cross3, las = 1, xlab = "Predicted Y", main = "Cross-Validation calibration with Lasso + SmokeNow")
dev.off()

## Test Error ##
pred.bic <- predict(ols.bic, newdata = test[,which(colnames(train) %in% c(select_var_b, "BPSysAve"))])
## Prediction error ##
pred.error.BIC <- mean((test$BPSysAve - pred.bic)^2)
pred.error.BIC

set.seed(1003928039)
### Cross Validation and prediction performance of lasso based selection ###
ols.lasso <- ols(train$BPSysAve ~ ., data = train[,which(colnames(train) %in% c(sel.var.lasso, "BPSysAve"))], 
                 x=T, y=T, model = T)

## 10 fold cross validation ##    
lasso.cross <- calibrate(ols.lasso, method = "crossvalidation", B = 10)
## Calibration plot ##
pdf("lasso_cross.pdf", height = 8, width = 16)
plot(lasso.cross, las = 1, xlab = "Predicted Probability", main = "Cross-Validation calibration with LASSO")
dev.off()

pred.lasso <- predict(ols.lasso, newdata = test[,which(colnames(train) %in% c(sel.var.lasso, "lpsa"))])
## Prediction error ##
pred.error.lasso <- mean((test$BPSysAve - pred.lasso)^2)
pred.error.lasso

print(c(pred.error.AIC, pred.error.BIC, pred.error.lasso))

# Data description 
count = 0
for (i in 1:743)
{if (small.nhanes$Gender[i]=="male")
{count=count+1}
}
count

mean(small.nhanes$Age)
sd(small.nhanes$Age)

count1 = 0
for (i in 1:743)
{if (small.nhanes$Race3[i]=="Black")
  {count1=count1+1}
}
count1
sum(small.nhanes$Education=="High School")
sum(small.nhanes$Education=="College Grad")
sum(small.nhanes$Education=="Some College")
sum(small.nhanes$Education=="8th Grade")
sum(small.nhanes$Education=="9 - 11th Grade")
str(small.nhanes$HHIncome)
sum(small.nhanes$MaritalStatus=="Divorced")
sum(small.nhanes$MaritalStatus=="Married")
sum(small.nhanes$MaritalStatus=="NeverMarried")
sum(small.nhanes$MaritalStatus=="LivePartner")
sum(small.nhanes$MaritalStatus=="Widowed")
sum(small.nhanes$MaritalStatus=="Separated")


sum(small.nhanes$HHIncome==" 0-4999")
sum(small.nhanes$HHIncome==" 5000-9999")
sum(small.nhanes$HHIncome=="10000-14999")
sum(small.nhanes$HHIncome=="15000-19999")
sum(small.nhanes$HHIncome=="20000-24999")
sum(small.nhanes$HHIncome=="25000-34999")
sum(small.nhanes$HHIncome=="35000-44999")
sum(small.nhanes$HHIncome=="45000-54999")
sum(small.nhanes$HHIncome=="55000-64999")
sum(small.nhanes$HHIncome=="65000-74999")
sum(small.nhanes$HHIncome=="75000-99999")
sum(small.nhanes$HHIncome=="more 99999")

sum(small.nhanes$Poverty)
mean(small.nhanes$Poverty)
sd(small.nhanes$Poverty)

mean(small.nhanes$Weight)
sd(small.nhanes$Weight)

mean(small.nhanes$BPSysAve)
sd(small.nhanes$BPSysAve)

sum(small.nhanes$Depressed=='None')
sum(small.nhanes$Depressed=='Several')
sum(small.nhanes$Depressed=='Most')
Type_peau<-as.factor(c("None","Several","Most"))
Type_peau
unclass(Type_peau)

mean(small.nhanes$SleepHrsNight)
sd(small.nhanes$SleepHrsNight)

sum(small.nhanes$SmokeNow=='No')
mean(small.nhanes$SmokeNow=='No')
sd(small.nhanes$SmokeNow=='No')

sd(small.nhanes$SleepTrouble)

# Visualize relationships between some predictors and their relationship with the outcomes
library(ggplot2)
library(ggsci)
ggplot(train, aes(train$SmokeNow, train$Age)) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_jama() +
  theme(text = element_text(family = "serif", size = 11), legend.position="top") +
  xlab("Non-smoke or Smoke") +
  ylab("Age") +
  ggtitle("Age vs. SmokeNow") +
  labs(
    caption = "Source: NHANES survey",
    col="Blood pressure")


```
