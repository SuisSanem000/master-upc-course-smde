#########################################################
###  SMDE R Lab: Multiple Linear Regression #############
#### Nihan Acar-Denizli, Phd  ###########################
#### UPC, Barcelona #####################################
#########################################################

###############################################################
###############################################################
#### Linear Regression on Heptathlon Data Set ################
###############################################################

install.packages("HSAUR")
library(HSAUR)

data("heptathlon", package = "HSAUR")
plot(heptathlon)

#Changing direction of some variables
heptathlon$hurdles <- max(heptathlon$hurdles) - heptathlon$hurdles
heptathlon$run200m <- max(heptathlon$run200m) - heptathlon$run200m
heptathlon$run800m <- max(heptathlon$run800m) - heptathlon$run800m

### Correlation Matrix ###
cor(heptathlon)
plot(heptathlon)

### Correlation with score variable ###
cor(heptathlon)[8,]

### Simple Linear Regression ####
slr<-lm(score~longjump,data=heptathlon)
summary(slr)


### Multiple Linear Regression Model ###
reg_model1<-lm(score~., data=heptathlon)
summary(reg_model1)


### Testing Regression Assumptions ###
### 1. Normality of the Error Term ###
# Using QQ plot
qqnorm(residuals(reg_model1))
# Using Histogram
hist(residuals(reg_model1))
# It is skewed.
#Shapiro Wilks Test
shapiro.test(residuals(reg_model1))
# The error term does not follow a Normal distribution. (p<0.05)

### 2. Homogenity of Variance ###
# Residual Analysis #
plot(residuals(reg_model1))
##Breusch Pagan Test
library(lmtest)
bptest(reg_model1)
# H0 is accepted (p>0.05).
# The homogenity of variances is provided.

### 3. The independence of errors ### 
dwtest(reg_model1, alternative = "two.sided")
# There is not an autocorrelation in the data set (p>0.05).
# The errors/observations are independent.

### 4. Multicollinearity ###

## Correlation among Independent Variables ##
score <- which(colnames(heptathlon) == "score")
plot(heptathlon[,-score])
cor(heptathlon[,-score])

library(car)
vif(reg_model1)

## Eliminating longjump from data set
reg_model2<-lm(score~highjump+shot+run200m+javelin+run800m, data=heptathlon)
summary(reg_model2)
vif(reg_model2)

###1. Normality###
#Shapiro Wilks Test
shapiro.test(residuals(reg_model2))
# Using Histogram
hist(residuals(reg_model2))

### 2. Homogenity of Variance ###
# Residual Analysis #
plot(residuals(reg_model2))
##Breusch Pagan Test
library(lmtest)
bptest(reg_model2)

### 3. The independence of errors ### 
dwtest(reg_model2, alternative = "two.sided")


### Model Validation ####
### Test-Train Models ###
n <- nrow(heptathlon)
train.sample1 <- sample(1:n, round(0.67*n))
train.set1 <- heptathlon[train.sample1, ] 
test.set1 <- heptathlon[-train.sample1, ] 

train.model1 <- lm(score~highjump+shot+run200m+javelin+run800m , data = train.set1)
summary(train.model1)

?predict
yhat<-predict(train.model1, test.set1, interval="prediction")
yhat

y<-test.set1$score

error<-cbind(yhat[,1,drop=FALSE],y,(y-yhat[,1])^2)
sqr_err<-error[,3]
mse<-mean(sqr_err)

### Root Mean Square Error ###
RMSE1<-sqrt(mse/(nrow(test.set1)))
RMSE1

names(train.model1)
RMSE_train1<- sqrt(mean((train.model1$residuals)^2)/nrow(train.set1))
RMSE_train1

###### Partial F-test##########################################
### Comparing simple linear regression model with multiple#####
slr<-lm(score~highjump, data=heptathlon)
anova(slr,reg_model2)

lr<-lm(score~highjump+shot, data=heptathlon)
anova(lr,reg_model2)

### Comparing two multiple regression model
reg_model3<-lm(score~highjump+shot+run200m+run800m, data=heptathlon)
summary(reg_model3)
anova(reg_model3,reg_model2)

