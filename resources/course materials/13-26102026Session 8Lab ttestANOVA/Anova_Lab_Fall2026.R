##########################################
###  SMDE R Lab: ANOVA ###################
#### Nihan Acar-Denizli, Phd  ############
#### UPC, Barcelona ######################
##########################################

### Generating Normal random vectors
v1=rnorm(200, mean=0, sd=1)
v2=rnorm(200, mean=2, sd=1)
v3=rnorm(200, mean=0, sd=1)

plot(density(v1),xlim=c(-4,6),main="Three Normal distributions")
lines(density(v2),col=2)
lines(density(v3),col=3)

v1n=data.frame(x1=v1, x2="v1")
v2n=data.frame(x1=v2, x2="v2")
v3n=data.frame(x1=v3, x2="v3")

install.packages("RcmdrMisc")
library(RcmdrMisc)
?mergeRows
data=mergeRows(v1n, v2n, common.only=FALSE)
data=mergeRows(as.data.frame(data), v3n, common.only=FALSE)
head(data)

### ANOVA on simulated data ####
AnovaModel.1 <- aov(x1 ~ x2, data=data)
summary(AnovaModel.1)

library(car)
Boxplot(x1~x2,data=data,id=FALSE)

#install.packages("lmtest")
library(lmtest)

##### Assumptions of ANOVA ###
#The observations within each sample must be independent.
#Durbin Watson 
dwtest(AnovaModel.1, alternative ="two.sided")

#The populations from which the samples are selected must be normal.
#Shapiro test
shapiro.test(residuals(AnovaModel.1))

# Kolmogorov-Smirnov Test
ks.test(residuals(AnovaModel.1), "pnorm", mean(residuals(AnovaModel.1)), sd(residuals(AnovaModel.1)))

#The populations from which the samples are selected must have equal variances (homogeneity of variance)
#Breusch Pagan test
bptest(AnovaModel.1)


##################################################
######## ANOVA Example: Wine (FactoMineR) ########
##################################################

#install.packages("FactoMineR")
library(FactoMineR)

data(wine)
head(wine)
summary(wine)

#### Assumptions ####
#### Normality of quantitative variables ###

# Histograms #
hist(wine$Aroma.intensity)
hist(wine$Flower)
hist(wine$Intensity)

# Test of Normality #
shapiro.test(wine$Aroma.intensity)
shapiro.test(wine$Flower)
shapiro.test(wine$Intensity)

## ANOVA MODELS ##
model1<-aov(Aroma.intensity~Soil,data=wine)
summary.aov(model1)

model2<-aov(Flower~Soil,data=wine)

summary.aov(model2)

model3<-aov(Intensity~Soil,data=wine)
summary.aov(model3)

model4<-aov(Intensity~Label,data=wine)
summary.aov(model4)

Boxplot(wine$Intensity~wine$Soil,id=FALSE,col=2:(nlevels(wine$Soil)+1))

#### Independency of observations ###
dwtest(model3,alternative="two.sided")

### Homogenity of Variances #####
### Levene's Test #####

?leveneTest
leveneTest(Intensity~Soil,data=wine)

### Breusch Pagan test ####
bptest(model3)

### Normality of residuals ###
shapiro.test(model3$residual)

#########################################
########## Multiple Comparisons #########
#########################################

#### Tukey's HSD ####
?TukeyHSD
TukeyHSD(model3)

#### Pairwise t-test ###
?pairwise.t.test

with(wine,
{
  pairwise.t.test(Intensity,Soil,p.adj="none")
})

######## Bonferroni Correction ###

with(wine,
{ 
pairwise.t.test(Intensity,Soil,p.adj="bonf")
})

####### LSD Test ####
install.packages("agricolae")
library(agricolae)

?LSD.test
LSD<-LSD.test(model3,"Soil") #p.adj = "bonferroni")
LSD

###########################
####### Two-Way ANOVA #####
###########################

model5<-aov(Intensity~Soil+Label,data=wine)
summary(model5)

head(wine)

for (i in 3:31){
  print(colnames(wine)[i])
  print(summary(aov(wine[,i]~Soil+Label,data=wine)))
}

model6<-aov(Odor.Intensity~Soil + Label,data=wine)
summary(model6)

dwtest(model6)
shapiro.test(wine$Odor.Intensity)

leveneTest(Odor.Intensity~Soil,data=wine)
leveneTest(Odor.Intensity~Label,data=wine)

TukeyHSD(model6)

## Interaction Plot ###
?interaction.plot
interaction.plot(wine$Soil,wine$Label, wine$Odor.Intensity, fun=mean, ylim=c(3,4), type="l", legend=TRUE)

