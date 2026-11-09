# Question 1 — Statistical Methods & Theory Guide

This document covers **only the statistical methods, tests, formulas, and decision rules needed for Question 1**. You can read this guide independently to prepare for discussions on data cleaning, blood pressure comparisons, confidence intervals, chi-square tests, and t-tests.

---

## 1. Exploratory Data Analysis & Checking Distributions

### 1.1 Measures of Center and Spread
For a numerical variable with values $x_1, x_2, \dots, x_n$:
- **Sample Mean ($\bar{x}$)**: The arithmetic average:
  $$\bar{x} = \frac{1}{n}\sum_{i=1}^n x_i$$
- **Sample Standard Deviation ($s$)**: Measures the average distance of points from the mean:
  $$s = \sqrt{\frac{1}{n-1}\sum_{i=1}^n (x_i - \bar{x})^2}$$
- **Sample Median ($\tilde{x}$)**: The middle value when data is sorted in order.
- **Interquartile Range ($IQR$)**: The spread of the middle 50% of the data:
  $$IQR = Q_3 - Q_1$$
  where $Q_1$ is the 25th percentile and $Q_3$ is the 75th percentile.
- **Why Median & IQR Matter**: When data is skewed or contains outliers, the median and IQR describe the true distribution much better than the mean and standard deviation because extreme values do not distort them.

### 1.2 Outlier Detection Rules
- **Tukey's $1.5 \times IQR$ Rule**: Points beyond $[Q_1 - 1.5 \times IQR, \; Q_3 + 1.5 \times IQR]$ are marked as outliers in boxplots.
- **Medical & Physical Rules for Question 1**:
  In a large dataset ($n > 13,000$), many healthy or athletic individuals naturally fall outside the boxplot whiskers. We do **not** delete data just because it is outside $1.5 \times IQR$. Instead, we only remove records that are **physically or medically impossible**:
  1. Blood pressure below living limits: systolic $< 70$ or diastolic $< 40$ mmHg.
  2. Inverted blood pressure: systolic $\le$ diastolic.
  3. Body fat below essential living limits: $< 2\%$ for men, $< 10\%$ for women, or $> 60\%$.
  4. Test scores of 0 on grip strength or broad jump (meaning the test was skipped).
  5. Obvious typing errors: flexibility $> 50$ cm (e.g. 185 cm and 213 cm).

### 1.3 Checking Normality & The Central Limit Theorem
- **Normal Q-Q Plot**: Plots your sample points against a theoretical normal distribution. If the points follow the straight diagonal red line, the variable is approximately normal.
- **Shapiro-Wilk Test (`shapiro.test`)**:
  - $H_0$: The variable follows a normal distribution.
  - $H_1$: The variable does not follow a normal distribution.
- **Important Note for Large Samples**:
  With large sample sizes ($n \approx 13,000$), hypothesis tests have so much power that they reject normality ($p < 10^{-16}$) even for tiny, harmless deviations. However, under the **Central Limit Theorem ($n \ge 30$)**, the sample mean is approximately normally distributed regardless. Therefore, we can safely use t-tests and confidence intervals.

---

## 2. Confidence Intervals for Population Means

When the population standard deviation $\sigma$ is unknown, the 95% confidence interval for the mean $\mu$ is:
$$CI_{95\%} = \bar{x} \pm t_{0.025, \; n-1} \frac{s}{\sqrt{n}}$$
- In R: `t.test(x)$conf.int`.
- **What it means**: If we repeated this study 100 times under the same conditions, 95 of the calculated intervals would contain the true population mean $\mu$.
- **Comparing Two Groups**: If the 95% confidence intervals for two groups (such as men and women) do not overlap, their population means are significantly different at the 5% significance level.

---

## 3. Comparing Two Groups: Two-Sample Tests

Whenever comparing two independent groups (such as males vs. females), follow this 2-step procedure:

### Step 1: Test for Equal Variances (F-Test)
- Null Hypothesis $H_0: \sigma_1^2 = \sigma_2^2$ (variances are equal).
- Alternative Hypothesis $H_1: \sigma_1^2 \ne \sigma_2^2$ (variances are unequal).
- In R: `var.test(x ~ gender, data = body)`.
- **Decision Rule**:
  - If $p > 0.05$: We fail to reject $H_0$ $\rightarrow$ Assume equal variances $\rightarrow$ Use **Student's t-test**.
  - If $p \le 0.05$: We reject $H_0$ $\rightarrow$ Variances are unequal $\rightarrow$ Use **Welch's t-test**.

### Step 2: Run the Appropriate Two-Sample t-Test
- **Equal Variances (Student’s Pooled t-Test)**:
  $$t = \frac{\bar{x}_1 - \bar{x}_2}{s_p \sqrt{\frac{1}{n_1} + \frac{1}{n_2}}}$$
  In R: `t.test(x ~ gender, var.equal = TRUE)`.
- **Unequal Variances (Welch’s t-Test)**:
  Adjusts the degrees of freedom using the Welch-Satterthwaite formula so unequal spreads do not distort the result:
  $$t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}$$
  In R: `t.test(x ~ gender, var.equal = FALSE)` (this is R's default).
- **Decision Rule**: If $p \le 0.05$, reject $H_0$ and conclude that the two group means are significantly different.

---

## 4. Testing Categorical Relationships: Pearson's Chi-Square Test

Used to test whether two categorical variables (such as age group and performance class) are related:

- **Null Hypothesis ($H_0$)**: The two variables are independent (no relationship).
- **Alternative Hypothesis ($H_1$)**: The two variables are dependent (there is a relationship).
- **Expected Frequency Formula**:
  $$E_{ij} = \frac{\text{Row Total } R_i \times \text{Column Total } C_j}{\text{Total Sample } N}$$
- **Chi-Square Statistic**:
  $$\chi^2 = \sum \frac{(O_{ij} - E_{ij})^2}{E_{ij}} \sim \chi^2_{(r-1)(c-1)}$$
  In R: `chisq.test(table)`.
- **Assumptions (Cochran's Rules)**:
  1. All observations are independent.
  2. No cell can have an expected count $E_{ij} < 1$.
  3. At least 80% of cells must have an expected count $E_{ij} \ge 5$.
  - Checked in R with `chisq.test(table)$expected`.
- **Decision Rule**: If $p \le 0.05$, reject $H_0$ and conclude that the two categories are statistically associated.
