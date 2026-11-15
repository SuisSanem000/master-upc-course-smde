# ANOVA (analysis of variance)

[← Back to the guides](README.md)

## When to use it

To test whether the mean of a numeric response is the same in **3 or more
groups** (the levels of a factor), e.g. wine intensity for 4 soils, or test
scores for 3 levels of caffeine.

- **H0**: μ₁ = μ₂ = … = μ_k (all group means are equal).
- **H1**: at least one mean is different.

Why not several t-tests? With k groups there are k(k − 1)/2 pairs; testing
each at α = 0.05 inflates the probability of at least one false positive
(with 100 independent tests it is 99.4%). ANOVA tests all means at once.

## Setup

The code assumes a data frame `df` with a numeric response `y` and a factor
`g` (the groups). For two-way ANOVA, a second factor `h`.

```r
df <- data.frame(y = my_data$my_numeric_variable,
                 g = factor(my_data$my_group_variable))

library(car)      # leveneTest()
library(lmtest)   # dwtest(), bptest()
```

## Steps

### 1. Explore the groups

```r
tapply(df$y, df$g, mean)     # mean of each group
tapply(df$y, df$g, sd)       # standard deviation of each group
table(df$g)                  # group sizes
mean(df$y)                   # grand mean

boxplot(y ~ g, data = df, col = "lightblue")
```

Rule of thumb from the slides: if one group variance is more than about twice
another, check the equal-variance assumption carefully (step 3).

### 2. Fit the model and read the ANOVA table

```r
model <- aov(y ~ g, data = df)
summary(model)
```

```
            Df Sum Sq Mean Sq F value  Pr(>F)
g            2    250     125    12.5 0.00116 **
Residuals   12    120      10
```

| Row / column | Meaning |
|---|---|
| `g` row | Between groups: SSB, with k − 1 df |
| `Residuals` row | Within groups (error): SSE, with N − k df |
| `Mean Sq` | Sum Sq / Df. In the `Residuals` row this is the MSE |
| `F value` | F = (SSB / (k − 1)) / MSE |
| `Pr(>F)` | p-value from the F(k − 1, N − k) distribution |

p ≤ 0.05 → reject H0: not all group means are equal. Go to step 4 to find which
ones differ.

The same table by hand (useful to check exercises):

```r
k   <- nlevels(df$g)
N   <- nrow(df)
gm  <- mean(df$y)                              # grand mean
nj  <- tapply(df$y, df$g, length)              # group sizes
mj  <- tapply(df$y, df$g, mean)                # group means

SSB <- sum(nj * (mj - gm)^2)                   # between groups
SSE <- sum((df$y - mj[df$g])^2)                # within groups
SST <- sum((df$y - gm)^2)                      # total = SSB + SSE
MSE <- SSE / (N - k)
F   <- (SSB / (k - 1)) / MSE
p   <- 1 - pf(F, k - 1, N - k)                 # p-value
qf(0.95, k - 1, N - k)                         # critical value: reject H0 if F > this
```

### 3. Check the assumptions

**Normality**: the response is normal in each group. Check each group, or the
residuals of the model (one test instead of k):

```r
tapply(df$y, df$g, function(v) shapiro.test(v)$p.value)  # H0: group is normal
shapiro.test(residuals(model))                           # H0: residuals are normal

qqnorm(residuals(model)); qqline(residuals(model), col = "red")
hist(residuals(model), col = "lightblue")
```

**Equal variances (homoscedasticity)**: same variance in all groups.

```r
leveneTest(y ~ g, data = df)   # Levene's test, H0: all group variances are equal
bptest(model)                  # Breusch-Pagan test, same H0
```

**Independence** of the observations:

```r
dwtest(model, alternative = "two.sided")   # Durbin-Watson, H0: no autocorrelation
```

For all three: p > 0.05 → the assumption holds. If equal variances fail, the
slides recommend redefining the variable, e.g. `aov(log(y) ~ g, data = df)`.

### 4. Post-hoc tests: which groups differ?

Only after rejecting H0 in step 2, and only with 3+ groups (with 2 groups use a
t-test).

```r
# pairwise t-tests without correction (inflated type I error)
pairwise.t.test(df$y, df$g, p.adj = "none")

# Bonferroni: each test at alpha / m (m = number of pairs); conservative
pairwise.t.test(df$y, df$g, p.adj = "bonferroni")

# Tukey's HSD (honest significant difference): confidence interval per pair
TukeyHSD(model)
plot(TukeyHSD(model))
```

In `TukeyHSD()` output, a pair differs when `p adj` ≤ 0.05, i.e. when its
interval `lwr`–`upr` does not contain 0. Tukey works with unequal group sizes.

**Least Significant Difference (LSD)**: an equal-variance t-test that uses the
MSE instead of the pooled variance. `pairwise.t.test()` uses a pooled SD by
default, so `p.adj = "none"` gives the LSD p-values.

### 5. If the assumptions fail (not in the slides)

- **Unequal variances**: Welch's ANOVA, `oneway.test(y ~ g, data = df, var.equal = FALSE)`.
- **Non-normal residuals**: Kruskal-Wallis test, `kruskal.test(y ~ g, data = df)`
  (H0: same distribution in all groups).
- Or transform the response (`log(y)`, Box-Cox) and fit again.

### 6. Two-way ANOVA

Two factors `g` and `h`, and their interaction (does the effect of `g` depend
on `h`?):

```r
model2 <- aov(y ~ g * h, data = df)   # g + h + g:h
summary(model2)                       # one F-test per factor and for the interaction

interaction.plot(df$g, df$h, df$y)    # parallel lines = no interaction
```

Read the interaction row (`g:h`) first: if it is significant, interpret the
effect of each factor separately for each level of the other. If not, refit
without it (`aov(y ~ g + h, data = df)`) and read the main effects. The
assumption checks of step 3 apply to `model2` as well.

## Checklist

| Assumption | How to check | If it fails |
|---|---|---|
| Independent observations | `dwtest(model)`, study design | Another design / model |
| Normality in each group | `shapiro.test()` per group or on `residuals(model)`, Q-Q plot | Transform `y`, `kruskal.test()` |
| Equal variances | `leveneTest(y ~ g)`, `bptest(model)` | Transform `y` (log), `oneway.test(var.equal = FALSE)` |

## Worked examples from the slides

**Caffeine** (exercise by hand): does caffeine affect the test score?

```r
caffeine <- data.frame(
  score = c(75, 77, 79, 81, 83,    # G1: control
            80, 82, 84, 86, 88,    # G2: mild
            70, 72, 74, 76, 78),   # G3: jolt
  group = factor(rep(c("G1", "G2", "G3"), each = 5))
)
model <- aov(score ~ group, data = caffeine)
summary(model)        # SSB = 250, SSE = 120, MSE = 10, F = 12.5, p = 0.0012
qf(0.95, 2, 12)       # critical value F_{0.05, 2, 12} = 3.885
TukeyHSD(model)
```

F = 12.5 > 3.885 (p = 0.0012): reject H0, caffeine affects the score. Tukey
shows which pairs differ.

**Example 2** (four treatments, 5 observations each):

```r
treat <- data.frame(
  v = c(26.589, 43.612, 26.349, 17.307, 20.943,    # A
        16.127, 28.982, 34.015, 46.446, 45.859,    # B
        14.567, 16.095, 40.438, 25.171, 52.711,    # C
        33.168, 32.435, 11.454, 34.995, 25.977),   # D
  trt = factor(rep(c("A", "B", "C", "D"), each = 5))
)
summary(aov(v ~ trt, data = treat))   # F = 0.351, p = 0.789
```

p = 0.789 > 0.05: no evidence of a difference between the treatments.

**Wine** (lecture example, needs the `FactoMineR` package):

```r
data(wine, package = "FactoMineR")
summary(aov(Intensity ~ Soil, data = wine))           # F = 3.766, p = 0.0306
pairwise.t.test(wine$Intensity, wine$Soil, p.adj = "bonferroni")
TukeyHSD(aov(Intensity ~ Soil, data = wine))          # only Env1 - Reference differs
```
