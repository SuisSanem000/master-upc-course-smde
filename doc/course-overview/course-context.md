# Statistical Modelling & Design of Experiments (SMDE) — Course Context & Methods

This document explains the statistical theory, formulas, hypothesis tests, assumption checks, and decision rules needed to solve **Homework Assignment 1 (Questions 1, 2, and 3)**. Other course topics (such as discrete simulation, GPSS, random number generators, general exam theory, and Principal Component Analysis) are left out so this document focuses only on what is needed for this homework.

---

## 1. Exploratory Data Analysis & Checking Distributions

### 1.1 Measures of Center and Spread
For a sample of numbers $X = \{x_1, x_2, \dots, x_n\}$:
- **Sample Mean**:
  $$\bar{x} = \frac{1}{n} \sum_{i=1}^n x_i$$
- **Sample Variance and Standard Deviation**:
  $$s^2 = \frac{1}{n-1}\sum_{i=1}^n (x_i - \bar{x})^2, \quad s = \sqrt{s^2}$$
- **Sample Median ($\tilde{x}$)** and **Interquartile Range ($IQR$)**:
  $$IQR = Q_3 - Q_1$$
  Here, $Q_1$ is the 25th percentile and $Q_3$ is the 75th percentile. When data is skewed or has heavy tails, the median and IQR describe the center and spread much better than the mean and standard deviation because extreme values do not distort them.

### 1.2 Outlier Rules: Statistical vs. Real-World Rules
- **Tukey’s Fences**: Points outside the range $[Q_1 - 1.5 \times IQR, \; Q_3 + 1.5 \times IQR]$ are marked as mild outliers. Points outside $[Q_1 - 3 \times IQR, \; Q_3 + 3 \times IQR]$ are marked as extreme outliers.
- **Rule for Homework 1**: In large health and fitness datasets ($n > 10,000$), unusual values often represent real people (for example, very fit athletes, high blood pressure patients, or natural body shapes). We must **not** delete data points simply because they fall outside the boxplot whiskers. We only remove values that are **physically or medically impossible** (such as zero blood pressure, diastolic pressure higher than systolic pressure, body fat below essential human levels of $2\%$, or missed fitness tests recorded as 0).

### 1.3 Checking for Normal Distribution
- **Normal Q-Q Plot**: Compares the sample values to a theoretical normal distribution. If the points fall along the straight diagonal line, the data is approximately normal. Curves indicate skewness, and S-shapes indicate heavy or light tails.
- **Shapiro-Wilk Test**:
  - $H_0$: The data comes from a normal distribution.
  - $H_1$: The data does not come from a normal distribution.
  - Test statistic:
    $$W = \frac{\left(\sum_{i=1}^n a_i x_{(i)}\right)^2}{\sum_{i=1}^n (x_i - \bar{x})^2}$$
  - *Important Note for Large Samples*: The `shapiro.test()` function in R only accepts between 3 and 5,000 observations. More importantly, with large sample sizes ($n \approx 13,000$), hypothesis tests have so much statistical power that they reject $H_0$ ($p < 0.001$) even for tiny differences that do not matter in practice. Under the Central Limit Theorem ($n \ge 30$), sample means are approximately normal regardless. Therefore, visual plots (histograms and Q-Q plots) are more helpful than $p$-values alone.

---

## 2. Statistical Inference: Confidence Intervals & Comparing Means

### 2.1 Confidence Interval for a Population Mean (One Sample)
When data is approximately normal (or when sample size $n$ is large enough for the Central Limit Theorem) and the population variance $\sigma^2$ is unknown:
$$\bar{x} \pm t_{\alpha/2, \; n-1} \frac{s}{\sqrt{n}}$$
- In R: `t.test(x)$conf.int` calculates the 95% confidence interval $[\bar{x} - t_{0.025} \cdot SE, \; \bar{x} + t_{0.025} \cdot SE]$.
- *Meaning*: If we repeated the study many times under identical conditions, 95% of the calculated intervals would contain the true population mean $\mu$.

### 2.2 Testing Equal Variances: The Two-Sample F-Test
Before comparing the means of two independent groups ($\mu_1$ and $\mu_2$), we test whether their variances are equal:
- $H_0: \sigma_1^2 = \sigma_2^2$ (equal variances, or homoscedasticity)
- $H_1: \sigma_1^2 \ne \sigma_2^2$ (unequal variances, or heteroscedasticity)
- Test statistic:
  $$F = \frac{s_1^2}{s_2^2} \sim F(n_1 - 1, \; n_2 - 1)$$
- In R: `var.test(x, y)` gives the F-statistic and $p$-value. If $p < 0.05$, we cannot assume equal variances.

### 2.3 Two-Sample t-Tests for Independent Groups
- **Equal Variances (Student’s t-Test)**:
  Used when $s_1^2 = s_2^2$:
  $$t = \frac{\bar{x}_1 - \bar{x}_2}{s_p \sqrt{\frac{1}{n_1} + \frac{1}{n_2}}} \sim t(n_1 + n_2 - 2)$$
  where the pooled variance is:
  $$s_p^2 = \frac{(n_1 - 1)s_1^2 + (n_2 - 1)s_2^2}{n_1 + n_2 - 2}$$
  In R: `t.test(x, y, var.equal = TRUE)`.
- **Unequal Variances (Welch’s t-Test)**:
  Used when variances are not equal ($s_1^2 \ne s_2^2$):
  $$t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}} \sim t(\nu)$$
  where degrees of freedom $\nu$ are calculated using the Welch-Satterthwaite formula:
  $$\nu = \frac{\left(\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}\right)^2}{\frac{(s_1^2 / n_1)^2}{n_1 - 1} + \frac{(s_2^2 / n_2)^2}{n_2 - 1}}$$
  In R: `t.test(x, y, var.equal = FALSE)`.

---

## 3. Relationships Between Categories: Contingency Tables & Chi-Square Tests

### 3.1 Two-Way Contingency Tables
When analyzing two categorical variables $A$ (with $r$ groups) and $B$ (with $c$ groups), we cross-tabulate their counts into a table:
- Observed count in row $i$ and column $j$: $O_{ij}$.
- Row totals: $R_i = \sum_{j=1}^c O_{ij}$. Column totals: $C_j = \sum_{i=1}^r O_{ij}$. Total observations: $N$.
- Proportions: Row percentages ($O_{ij} / R_i$) and column percentages ($O_{ij} / C_j$).

### 3.2 Pearson’s Chi-Square Test of Independence
- $H_0$: Variables $A$ and $B$ are independent (there is no relationship between them).
- $H_1$: Variables $A$ and $B$ are dependent (there is a relationship between them).
- Expected counts under $H_0$:
  $$E_{ij} = \frac{R_i \times C_j}{N}$$
- Test statistic:
  $$\chi^2 = \sum_{i=1}^r \sum_{j=1}^c \frac{(O_{ij} - E_{ij})^2}{E_{ij}} \sim \chi^2_{(r-1)(c-1)}$$
- **Assumptions (Cochran’s Rules)**:
  1. All observations must be independent.
  2. No cell can have an expected count $E_{ij} < 1$.
  3. At least 80% of the cells must have an expected count $E_{ij} \ge 5$.
  - In R: `chisq.test(table)` gives the test result, and `chisq.test(table)$expected` checks the expected counts.

---

## 4. Analysis of Variance (ANOVA)

### 4.1 One-Way ANOVA
One-Way ANOVA tests whether the means of a continuous variable are equal across 3 or more groups:
$$y_{ij} = \mu + \alpha_i + \varepsilon_{ij}$$
where $\mu$ is the overall mean, $\alpha_i$ is the effect of group $i$, and $\varepsilon_{ij}$ is the random error ($\varepsilon_{ij} \sim \mathcal{N}(0, \sigma^2)$).

#### Hypotheses:
- $H_0: \mu_1 = \mu_2 = \dots = \mu_k$ (all group means are equal).
- $H_1$: At least two group means are different.

#### Partitioning the Sum of Squares:
Total variation is split into variation between groups and variation within groups:
$$SS_{Total} = SS_{Between} + SS_{Within} \quad (SS_T = SS_{Group} + SS_E)$$
Degrees of freedom:
$$(N - 1) = (k - 1) + (N - k)$$
Mean Squares:
$$MS_{Group} = \frac{SS_{Group}}{k - 1}, \quad MS_E = \frac{SS_E}{N - k}$$
F-Statistic:
$$F = \frac{MS_{Group}}{MS_E} \sim F(k - 1, \; N - k)$$
If $p < 0.05$, we reject $H_0$ and conclude that at least one group mean is different.

### 4.2 Checking ANOVA Assumptions
ANOVA results are only reliable if three assumptions are met:
1. **Normality of Residuals**:
   - The errors $\varepsilon$ must follow a normal distribution.
   - Check using a residual Q-Q plot (`qqnorm(residuals(model))`), histogram, and the Shapiro-Wilk test (`shapiro.test()`).
2. **Equal Variances (Homoscedasticity)**:
   - All groups must have approximately equal variances.
   - Check with **Levene's Test** (`car::leveneTest(y ~ group, data = df)`) or the **Breusch-Pagan Test** (`lmtest::bptest(model)`).
3. **Independence of Observations**:
   - Observations must not influence each other.
   - Check with the **Durbin-Watson Test** (`lmtest::dwtest(model, alternative = "two.sided")`). A value near 2 indicates independent errors.

### 4.3 Post-Hoc Tests (Three Required Methods)
When ANOVA rejects $H_0$, it tells us that a difference exists, but not *which* groups differ. If we run many separate t-tests, the chance of making a false discovery (Type I error) increases quickly. Post-hoc tests adjust for this problem.
The homework requires using and comparing three different post-hoc methods:

| Method | How it Works | Error Control | Strengths and Weaknesses |
| :--- | :--- | :--- | :--- |
| **1. Tukey's HSD** *(Honestly Significant Difference)* | Uses the Studentized Range distribution ($q$) to set a single threshold for all group pairs.<br>In R: `TukeyHSD(model)` | Controls the family error rate across all comparisons | **Balanced**: Offers a good compromise between preventing false positives and finding real differences. |
| **2. Bonferroni Correction** | Divides the target error rate $\alpha$ by the number of comparisons $m = \frac{k(k-1)}{2}$ (or multiplies $p$-values by $m$).<br>In R: `pairwise.t.test(y, group, p.adj = "bonf")` | Very strict control against false positives | **Very Conservative**: Strongly reduces false positives, but can miss small real differences (higher Type II error). |
| **3. Fisher's LSD** *(Least Significant Difference)* | Runs standard t-tests using the shared error variance $MS_E$ from ANOVA without adjusting $p$-values.<br>In R: `agricolae::LSD.test(model, "group")` or `pairwise.t.test(y, group, p.adj = "none")` | Does not adjust for multiple comparisons | **Liberal**: High statistical power to detect small differences, but higher risk of false positives. |

### 4.4 Two-Way ANOVA with Interaction
Two-Way ANOVA tests the effect of two categorical factors ($A$ and $B$) on a continuous response:
$$y_{ijk} = \mu + \alpha_i + \beta_j + (\alpha\beta)_{ij} + \varepsilon_{ijk}$$
- **Main Effects**: Tests factor $A$ alone and factor $B$ alone.
- **Interaction Effect ($A \times B$)**: Tests whether the effect of factor $A$ changes depending on the level of factor $B$.
- **Interpretation Rule**: If the interaction term is significant ($p < 0.05$), we cannot interpret the main effects in isolation. We must describe how the two factors work together.
- **Interaction Plot**: In R, `interaction.plot(factor1, factor2, response, fun = mean)`. If the lines are parallel, there is no interaction. If the lines cross or have different slopes, a meaningful interaction is present.

---

## 5. Linear Regression Modeling & Validation

### 5.1 Simple Linear Regression (SLR)
Simple linear regression models the relationship between a continuous outcome $Y$ and one numerical predictor $X$:
$$Y_i = \beta_0 + \beta_1 X_i + \varepsilon_i, \quad \varepsilon_i \sim \mathcal{N}(0, \sigma^2)$$
- **Least Squares Estimates**:
  $$\hat{\beta}_1 = \frac{\sum (X_i - \bar{X})(Y_i - \bar{Y})}{\sum (X_i - \bar{X})^2} = \frac{\text{Cov}(X, Y)}{\text{Var}(X)}, \quad \hat{\beta}_0 = \bar{Y} - \hat{\beta}_1 \bar{X}$$
- **Testing the Slope**:
  To test $H_0: \beta_1 = 0$ (no linear relationship):
  $$t = \frac{\hat{\beta}_1}{SE(\hat{\beta}_1)} \sim t(n - 2)$$
- **Goodness-of-Fit ($R^2$)**:
  $$R^2 = 1 - \frac{SS_{Res}}{SS_{Tot}} = \frac{SS_{Reg}}{SS_{Tot}}$$
  $R^2$ represents the proportion of total variation in $Y$ explained by predictor $X$.

### 5.2 Multiple Linear Regression (MLR)
Extends regression to several numerical predictors $X_1, X_2, \dots, X_p$:
$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \dots + \beta_p X_p + \varepsilon$$
- **Adjusted $R^2$ ($R_{adj}^2$)**: Adding any variable mechanically increases $R^2$. Adjusted $R^2$ penalizes adding variables that do not improve the model:
  $$R_{adj}^2 = 1 - \left[\frac{(1 - R^2)(n - 1)}{n - p - 1}\right]$$
- **Checking Multicollinearity (Variance Inflation Factor - VIF)**:
  Checks if independent variables are too strongly correlated with each other:
  $$VIF_j = \frac{1}{1 - R_j^2}$$
  - $VIF \approx 1$: No correlation between predictors (ideal).
  - $VIF > 5$: Moderate correlation; worth checking.
  - $VIF > 10$: High correlation; estimates become unstable and unreliable. In R: `car::vif(model)`.

### 5.3 Categorical Predictors (Dummy Variables)
When adding a factor with $k$ levels to regression:
- R creates $k - 1$ binary (dummy) variables: $D_2, \dots, D_k$. Level 1 serves as the baseline reference.
- Model equation:
  $$Y = \beta_0 + \beta_1 X + \gamma_2 D_2 + \dots + \gamma_k D_k + \varepsilon$$
- **How to Interpret the Coefficients**:
  - Baseline group ($D_2 = \dots = D_k = 0$): Expected value is $\beta_0 + \beta_1 X$.
  - Group $m$ ($D_m = 1$): Expected value is $(\beta_0 + \gamma_m) + \beta_1 X$.
  - The slope $\beta_1$ stays the same for all groups (parallel lines).
  - The coefficient $\gamma_m$ shows the vertical shift in the intercept compared to the baseline group.

### 5.4 Comparing Models: Partial F-Test, AIC, and BIC
To check whether adding new predictors significantly improves the model:
- **Partial F-Test**:
  $$F = \frac{(SS_{Res, \text{reduced}} - SS_{Res, \text{full}}) / q}{MS_{Res, \text{full}}} \sim F(q, \; n - p - q - 1)$$
  In R: `anova(model_small, model_large)`. A small $p$-value ($p < 0.05$) means the added variables significantly improve the model.
- **AIC and BIC (Information Criteria)**:
  $$AIC = n \ln\left(\frac{SS_{Res}}{n}\right) + 2(p + 1)$$
  $$BIC = n \ln\left(\frac{SS_{Res}}{n}\right) + \ln(n)(p + 1)$$
  Lower values mean a better model that balances good fit with simplicity.

### 5.5 Checking Regression Assumptions
Every regression model requires four checks on its residuals ($e_i = y_i - \hat{y}_i$):
1. **Linearity**: The Residuals vs. Fitted plot should show points scattered randomly around zero without any curved pattern.
2. **Normality**: The Q-Q plot and Shapiro-Wilk test check if residuals follow a normal distribution.
3. **Equal Variance (Homoscedasticity)**: The spread of residuals should stay constant across fitted values. Tested with the Breusch-Pagan test (`lmtest::bptest(model)`). If violated, transformations (such as logarithmic) can help.
4. **Independence**: Residuals should not correlate with each other. Tested with the Durbin-Watson test (`lmtest::dwtest(model)`).

### 5.6 Model Validation: Train/Test Split
To verify that the model works well on new, unseen data and is not overfitting:
1. **Split the Data**: Randomly divide the dataset into a Training set (70%, $n \approx 9,355$) and a Testing set (30%, $n \approx 4,010$) using a fixed seed (`set.seed(123)`).
2. **Fit the Model**: Train the regression model only on the training set.
3. **Predict**: Use the model to predict outcomes on the test set:
   $$\hat{y}_{test} = \text{predict}(model, newdata = test\_data)$$
4. **Calculate RMSE (Root Mean Square Error)**:
   $$RMSE_{test} = \sqrt{\frac{1}{n_{test}}\sum_{i=1}^{n_{test}} (y_{i, test} - \hat{y}_{i, test})^2}$$
   $$RMSE_{train} = \sqrt{\frac{1}{n_{train}}\sum_{i=1}^{n_{train}} (y_{i, train} - \hat{y}_{i, train})^2}$$
   If $RMSE_{train}$ and $RMSE_{test}$ are close to each other, the model generalizes well and does not overfit.
