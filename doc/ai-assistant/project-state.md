# SMDE Homework 1 — AI Assistant Project State & Action Plan

This document is the master project tracker, status log, and roadmap for the AI assistant across all phases of **SMDE Homework Assignment 1 (Questions 1, 2, and 3)**.

---

## 1. Project Overview

| Detail | Description |
| :--- | :--- |
| **Course** | Statistical Modelling & Design of Experiments (SMDE - MIRI, Fall 2026) |
| **University** | Facultat d'Informàtica de Barcelona (FIB), Universitat Politècnica de Catalunya (UPC) |
| **Instructor** | Prof. Nihan Acar-Denizli, PhD |
| **Deliverable** | **Homework Assignment 1 (Single integrated report covering Q1, Q2, and Q3)** |
| **Current Date** | November 9, 2026 |
| **Submission Deadline** | **Thursday, November 19, 2026, at 23:59 CET (10 days remaining)** |
| **Submission Method** | Upload to Racó de la FIB: One `.zip` file containing the PDF report, the R script, and the cleaned CSV data |
| **Page Budget** | **Strict limit of 12 pages maximum** (including Title Page and Table of Contents) |
| **Current Status** | **Phase 1: Planning, Understanding, and Architecture (Completed)** |

---

## 2. Core Operational Constraints & Language Rules

### 2.1 Workspace and Safety Rules
1. **Safety Constraint**: The `resources/` folder is strictly read-only. We do not modify or delete anything inside `resources/` (except removing `.git/` folders as instructed).
2. **Implementation Status**: **Zero implementation code has been written.** The project is currently strictly in Phase 1 (Planning and Understanding). No code or workspace directories have been copied, created, or changed for Homework 1. When the user decides to start Phase 2, code will be developed in `./smde-lab/` at the root.
3. **Documentation Boundary**: All project planning, guides, and review notes reside strictly inside the `doc/` subfolders.
4. **Clean State**: The `.git/` directories inside both `SMDE-Labs` and `GPSS-simulator` have been permanently deleted.

### 2.2 Other Repositories in Workspace: `GPSS-simulator`
- **Location**: `resources/homework assignments/homework1-deliver 19th of november/teammates work till now/github repos/GPSS-simulator/`
- **Topic**: Discrete Simulation Practical (Prof. Pau Fonseca i Casas: Pseudo-Random Number Generators [PRNG], Chi-square uniformity tests, spectral analysis, Drunkard's Walk, and the aGPSS simulation engine).
- **Relevance to Homework 1**: **Not related to Homework 1.** Homework 1 is strictly the Statistics module (Prof. Nihan Acar-Denizli: Questions 1, 2, and 3 using `bodyPerformance.csv`).
- **Action**: Ignored for Homework 1. Its `.git/` folder was removed. It is preserved for future simulation practical work.

### 2.3 Local Git Repository & No-Push Policy (MANDATORY RULE)
> [!IMPORTANT]
> **LOCAL VERSION CONTROL ONLY — NEVER PUSH**:
> 1. **Local Repository**: A local Git repository is initialized at the workspace root (`/Users/siminshoeibizadeh/My Drive/uni/sem1/uni projects/sem1/SMDE`).
> 2. **Never Push**: This repository is strictly for local version tracking. It must **never** be pushed to GitHub, GitLab, or any remote server. No remote origin shall be configured or pushed to under any circumstances.
> 3. **Commit Every Step**: The AI assistant must track each meaningful step, update markdown files when needed, and make clear, descriptive local commits.

### 2.4 Language and Style Constraint (Upper B2 English)
> [!IMPORTANT]
> **MANDATORY RULE FOR ALL FUTURE AI ASSISTANT TASKS**:
> - **Language Level**: English up to **Upper B2**.
> - **Clarity**: Use clear, direct, and natural sentences. Avoid overly dense, flowery, or complicated words when simpler words express the same meaning.
> - **Technical Terms & Proper Names**: Always keep official statistical names, test names, formulas, and clinical terms intact (for example: ANOVA, One-Way ANOVA, Two-Way ANOVA, Tukey's HSD, Bonferroni correction, Fisher's LSD, Shapiro-Wilk test, Levene's test, Breusch-Pagan test, Durbin-Watson test, Ordinary Least Squares, VIF, RMSE, AIC, BIC, systolic, diastolic, etc.).
> - **Explanations**: State statistical findings, test results, and their practical real-world meaning simply and clearly.

---

## 3. Current Project State: Done vs. Open

```
Total Homework 1 (30.0 Points Practical Statistics)
├── Question 1: Visualisation, Chi-Square, t-Test (10.0 pts)
│   ├── Q1.a: Import & Variable Types [Done: 0.5/0.5]
│   ├── Q1.b: Summaries & Outlier Cleaning [Code Done, Text Missing: 1.0/2.0]
│   ├── Q1.c: Blood Pressure by Gender [Code Done, Text Missing: 0.5/1.0]
│   ├── Q1.d: Systolic BP 95% CIs [Buggy in Code, Text Missing: 0.2/1.0]
│   ├── Q1.e: Age Grouping [Done: 0.5/0.5]
│   ├── Q1.f: Chi-Square Independence Tests [Code Done, Text Missing: 1.5/2.5]
│   └── Q1.g: Physical Tests by Gender [Completely Missing: 0.0/2.5]
│   └── Total Q1 Progress: ~4.2 / 10.0 pts
├── Question 2: ANOVA (10.0 pts)
│   ├── Q2.a: Group Distributions [Not Started: 0.0/2.0]
│   ├── Q2.b: One-Way ANOVA + 3 Post-Hoc Tests [Not Started: 0.0/6.0]
│   └── Q2.c: Two-Way ANOVA + Interaction [Not Started: 0.0/2.0]
│   └── Total Q2 Progress: 0.0 / 10.0 pts
├── Question 3: Regression Analysis (10.0 pts)
│   ├── Q3.a: Best Simple Linear Regression [Not Started: 0.0/2.5]
│   ├── Q3.b: Multiple Regression with 2 Predictors [Not Started: 0.0/2.5]
│   ├── Q3.c: Factor Models (Age & Gender) [Not Started: 0.0/3.0]
│   ├── Q3.d: Model Comparison & Selection [Not Started: 0.0/1.0]
│   └── Q3.e: Diagnostics & Validation [Not Started: 0.0/1.0]
│   └── Total Q3 Progress: 0.0 / 10.0 pts
└── Report and Submission Preparation
    ├── LaTeX Setup: Template ready in UPC_Template, narrative text needs writing
    ├── Layout: Move key tables and figures from appendix into main body
    └── 12-Page Limit: Manage spacing and layout to stay strictly under 12 pages
```

---

## 4. Technical Reference Information for Next Phases

This reference summary preserves all key technical details so the AI assistant can access them immediately in future steps.

### 4.1 Data Rules & Cleaning
- **Raw Data**: `bodyPerformance.csv` (13,393 rows, 12 columns).
- **Cleaned Data**: `bodyPerformance_clean.csv` (13,365 rows, 12 columns).
- **Exclusion Rules**:
  1. `systolic >= 70` and `diastolic >= 40` (removes zero readings and severe hypotension).
  2. `systolic > diastolic` (removes impossible inverted blood pressure readings).
  3. `body_fat_pct >= 2%` for men, `body_fat_pct >= 10%` for women, and `body_fat_pct <= 60%`.
  4. `grip_force > 0` and `broad_jump_cm > 0` (removes unperformed tests).
  5. `sit_bend_cm <= 50` (removes typing errors: 185 cm and 213 cm).
- **Age Categories (`age_cat`)**:
  ```r
  body$age_cat <- cut(body$age, breaks = c(-Inf, 30, 40, 50, Inf),
                      labels = c("<30", "30-39", "40-49", "50+"), right = FALSE)
  ```

### 4.2 Script Execution Pattern
Scripts should run smoothly from both the repository root and the `R/` directory:
```r
if (!file.exists("bodyPerformance.csv") && file.exists("../bodyPerformance.csv")) setwd("..")
log_dir <- "R/logs"
tab_dir <- c("report/tables", "UPC_Template/tables")
fig_dir <- c("report/figures", "UPC_Template/figures")
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
```

### 4.3 Required R Packages & Key Functions
- **ANOVA & Diagnostics**:
  - `aov(y ~ group, data = df)`
  - `car::leveneTest(y ~ group, data = df)`
  - `lmtest::bptest(model)`
  - `lmtest::dwtest(model, alternative = "two.sided")`
  - `shapiro.test(residuals(model))` (sample 5,000 if $n > 5,000$)
- **Three Required Post-Hoc Tests**:
  - 1. Tukey's HSD: `TukeyHSD(aov_model)`
  - 2. Bonferroni: `pairwise.t.test(df$y, df$group, p.adj = "bonf")`
  - 3. Fisher's LSD: `agricolae::LSD.test(aov_model, "group")`
- **Regression & Validation**:
  - `lm(broad_jump_cm ~ predictors, data = train_data)`
  - `car::vif(model)`
  - `anova(model_small, model_large)` (Partial F-test)
  - `AIC(model)`, `BIC(model)`
  - `RMSE = sqrt(mean((test_data$broad_jump_cm - predict(model, test_data))^2))`

### 4.4 LaTeX Macros & Formatting (`UPC_Template`)
- Section files: `sections/q1.tex`, `sections/q2.tex`, `sections/q3.tex`.
- Subquestion box: `\task{Question statement}`
- Table inclusion: `\csvtable{filename_without_csv}{Caption}{tab:label}`
- Referencing: `\autoref{tab:...}`, `\autoref{fig:...}`, `\autoref{sec:...}`
- Page layout target: Approximately 3 pages per question to ensure Title Page + Table of Contents + Q1 + Q2 + Q3 $\le 12$ pages total.

---

## 5. Concrete Action Plan for Subsequent Phases

```mermaid
flowchart TD
    P1[Phase 1: Planning & Understanding] -->|COMPLETE| P2[Phase 2: Finalize Question 1]
    P2 -->|Fix Q1.d, Implement Q1.g, Draft q1.tex| P3[Phase 3: Implement Question 2 ANOVA]
    P3 -->|Q2.a, Q2.b 3 Post-Hocs, Q2.c Interaction, Draft q2.tex| P4[Phase 4: Implement Question 3 Regression]
    P4 -->|Q3.a SLR, Q3.b MLR, Q3.c Factors, Q3.d Select, Q3.e Validate, Draft q3.tex| P5[Phase 5: Synthesis, Compilation & 12-Page Layout]
```

### Phase 2: Finalize Question 1 (Detailed Technical Blueprint)

When implementation begins, Phase 2 will execute the following technical plan:

1. **Working Directory Setup**:
   - Copy `resources/.../SMDE-Labs` to `./smde-lab/` at the workspace root so that `resources/` remains completely read-only.
2. **Fix Q1.d in R (`R/Q1.R`)**:
   - **Math Formulation**: Compute individual 95% confidence intervals for the population mean systolic blood pressure of women and men:
     $$CI_{95\%}(\mu_{\text{Female}}) = \bar{x}_F \pm t_{0.025, n_F-1} \frac{s_F}{\sqrt{n_F}}$$
     $$CI_{95\%}(\mu_{\text{Male}}) = \bar{x}_M \pm t_{0.025, n_M-1} \frac{s_M}{\sqrt{n_M}}$$
   - **R Code Design**:
     ```r
     ci_female <- t.test(female$systolic)$conf.int
     ci_male   <- t.test(male$systolic)$conf.int
     ```
   - **Export Table**: Update `q1d_t_test.csv` to include separate rows for Female and Male means, standard deviations, sample sizes, and individual 95% confidence intervals, alongside the difference CI.
   - **Interpretation**: Clearly explain that because the male and female confidence intervals do not overlap, there is a statistically significant and clinically meaningful difference in systolic blood pressure between genders.
3. **Implement Q1.g in R (`R/Q1.R`)**:
   - **Fitness Variables to Test**: `grip_force` (kg), `sit_bend_cm` (cm), `sit_ups` (count), and `broad_jump_cm` (cm).
   - **Assumption Checking**:
     - Check normality per gender using Q-Q plots and sample Shapiro-Wilk tests.
     - Check equal variances between genders using the two-sample F-test:
       `f_test <- var.test(x ~ gender, data = body)`
   - **Hypothesis Testing**:
     - Null hypothesis $H_0: \mu_{\text{Male}} = \mu_{\text{Female}}$ vs. $H_1: \mu_{\text{Male}} \ne \mu_{\text{Female}}$.
     - Use Welch's t-test (`var.equal = FALSE`) if variances differ, or Student's pooled t-test (`var.equal = TRUE`) if variances are equal.
   - **Export Outputs**:
     - Table `q1g_performance_tests.csv`: variable name, female mean/SD, male mean/SD, F-test statistic and $p$-value, t-test statistic, degrees of freedom, $p$-value, and 95% confidence interval for the difference.
     - Figure `q1g_performance_boxplots.png`: 4-panel comparative boxplot grid (2 rows $\times$ 2 columns) with consistent color-coding (pink for Female, light blue for Male).
4. **Draft Academic Text in `sections/q1.tex`**:
   - Replace all author placeholder tags (`\xfcomment{TODO: ...}`) with complete, clear Upper B2 English explanations:
     - **Q1.b**: Explain distribution shapes, skewness, and the reason why large-sample Shapiro-Wilk tests reject normality under the Central Limit Theorem.
     - **Q1.c**: Explain physiological blood pressure differences between men and women.
     - **Q1.d**: Report the separate 95% confidence intervals and interpret their non-overlapping nature.
     - **Q1.e**: Comment on sample distribution across the four age groups.
     - **Q1.f**: Report Chi-Square test statistics ($\chi^2$, $df$, $p$-value), confirm that expected cell counts exceed 5, and discuss the drop in fitness performance class with increasing age.
     - **Q1.g**: Summarize assumption checks and present sports-science explanations for gender performance differences (higher upper-body and jump power in men vs. greater flexibility in women).

### Phase 3: Implement Question 2 (ANOVA Pipeline)
1. **Write `R/Q2.R`**:
   - **Q2.a**: Summary tables across `age_cat` and `class` for the 4 responses; multi-panel distribution charts (`q2a_distributions.png`).
   - **Q2.b**: One-way ANOVA models; residual assumption checks (Shapiro-Wilk, Q-Q plots, Levene test, Breusch-Pagan, Durbin-Watson); run the **three post-hoc tests** (`TukeyHSD`, Bonferroni `pairwise.t.test`, Fisher's LSD via `agricolae`); export comparison table (`q2b_posthoc_comparison.csv`).
   - **Q2.c**: Two-way ANOVA with interaction (`response ~ age_cat * gender`) for `sit_ups` and `broad_jump_cm`; test main effects and interaction; generate interaction plots (`q2c_interaction_plots.png`).
2. **Write Text in `sections/q2.tex`**:
   - Clear explanations of hypotheses, ANOVA tables, comparison of the three post-hoc tests, and the interaction between age and gender.

### Phase 4: Implement Question 3 (Linear Regression Pipeline)
1. **Write `R/Q3.R`**:
   - **Q3.a**: Correlation matrix with `broad_jump_cm`; fit candidate simple models; pick the best single predictor; check assumptions; explain slope and intercept.
   - **Q3.b**: Fit multiple regression with the two best numerical predictors; check VIF; compare with simple model using a Partial F-test (`anova(slr, mlr)`).
   - **Q3.c**: Add factors (i) `age_cat` and (ii) `gender`; explain dummy coefficients and shifts.
   - **Q3.d**: Build model comparison table ($R^2$, adjusted $R^2$, RSE, AIC, BIC, F-tests); choose the best model.
   - **Q3.e**: Draw 4 diagnostic plots; split data into 70% train / 30% test; compute $RMSE_{\text{train}}$ and $RMSE_{\text{test}}$; confirm good generalization.
2. **Write Text in `sections/q3.tex`**:
   - Clear write-up explaining model selection, practical meaning of coefficients, and test predictions.

### Phase 5: Synthesis, Compilation & 12-Page Budgeting
1. **Adjust Report Layout**: Move key tables and figures into the main text; keep the compiled PDF strictly under 12 pages.
2. **Verify Code & Run**: Re-run all R scripts to ensure full reproducibility.
3. **Check Deliverables**: Confirm the `.zip` package contains the PDF report, the R script, and the cleaned CSV file.
