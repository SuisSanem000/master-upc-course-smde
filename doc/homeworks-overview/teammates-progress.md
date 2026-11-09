# Review of Teammates' Progress, Code Quality & Open Gaps

This document gives a clear technical review of the code, scripts, reports, and notes created by teammates (*Xiangfeng Ye Pan [XF]*, *Antonina Oliwia C. [AOC]*, and *Simin Shoeibizadeh [SS]*) in the baseline repository located at `resources/homework assignments/homework1-deliver 19th of november/teammates work till now/SMDE-Labs`.

---

## 1. Summary of Current Progress

| Module / Topic | File / Script | Current Status | Grade Weight (out of 40) | Current State & Quality |
| :--- | :--- | :--- | :--- | :--- |
| **Question 1: Visualisation, Chi-Square, t-Test** | `R/Q1.R`<br>`UPC_Template/sections/q1.tex` | **Partially Complete (~70% of code, ~20% of text)** | 10.0 pts (25% of HW1) | Good data cleaning; subquestion 1(g) is completely missing; bug in 1(d); report text is mostly unwritten. |
| **Question 2: ANOVA** | `R/Q2.R`<br>`UPC_Template/sections/q2.tex` | **Empty Template (~5% of code, 0% of text)** | 10.0 pts (25% of HW1) | Only boilerplate code and `# TODO` comments. No models, tests, or plots have been written. |
| **Question 3: Linear Regression Analysis** | `R/Q3.R`<br>`UPC_Template/sections/q3.tex` | **Empty Template (0% of code, 0% of text)** | 10.0 pts (25% of HW1) | Blank template. Does not yet reference variables or fit any models. |
| **Report in LaTeX** | `UPC_Template/` (`ociamthesismain.tex`) | **Basic Template Ready** | Report Structure | Thesis style template is set up, but all tables and plots are in the appendix; body text is mostly blank. |
| **Report in Typst** | `report/` (`main.typ`) | **Deprecated** | Report Structure | Marked as deprecated in the project `README.md` in favor of LaTeX. |
| **Statistical Study Notes** | `docs/*.md` | **Complete Summaries** | Reference Notes | Good summaries of lecture slides on t-tests, ANOVA, and regression. |

---

## 2. In-Depth Review of R Scripts

### 2.1 Question 1 (`R/Q1.R` — 442 lines)

#### What Has Been Done Well:
1. **Automatic Folder and Path Handling**:
   The script checks whether `bodyPerformance.csv` exists and moves up to the parent directory automatically if run from inside `R/`.
2. **Dual-Export System**:
   Helper functions `save_table()` and `save_figure()` automatically export data tables as CSV files and plots as clean PNG files into both `report/` and `UPC_Template/` folders. It also saves all console output into `R/logs/Q1.log`.
3. **Data Import and Variable Typing (Q1.a)**:
   - Changes messy CSV column names into clean R names.
   - Sets correct variable types: `gender` as a factor (`Female`, `Male`), `class` as an ordered factor ($D < C < B < A$), and the other 10 variables as `numeric`.
   - Confirms that the dataset has 13,393 rows and 12 columns with zero missing values (`NA`).
4. **Removing Impossible Values with Medical Rules (Q1.b)**:
   - Instead of blindly deleting any point outside boxplot whiskers, the team used reasonable health guidelines (from NHS, AHA, and ACE).
   - Removed 28 impossible records (about 0.2% of the data):
     - Blood pressure below living thresholds ($\text{systolic} < 70$ or $\text{diastolic} < 40$ mmHg).
     - Inverted blood pressure readings ($\text{systolic} \le \text{diastolic}$).
     - Body fat below essential living levels ($< 2\%$ for men, $< 10\%$ for women, or $> 60\%$).
     - Tests that were not performed (`grip_force == 0` or `broad_jump_cm == 0`).
     - Obvious typing errors in flexibility (`sit_bend_cm > 50` cm, such as 185 cm and 213 cm).
   - Saved the cleaned dataset as `bodyPerformance_clean.csv` ($n = 13,365$).
5. **Grouping Age into 4 Categories (Q1.e)**:
   Used `cut()` with cut points at 30, 40, and 50 to create clean age brackets: `<30`, `30-39`, `40-49`, and `50+`.
6. **Chi-Square Analysis (Q1.f)**:
   Created contingency tables, ran chi-square tests of independence, checked that expected counts are greater than 5, and exported stacked proportion bar charts.

#### Key Gaps, Issues, and Bugs in `Q1.R`:
1. **MAJOR OMISSION: Question 1(g) is Completely Missing (Worth 2.5 Points / 25% of Q1)**:
   - **Assignment Prompt**: *"g) Test whether physical performance test results of the individuals are affected from the gender. Check the assumptions and visualize the relationship between these two characteristics. (2.5p)"*
   - **Audit Finding**: `Q1.R` stops at line 442 after Section f. Subquestion g has **no code at all**. None of the four tests (`grip_force`, `sit_bend_cm`, `sit_ups`, `broad_jump_cm`) were tested across gender; no assumption tests were run; no t-tests were performed; and no boxplots were drawn.
   - **Impact**: Without this part, the group loses 2.5 points out of 10 for Question 1.
2. **METHODOLOGICAL BUG in Question 1(d) (Worth 1.0 Point)**:
   - **Assignment Prompt**: *"d) Construct 95% confidence intervals for the mean systolic blood pressure of two gender groups and interpret them. (1p)"*
   - **Teammates' Code (`Q1.R`, lines 331–354)**:
     ```r
     t_sys <- t.test(male$systolic, female$systolic, var.equal = FALSE, ...)
     # Saves CI: [12.78, 13.56]
     ```
   - **Audit Finding**: The teammates calculated the confidence interval for the **difference between the two means** ($\mu_{\text{Male}} - \mu_{\text{Female}}$).
   - **How to Fix**: The assignment asks for the confidence interval for the *mean systolic blood pressure of two gender groups* (that is, the separate 95% CI for men and the separate 95% CI for women). The professor's lab script `Lab_t_test.R` shows this clearly:
     ```r
     round(t.test(cars$speed[cars$dist_cat=="1"])$conf.int, 2)
     round(t.test(cars$speed[cars$dist_cat=="2"])$conf.int, 2)
     ```
     The difference CI is useful extra information, but the two individual group CIs must be calculated and reported.
3. **Sample Size Effect in Normality Tests (Q1.b)**:
   - The team correctly noticed that `shapiro.test()` cannot take more than 5,000 rows, so they took a random sample of 5,000. However, the resulting $p$-values ($p < 10^{-16}$) reject normality. The text needs to explain why: with very large samples, even tiny differences from a perfect bell curve cause the test to reject $H_0$, even though the data looks approximately normal in the charts and can be used with standard tests under the Central Limit Theorem.

---

### 2.2 Question 2 (`R/Q2.R` — 120 lines)

#### Current Status: Empty Boilerplate (0% Working Code)
- Lines 1–86 copy the initial folder setup and load the cleaned dataset.
- Lines 87–120 contain only comments:
  - Line 93: `# TODO: summary statistics per group...`
  - Line 102: `# TODO: remove outlying observations if required...`
  - Line 103: `# TODO: aov() for each response, with age_cat and with class...`
  - Line 104: `# TODO: assumptions: normality..., equal variances..., independence...`
  - Line 106: `# TODO: three post-hoc tests and compare them (e.g. Tukey, Bonferroni, LSD)...`
  - Line 114: `# TODO: aov(y ~ age_cat * gender) for sit_ups and broad_jump_cm...`
  - Line 115: `# TODO: interaction plot, assumptions and post-hoc tests...`
- **Audit Finding**: No calculations, statistical tests, or charts have been created for Question 2 yet. All 10 points for Question 2 remain to be done.

---

### 2.3 Question 3 (`R/Q3.R` — 63 lines)

#### Current Status: Empty Template (0% Working Code)
- Contains generic template headers without mentioning the dataset, variables, or questions.
- Line 54: `# TODO: analysis of part a`
- **Audit Finding**: Question 3 was released by the professor on November 8, 2026. The teammates added an empty placeholder script but have not written any code yet. All 10 points for Question 3 remain open.

---

## 3. Review of the LaTeX Report

### 3.1 Template Choice & Deprecation
- The team initially used **Typst** (`report/main.typ`), but deprecated it and noted in `README.md`:
  > `> [!WARNING]`  
  > `> **DEPRECATED:** This report in typst is deprecated and may be removed.`
- Work is now focused on **LaTeX** inside `UPC_Template/`, using `ociamthesismain.tex`.

### 3.2 Report Setup and Layout
- **Style**: Uses an adapted UPC thesis style (`ociamthesis.cls`).
- **Title Page**: Already includes official UPC and FIB logos, course title (*Statistical Modelling and Design of Experiments*), term (*Fall 2026*), and student names (*Simin Shoeibizadeh, Antonina Oliwia C., Xiangfeng Ye Pan*).
- **Structure**: Uses modular files: `sections/q1.tex`, `sections/q2.tex`, `sections/q3.tex`, and `sections/appendix.tex`.

### 3.3 Text Content Status in `UPC_Template/sections/`

#### `sections/q1.tex`:
- Only subquestion 1.a (Import) and the outlier rules in 1.b have written text.
- The rest of the file consists of placeholder notes:
  - `\xfcomment{TODO: describe the shape of each variable...}`
  - `\xfcomment{TODO: check whether the two peaks of grip_force...}`
  - `\xfcomment{TODO: comment on the Q-Q plots...}`
  - `\xfcomment{TODO: report the Shapiro-Wilk test...}`
  - `\xfcomment{Discuss the differences in the distributions of diastolic and systolic...}`
  - `\xfcomment{State the resulting intervals and explain their practical meaning in context.}`
  - `\xfcomment{TODO: comment on the size of each level of age_cat...}`
  - `\xfcomment{TODO: state the hypotheses, check the assumption...}`
  - `\xfcomment{Summarize the assumption checks and discuss whether grip_force, sit_bend_cm, sit_ups and broad_jump_cm differ significantly by gender.}`
- **Audit Finding**: Almost all the actual explanations and statistical interpretations still need to be written.

#### `sections/q2.tex` and `sections/q3.tex`:
- Contain only dummy headings and empty comment tags.
- Completely unwritten.

### 3.4 The 12-Page Limit
The professor's instructions state:
> *"The report should maximum consists of 12 pages. It should have a title page and an outline. The tables and figures in the body of the text should be numbered and titled."*

- **Current Issue**:
  In `UPC_Template/sections/appendix.tex`, the team put **all tables and figures into the appendix**, leaving only text references in the main body.
  - This contradicts the professor's instruction that tables and figures should be inside the main body.
  - Also, if the examiner counts the appendix toward the 12 pages, the report could easily exceed the limit.
- **How to Fix This**:
  Place the key summary tables and compact multi-panel figures directly in the main body where they are explained, keeping the entire compiled PDF under 12 pages total.

---

## 4. Summary Table of What Needs to Be Done

| Section | Task | Current Status | What Needs Fixing | Action Needed |
| :--- | :--- | :--- | :--- | :--- |
| **Q1.a** | Data import and types | Done | None | Keep as is |
| **Q1.b** | Summaries and outliers | Code done; text missing | Text explanation of distribution shapes is missing | Write explanations in `q1.tex` |
| **Q1.c** | Blood pressure by gender | Code done; text missing | Physical interpretation is missing | Write explanations in `q1.tex` |
| **Q1.d** | Systolic BP confidence intervals | Code has bug; text missing | Computed difference CI instead of separate group CIs | Update R script to compute separate CIs ($\mu_M, \mu_F$); write text |
| **Q1.e** | Age grouping | Code done; text missing | Text commentary is missing | Write explanations in `q1.tex` |
| **Q1.f** | Chi-Square tests | Code done; text missing | Formal hypothesis statements are missing | Write test results in `q1.tex` |
| **Q1.g** | Physical tests by gender | **Missing in code & text** | Completely omitted (2.5 pts) | Add R code for assumption checks, t-tests, and boxplots; write full text |
| **Q2.a** | Distributions by age and class | Not started | 0% complete | Write R code for group summaries and faceted plots |
| **Q2.b** | One-Way ANOVA + 3 post-hoc tests | Not started | 0% complete | Fit ANOVA models, check assumptions, run Tukey, Bonferroni, and LSD |
| **Q2.c** | Two-Way ANOVA with interaction | Not started | 0% complete | Fit two-way models, draw interaction plots, check diagnostics |
| **Q3.a** | Best simple linear regression | Not started | 0% complete | Compute correlations, fit simple models, check assumptions |
| **Q3.b** | Multiple regression (2 variables) | Not started | 0% complete | Fit MLR model, check VIF, compare with SLR using Partial F-test |
| **Q3.c** | Adding factors (Age and Gender) | Not started | 0% complete | Add dummy variables, interpret coefficients and shifts |
| **Q3.d** | Model comparison | Not started | 0% complete | Compare models using $R^2$, AIC, BIC, and Partial F-tests |
| **Q3.e** | Diagnostics and validation | Not started | 0% complete | Draw residual plots, run 70/30 train/test split, compute RMSE |
| **Report** | Final LaTeX document | Incomplete | Sections are empty; tables are in appendix | Move key tables/figures into text body; stay under 12 pages |
