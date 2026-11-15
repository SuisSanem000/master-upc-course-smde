# Multiple linear regression (MLR)

[← Back to the guides](README.md)

## When to use it

To describe and predict a numeric response Y from **two or more** predictors
(numeric or categorical), e.g. the price of a house from its size, number of
rooms and location:

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \dots + \beta_k X_k + \varepsilon$$

- **β0**: expected value of Y when all predictors are 0.
- **βj**: expected change of Y when Xj increases by one unit **while all the
  other predictors stay constant**.

Everything in [simple linear regression](simple-linear-regression.md)
(least squares, the assumptions on ε, diagnostics, intervals) still applies.
MLR adds: the overall F-test, adjusted R², categorical predictors (dummy
variables), multicollinearity and variable selection.

## Setup

The code assumes a data frame `df` with a numeric response `y`, numeric
predictors `x1`, `x2`, `x3` and a factor `cat`:

```r
df <- data.frame(y   = my_data$my_response,
                 x1  = my_data$my_predictor_1,
                 x2  = my_data$my_predictor_2,
                 x3  = my_data$my_predictor_3,
                 cat = factor(my_data$my_categorical_predictor))

library(car)      # vif()
library(lmtest)   # dwtest(), bptest()
```

## Steps

### 1. Explore the variables

```r
pairs(df[, c("y", "x1", "x2", "x3")])     # scatter plot of every pair
cor(df[, c("y", "x1", "x2", "x3")])       # correlation matrix
```

Look for predictors related to `y`, and for predictors strongly correlated
with **each other** (a sign of multicollinearity, step 6).

### 2. Fit the model

```r
model <- lm(y ~ x1 + x2 + x3 + cat, data = df)   # or lm(y ~ ., data = df) for all columns
summary(model)
```

The `Coefficients` table gives b0, b1, …, bk and a t-test for each (step 4);
the last lines give R², adjusted R² and the overall F-test (step 3).

### 3. Is the model significant? Overall F-test

- **H0**: β1 = β2 = … = βk = 0 (no predictor explains Y).
- **H1**: at least one βj ≠ 0.

F = MSR / MSE = (SSR / k) / (SSE / (n − k − 1)), with k and n − k − 1 degrees
of freedom. It is the last line of `summary(model)`:

```r
summary(model)$fstatistic                     # F, k, n - k - 1
```

The ANOVA table of the regression:

| Source | Sum of squares | df | Mean square | F |
|---|---|---|---|---|
| Model | SSR = Σ(ŷ − ȳ)² | k | MSR = SSR / k | MSR / MSE |
| Error | SSE = Σ(y − ŷ)² | n − k − 1 | MSE = SSE / (n − k − 1) | |
| Total | SST = Σ(y − ȳ)² | n − 1 | | |

```r
SSE <- sum(residuals(model)^2)
SST <- sum((df$y - mean(df$y))^2)
SSR <- SST - SSE
anova(model)    # sequential sums of squares: SSR is the sum of the predictor rows
```

### 4. Which predictors are significant? t-tests

For each predictor:

- **H0**: βj = 0 (Xj adds nothing, given the other predictors).
- **H1**: βj ≠ 0.

t = bj / s(bj), with n − k − 1 degrees of freedom. These are the `t value` and
`Pr(>|t|)` columns of `summary(model)`.

```r
coef(summary(model))                          # estimates, std. errors, t, p-values
confint(model)                                # CI for every coefficient
qt(0.975, df = df.residual(model))            # critical value t_{alpha/2, n-k-1}
```

A predictor can be significant alone (in SLR) and not significant in MLR,
because its information is already carried by the other predictors.

### 5. Goodness of fit: R² and adjusted R²

R² = SSR / SST is the share of the variation of Y explained by the model. It
**always** grows when a predictor is added, even a useless one. The adjusted R²
only grows if the new predictor reduces the MSE:

$$R^2_a = 1 - (1 - R^2)\frac{n - 1}{n - p - 1}$$

(n observations, p predictors). Use it to compare models with different
numbers of predictors.

```r
summary(model)$r.squared
summary(model)$adj.r.squared
```

### 6. Categorical predictors (dummy variables)

A factor with c levels enters the model as c − 1 dummy (0/1) variables. The
level without a dummy is the **reference category**. R creates the dummies
automatically when the variable is a `factor`:

```r
levels(df$cat)                                # the first level is the reference
df$cat <- relevel(df$cat, ref = "DOS")        # choose another reference level
head(model.matrix(model))                     # the dummy columns R created
```

The coefficient of a dummy (e.g. `catUnix`) is the expected difference in Y
between that category and the reference category, with the other predictors
constant.

### 7. Multicollinearity

The predictors should not be strongly correlated with each other: otherwise
the coefficients become unstable and their standard errors large.

```r
cor(df[, c("x1", "x2", "x3")])   # pairs with |r| close to 1
vif(model)                       # variance inflation factor per predictor
```

**VIF > 10** indicates high multicollinearity. (For factors, `vif()` gives a
GVIF; compare GVIF^(1/(2·Df)) with √10 ≈ 3.16.)

Solutions from the slides:

- Remove correlated variables with a variable selection procedure (step 8).
- Replace them with uncorrelated principal components (PCA).
- Use an estimation method less sensitive to multicollinearity (ridge regression).

### 8. Variable selection

**Partial F-test**: compare a **full** model with a **reduced** (nested)
model that has a subset of its predictors.

- **H0**: all coefficients removed from the full model are 0.
- **H1**: at least one of them is not 0.

F = ((SSE_reduced − SSE_full) / p) / (SSE_full / (n − k)), where p is the
number of removed predictors and k the number of coefficients of the full
model (with intercept).

```r
full    <- lm(y ~ x1 + x2 + x3, data = df)
reduced <- lm(y ~ x1, data = df)
anova(reduced, full)     # p > 0.05: the removed predictors are not needed
```

**Automatic selection**: forward, backward and stepwise.

```r
drop1(full, test = "F")                           # partial F-test for removing each predictor
step(full, direction = "backward")                # backward elimination (by AIC)
step(lm(y ~ 1, data = df), scope = formula(full),
     direction = "forward")                       # forward selection
step(full, direction = "both")                    # stepwise selection
```

`step()` uses the AIC (lower is better) instead of p-values; `drop1()` /
`add1()` with `test = "F"` give the partial F-tests of the slides, one variable
at a time.

### 9. Check the assumptions

The same checks as in SLR, on the residuals of the final model (see
[SLR, step 5](simple-linear-regression.md#5-regression-diagnostics-check-the-assumptions)):

```r
par(mfrow = c(2, 2)); plot(model); par(mfrow = c(1, 1))

shapiro.test(residuals(model))            # normality, H0: residuals are normal
bptest(model)                             # equal variance, H0: homoscedasticity
dwtest(model, alternative = "two.sided")  # independence, H0: no autocorrelation
which(abs(rstandard(model)) > 2)          # suspected outliers
vif(model)                                # multicollinearity (MLR only)
```

Also plot the residuals against each predictor: a pattern means that predictor
enters the model non-linearly.

### 10. Prediction

`newdata` must contain **every** predictor of the model:

```r
new <- data.frame(x1 = 10, x2 = 5, x3 = 2, cat = factor("Unix", levels = levels(df$cat)))
predict(model, newdata = new, interval = "confidence")   # mean of Y
predict(model, newdata = new, interval = "prediction")   # one new Y
```

### 11. Matrix form (what `lm()` computes)

In matrix form y = Xβ + ε, where X is the n × (k + 1) matrix of predictors
with a first column of 1s. The least squares estimate and its
variance-covariance matrix are:

$$b = (X^tX)^{-1}X^ty, \qquad \widehat{Var}(b) = s^2 (X^tX)^{-1}, \quad s^2 = MSE$$

```r
X <- model.matrix(model)                       # includes the column of 1s and dummies
b <- solve(t(X) %*% X) %*% t(X) %*% df$y       # same as coef(model)
s2 <- sum(residuals(model)^2) / df.residual(model)
V <- s2 * solve(t(X) %*% X)                    # same as vcov(model)
sqrt(diag(V))                                  # standard errors of the coefficients
```

## Checklist

| Assumption | How to check | If it fails |
|---|---|---|
| Linearity | Residuals vs fitted and vs each predictor | Transform predictors / response |
| Normality of ε | Q-Q plot, `shapiro.test(residuals(model))` | Transform Y (log, Box-Cox) |
| Constant variance | Residuals vs fitted, `bptest(model)` | Transform Y |
| Independence | `dwtest(model)` | Model the time structure |
| No multicollinearity | `cor()` of the predictors, `vif(model)` < 10 | Drop variables, PCA, ridge regression |
| No influential outliers | `rstandard()` > 2, `cooks.distance()` | Check the data, refit and compare |

## Worked example from the slides

Processed requests per hour as a function of the data size (GB) and the
number of tables:

```r
db <- data.frame(
  requests = c(40, 55, 50, 41, 17, 26, 16),
  size     = c( 6,  7,  7,  8, 10, 10, 15),
  tables   = c( 4, 20, 20, 10, 10,  2,  1)
)

model <- lm(requests ~ size + tables, data = db)
coef(model)         # 52.7, -2.87, 0.85: requests = 52.7 - 2.87 size + 0.85 tables
summary(model)      # F = 7.41 on 2 and 4 df, R^2 = 0.787
anova(model)        # SSR = 961.1 + 182.2 = 1143.3, SSE = 308.7, MSE = 77.2

# t-test for tables: t = 0.85 / 0.55 = 1.54 < t_{0.025, 4} = 2.776
coef(summary(model))["tables", ]
qt(0.975, df = 4)

# the same coefficients with the matrix formula
X <- cbind(1, db$size, db$tables)
solve(t(X) %*% X) %*% t(X) %*% db$requests
```

The model is significant at 0.05 (F = 7.41 > `qf(0.95, 2, 4)` = 6.94) and
explains 79% of the variation of the requests, but the number of tables is
not significant (t = 1.54 < 2.776). A partial F-test confirms it:

```r
anova(lm(requests ~ size, data = db), model)   # F = 2.36, p = 0.199
```

**Exercise from the slides**: fit the SLR `lm(requests ~ size, data = db)`,
interpret the coefficients, check its significance, build its ANOVA table and
interpret its R².
