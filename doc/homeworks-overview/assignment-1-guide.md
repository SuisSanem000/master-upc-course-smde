# SMDE Homework Assignment 1 — Complete Guide (Questions 1, 2, and 3)

This guide provides a clear and detailed breakdown of **Homework Assignment 1** for the *Statistical Modelling and Design of Experiments (SMDE)* master's course at FIB - UPC (Universitat Politècnica de Catalunya).

> [!IMPORTANT]
> **Important Note on Assignment Scope**:
> As stated in course announcements and professor instructions, **Homework Assignment 1 is a single report covering all three questions: Question 1, Question 2, and Question 3**. Question 4 (which covers Principal Component Analysis, or PCA) will be given and submitted separately in December 2026.

---

## 1. Course Details & Submission Requirements

| Parameter | Course Requirement |
| :--- | :--- |
| **Course** | Statistical Modelling and Design of Experiments (SMDE - MIRI, Fall 2026) |
| **Faculty / University** | Facultat d'Informàtica de Barcelona (FIB), Universitat Politècnica de Catalunya (UPC) |
| **Course Instructor** | Prof. Nihan Acar-Denizli, PhD |
| **Grading Weight** | 40% of the total course grade (the Statistics practical part). Questions 1, 2, and 3 each count for 25% of this practical grade (10 points each out of 40). |
| **Submission Deadline** | **Thursday, November 19, 2026, at 23:59 CET** |
| **Where to Submit** | Racó de la FIB (the online student portal) |
| **Page Limit** | **Maximum 12 pages**. The report must include a Title Page and a Table of Contents. |
| **Formatting Rules** | All tables and figures in the main body must be numbered, given a title/caption, and referenced directly in the text. |
| **Submission Package** | A single `.zip` file containing:<br>1. The written report in PDF format (`.pdf`)<br>2. The complete, runnable R script (`.R`)<br>3. The cleaned dataset in CSV format (`.csv`) |

---

## 2. Dataset Information: `bodyPerformance.csv`

The homework uses `bodyPerformance.csv`, which contains physical fitness and health measurements collected from adult participants.

### 2.1 Variable Codebook

| Column in CSV | Name in R | Type in R | Values / Units | Description |
| :--- | :--- | :--- | :--- | :--- |
| `age` | `age` | `numeric` | 21 to 64 years | Age of the participant |
| `gender` | `gender` | `factor` | `Female`, `Male` (`F`, `M`) | Gender of the participant |
| `height_cm` | `height_cm` | `numeric` | 125.0 to 193.8 cm | Standing height |
| `weight_kg` | `weight_kg` | `numeric` | 26.3 to 138.1 kg | Body weight |
| `body fat_%` | `body_fat_pct` | `numeric` | 3.0 to 78.4 % | Body fat percentage |
| `diastolic` | `diastolic` | `numeric` | 0.0 to 156.2 mmHg | Diastolic blood pressure (bottom number) |
| `systolic` | `systolic` | `numeric` | 0.0 to 201.0 mmHg | Systolic blood pressure (top number) |
| `gripForce` | `grip_force` | `numeric` | 0.0 to 70.5 kg | Grip strength test (isometric force) |
| `sit and bend forward_cm` | `sit_bend_cm` | `numeric` | -25.0 to 213.0 cm | Flexibility test (reach distance forward) |
| `sit-ups counts` | `sit_ups` | `numeric` | 0 to 80 counts | Number of sit-ups done in a set time |
| `broad jump_cm` | `broad_jump_cm` | `numeric` | 0.0 to 303.0 cm | Standing long jump distance (explosive power) |
| `class` | `class` | `ordered factor` | $D < C < B < A$ | Fitness performance class ($A$: Best, $D$: Worst) |

### 2.2 Data Quality & Medical Rules
- **Blood Pressure Rules**: Systolic pressure must always be higher than diastolic pressure ($\text{systolic} > \text{diastolic}$). Realistic living blood pressure must be at least $\text{systolic} \ge 70$ mmHg and $\text{diastolic} \ge 40$ mmHg. Values of 0 mean the test was not measured properly.
- **Essential Body Fat**: Healthy minimum body fat is about $2\text{--}5\%$ for men and $10\text{--}13\%$ for women. Values below these numbers or above $60\%$ point to recording mistakes or sensor errors.
- **Fitness Test Zeros**: A score of 0 for `grip_force` or `broad_jump_cm` means the person did not do the test. Values above 50 cm for `sit_bend_cm` (such as 185 cm or 213 cm) are clearly typing mistakes.

---

## 3. Question-by-Question Breakdown

### 3.1 Question 1: Visualisation, Chi-Square and t-Test (Weight: 25% / 10 Points)

Question 1 focuses on data cleaning, basic summary statistics, confidence intervals for blood pressure, age grouping, and testing independence between categories.

```
Question 1 Total: 10.0 Points
├── Part a: Import data and assign variable types (0.5 pt)
├── Part b: Summaries, distributions & outlier cleaning (2.0 pts)
├── Part c: Blood pressure distributions by gender (1.0 pt)
├── Part d: 95% Confidence intervals for systolic BP (1.0 pt)
├── Part e: Grouping age into 4 categories (0.5 pt)
├── Part f: Chi-square tests of independence (2.5 pts)
└── Part g: Gender differences in physical tests (2.5 pts)
```

#### Detailed Tasks:
- **Part a (0.5 pt) — Data Import and Variable Types**:
  - Read `bodyPerformance.csv` cleanly into R without altering text.
  - Rename column headers into clean, easy-to-use variable names.
  - Set correct types: `gender` as a factor (`Female`, `Male`), `class` as an ordered factor ($D < C < B < A$), and the remaining 10 variables as `numeric`.
  - Confirm the dataset dimensions ($13,393 \times 12$) and check that there are no missing values (`NA`).
- **Part b (2.0 pts) — Descriptive Statistics & Outlier Treatment**:
  - Calculate summary statistics for all 10 numerical variables: Mean, Standard Deviation, Median, IQR, Min, Max, and Quartiles.
  - Display initial distributions using boxplots and histograms.
  - Look for outliers using Tukey’s $1.5 \times IQR$ rule.
  - Remove impossible medical and physical records (28 rows) and save the cleaned dataset as `bodyPerformance_clean.csv` ($n = 13,365$).
  - Review the cleaned data with histograms and Normal Q-Q plots.
  - Run the Shapiro-Wilk test on a random sample ($n = 5,000$). Explain clearly that with such a large sample, the test rejects normality ($p < 10^{-16}$) even for distributions that look close to normal in charts.
- **Part c (1.0 pt) — Blood Pressure by Gender**:
  - Remove records with zero or impossible blood pressure values.
  - Plot histograms (using the same axis scale and bin widths) and boxplots for `systolic` and `diastolic` blood pressure for men and women.
  - Explain the physical findings (men have higher median blood pressure and greater spread than women).
- **Part d (1.0 pt) — 95% Confidence Intervals for Systolic BP**:
  - Calculate separate 95% confidence intervals for the mean systolic blood pressure of women ($\mu_{\text{Female}}$) and men ($\mu_{\text{Male}}$):
    $$CI_{95\%} = \bar{x} \pm t_{0.025, \; n-1} \frac{s}{\sqrt{n}}$$
  - Test if variances are equal using the F-test (`var.test()`).
  - Explain what the results mean: because the confidence intervals do not overlap, there is a clear and statistically significant difference in systolic blood pressure between men and women.
- **Part e (0.5 pt) — Age Grouping**:
  - Divide `age` into 4 groups using cut points at 30, 40, and 50:
    $$\text{age\_cat} = \begin{cases} <30 & [21, 30) \\ 30\text{--}39 & [30, 40) \\ 40\text{--}49 & [40, 50) \\ 50+ & [50, \infty) \end{cases}$$
  - Present the count and percentage of people in each age group.
- **Part f (2.5 pts) — Testing Independence (Chi-Square Tests)**:
  - Create two contingency tables: (1) `age_cat` $\times$ `class` ($4 \times 4$), and (2) `age_cat` $\times$ `gender` ($4 \times 2$).
  - Perform Pearson's Chi-Square Test of Independence on both tables.
  - Check Cochran's rules: verify that all expected cell counts are at least 5 using `chisq$expected`.
  - Show the relationships using stacked bar charts of proportions.
  - Conclude whether fitness performance drops as people age, and whether the proportion of men and women stays balanced across age groups.
- **Part g (2.5 pts) — Effect of Gender on Physical Tests**:
  - Analyze all four fitness tests: `grip_force`, `sit_bend_cm`, `sit_ups`, and `broad_jump_cm` across gender groups.
  - Check assumptions: normality with Q-Q plots, and equal variances with F-tests (`var.test()`).
  - Run the appropriate two-sample t-test (Welch’s t-test when variances differ).
  - Illustrate the differences with clear boxplots.
  - Explain the physical and sports-science reasons (for example, men showing higher strength and jump power, while women show better flexibility).

---

### 3.2 Question 2: Analysis of Variance — ANOVA (Weight: 25% / 10 Points)

Question 2 analyzes how age groups and fitness classes affect physical measurements, using one-way ANOVA, three post-hoc tests, and two-way ANOVA with interaction.

```
Question 2 Total: 10.0 Points
├── Part a: Distributions across age groups and performance classes (2.0 pts)
├── Part b: One-Way ANOVA across age and class + 3 Post-Hoc Tests (6.0 pts)
└── Part c: Two-Way ANOVA (Age × Gender) with Interaction (2.0 pts)
```

#### Detailed Tasks:
- **Part a (2.0 pts) — Exploring Distributions by Groups**:
  - Response variables: `body_fat_pct`, `diastolic`, `sit_ups`, and `broad_jump_cm`.
  - Factors: `age_cat` (4 groups) and `class` (4 grades).
  - Create summary tables showing the Mean, Standard Deviation, Median, and IQR for each group.
  - Make multi-panel plots (boxplots and density curves) showing how each measurement changes across age groups and fitness classes.
- **Part b (6.0 pts) — One-Way ANOVA, Assumptions, and Multiple Comparisons**:
  - **Fit ANOVA Models**: Fit one-way ANOVA models for each response variable against `age_cat` and against `class` (for example, `aov(body_fat_pct ~ age_cat)`).
  - **Check Assumptions**:
    1. *Normality of residuals*: Shapiro-Wilk test on residuals (`shapiro.test(residuals(model))`) and normal Q-Q plots.
    2. *Equal variances*: Levene's test (`car::leveneTest()`) and Breusch-Pagan test (`lmtest::bptest()`).
    3. *Independence*: Durbin-Watson test (`lmtest::dwtest()`).
  - **Three Required Post-Hoc Tests**:
    1. *Tukey’s HSD*: `TukeyHSD(model)` (controls the family error rate across all pairs).
    2. *Bonferroni Correction*: `pairwise.t.test(y, factor, p.adj = "bonf")` (very strict control against false positives).
    3. *Fisher's LSD*: `agricolae::LSD.test(model, "factor")` or unadjusted pairwise t-tests (highest power to find differences).
  - **Compare Findings**: Compare the results of the three methods, discuss why some find more significant pairs than others, and write clear conclusions about which groups differ.
- **Part c (2.0 pts) — Two-Way ANOVA with Interaction (Age $\times$ Gender)**:
  - Selected responses: `sit_ups` (endurance) and `broad_jump_cm` (explosive power).
  - Model formula: `aov(response ~ age_cat * gender, data = body)`.
  - Test if the main effects ($F_{\text{age}}$, $F_{\text{gender}}$) and the interaction effect ($F_{\text{age} \times \text{gender}}$) are significant.
  - Draw interaction plots (`interaction.plot(age_cat, gender, response, fun = mean)`).
  - Interpret the physical meaning: Does jump distance or sit-up endurance decline with age at the same rate for men and women, or does gender change the rate of decline?

---

### 3.3 Question 3: Linear Regression Analysis (Weight: 25% / 10 Points)

Question 3 builds a regression model to predict standing broad jump distance (`broad_jump_cm`), starting with a simple model and moving to multiple regression with categorical factors and validation.

```
Question 3 Total: 10.0 Points
├── Part a: Finding the best Simple Linear Regression (2.5 pts)
├── Part b: Multiple Linear Regression with two numerical variables (2.5 pts)
├── Part c: Adding categorical factors (Age Categories and Gender) (3.0 pts)
├── Part d: Model comparison and choosing the best model (1.0 pt)
└── Part e: Diagnostic checks and predictive validation (1.0 pt)
```

#### Detailed Tasks:
- **Part a (2.5 pts) — Best Simple Linear Regression (SLR)**:
  - Outcome variable: `broad_jump_cm`.
  - Candidate numerical predictors: `body_fat_pct`, `grip_force`, and `sit_ups`.
  - Filter the data, calculate correlation values (`cor()`), and make scatterplots.
  - Fit simple linear regression models for each candidate predictor (`lm(broad_jump_cm ~ X)`).
  - Select the best single predictor (the one with the highest $R^2$, lowest error, and significant $p$-value).
  - Check OLS assumptions: linearity (residuals vs fitted), normality (Q-Q plot), constant variance (`bptest`), and independence (`dwtest`). Apply transformations if necessary.
  - Interpret the intercept $\hat{\beta}_0$ and slope $\hat{\beta}_1$ using practical units.
- **Part b (2.5 pts) — Multiple Linear Regression (MLR) with Two Numerical Predictors**:
  - Fit an MLR model using the two best numerical predictors from Part a.
  - Check for multicollinearity using the Variance Inflation Factor (`car::vif(model)`).
  - Check all residual assumptions.
  - Compare this model with the simple model from Part a using a Partial F-test (`anova(slr, mlr)`), adjusted $R^2$, and AIC/BIC. Explain why two predictors work better than one.
- **Part c (3.0 pts) — Adding Categorical Factors**:
  - **Subpart (i)**: Add `age_cat` as a factor to the two-variable numerical model:
    $$\text{broad\_jump\_cm} = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \gamma_1 D_{30-39} + \gamma_2 D_{40-49} + \gamma_3 D_{50+} + \varepsilon$$
    Explain the baseline group ($<30$), what each dummy coefficient $\gamma$ means (the drop in jump distance for older age brackets), and review model $R^2$.
  - **Subpart (ii)**: Add `gender` as a factor to the two-variable numerical model:
    $$\text{broad\_jump\_cm} = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \delta_1 D_{\text{Male}} + \varepsilon$$
    Explain the baseline group (`Female`), the male coefficient $\delta_1$, and the increase in $R^2$.
- **Part d (1.0 pt) — Model Comparison and Final Choice**:
  - Make a summary comparison table of all candidate models:
    1. Two-variable numerical MLR (Part b)
    2. Numerical MLR + `age_cat` (Part c.i)
    3. Numerical MLR + `gender` (Part c.ii)
    4. Full model with numerical predictors + `age_cat` + `gender`
  - Compare them using: Partial F-tests (`anova`), Adjusted $R^2$, Residual Standard Error, AIC, and BIC.
  - Pick the best model that balances high accuracy with simplicity, and justify the choice clearly.
- **Part e (1.0 pt) — Model Diagnostics and Testing on New Data**:
  - Check the final model with 4 diagnostic plots:
    - Residuals vs Fitted (checks linearity and constant variance).
    - Normal Q-Q plot (checks normal errors).
    - Scale-Location plot (checks homoscedasticity).
    - Residuals vs Leverage (checks for overly influential points).
    - Formal checks: Breusch-Pagan (`bptest`) and Durbin-Watson (`dwtest`).
  - **Validation with Train/Test Split**:
    - Split the dataset into 70% training ($n \approx 9,355$) and 30% testing ($n \approx 4,010$) using `set.seed(123)`.
    - Train the selected model on the training set only.
    - Predict broad jump values on the test set.
    - Calculate and compare $RMSE_{\text{train}}$ and $RMSE_{\text{test}}$.
    - Confirm that the model predicts new data accurately and does not overfit.

---

## 4. How the Homework is Evaluated

Prof. Nihan Acar-Denizli will grade the submission based on four key standards:

1. **Statistical Correctness**:
   - Clearly state the null ($H_0$) and alternative ($H_1$) hypotheses for every test.
   - Report exact test statistics ($t$, $F$, $\chi^2$, $W$), degrees of freedom ($df$), and $p$-values.
   - Always check assumptions before interpreting final models.
2. **Completeness**:
   - Answer every subquestion completely (especially Question 1(g), the three post-hoc tests in 2(b), the interaction in 2(c), and model validation in 3(e)).
   - Discuss how large samples affect statistical tests (such as the Shapiro-Wilk test rejecting normality on large datasets).
3. **Report Presentation (Strict 12-Page Limit)**:
   - Stay within the 12-page limit (including the title page and table of contents).
   - Use clean, readable charts, properly styled tables, and clear captions.
   - Place key tables and figures directly in the text where they are discussed, rather than hiding everything in an appendix.
4. **Code Quality and Reproducibility**:
   - Provide clean, commented R scripts that run from start to finish without errors.
   - Make sure all numbers, tables, and figures in the report match the script output exactly.
