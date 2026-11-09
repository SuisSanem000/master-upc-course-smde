# Question 1: Visualisation, Chi-Square and t-Test — Master Study & Meeting Guide

This guide is designed to prepare you for the **8:00 PM team meeting**. It explains everything in simple, clear language without confusing statistical jargon, connects each subquestion to the professor's lectures, and summarizes exactly what your teammates have done in the code and what remains to be discussed.

---

## 1. The Big Picture: What is Question 1 Really About?

Imagine you are given a large health and fitness dataset (`bodyPerformance.csv`) with over 13,000 people. 
The professor wants you to answer some practical questions:
1. Is the data clean, or are there typing mistakes (like someone having 0 blood pressure or 200 cm of flexibility)?
2. How do basic physical measurements look across the population?
3. Do men and women have different blood pressure?
4. How sure are we about the average blood pressure of men and women?
5. Does fitness performance get worse as people get older?
6. Do men and women perform differently in physical tests like grip strength, jump distance, and sit-ups?

To answer these questions, you use basic statistical tools: **descriptive charts (boxplots/histograms)**, **confidence intervals**, **chi-square tests for categories**, and **two-sample t-tests**.

---

## 2. Connections to Course Materials

| Question 1 Part | Relevant Course Material | What the Professor Taught |
| :--- | :--- | :--- |
| **Q1.a & Q1.b** | **Session 1 & Session 2** (`SMDE_Introduction_to_R.pdf`, `SMDE_Prob_Dist_Random_variables.pdf`) | How to import data, check variable types (`factor`, `numeric`), draw boxplots, and check for normal distributions using Q-Q plots and the Shapiro-Wilk test. |
| **Q1.c & Q1.d** | **Session 8 Lab** (`Lab_t_test.R`, `exercises_ttest_Anova.pdf`) | How to calculate 95% confidence intervals for group means using `t.test()` and how to compare two groups with an F-test (`var.test()`). |
| **Q1.e & Q1.f** | **Session 4** (`SMDE-_Chi-squared_test.pdf`, `R_Lab_chisquare_test.R`) | How to group a continuous variable using `cut()`, create contingency tables (`table()`), and test if two categories are related using `chisq.test()`. |
| **Q1.g** | **Session 8 Lab** (`Lab_t_test.R`) | How to test whether two groups (males vs. females) have different test averages using two-sample t-tests (`t.test(y ~ gender)`). |

---

## 3. Subquestion Breakdown: What Teammates Did & What the Results Mean

### Part a: Importing Data & Assigning Types (0.5 pt)
- **What is asked**: Load `bodyPerformance.csv` and make sure every column has the correct data type.
- **What your teammates did (`R/Q1.R`, lines 50–107)**:
  - Loaded 13,393 rows and 12 columns.
  - Renamed the column headers to clean R names (e.g., `body fat_%` becomes `body_fat_pct`).
  - Set `gender` as a factor with levels `Female` and `Male`.
  - Set `class` as an ordered factor ($D < C < B < A$, from worst to best).
  - Set all other 10 variables as `numeric`.
  - Confirmed there are zero missing values (`NA`).
- **Meeting Status**: Completely finished and correct.

---

### Part b: Summary Statistics & Outliers (2.0 pts)
- **What is asked**: Summarize numerical variables, check distributions, and clean outliers if necessary.
- **What your teammates did (`R/Q1.R`, lines 109–209)**:
  - Calculated Mean, Median, Standard Deviation, and IQR for all 10 numerical columns (saved in `q1b_summary.csv`).
  - Drew boxplots (`q1b_boxplots.png`) and histograms (`q1b_histograms.png`).
  - Found many points outside the boxplot whiskers (using Tukey’s $1.5 \times IQR$ rule).
  - **Important Decision**: Instead of deleting every point outside the boxplot whiskers (which would delete thousands of healthy or athletic people), the team used **medical rules**:
    - Removed blood pressures below living limits (systolic $< 70$ or diastolic $< 40$).
    - Removed cases where diastolic was higher than systolic (impossible in real life).
    - Removed body fat $< 2\%$ for men or $< 10\%$ for women.
    - Removed test scores of 0 for grip force and jump distance (meaning the test was skipped).
    - Removed extreme typing errors (sit-and-bend flexibility of 185 cm and 213 cm).
  - Total removed: **only 28 rows (0.2%)**, leaving 13,365 rows in `bodyPerformance_clean.csv`.
- **What about Normality?**:
  - The team tested normality with the Shapiro-Wilk test (`q1b_shapiro.csv`) on a sample of 5,000 rows. The $p$-value was tiny ($p < 10^{-16}$), meaning the test rejects normality.
  - **Why this happens**: With such a large sample, the test detects even tiny, unimportant deviations from a perfect bell curve. But because $n$ is so large, the Central Limit Theorem applies, so we can still safely use t-tests and ANOVA.
- **Meeting Status**: Code is done, but the written explanations in the LaTeX report are currently empty placeholders.

---

### Part c: Blood Pressure by Gender (1.0 pt)
- **What is asked**: Remove zero blood pressure values, plot distributions of systolic and diastolic pressure for men and women, and explain what you see.
- **What your teammates did (`R/Q1.R`, lines 211–311)**:
  - Filtered out invalid readings.
  - Plotted comparative histograms (`q1c_histograms.png`) and side-by-side boxplots (`q1c_boxplots.png`).
  - Calculated mean, median, and standard deviation by gender (`q1c_summary.csv`).
- **What the numbers mean**:
  - **Systolic**: Males average **130.2 mmHg**; Females average **117.0 mmHg** (men are about 13 mmHg higher).
  - **Diastolic**: Males average **80.8 mmHg**; Females average **74.1 mmHg** (men are about 6.7 mmHg higher).
  - Both distributions look like smooth bell curves, but men are shifted to the right and show slightly higher variation.
- **Meeting Status**: Code and figures are done. The written medical interpretation in `q1.tex` needs to be completed.

---

### Part d: 95% Confidence Intervals for Systolic BP (1.0 pt)
- **What is asked**: Construct 95% confidence intervals for the mean systolic blood pressure of the two gender groups and interpret them.
- **What your teammates did in the code (`R/Q1.R`, lines 313–356)**:
  - They tested equal variances using an F-test (`var.test()`). The test gave $p < 0.05$, showing that male and female variances are not equal.
  - Then they ran a Welch t-test comparing males to females: `t.test(male$systolic, female$systolic)`.
  - This produced the confidence interval for the **difference between the two means**: $[12.78, 13.56]$ mmHg.
- **THE BIG TALKING POINT FOR TODAY'S MEETING**:
  - Xiang posted in WhatsApp that the question says *"Construct 95% confidence intervals"* (plural), which means we need the **separate confidence interval for women** and the **separate confidence interval for men**, not just the difference between them!
  - **The math**:
    - Female Mean: $117.0$ mmHg $\rightarrow 95\%$ CI: $[116.7, 117.3]$ mmHg.
    - Male Mean: $130.2$ mmHg $\rightarrow 95\%$ CI: $[129.9, 130.5]$ mmHg.
  - **Interpretation**: Notice that the female interval $[116.7, 117.3]$ and the male interval $[129.9, 130.5]$ **do not overlap at all**. This proves beyond any doubt that men have significantly higher resting systolic blood pressure than women in this population.
- **Meeting Status**: We need to update `Q1.R` to report both individual group intervals and the difference interval.

---

### Part e: Categorizing Age into 4 Groups (0.5 pt)
- **What is asked**: Cut age at 30, 40, and 50 into 4 categories and save it as a new variable `age_cat`.
- **What your teammates did (`R/Q1.R`, lines 358–386)**:
  - Used `cut()` with breaks `c(-Inf, 30, 40, 50, Inf)` and labels `<30`, `30-39`, `40-49`, `50+`.
  - Exported counts and percentages (`q1e_age_groups.csv`) and a bar chart (`q1e_age_groups.png`).
- **What the numbers show**:
  - `<30`: 4,374 people (32.7%) — the largest group.
  - `30-39`: 3,598 people (26.9%).
  - `40-49`: 2,903 people (21.7%).
  - `50+`: 2,490 people (18.6%).
  - The sample has plenty of people in every age category, making it good for group comparisons.
- **Meeting Status**: Code is completely done.

---

### Part f: Association Tests (Chi-Square) (2.5 pts)
- **What is asked**: Test whether age groups are related to performance class, and whether age groups are related to gender.
- **What your teammates did (`R/Q1.R`, lines 388–438)**:
  - Built two contingency tables: (1) Age vs. Class ($4 \times 4$), (2) Age vs. Gender ($4 \times 2$).
  - Ran `chisq.test()` on both tables (saved in `q1f_chisq.csv`).
  - Checked that all expected cell counts are greater than 5 (smallest was over 500, so assumptions are easily met).
  - Plotted stacked proportion bar charts (`q1f_proportions.png`).
- **What the results mean**:
  - **Age vs. Class**: $\chi^2 = 724.87, p < 10^{-16}$. There is a very strong relationship! Looking at the bar chart, younger people ($<30$) have a much higher percentage of Class A (excellent), while older people ($50+$) have a much higher percentage of Class D (poor). Physical fitness clearly declines with age.
  - **Age vs. Gender**: $\chi^2 = 8.16, p = 0.043$. A weak relationship, but males and females remain fairly evenly represented across all age brackets.
- **Meeting Status**: Code and charts are done.

---

### Part g: Physical Performance by Gender (2.5 pts)
- **What is asked**: Test whether physical performance test results are affected by gender. Check assumptions and visualize the relationship.
- **What your teammates did in `R/Q1.R`**:
  - **THEY DID NOTHING!** The script ends at line 442 after Section f.
- **What MUST be done**:
  - Take the 4 fitness tests: `grip_force`, `sit_bend_cm`, `sit_ups`, and `broad_jump_cm`.
  - Test for equal variances between men and women using `var.test()`.
  - Run two-sample t-tests (`t.test(variable ~ gender)`).
  - Draw comparative boxplots for all 4 tests.
  - Explain the physical results: men perform higher in grip strength and broad jump (explosive muscle power), while women perform significantly better in sit-and-bend (flexibility).
- **Meeting Status**: **This is the biggest open gap in Question 1.** Pointing this out in the meeting will show that you thoroughly reviewed the assignment!

---

## 4. Key Talking Points for Your 8:00 PM Meeting

When you join the meeting at 8:00 PM, here are the exact points you can share:

1. **Compliment the Data Cleaning**:
   > *"The way we cleaned the data in Q1.b makes a lot of sense. Instead of deleting all 1.5 IQR points, using medical thresholds (removing systolic < 70, diastolic < 40, and essential body fat limits) only dropped 28 rows (0.2%) while keeping real athletic variation."*

2. **Agree with Xiang on Question 1(d)**:
   > *"I saw Xiang's message in WhatsApp about Q1.d, and I completely agree. The prompt asks for 95% confidence intervals in plural. We should report the individual intervals for women [116.7, 117.3] and men [129.9, 130.5], and point out that because they do not overlap, the difference between men and women is very clear."*

3. **Highlight the Missing Question 1(g)**:
   > *"Looking through `Q1.R`, I noticed that subquestion 1(g) is completely missing from the script. That part is worth 2.5 points (25% of Question 1). We need to run two-sample t-tests on the 4 fitness tests (grip force, sit and bend, sit-ups, and broad jump) across gender, check variance equality with F-tests, and draw a 4-panel boxplot."*

4. **Volunteer / Discuss Question 3 (Linear Regression)**:
   > *"For our next division of work, since Question 1 is mostly coded and Question 2 is ANOVA, I can take on Question 3 (Linear Regression on broad jump distance) once we finalize Q1 tonight."*

