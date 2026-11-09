# Question 2 Statistical Methods: Analysis of Variance (ANOVA) & Post-Hoc Tests

This document explains the statistical theory and methodology needed to understand and solve **Question 2** of Homework 1 in simple, clear, Upper B2 English.

---

## 1. What is ANOVA and Why Do We Need It?

In Question 1, we compared the means of **two** groups (males vs. females) using a two-sample t-test.
In Question 2, we need to compare means across **four** groups:
- 4 age groups: `<30`, `30-39`, `40-49`, `50+`
- 4 fitness performance classes: `A`, `B`, `C`, `D`

### Why Not Run Many t-Tests?
If we have $k = 4$ groups, the number of pairwise comparisons is:
$$m = \frac{k(k - 1)}{2} = \frac{4 \times 3}{2} = 6 \text{ pairs}$$
If we perform 6 separate t-tests, each with a significance level of $\alpha = 0.05$, the probability of making at least one false positive (Type I error) increases dramatically:
$$\alpha_{\text{family-wise}} = 1 - (1 - \alpha)^m = 1 - (0.95)^6 \approx 0.265 \quad (26.5\%)$$
This dangerous accumulation of error is called **alpha inflation** or **family-wise error rate**.

### The Solution: One-Way ANOVA
ANOVA (Analysis of Variance) tests all groups simultaneously with a single overall test, maintaining the Type I error rate at exactly $\alpha = 0.05$.

---

## 2. The One-Way ANOVA Mathematical Model

The statistical model for an observation $y_{ij}$ (the $j$-th individual in group $i$) is:
$$y_{ij} = \mu + \alpha_i + \epsilon_{ij}$$
Where:
- $\mu$ is the overall population grand mean.
- $\alpha_i = \mu_i - \mu$ is the effect of group $i$.
- $\epsilon_{ij} \sim \mathcal{N}(0, \sigma^2)$ is the random error term, assumed independent and normally distributed with constant variance $\sigma^2$.

### Hypotheses:
- **Null Hypothesis ($H_0$)**: $\mu_1 = \mu_2 = \dots = \mu_k$ (all group means are equal; group effect $\alpha_i = 0$ for all $i$).
- **Alternative Hypothesis ($H_1$)**: At least two group means are significantly different ($\exists i \neq j \text{ such that } \mu_i \neq \mu_j$).

### Partitioning the Total Variation:
ANOVA breaks down the total variability in the data into two separate sources:
$$SS_{\text{Total}} = SS_{\text{Between}} + SS_{\text{Within}}$$
- **$SS_{\text{Between}}$ (Sum of Squares Between Groups)**: Measures differences between group averages and the grand mean (due to the factor effect).
- **$SS_{\text{Within}}$ (Sum of Squares Within Groups / Residual Error)**: Measures random variation of individuals around their own group mean.

### The F-Test Statistic:
$$F = \frac{MS_{\text{Between}}}{MS_{\text{Within}}} = \frac{SS_{\text{Between}} / (k - 1)}{SS_{\text{Within}} / (N - k)}$$
- If the group means are equal ($H_0$ is true), $F \approx 1$.
- If group means differ significantly, $MS_{\text{Between}}$ is much larger than $MS_{\text{Within}}$, so $F \gg 1$.
- We reject $H_0$ if $p < 0.05$.

In R:
```r
fit <- aov(body_fat_pct ~ age_cat, data = body)
summary(fit)
```

---

## 3. Assumptions of ANOVA & How to Test Them

Before accepting the ANOVA result, three mathematical assumptions must be checked on the residuals ($e_{ij} = y_{ij} - \bar{y}_i$):

### 1. Normality of Residuals
- **Requirement**: Residuals within each group should follow a normal distribution.
- **Diagnostics**:
  - Q-Q plot (`plot(fit, which = 2)`): Residuals should lie close to the diagonal line.
  - Shapiro-Wilk test (`shapiro.test(residuals(fit))`): $H_0$: residuals are normal.
- **Large Sample Robustness**: When sample size is very large ($N > 10,000$), ANOVA is extremely robust to non-normality due to the Central Limit Theorem.

### 2. Homoscedasticity (Equal Variances)
- **Requirement**: All groups must have the same population variance ($\sigma_1^2 = \sigma_2^2 = \dots = \sigma_k^2$).
- **Diagnostics**:
  - Residuals vs. Fitted plot (`plot(fit, which = 1)`): Spread should be even across groups.
  - **Levene's Test** (`car::leveneTest(y ~ factor)`): The gold standard because it does not depend strictly on normality.
  - **Bartlett's Test** (`bartlett.test(y ~ factor)`): Powerful, but sensitive to non-normality.
- **What if variances are unequal?**
  - If variances differ substantially, use **Welch's ANOVA** (`oneway.test(y ~ factor, var.equal = FALSE)`).

### 3. Independence of Observations
- **Requirement**: Observations must be randomly sampled and independent of each other.
- **Diagnostic**: **Durbin-Watson Test** (`lmtest::dwtest(fit)`) checks for autocorrelation in the residuals ($d \approx 2$ means no correlation).

---

## 4. Post-Hoc Multiple Comparison Tests

When ANOVA rejects $H_0$, it proves that group means are not all equal, but it does **not** identify which specific pairs differ. 
The assignment requires us to perform **three post-hoc tests**:

### Test 1: Tukey's Honestly Significant Difference (Tukey HSD)
- **Concept**: Specifically designed for all possible pairwise comparisons of group means.
- **How it works**: Uses the Studentized range distribution ($q$) to construct simultaneous confidence intervals that control the family-wise error rate at exactly $\alpha = 0.05$.
- **When to use**: The standard, most reliable test when sample sizes are balanced or roughly equal.
- In R:
  ```r
  TukeyHSD(fit)
  plot(TukeyHSD(fit))
  ```

### Test 2: Bonferroni Adjustment
- **Concept**: A simple, general correction method.
- **How it works**: Divides the significance level by the number of comparisons:
  $$\alpha^* = \frac{\alpha}{m}$$
  For 6 comparisons, each pair is tested at $\alpha^* = 0.05 / 6 = 0.0083$.
- **Characteristics**: Very conservative (safe against false positives, but slightly higher risk of missing small true differences).
- In R:
  ```r
  pairwise.t.test(body$body_fat_pct, body$age_cat, p.adjust.method = "bonferroni")
  ```

### Test 3: Fisher's LSD (Least Significant Difference) / Scheffé's Test
- **Fisher's LSD**:
  - Runs standard t-tests between all pairs without adjusting $\alpha$, **only if** the overall ANOVA F-test was significant.
  - Most powerful (detects small differences easily), but offers the weakest control against false positives.
  - In R: `agricolae::LSD.test(fit, "age_cat", p.adj = "none")`
- **Scheffé's Test**:
  - Extremely conservative test that controls the error rate for all possible linear contrasts, not just pairwise comparisons.
  - In R: `agricolae::scheffe.test(fit, "age_cat")`

---

## 5. Two-Way ANOVA with Interaction (Q2.c)

In Question 2(c), we evaluate **two categorical factors at the same time**:
- Factor A: `age_cat` (4 levels)
- Factor B: `class` (4 levels)
- Response variable: `sit_ups` or `broad_jump_cm`

### The Two-Way Model Formula:
$$y_{ijk} = \mu + \alpha_i + \beta_j + (\alpha\beta)_{ij} + \epsilon_{ijk}$$
Where:
- $\alpha_i$ is the main effect of Factor A.
- $\beta_j$ is the main effect of Factor B.
- $(\alpha\beta)_{ij}$ is the **interaction effect** between Factor A and Factor B.

### What is an Interaction Effect?
An interaction exists when the effect of one factor depends on the level of the other factor.
- *Example*: Does age reduce jump performance at the same rate for elite athletes (Class A) as it does for unfit individuals (Class D)?
  - If **no interaction** ($p > 0.05$): Age reduces jump distance by the exact same amount for all classes. The performance lines in a plot are **parallel**.
  - If **interaction exists** ($p < 0.05$): The lines in the plot **cross or have different slopes**, meaning aging affects one class differently than another.

### In R:
```r
# Fit two-way ANOVA with interaction (*)
fit_2way <- aov(broad_jump_cm ~ age_cat * class, data = body)
summary(fit_2way)

# Interaction Plot
interaction.plot(body$age_cat, body$class, body$broad_jump_cm,
                 xlab = "Age Group", ylab = "Broad Jump (cm)",
                 trace.label = "Class", col = 1:4, lty = 1, lwd = 2)
```

---

## 6. Summary Checklist for Question 2

1. **Q2(a)**: Group numerical responses by factor levels, compute summary tables (Mean, SD, Median, IQR), and draw multi-panel boxplots.
2. **Q2(b)**: Fit One-Way ANOVA (`aov`), check residual plots and Levene's test, and run the 3 post-hoc tests (Tukey HSD, Bonferroni, LSD/Scheffé).
3. **Q2(c)**: Fit Two-Way ANOVA with interaction (`*`), test if the interaction term is significant, and draw the interaction plot to visually confirm parallelism.

