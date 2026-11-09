
########################################################
###  SMDE R Lab: Simple Linear Regression ##############
#### Nihan Acar-Denizli, Phd  ##########################
#### UPC, Barcelona ####################################
########################################################

##### Example: anscombe data set #####
# Check the data set

#In anscombe data there are four independent and four dependent variables.
anscombe

#Let us construct four different simple linear regression models.
reg1<-lm(y1~x1,data=anscombe)
summary(reg1)

reg2<-lm(y2~x2, data=anscombe)
summary(reg2)

reg3<-lm(y3~x3,data=anscombe)
summary(reg3)

reg4<-lm(y4~x4,data=anscombe)
summary(reg4)

#Both of the models seem significant with almost the same values for
# residual standard error, R^2, adjusted R^2 and F test. 
# Which model is better? 

# Let us check the coefficient of correlation between variables
# and scatter plots.

## Correlation Tests ##
cor.test(anscombe$x1,anscombe$y1)
cor.test(anscombe$x2,anscombe$y2)
cor.test(anscombe$x3,anscombe$y3)
cor.test(anscombe$x4,anscombe$y4)
# In all cases the coefficient of correlation is 0.816
# and significant (p=0.002).

## Scatter Plots ##
op<-par(mfrow=c(2,2))
plot(y1~x1,data=anscombe)
plot(y2~x2,data=anscombe)
plot(y3~x3,data=anscombe)
plot(y4~x4,data=anscombe)
par(op)

# 1st scatter plot: The relationship is linear.

# 2nd scatter plot: The relationship is not linear. The shape is curve linear.
#The plot of residuals vs. fitted values suggests a parabolic relationship /a quadratic model
names(reg2)
plot(reg2$fitted.values,reg2$residuals)

# Adding a quadratic term can increase R^2 value.
x2_2<-(anscombe$x2)^2

#If we add x^2 to the regression model the R^2 increases to 1.
# So all the variation of y could be explained by using x2 and 
# x2_2 together in the model.
reg2_2<-lm(y2~x2+x2_2,data=anscombe)
summary(reg2_2)

# 3rd scatter plot: The relationship is linear but there is 
# one outlier. Either this observation should be omitted or
# a robust regression analysis should be done so as to the 
# regression line is not effected from the outlier.

# When we omit that observation.(3rd observation)) 
anscombe2<-anscombe[-3,]
reg3_2<-lm(y3~x3,data=anscombe2)
summary(reg3_2)
# R squared value increase to 1. Perfect fit!

# 4th scatter plot: Most of the observations cumulated around 
# x=8. There is just one observation apart from other which 
# causes a linear relationship in the data set. This is an influential point.
# When it is removed, there is no reason to use regression.
anscombe3<-anscombe[-8,]
plot(anscombe3$x4,anscombe3$y4)
reg4<-lm(y4~x4,data=anscombe3)
summary(reg4)


###############################################################
###############################################################
#### Linear Regression on Heptathlon Data Set ################
###############################################################

install.packages("HSAUR")
library(HSAUR)

data("heptathlon", package = "HSAUR")
plot(heptathlon)

cor(heptathlon)

### Correlation with score variable ###
cor(heptathlon)[8,]


### Simple Linear Regression ####
slr<-lm(score~longjump,data=heptathlon)
summary(slr)

slr2<-lm(score~hurdles,data=heptathlon)
summary(slr2)

library(car)
scatterplot(score~longjump, regLine=lm, smooth=FALSE, data=heptathlon)
scatterplot(score~hurdles, regLine=lm, smooth=FALSE, data=heptathlon)

### Testing Regression Assumptions ###
### 1. Normality of the Error Term ###
# Using QQ plot
qqnorm(residuals(slr))
qqnorm(residuals(slr2))

# Using Histogram
hist(residuals(slr))
hist(residuals(slr2), breaks=6)

#Shapiro Wilks Test
shapiro.test(residuals(slr))
shapiro.test(residuals(slr2))

### 2. Homogenity of Variance ###
# Residual Analysis #
plot(residuals(slr))
plot(residuals(slr2))

##Breusch Pagan Test
install.packages("lmtest")
library(lmtest)
bptest(slr)
bptest(slr2)

### 3. The independence of errors ### 
dwtest(slr, alternative = "two.sided")
dwtest(slr2, alternative = "two.sided")

##### Confidence interval for beta parameters ####
confint(slr)
confint(slr2)

#Predicted Values of the Response
yhat<-slr2$fitted.values

# Predicted Values of the Response with Their confidence Levels
predict.lm(slr2,interval="confidence")

# Prediction interval for the Response (for x=16)
?predict.lm

new=data.frame(hurdles=3)
predict.lm(slr2, newdata=new, interval="prediction")

### Model Validation ####
### Test-Train Models ###
n <- nrow(heptathlon)
train.sample1 <- sample(1:n, round(0.67*n))
train.set1 <- heptathlon[train.sample1, ] 
test.set1 <- heptathlon[-train.sample1, ] 

train.model1 <- lm(score~hurdles , data = train.set1)
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


################################
##### Adding Dummy Variables ###
################################

data("mtcars")
head(mtcars)
summary(mtcars)

as.factor(mtcars$am)

reg1<-lm(mpg ~ hp + am , data = mtcars)
summary(reg1)
names(reg1)
coefficients(reg1)

## Yauto = bo+b1x1
## Ymanual =(b0+b2)+b1x1+b2x2

b0man=coefficients(reg1)[1]+coefficients(reg1)[3]
b0auto=coefficients(reg1)[1]

### Plot Regression Lines for Manual and Automatic Cars ###
plot(mpg ~ hp, data = mtcars, col =  am+1, pch = am+1, cex = 1)
abline(b0auto, coefficients(reg1)[2], col = 1, lty = 1, lwd = 1) # add line for auto
abline(b0man,  coefficients(reg1)[2], col = 2, lty = 2, lwd = 1) # add line for manual
legend("topright", c("Automatic", "Manual"), col = c(1, 2), pch = c(1, 2))

### Simple Model vs. Dummy Variable Model ###
reg2<-lm(mpg ~ hp, data = mtcars)
anova(reg2,reg1)



