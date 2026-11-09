# Question 3 Statistical Methods: Linear Regression Analysis & Model Validation

This document explains the statistical theory and methodology needed to understand and solve **Question 3** of Homework 1 in simple, clear, Upper B2 English.

---

## 1. The Core Objective of Question 3

In Question 3, our goal is **predictive statistical modeling**:
We want to predict how far an individual can jump in the standing broad jump test (`broad_jump_cm`) using their other physical measurements.

We do this through a structured sequence of modeling steps:
1. **Simple Linear Regression (Q3.a)**: Predict jump distance using a single numerical variable.
2. **Multiple Linear Regression (Q3.b)**: Predict jump distance using two numerical variables together.
3. **Dummy Variable Regression (Q3.c)**: Add categorical groups (like age brackets) to see if group membership shifts the regression line.
4. **Model Comparison & Selection (Q3.d)**: Use formal statistical metrics to pick the best overall model.
5. **Model Validation (Q3.e)**: Split the dataset into a 70% training set and a 30% testing set to confirm that the model predicts accurately on unseen data.

---

## 2. Simple Linear Regression (Q3.a)

### The Mathematical Formula:
$$y_i = \beta_0 + \beta_1 x_i + \epsilon_i, \quad \epsilon_i \sim \mathcal{N}(0, \sigma^2)$$
Where:
- $y_i$ is the dependent variable (response: `broad_jump_cm`).
- $x_i$ is the independent variable (predictor: e.g., `grip_force`).
- $\beta_0$ is the **intercept** (the predicted jump distance when $x = 0$).
- $\beta_1$ is the **slope** (the change in predicted jump distance for every 1-unit increase in $x$).
- $\epsilon_i$ is the random error term.

### Ordinary Least Squares (OLS) Estimation:
OLS finds the best-fitting line by minimizing the sum of squared vertical distances between data points and the line:
$$\min \sum_{i=1}^n e_i^2 = \min \sum_{i=1}^n (y_i - \hat{y}_i)^2$$

### Evaluating Model Quality:
1. **Correlation Coefficient ($r$)**: Measures the linear association strength (between $-1$ and $+1$).
2. **Coefficient of Determination ($R^2$)**: The percentage of variation in the response variable explained by the model:
   $$R^2 = \frac{SS_{\text{Regression}}}{SS_{\text{Total}}} = 1 - \frac{SS_{\text{Residual}}}{SS_{\text{Total}}}$$
   An $R^2 = 0.55$ means that 55% of the differences in broad jump distances are explained by handgrip strength.

In R:
```r
model_simple <- lm(broad_jump_cm ~ grip_force, data = body)
summary(model_simple)
```

---

## 3. Multiple Linear Regression & Multicollinearity (Q3.b)

When two numerical predictors are combined:
$$y_i = \beta_0 + \beta_1 x_{i1} + \beta_2 x_{i2} + \epsilon_i$$
- $\beta_1$ represents the effect of $x_1$ on $y$ **holding $x_2$ constant** (partial slope).
- $\beta_2$ represents the effect of $x_2$ on $y$ **holding $x_1$ constant**.

### The Danger of Multicollinearity:
If the two predictors ($x_1$ and $x_2$) are strongly correlated with each other (e.g., body weight and BMI), the model struggles to separate their individual effects. This leads to unstable coefficients and inflated standard errors.

### How to Detect Multicollinearity:
- **Variance Inflation Factor (VIF)**:
  $$\text{VIF}_j = \frac{1}{1 - R_j^2}$$
  - $\text{VIF} \approx 1$: No collinearity.
  - $\text{VIF} < 5$: Safe, acceptable collinearity.
  - $\text{VIF} > 10$: Severe collinearity; one of the variables should usually be removed.

In R:
```r
library(car)
vif(model_multiple)
```

---

## 4. Categorical Predictors & Dummy Variables (Q3.c)

Regression models only accept numbers. To include a categorical variable with $k$ levels (such as `age_cat` with 4 levels), R automatically creates $k - 1 = 3$ **dummy indicator variables** ($0$ or $1$):
- $D_1 = 1$ if age is 30–39, else $0$
- $D_2 = 1$ if age is 40–49, else $0$
- $D_3 = 1$ if age is 50+, else $0$
- The excluded level (`<30`) becomes the **reference baseline**.

### The Dummy Model Equation:
$$y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \gamma_1 D_1 + \gamma_2 D_2 + \gamma_3 D_3 + \epsilon$$

### How to Interpret the Coefficients:
- $\beta_0$: Expected jump distance for the **reference group** (`<30`) when numerical predictors equal zero.
- $\gamma_1$: The difference in jump distance for someone aged 30–39 compared to someone under 30 with identical physical measurements.
- Since jump power declines with age, we expect $\gamma_1, \gamma_2, \gamma_3$ to be negative numbers that become progressively more negative as age increases.

In R:
```r
model_dummy <- lm(broad_jump_cm ~ grip_force + sit_ups + age_cat, data = body)
summary(model_dummy)
```

---

## 5. Model Comparison & Diagnostics (Q3.d)

When choosing the best model among several candidates, we use four formal criteria:

### 1. Partial F-Test (Nested Model Comparison)
Used when a simpler model is a subset of a larger model (e.g., adding `age_cat` to numerical predictors):
- $H_0: \gamma_1 = \gamma_2 = \gamma_3 = 0$ (the added variables do not improve the model).
- $H_1$: At least one added variable significantly improves predictions.
In R:
```r
anova(model_multiple, model_dummy)
```

### 2. Adjusted $R^2$ ($R^2_{\text{adj}}$)
Standard $R^2$ always increases whenever you add another variable, even if that variable is useless. Adjusted $R^2$ penalizes adding unnecessary variables:
$$R^2_{\text{adj}} = 1 - \left[ \frac{(1 - R^2)(n - 1)}{n - p - 1} \right]$$
We prefer models with higher Adjusted $R^2$.

### 3. AIC and BIC (Information Criteria)
- **Akaike Information Criterion (AIC)**: Balances model fit against complexity.
- **Bayesian Information Criterion (BIC)**: Applies a stronger penalty for extra parameters.
- **Rule**: Lower AIC and lower BIC values indicate a better, more parsimonious model.
In R:
```r
AIC(model_simple, model_multiple, model_dummy)
BIC(model_simple, model_multiple, model_dummy)
```

---

## 6. Model Assumptions & Diagnostic Plots

To verify that the linear model is mathematically valid, four assumptions must be checked:

| Assumption | Meaning | How to Test | What to Look For |
| :--- | :--- | :--- | :--- |
| **Linearity** | Relationship between $x$ and $y$ is straight. | Residuals vs Fitted plot | Flat horizontal red line around 0 with no curved pattern. |
| **Homoscedasticity** | Residuals have constant variance across all fitted values. | Scale-Location plot & Breusch-Pagan test (`lmtest::bptest`) | Random scatter of points without funnel or cone shapes; $p > 0.05$. |
| **Normality of Residuals** | Error terms follow a normal distribution. | Normal Q-Q plot & Shapiro-Wilk test | Points lie close to the diagonal line. |
| **Independence of Errors** | No correlation between consecutive error terms. | Durbin-Watson test (`lmtest::dwtest`) | $d \approx 2.0, p > 0.05$. |

---

## 7. Model Validation: Train/Test Split (Q3.e)

To confirm that our model generalizes well to new, real-world data and does not suffer from overfitting, we split the dataset:
- **70% Training Set**: Used to fit the model parameters ($\hat{\beta}$).
- **30% Test Set**: Kept completely untouched during model training, used only to evaluate predictions.

### Evaluation Metric: Root Mean Square Error (RMSE)
$$\text{RMSE} = \sqrt{\frac{1}{n_{\text{test}}} \sum_{i=1}^{n_{\text{test}}} (y_i - \hat{y}_i)^2}$$
- Represents the average prediction error in the original units (cm).
- If the test RMSE is close to the training RMSE, the model is stable, robust, and ready for practical use.

In R:
```r
set.seed(42)
train_idx <- sample(seq_len(nrow(body)), size = 0.70 * nrow(body))
train_data <- body[train_idx, ]
test_data  <- body[-train_idx, ]

# Fit model on training set
model_final <- lm(broad_jump_cm ~ grip_force + sit_ups + age_cat, data = train_data)

# Predict on test set
predictions <- predict(model_final, newdata = test_data)

# Compute Test RMSE
test_rmse <- sqrt(mean((test_data$broad_jump_cm - predictions)^2))
cat("Test RMSE:", round(test_rmse, 2), "cm\n")
```

---

## 8. Summary Checklist for Question 3

1. **Q3(a)**: Compute correlations with `broad_jump_cm`, fit simple regression for the top predictor (`grip_force`), check assumptions, and interpret slope.
2. **Q3(b)**: Add a second numerical predictor (`sit_ups`), check VIF for multicollinearity, and test whether $R^2$ increases.
3. **Q3(c)**: Add categorical factor `age_cat` as dummy variables and interpret the baseline intercept and age penalties.
4. **Q3(d)**: Compare models using Partial F-tests (`anova`), Adjusted $R^2$, AIC, and BIC to select the optimal model.
5. **Q3(e)**: Perform 70/30 train/test split, predict on the test set, calculate RMSE, and verify model generalizability.
