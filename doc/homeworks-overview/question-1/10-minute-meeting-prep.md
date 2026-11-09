# Question 1: 10-Minute Pre-Meeting Summary

Read this document 10 minutes before the 8:00 PM team call. It gives you a clear, high-level summary of **Question 1 (10.0 points)**, what your teammates coded, the key results, and the exact points to raise during the discussion.

---

## 1. The Goal of Question 1 in 30 Seconds

Question 1 analyzes health and athletic performance data from 13,393 Korean adults.
The objectives are:
1. Clean the data using sensible medical rules.
2. Compare resting blood pressure between men and women.
3. Test if age is linked to fitness performance and gender.
4. Test if men and women perform differently on physical fitness tests.

---

## 2. Quick Subquestion Breakdown (Parts a to g)

### Part a: Importing & Variable Types (0.5 pt)
- **Task**: Load `bodyPerformance.csv` and set proper R data types.
- **Teammate Code**: Set `gender` as a factor (`Female`, `Male`), `class` as an ordered factor ($D < C < B < A$), and 10 numerical columns.
- **Result**: 0 missing values (`NA`). Everything is clean and finished.

### Part b: Summary Statistics & Outliers (2.0 pts)
- **Task**: Calculate statistics (Mean, Median, SD, IQR) and deal with outliers.
- **Key Decision**: Standard boxplots flag thousands of outliers. Instead of deleting real people, the team used **medical validity rules**:
  - Removed blood pressures below life limits (systolic $< 70$, diastolic $< 40$, or systolic $\le$ diastolic).
  - Removed body fat below essential limits ($< 2\%$ for men, $< 10\%$ for women).
  - Removed test scores of 0 (tests not taken) and impossible flexibility scores ($> 50$ cm).
- **Result**: Only **28 rows (0.2%)** were removed, leaving **13,365 clean rows** in `bodyPerformance_clean.csv`.
- **Normality Note**: Shapiro-Wilk test rejects perfect normality ($p < 10^{-16}$). Because $N = 13,365$, the **Central Limit Theorem** applies, so sample means are normally distributed and t-tests are completely valid.

### Part c: Blood Pressure by Gender (1.0 pt)
- **Task**: Plot distributions and compare systolic and diastolic pressure between men and women.
- **Key Numbers**:
  - **Systolic**: Males average **130.2 mmHg**; Females average **117.0 mmHg** (men are $\approx 13$ mmHg higher).
  - **Diastolic**: Males average **80.8 mmHg**; Females average **74.1 mmHg** (men are $\approx 6.7$ mmHg higher).
- **Visuals**: Both distributions are bell-shaped, but male curves are shifted to higher values.

### Part d: 95% Confidence Intervals for Systolic BP (1.0 pt)
- **Task**: Test variance equality and build 95% confidence intervals for mean systolic blood pressure.
- **Statistical Test**:
  - F-test (`var.test`): Variances are unequal ($p < 0.05$).
  - Therefore, we must use **Welch's t-test**.
- **Important Catch for the Meeting**:
  - Teammate code only calculated the CI for the *difference* between genders ($[12.78, 13.56]$ mmHg).
  - The prompt says *"confidence intervals"* (plural), meaning we need the **separate CIs for each gender**:
    - **Female 95% CI**: $[116.7, 117.3]$ mmHg
    - **Male 95% CI**: $[129.9, 130.5]$ mmHg
  - **Key Interpretation**: Because the two intervals **do not overlap at all**, male systolic pressure is significantly higher than female systolic pressure ($p < 10^{-16}$).

### Part e: Categorizing Age into 4 Groups (0.5 pt)
- **Task**: Cut age at 30, 40, and 50 into 4 groups: `<30`, `30-39`, `40-49`, `50+`.
- **Distribution**:
  - `<30`: 4,374 (32.7%)
  - `30-39`: 3,598 (26.9%)
  - `40-49`: 2,903 (21.7%)
  - `50+`: 2,490 (18.6%)
- **Status**: Finished and saved to `q1e_age_groups.csv` and a bar chart.

### Part f: Chi-Square Tests of Independence (2.5 pts)
- **Task**: Test whether age group is associated with performance class, and with gender.
- **Results**:
  - **Age vs. Class**: $\chi^2 = 724.87, \text{df} = 9, p < 10^{-16}$. **Strong relationship!** As age increases, the proportion of people in Class A (best) drops, while Class D (worst) increases.
  - **Age vs. Gender**: $\chi^2 = 25.13, \text{df} = 3, p = 1.45 \times 10^{-5}$. A slight statistical imbalance across age groups, but both genders remain well represented.
- **Assumption Check**: Cochran's rule requires all expected cell counts $\ge 5$. In our data, the smallest expected count is over 400, so the test is fully valid.

### Part g: Physical Performance Tests by Gender (2.5 pts) — **CRITICAL GAP**
- **Task**: Compare males and females across the 4 physical tests using two-sample t-tests after checking variance equality.
- **Status in Teammates' Code**: **Completely missing!** `Q1.R` stops at line 442 right after Part f.
- **Our Ready Numbers (13,365 rows)**:
  1. `grip_force`: Males $43.46$ kg vs. Females $25.83$ kg ($\mathbf{+17.63\text{ kg}}$ male advantage, $t = 172.17$, Welch test).
  2. `sit_bend_cm`: Females $18.85$ cm vs. Males $13.05$ cm ($\mathbf{+5.80\text{ cm}}$ female advantage, $t = -43.42$, Welch test). **Females significantly win on flexibility!**
  3. `sit_ups`: Males $44.94$ vs. Females $30.91$ ($\mathbf{+14.02\text{ counts}}$ male advantage, $t = 59.58$, Welch test).
  4. `broad_jump_cm`: Males $211.60$ cm vs. Females $153.54$ cm ($\mathbf{+58.06\text{ cm}}$ male advantage, $t = 116.05$, Student test, equal variance).

---

## 3. Your 3 Main Speaking Points for Tonight

1. **Acknowledge their work**:
   > *"I checked `Q1.R` in detail. The data cleaning in Part b makes complete sense, and the chi-square tests in Part f are very clearly presented."*
2. **Bring up Xiang's point on Q1(d)**:
   > *"Regarding Q1(d), I agree with Xiang's message in WhatsApp. We need to report the individual confidence intervals: $[116.7, 117.3]$ mmHg for women and $[129.9, 130.5]$ mmHg for men. The fact that they do not overlap proves the difference directly."*
3. **Offer the missing Q1(g) solution**:
   > *"In `Q1.R`, subquestion 1(g) is currently missing. It is worth 2.5 points. I already calculated the Welch t-tests for all four physical variables: men win on grip strength, sit-ups, and jumping, but women are significantly better in flexibility (sit-and-bend). I have the code and summary table ready to insert."*
4. **Volunteer for Question 3**:
   > *"If someone wants to take Question 2 (ANOVA), I can take on Question 3 (Linear Regression on broad jump distance) once we finalize Q1 tonight."*

---

## 4. Quick Numbers Cheat Table

| Variable | Females | Males | Difference | Test Used | Significant? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Systolic BP (Q1.c/d)** | $117.0$ mmHg $[116.7, 117.3]$ | $130.2$ mmHg $[129.9, 130.5]$ | $+13.2$ mmHg (M > F) | Welch t-test | Yes ($p < 10^{-16}$) |
| **Diastolic BP (Q1.c/d)** | $74.1$ mmHg | $80.8$ mmHg | $+6.7$ mmHg (M > F) | Student t-test | Yes ($p < 10^{-16}$) |
| **Grip Force (Q1.g)** | $25.8$ kg | $43.5$ kg | $+17.6$ kg (M > F) | Welch t-test | Yes ($p < 10^{-300}$) |
| **Sit & Bend (Q1.g)** | **$18.9$ cm** | $13.1$ cm | **$-5.8$ cm (F > M)** | Welch t-test | **Yes (Females Win)** |
| **Sit-ups (Q1.g)** | $30.9$ counts | $44.9$ counts | $+14.0$ counts (M > F) | Welch t-test | Yes ($p < 10^{-300}$) |
| **Broad Jump (Q1.g)**| $153.5$ cm | $211.6$ cm | $+58.1$ cm (M > F) | Student t-test | Yes ($p < 10^{-300}$) |
