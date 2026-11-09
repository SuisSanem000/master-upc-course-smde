##########################################
###  SMDE R Lab 3 ########################
#### Nihan Acar-Denizli, Phd  ############
#### UPC, Barcelona ######################
##########################################

##########################################
##### Confidence Intervals and t-test ####
##########################################

#####################################################################
### t distributions vs. Standart Normal Distribution #####
curve(dnorm(x), from = -4, to = 4, lwd = 2, xlab = "X", ylab = "f(t)")
curve(dt(x, 2), from = -4, to = 4, lwd = 2, col = 4, add = TRUE)
curve(dt(x, 9), from = -4, to = 4, lwd = 2, col = 3, add = TRUE)
curve(dt(x, 30), from = -4, to = 4, lwd = 2, col = 2, add = TRUE)
legend("topleft", c("Standard Normal", paste("t distribution:", c(30, 9, 2),
                                             "d.f.")),lwd = 2, col = 1:4, bty = "n")
title("Density functions of t and z distributions")
#################################################################################

### Confidence Interval examples ####
install.packages("TeachingDemos")
library(TeachingDemos)

## 95% confidence level ## 
ci.examp(100, 10, 100, 100)
## 99% confidence level ##
ci.examp(100, 10, 100, conf.level = 0.99)

#################################################
#### Application: cars data set #################
#################################################
cars
summary(cars)

hist(cars$speed)
hist(cars$dist)

## Categorizing Distance ##
summary(cars$dist)

cars$dist_cat<- cut(cars$dist,c(1,36,120))
levels(cars$dist_cat)<-c("1","2")

### Checking distribution of speed across groups ###
?which
g1<-which(cars$dist_cat=="1")
g2<-which(cars$dist_cat=="2")

plot(density(cars$speed[g1]),main="Density curves of 2 Groups",xlim=c(0,35))
lines(density(cars$speed[g2]),col=2)

##############################################
#### 95% Confidence Intervals  ###############
##############################################

mu <- mean(cars$speed, na.rm = TRUE)
std <- sd(cars$speed, na.rm = TRUE)
n <- sum(complete.cases(cars$speed))

#### 95% CI of overall mean  ####
## 1. Manual Computation ###
round(mu + qt(c(0.025, 0.975), n - 1) * std / sqrt(n), 2)

## 2. Output of t.test function ####
round(t.test(cars$speed)$conf.int, 2)

### 95% CI for group means ####
mean(cars$speed[cars$dist_cat=="1"])
round(t.test(cars$speed[cars$dist_cat=="1"])$conf.int, 2)

mean(cars$speed[cars$dist_cat=="2"])
round(t.test(cars$speed[cars$dist_cat=="2"])$conf.int, 2)

########################################
##### Comparing Means of Two Groups ####
############### t-Test #################
########################################

##### Assumption 1 ########
#### Testing Normality ####
?shapiro.test
shapiro.test(cars$dist)
shapiro.test(cars$speed)

## Checking groupwise distributions ####
shapiro.test(cars$speed[cars$dist_cat=="1"])
shapiro.test(cars$speed[cars$dist_cat=="2"])

######### Assumption 2 ##################
##### Homogenity of Variances ###########
?var.test
var.test(cars$speed~cars$dist_cat,data=cars)

## 95% CI for the variance ##
install.packages("DescTools")
library(DescTools)
VarCI(cars$speed)

VarCI(cars$speed[cars$dist_cat=="1"])
VarCI(cars$speed[cars$dist_cat=="2"])

####### t-test #########
?t.test
t.test(cars$speed~cars$dist_cat,var.equal=TRUE)

## Boxplots to Compare Group Means ###
plot(cars$speed~cars$dist_cat)


