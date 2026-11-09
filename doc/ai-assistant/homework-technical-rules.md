# Homework 1 — Technical Rules & Academic Specifications

This document outlines the strict technical rules, formatting requirements, data cleaning standards, and script conventions for **SMDE Homework Assignment 1 (Questions 1, 2, and 3)**.

---

## 1. Submission Framework & Administrative Rules

| Rule | Requirement |
| :--- | :--- |
| **Integrated Scope** | **Homework 1 comprises Questions 1, 2, and 3** as a single combined report. Question 4 (PCA) is assigned separately in December. |
| **Course Weight** | 40% of the overall course mark (the Statistics practical part). Questions 1, 2, and 3 each count for 25% of this component (10 points each out of 40). |
| **Submission Deadline** | **Thursday, November 19, 2026, at 23:59 CET** |
| **Submission Portal** | Racó de la FIB (online submission portal) |
| **Page Budget** | **Strict maximum of 12 pages** (including Title Page and Table of Contents). |
| **Table & Figure Rules** | Tables and figures must be placed inside the main body of the text (not hidden in an appendix), sequentially numbered, titled, and cross-referenced. |
| **Submission Package** | Single `.zip` archive containing: <br>1. Compiled PDF report (`.pdf`)<br>2. Complete, reproducible R script (`.R`)<br>3. Cleaned dataset in CSV format (`.csv`) |

---

## 2. Dataset Hygiene & Clinical Cleaning Rules

The raw dataset `bodyPerformance.csv` contains 13,393 rows and 12 columns. To ensure scientific validity, observations are filtered using medically grounded rules:

1. **Blood Pressure Bounds**:
   - Living human limits: $\text{systolic} \ge 70$ mmHg and $\text{diastolic} \ge 40$ mmHg (removes unmeasured zero readings and severe shock/hypotension).
   - Logical relationship: Systolic pressure must always exceed diastolic pressure ($\text{systolic} > \text{diastolic}$). Readings where systolic $\le$ diastolic are inverted errors.
2. **Essential Body Fat**:
   - Physiological minimum lipid levels: $\ge 2\%$ for men and $\ge 10\%$ for women. Maximum reasonable limit: $\le 60\%$.
3. **Fitness Test Zeros**:
   - Test scores of 0 for `grip_force` or `broad_jump_cm` mean the test was refused or not performed, rather than an accurate capability score.
4. **Typing Error Thresholds**:
   - Sit-and-bend flexibility scores $> 50$ cm (specifically records with 185 cm and 213 cm) are obvious typographical mistakes.
5. **Output**:
   - Exactly **28 rows (0.2%)** are excluded, producing `bodyPerformance_clean.csv` ($n = 13,365$), which serves as the dataset for all subsequent questions.

---

## 3. Variable Categorization Rules

- **Gender**: 2-level factor with levels `Female` and `Male` (encoded from `F` and `M`).
- **Class**: 4-level ordered factor with levels $D < C < B < A$ (from poor to excellent performance).
- **Age Categories (`age_cat`)**:
  - Continuous `age` is cut at 30, 40, and 50 using left-closed intervals $[a, b)$:
    $$\text{age\_cat} = \begin{cases} <30 & [21, 30) \\ 30\text{--}39 & [30, 40) \\ 40\text{--}49 & [40, 50) \\ 50+ & [50, \infty) \end{cases}$$
  - In R: `cut(body$age, breaks = c(-Inf, 30, 40, 50, Inf), labels = c("<30", "30-39", "40-49", "50+"), right = FALSE)`.

---

## 4. R Scripting Architecture & Output Conventions

Every script (`Q1.R`, `Q2.R`, `Q3.R`) must adhere to the standardized team setup:

1. **Working Directory Resolution**:
   Must run seamlessly from both the repository root and from inside the `R/` directory:
   ```r
   if (!file.exists("bodyPerformance.csv") && file.exists("../bodyPerformance.csv")) setwd("..")
   ```
2. **Dual-Export Architecture**:
   Helper functions must save all data tables and figures simultaneously to both report folders (`report/` and `UPC_Template/`):
   ```r
   log_dir <- "R/logs"
   tab_dir <- c("report/tables", "UPC_Template/tables")
   fig_dir <- c("report/figures", "UPC_Template/figures")
   ```
3. **Automated Helpers**:
   - `save_table(df, name)`: Saves a data frame as CSV in every table folder and prints it to the console.
   - `save_figure(name, draw_fn, width = 1600, height = 700, res = 120)`: Renders plotting code into high-resolution PNGs in every figure folder.
   - `sink(file.path(log_dir, "Q*.log"), split = TRUE)`: Captures full console output to a log file.
4. **Naming Conventions**:
   All exported tables and figures must follow the naming pattern `q<question><part>_<name>` (for example: `q1b_summary.csv`, `q1d_t_test.csv`, `q2b_posthoc.csv`, `q3a_slr_comparison.csv`).

---

## 5. Required R Packages & Functions

The coursework relies strictly on standard CRAN packages taught by Prof. Nihan:

| Package | Key Functions | What it is Used For |
| :--- | :--- | :--- |
| **base / stats** | `t.test()`, `var.test()`, `chisq.test()`, `aov()`, `lm()`, `TukeyHSD()`, `pairwise.t.test()`, `shapiro.test()` | Core hypothesis tests, confidence intervals, ANOVA, linear regression, and normality tests. |
| **car** | `leveneTest()`, `vif()`, `Boxplot()` | Levene's test for equal variances across groups; Variance Inflation Factor (VIF) for multicollinearity in regression. |
| **lmtest** | `bptest()`, `dwtest()` | Breusch-Pagan test for constant variance (homoscedasticity); Durbin-Watson test for independence of residuals. |
| **agricolae** | `LSD.test()` | Fisher's Least Significant Difference (LSD) post-hoc test for ANOVA (as demonstrated in Session 8). |

---

## 6. LaTeX Report Architecture (`UPC_Template`)

- **Main File**: `UPC_Template/ociamthesismain.tex`.
- **Modular Sections**: `sections/q1.tex`, `sections/q2.tex`, `sections/q3.tex`.
- **Macros**:
  - `\task{...}`: Displays the official subquestion prompt in grey italics.
  - `\csvtable{filename_without_extension}{Caption text}{tab:label}`: Generates a booktabs table from the exported CSV file.
  - `\autoref{tab:...}` / `\autoref{fig:...}`: Automatically generates clickable cross-references.
- **Page Budget Strategy**:
  - Title page + Table of contents: 2 pages.
  - Question 1: $\sim 3$ to 3.5 pages.
  - Question 2: $\sim 3$ to 3.5 pages.
  - Question 3: $\sim 3$ to 3.5 pages.
  - Total document stays strictly $\le 12$ pages.
