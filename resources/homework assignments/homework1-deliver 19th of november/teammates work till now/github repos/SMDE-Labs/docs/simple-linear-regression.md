# Simple linear regression (SLR)

[← Back to the guides](README.md)

## When to use it

To describe and predict a numeric **response** Y from **one** numeric
**predictor** X, assuming a straight-line relationship:

$$Y = \beta_0 + \beta_1 X + \varepsilon$$

- **β0** (intercept): expected value of Y when X = 0.
- **β1** (slope): expected change of Y when X increases by one unit.
- **ε** (error): random noise, ε ~ N(0, σ).

The least squares method estimates β0 and β1 with b0 and b1, the line that
minimises the sum of squared residuals (SSE). It **always** produces a line,
even when there is no linear relationship, so the model must be assessed and
its assumptions checked. For several predictors, see
[multiple linear regression](multiple-linear-regression.md).

### Assumptions (on the error ε)

1. **Linearity**: E(ε) = 0, the relationship between X and Y is linear.
2. **Normality**: ε is normally distributed.
3. **Homoscedasticity**: the standard deviation σ of ε is constant for every x.
4. **Independence**: the errors are independent of each other.

Also: no outliers or influential points that drive the fit.

## Setup

The code assumes a data frame `df` with a numeric response `y` and a numeric
predictor `x`:

```r
df <- data.frame(x = my_data$my_x_variable,
                 y = my_data$my_y_variable)

library(lmtest)      # dwtest(), bptest()
library(MASS)        # boxcox()
library(tolerance)   # regtol.int() (tolerance intervals only)
```

## Procedure

The slides' procedure for a regression analysis:

1. Have a model with a theoretical basis and collect the data.
2. Draw the scatter plot: is a line appropriate? Any outliers? (step 1)
3. Determine the regression equation. (steps 2–4)
4. Compute the residuals and check the required conditions. (steps 5–6)
5. Assess the fit. (step 3)
6. If the model fits, use it to predict a value of Y or estimate its mean. (step 7)

## Steps

### 1. Scatter plot

```r
plot(y ~ x, data = df, pch = 19, main = "Y vs X")
abline(lm(y ~ x, data = df), col = "red")        # least squares line
lines(lowess(df$x, df$y), col = "blue", lty = 2) # smooth trend, to spot curvature
```

The points should follow a roughly straight band. A curve suggests a
transformation or another model; isolated points are possible outliers.

### 2. Correlation

The correlation coefficient r (−1 ≤ r ≤ 1) measures the strength and
direction of the **linear** relationship.

```r
cor(df$x, df$y)
cor.test(df$x, df$y)     # H0: rho = 0 (no linear correlation), H1: rho != 0
```

- r close to +1 / −1: strong positive / negative linear relationship.
- r close to 0: no linear relationship (there may still be a non-linear one).
- Correlation does not imply causation.

### 3. Fit the model and assess it

```r
model <- lm(y ~ x, data = df)
summary(model)
```

Example output (decathlon data from the slides: 100 m time vs 110 m hurdles time):

```
Coefficients:
             Estimate Std. Error t value Pr(>|t|)
(Intercept)   6.27614    1.06281   5.905 7.01e-07 ***
x             0.32329    0.07273   4.445 7.08e-05 ***

Residual standard error: 0.217 on 39 degrees of freedom
Multiple R-squared:  0.3363,	Adjusted R-squared:  0.3193
F-statistic: 19.76 on 1 and 39 DF,  p-value: 7.082e-05
```

| Output | Meaning |
|---|---|
| `Estimate` | b0 (`(Intercept)`) and b1 (`x`): ŷ = b0 + b1·x |
| `Std. Error`, `t value`, `Pr(>|t|)` | t-test of each coefficient (step 4) |
| `Residual standard error` | S, the standard error of the estimate: √(SSE / (n − 2)) |
| `Multiple R-squared` | R² = r²: share of the variation of Y explained by X |
| `Adjusted R-squared` | R² penalised for the number of predictors |
| `F-statistic` | Overall model test; in SLR it is the same test as the slope (F = t²) |

**Standard error S**: S = 0 means all points are on the line. To judge whether
S is "small", compare it with the mean of Y:

```r
sigma(model)            # S
sigma(model) / mean(df$y)   # relative size: small values = good fit
```

**R²**: e.g. R² = 0.65 means 65% of the variation of Y is explained by the
model and 35% is unexplained (error). There is no critical value for R²; the
higher it is, the better the fit (R² = 1: perfect fit, R² = 0: no linear
relationship).

### 4. Test the slope

If there is no linear relationship, the line is horizontal (β1 = 0).

- **H0**: β1 = 0 (no linear relationship between X and Y).
- **H1**: β1 ≠ 0.

t = b1 / s_b1, with a t distribution with n − 2 degrees of freedom (if ε is
normal). In `summary(model)` it is the `x` row:

```r
coef(summary(model))["x", ]                    # estimate, std. error, t, p-value
qt(0.975, df = nrow(df) - 2)                   # critical value: reject H0 if |t| > this
confint(model, level = 0.95)                   # CI for beta0 and beta1: b1 +- t * s_b1
```

p ≤ 0.05 (or a CI for β1 that does not contain 0): there is evidence of a
linear relationship.

### 5. Regression diagnostics (check the assumptions)

All checks use the residuals e = y − ŷ. The four standard plots:

```r
par(mfrow = c(2, 2))
plot(model)        # residuals vs fitted, Q-Q, scale-location, residuals vs leverage
par(mfrow = c(1, 1))
```

**Linearity and homoscedasticity**: residuals vs fitted values.

```r
plot(fitted(model), residuals(model), pch = 19,
     xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = "red")
```

A random cloud around 0 supports both. A curve means non-linearity; a funnel
(spread growing with ŷ) means heteroscedasticity.

```r
bptest(model)      # Breusch-Pagan, H0: constant variance (homoscedasticity)
```

**Normality**: Q-Q plot, histogram and Shapiro-Wilk test of the residuals.

```r
qqnorm(residuals(model)); qqline(residuals(model), col = "red")
hist(residuals(model), col = "lightblue")   # bell-shaped, centred at 0
shapiro.test(residuals(model))              # H0: residuals are normal
```

**Independence**: especially for time series, where errors are often
autocorrelated. Plot the residuals in the order of the data: runs of positive
then negative residuals, or a regular oscillation, indicate autocorrelation.

```r
plot(residuals(model), type = "b", xlab = "Observation order", ylab = "Residuals")
abline(h = 0, col = "red")
dwtest(model, alternative = "two.sided")   # Durbin-Watson, H0: no autocorrelation
```

The Durbin-Watson statistic is close to 2 with no autocorrelation, close to 0
with positive and close to 4 with negative autocorrelation.

**Outliers and influential points**: a standardised residual with |value| > 2
is a suspected outlier (> 3: extreme). Check whether it is a recording error,
a point that should not be in the sample, or a valid observation.

```r
which(abs(rstandard(model)) > 2)                 # suspected outliers
which(cooks.distance(model) > 4 / nrow(df))      # influential points (rule of thumb)
plot(model, which = 4)                           # Cook's distance plot
```

For all tests: p > 0.05 → the assumption holds.

### 6. If the assumptions fail

- **Non-normality or heteroscedasticity**: transform the response. The
  **Box-Cox** transformation finds the power λ that makes Y closest to normal
  (Y must be positive):

  ```r
  bc <- boxcox(model)                    # plot of the log-likelihood for each lambda
  lambda <- bc$x[which.max(bc$y)]        # best lambda
  lambda
  # lambda close to 0 -> log(y); close to 0.5 -> sqrt(y); close to 1 -> no change
  model_bc <- lm(((y^lambda - 1) / lambda) ~ x, data = df)
  ```

  Then check the assumptions again on the new model.
- **Non-linearity**: transform X or Y (`log(x)`, `x^2`) or use another model.
- **Outliers**: fix recording errors; refit with and without the point and
  compare. Do not delete valid observations without a reason.

### 7. Use the model: point prediction and intervals

```r
new <- data.frame(x = 40)                                 # value(s) of x to predict at

predict(model, newdata = new)                             # point prediction y-hat
predict(model, newdata = new, interval = "confidence")    # CI for the MEAN of Y at x
predict(model, newdata = new, interval = "prediction")    # PI for ONE new Y at x
```

| Interval | Tells you | Width |
|---|---|---|
| **Confidence** | Where the true regression line (mean of Y at x) lies | Narrower |
| **Prediction** | Where one new observation of Y at x will fall | Wider (mean uncertainty + scatter) |
| **Tolerance** | An interval that contains a proportion P of the values with confidence 1 − α | Wider than prediction for a high confidence |

A tolerance interval needs two percentages: how sure you want to be (1 − α)
and what fraction of the values it should contain (P):

```r
# 95% confidence that the interval contains 95% of the values at each x
regtol.int(model, new.x = new, side = 2, alpha = 0.05, P = 0.95)
```

### 8. Validate the model on new data

```r
set.seed(123)
train <- sample(seq_len(nrow(df)), round(0.67 * nrow(df)))   # 67% of rows to fit
train_model <- lm(y ~ x, data = df[train, ])

yhat <- predict(train_model, newdata = df[-train, ])         # predict the other 33%
rmse <- sqrt(mean((df$y[-train] - yhat)^2))                  # root mean squared error
rmse
```

A lower RMSE means smaller prediction errors (in the units of Y). Compare RMSEs
only between models evaluated on the same test data.

## Checklist

| Assumption | How to check | If it fails |
|---|---|---|
| Linearity | Scatter plot, residuals vs fitted (no curve) | Transform X or Y |
| Normality of ε | Q-Q plot, histogram, `shapiro.test(residuals(model))` | Box-Cox / log transform of Y |
| Constant variance | Residuals vs fitted (no funnel), `bptest(model)` | Transform Y (log, Box-Cox) |
| Independence | Residuals in order, `dwtest(model)` | Model the time structure |
| No outliers / influential points | `rstandard()` > 2, `cooks.distance()` > 4/n | Check the data, refit without them and compare |

## Worked examples from the slides

**Correlation** (built-in `trees` data):

```r
cor(trees[, c("Height", "Volume")])   # r = 0.598
cor.test(trees$Height, trees$Volume)  # H0: rho = 0
```

**Computation by hand**: 10 observations.

```r
x <- c(5, 10, 4, 8, 2, 7, 9, 6, 1, 12)
y <- c(5,  2, 8, 3, 8, 5, 5, 7, 10, 3)
n <- length(x)

Sxy <- sum((x - mean(x)) * (y - mean(y)))   # -73.4
Sxx <- sum((x - mean(x))^2)                 # 110.4
b1  <- Sxy / Sxx                            # -0.665
b0  <- mean(y) - b1 * mean(x)               # 9.855

SSE <- sum((y - (b0 + b1 * x))^2)
S   <- sqrt(SSE / (n - 2))                  # 1.204
t   <- qt(0.975, df = n - 2)                # t_{0.025, 8} = 2.306

b1 + c(-1, 1) * t * S / sqrt(Sxx)           # slope CI: (-0.929, -0.401)

x0 <- 11                                    # prediction interval at x = 11
y0 <- b0 + b1 * x0                          # 2.541
y0 + c(-1, 1) * t * S * sqrt(1 + 1/n + (x0 - mean(x))^2 / Sxx)   # (-0.614, 5.697)
```

The same with `lm()`:

```r
model <- lm(y ~ x)
coef(model)                                                   # 9.855, -0.665
confint(model)["x", ]                                         # -0.929, -0.401
predict(model, data.frame(x = 11), interval = "prediction")   # 2.541 (-0.614, 5.697)
```
