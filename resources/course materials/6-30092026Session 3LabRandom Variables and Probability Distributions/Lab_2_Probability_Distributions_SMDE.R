##########################################
###  SMDE R Lab 2 ########################
#### Nihan Acar-Denizli, Phd  ############
#### UPC, Barcelona ######################
##########################################

#### Importing Data ####

### Importing txt data ###

### From the website: 
### http://archive.ics.uci.edu/ml/datasets/Car+Evaluation

car<-read.table("car.txt")
?read.table
car
summary(car)
head(car)

car<-read.table("car.txt", sep=",")
summary(car)
colnames(car)
colnames(car)<-c("buying", "maint","doors", "persons", "lug_boot", "safety", "class")

car$buying<-as.factor(car$buying)
levels(car$buying)
str(car$buying)
summary(car$buying)
summary(car)

car<-read.table("car.txt", sep=",", stringsAsFactors = TRUE)
summary(car)
str(car)

### Importing xls data ###
??read_excel
install.packages("readxl")
library(readxl)

??read.xlsx
install.packages("openxlsx")
library(openxlsx)

wine_xl1<-read_excel("winequality-red.xlsx")
summary(wine_xl1)

wine_xl2<-read.xlsx("winequality-red.xlsx")
summary(wine_xl2)


### Importing csv data ###
?read.csv2
red<-read.csv2("winequality-red.csv")
summary(red)
red<-read.csv2("winequality-red.csv",dec=".")
summary(red)

white<-read.csv2("winequality-white.csv",dec=".")
summary(white)
head(white)

####### Creating a Factor ####

dim(red)
dim(white)

winequal<-rbind(red,white)
dim(winequal)

winequal$cat<-as.factor(rep(c(1,2),c(nrow(red),nrow(white))))
head(winequal)
summary(winequal)

levels(winequal$cat)<-c("red","white")

##############################################################
### Converting a Numerical Variable to a Categorical Variable 
##############################################################

summary(winequal$quality)
?cut

winequal$qual_cat<- cut(winequal$quality,c(1,5.5,10))
levels(winequal$qual_cat)<-c("Low","High")
summary(winequal$qual_cat)

winequal$qual_cat<- cut(winequal$quality,c(2,5,6,9))
summary(winequal$qual_cat)
levels(winequal$qual_cat)<-c("Low","Medium","High")
summary(winequal$qual_cat)


##################################
##### Factor Data and Tables #####
##################################

?mtcars
summary(mtcars)
View(mtcars)


mtcars[,8]<-as.factor(mtcars[,8])
mtcars[,8]
summary(mtcars)

mtcars[,9]<-as.factor(mtcars[,9])
summary(mtcars)

## Alternatively ##
for (i in 8:9){
  mtcars[,i]<-as.factor(mtcars[,i])
}

summary(mtcars)

levels(mtcars[,8])<-c("V-shaped","straight")
levels(mtcars[,9])<-c("automatic","manual")

## Cross Table ##
tab<-table(mtcars$vs,mtcars$am)
tab

?prop.table

#Joint Probability
prop.table(tab)

#Marginal Probabilities
colSums(prop.table(tab))
rowSums(prop.table(tab))

##########################
#Conditional Probabilities
##########################

# Row Profile
prop.table(tab,1)

#Column Profile
prop.table(tab,2)


##########################
#### Birthday Problem ####
##########################

?qbirthday

qbirthday(prob=0.5,365,2)

?pbirthday
pbirthday(9,classes=365,coincident=2)
pbirthday (23,365,2)


###################################
### Generating Random Variables ###
###################################

## Uniform Distribution ###
?runif
# generating a random number
runif(1)    
#generating 3 random numbers
runif(3)    
# generating 3 random numbers on a defined range 
runif(3, min=5, max=10)    
runif(5, min=0.25, max=0.5)

#generating an uniform random vector of 100 observations for the interval [0,1]
vec_u<-runif(100,0,1)
hist(vec_u)


## Normal Distribution ###
?rnorm
# generating 1 random number from a standard normal distribution
rnorm(1)   
# generating 3 random numbers from a standard normal distribution
rnorm(3)    
# generating 3 random numbers from a Normal distribution with a specific mean and standard deviation
rnorm(3, mean=10, sd=2)   

# generating three different samples of length 100 observations from a Normal distribution
vec_n1<-rnorm(100, mean=60, sd=5)
hist(vec_n1) 

vec_n2<-rnorm(100, mean=40,sd=5)
hist(vec_n2)

vec_n3<-rnorm(100, mean=60, sd=10)   
hist(vec_n3)

?density
plot(density(vec_n1))

## Arranging limits of axes ###
plot(density(vec_n1),xlim=c(10,100),ylim=c(0,0.085), main="Three different Normal distributed samples")
lines(density(vec_n2),col=2)
lines(density(vec_n3),col=3)

### Poisson Distribution ###
?rpois
vec_p1<-rpois(50,10)
hist(vec_p1)

vec_p2<-rpois(100,10)
hist(vec_p2)

vec_p3<-rpois(1000,10)
hist(vec_p3)

############ Expected Value and Variance #############################
### Expected Value of Rolling a Die ###

p_die <- rep(1/6,6)
die <- 1:6
exp_val<-sum(die*p_die)
exp_val

sample(die, size=10, prob=p_die, replace=T)
hist(sample(die, size=1000, prob=p_die, replace=T))

s <- table(sample(die, size=1000, prob=p_die, replace=T))
s

############################################
#### Distribution of Sample Means ####
############################################
## Function for generating n sample means ###
gen_sample_means <- function(n) {
  sample_means <- numeric()
  for (i in 1:1000) { 
    sample_means <- append(sample_means, sum(sample(die, size=n, prob=p_die, replace=T))/n)
  }
  return (sample_means)
}
###############################################

sample_means <- gen_sample_means(100)
plot(density(sample_means), main="Distribution of the sample means", xlab="sample mean", col="red")

mean(sample_means)
sd(sample_means)
var(sample_means)

