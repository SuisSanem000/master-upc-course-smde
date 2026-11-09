# Question 2: ANOVA (Analysis of Variance) — Master Study & Meeting Guide

This guide breaks down **Question 2** of the assignment into simple, easy-to-understand concepts. It explains how ANOVA works, connects each part to the professor's lectures, and reviews the current status in the team repository.

---

## 1. The Big Picture: What is Question 2 Really About?

In Question 1, we compared **two groups** (males vs. females) using a t-test. 
In Question 2, we have **four age groups** (`<30`, `30-39`, `40-49`, `50+`) and **four performance classes** (`A`, `B`, `C`, `D`).

- **Why can't we just run lots of t-tests?**
  If you have 4 groups, there are 6 possible pairs to compare. If you run 6 separate t-tests, your chance of getting a false positive (saying there is a difference when there isn't) increases from 5% to almost 30%.
- **What ANOVA does**:
  ANOVA (Analysis of Variance) tests all groups at the same time with a single test. It asks: *"Is the variation between the groups significantly larger than the random variation within the groups?"*
  - If the answer is **no**, all group averages are roughly equal.
  - If the answer is **yes**, at least two group averages are significantly different.
- **What Post-Hoc tests do**:
  When ANOVA tells you that groups differ, post-hoc tests check all pairs to tell you *which specific groups* differ, while keeping false positives under control.

---

## 2. Connections to Course Materials

| Question 2 Part | Relevant Course Material | What the Professor Taught |
| :--- | :--- | :--- |
| **Q2.a** | **Session 7 & Session 8** (`SMDE_Introduction_to_ANOVA_NAD.pdf`, `Anova_Lab_Fall2026.R`) | How to group continuous data by factors using `tapply()` or `aggregate()`, and visualize distributions with grouped boxplots. |
| **Q2.b** | **Session 8 Lab** (`Anova_Lab_Fall2026.R`) | How to fit one-way ANOVA with `aov(y ~ factor)`, check residual assumptions (normality, Levene's test for equal variances, Durbin-Watson for independence), and run 3 post-hoc tests: `TukeyHSD()`, Bonferroni `pairwise.t.test()`, and Fisher's LSD (`agricolae::LSD.test`). |
| **Q2.c** | **Session 8 Lab** (`Anova_Lab_Fall2026.R`, lines 135–158) | Two-way ANOVA with interaction: `aov(y ~ factor1 * factor2)`. How to read interaction significance and draw interaction plots using `interaction.plot()`. |

---

## 3. Subquestion Breakdown: Tasks & Methodologies

### Part a: Exploring Distributions by Groups (2.0 pts)
- **What is asked**: Check the distribution of 4 measurements (`body_fat_pct`, `diastolic`, `sit_ups`, `broad_jump_cm`) for each age group and for each performance class.
- **What we need to do**:
  - Calculate summary tables (Mean, Standard Deviation, Median, IQR) for each response variable split by `age_cat` and split by `class`.
  - Draw multi-panel boxplots or density curves showing the changes across groups.
- **Expected findings**:
  - Across **age groups**: Body fat and blood pressure increase with age, while sit-ups and jump distance decrease.
  - Across **performance classes** ($A \rightarrow D$): Body fat and blood pressure increase from best to worst, while muscular endurance (sit-ups) and explosive power (broad jump) decrease dramatically.
- **Teammate Status**: `R/Q2.R` has only `# TODO` comments. Nothing has been written yet.

---

### Part b: One-Way ANOVA & Three Post-Hoc Tests (6.0 pts)
- **What is asked**:
  1. Test whether each of the 4 variables is affected by `age_cat` and by `class`.
  2. Test the assumptions of ANOVA.
  3. Apply **three different post-hoc tests** and compare their findings.
- **Step 1: Fit the ANOVA Models**:
  - Run `aov(y ~ age_cat)` and `aov(y ~ class)` for each of the 4 response variables.
- **Step 2: Check ANOVA Assumptions**:
  - *Normality of residuals*: Q-Q plot and Shapiro-Wilk test on model residuals (`shapiro.test(residuals(model))`).
  - *Equal variances (homoscedasticity)*: Levene's test (`car::leveneTest(y ~ factor)`) and Breusch-Pagan test (`lmtest::bptest(model)`).
  - *Independence*: Durbin-Watson test (`lmtest::dwtest(model)`).
- **Step 3: Three Required Post-Hoc Tests**:
  The professor explicitly mandates three post-hoc tests and comparing them:
  1. **Tukey’s HSD (`TukeyHSD(model)`)**: Balanced method; controls the overall family error rate across all pairwise comparisons.
  2. **Bonferroni Correction (`pairwise.t.test(y, factor, p.adj = "bonf")`)**: Very strict and conservative; strongly protects against false positives, but has lower statistical power.
  3. **Fisher’s LSD (`agricolae::LSD.test(model, "factor")`)**: Liberal method without multiple testing penalty; highest statistical power to detect small differences, but higher risk of false positives.
- **Teammate Status**: `R/Q2.R` has empty `# TODO` placeholders. 0% complete.

---

### Part c: Two-Way ANOVA with Interaction (2.0 pts)
- **What is asked**: Analyze the effect of age and gender *together* on sit-ups and broad jump distance. Test whether the interaction between age and gender is significant.
- **What this means in simple terms**:
  - Main effect of Age: Do older people jump less or do fewer sit-ups?
  - Main effect of Gender: Do men and women have different jump distances and sit-up counts?
  - **Interaction effect (Age $\times$ Gender)**: Does the physical decline with age happen faster in one gender than the other? (For example, do men lose jumping power faster as they age than women do?)
- **How to test this**:
  - Model: `aov(sit_ups ~ age_cat * gender, data = body)` and `aov(broad_jump_cm ~ age_cat * gender, data = body)`.
  - Check the $p$-value of the interaction row `age_cat:gender`.
  - Draw an interaction plot: `interaction.plot(body$age_cat, body$gender, body$broad_jump_cm, fun = mean)`.
  - If the lines for men and women are parallel, there is no interaction. If the lines converge or have different slopes, the interaction is significant.
- **Teammate Status**: `R/Q2.R` has empty `# TODO` placeholders. 0% complete.

---

## 4. Key Talking Points for Question 2

If your teammates ask about Question 2 during the 8:00 PM meeting, here is what you can say:

1. **Assumptions and Post-Hoc Tests**:
   > *"For Question 2(b), remember that the prompt specifically requires three different post-hoc tests. In the course lab, Prof. Nihan used Tukey's HSD, Bonferroni-adjusted pairwise t-tests, and Fisher's LSD from the `agricolae` library. We should run all three and compare how their significance cutoffs differ."*

2. **Two-Way Interaction**:
   > *"In Question 2(c), the interaction between age and gender on broad jump and sit-ups is key. Drawing the interaction plot will make it very easy to show whether age-related performance decline happens at the same rate for men and women."*

