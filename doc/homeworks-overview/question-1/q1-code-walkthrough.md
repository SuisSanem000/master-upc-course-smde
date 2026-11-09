# Question 1: Line-by-Line Code Walkthrough of `R/Q1.R`

This document explains the entire R script [`Q1.R`](file:///Users/siminshoeibizadeh/My%20Drive/uni/sem1/uni%20projects/sem1/SMDE/resources/homework%20assignments/homework1-deliver%2019th%20of%20november/teammates%20work%20till%20now/github%20repos/SMDE-Labs/R/Q1.R) line by line in clear, Upper B2 English. Use this guide so you know exactly how each line works if your teammates ask during the meeting.

---

## 1. Setup & Output Directory Management (Lines 1–48)

```r
# lines 15-16
if (!file.exists("bodyPerformance.csv") && file.exists("../bodyPerformance.csv")) setwd("..")
if (!file.exists("bodyPerformance.csv")) stop("Run this script from the repository root or from the R/ folder")
```
- **What this does**: It checks where the user is running the script. If the user started R inside the `R/` subfolder, it automatically moves up to the root folder where `bodyPerformance.csv` is located. If it cannot find the data file anywhere, it stops execution with a friendly warning.

```r
# lines 19-22
log_dir <- "R/logs"
tab_dir <- c("report/tables", "UPC_Template/tables")
fig_dir <- c("report/figures", "UPC_Template/figures")
for (d in c(log_dir, tab_dir, fig_dir)) dir.create(d, showWarnings = FALSE)
```
- **What this does**: It creates the folders for logs, CSV tables, and PNG figures in both the `report/` and `UPC_Template/` folders if they do not exist already (`showWarnings = FALSE` prevents error messages if the folders already exist).

```r
# lines 26-28
if (sink.number() > 0) sink()   
sink(file.path(log_dir, "Q1.log"), split = TRUE)
```
- **What this does**: `sink()` records every single line of text printed to the R console into `R/logs/Q1.log`. Setting `split = TRUE` ensures you can still see the output on your screen while saving it to disk.

```r
# lines 34-47
save_table <- function(df, name) { ... }
save_figure <- function(name, draw, width = 1600, height = 700, res = 120) { ... }
```
- **What this does**: These are helper functions. `save_table()` writes a data frame to CSV files in both table directories and prints it. `save_figure()` opens a PNG file, runs the plotting code passed to `draw()`, and closes the device with `dev.off()`.

---

## 2. Part a: Data Loading & Variable Types (Lines 50–107)

```r
# lines 55-58
body <- read.csv("bodyPerformance.csv",
                 header = TRUE,
                 stringsAsFactors = FALSE,
                 check.names = FALSE)
```
- **What this does**: Reads the dataset from the CSV file. `check.names = FALSE` prevents R from automatically altering column names with special symbols (like `body fat_%`).

```r
# lines 61-75
names(body) <- c("age", "gender", "height_cm", "weight_kg", "body_fat_pct",
                 "diastolic", "systolic", "grip_force", "sit_bend_cm",
                 "sit_ups", "broad_jump_cm", "class")
```
- **What this does**: Renames the 12 columns to clean, standard R variable names using snake_case without spaces or percentage symbols.

```r
# lines 78-83
body$gender <- factor(body$gender, levels = c("F", "M"), labels = c("Female", "Male"))
body$class <- factor(body$class, levels = c("D", "C", "B", "A"), ordered = TRUE)
```
- **What this does**: 
  - Converts `gender` into a categorical factor with readable labels (`Female`, `Male`).
  - Converts `class` into an **ordered factor** where $D < C < B < A$ (from lowest physical performance grade to highest).

```r
# lines 86-89
num_vars <- c("age", "height_cm", "weight_kg", "body_fat_pct", "diastolic",
              "systolic", "grip_force", "sit_bend_cm", "sit_ups", "broad_jump_cm")
body[num_vars] <- lapply(body[num_vars], as.numeric)
```
- **What this does**: Ensures that all 10 continuous numerical measurements are stored as numeric floating-point values.

```r
# lines 98-106
colSums(is.na(body))
save_table(..., "q1a_variables")
```
- **What this does**: Verifies that there are 0 missing values (`NA`) across the entire dataset and exports the metadata summary to `q1a_variables.csv`.

---

## 3. Part b: Summary Statistics, Distributions & Outlier Cleaning (Lines 109–209)

```r
# lines 116-125
save_table(data.frame(
    Variable = num_vars,
    Min      = sapply(body[num_vars], min),
    Q1       = sapply(body[num_vars], quantile, 0.25),
    Median   = sapply(body[num_vars], median),
    Mean     = round(sapply(body[num_vars], mean), 2),
    Q3       = sapply(body[num_vars], quantile, 0.75),
    Max      = sapply(body[num_vars], max),
    SD       = round(sapply(body[num_vars], sd), 2)
), "q1b_summary")
```
- **What this does**: Computes the five-number summary (Min, Q1, Median, Q3, Max) plus the Mean and Standard Deviation (SD) for every numerical variable, saving them to `q1b_summary.csv`.

```r
# lines 147-158: The Cleaning Rules
impossible <- list(
    "systolic < 70 or diastolic < 40" = body$systolic < 70 | body$diastolic < 40,
    "systolic <= diastolic"           = body$systolic <= body$diastolic,
    "body_fat_pct < essential or > 60" =
        body$body_fat_pct < ifelse(body$gender == "Female", 10, 2) | body$body_fat_pct > 60,
    "grip_force = 0"                  = body$grip_force == 0,
    "broad_jump_cm = 0"               = body$broad_jump_cm == 0,
    "sit_bend_cm > 50"                = body$sit_bend_cm > 50
)
remove <- Reduce(`|`, impossible)
```
- **What this does**: This is one of the smartest parts of the teammates' work. Instead of mechanically deleting every point outside Tukey's whiskers ($1.5 \times IQR$), they set **medical and physical validity boundaries**:
  - Systolic blood pressure below 70 mmHg or diastolic below 40 mmHg indicates circulatory collapse (impossible for walking individuals).
  - Systolic blood pressure must always be higher than diastolic.
  - Essential body fat cannot drop below 2% for men or 10% for women.
  - A score of 0 for grip strength or broad jump means the subject skipped the test.
  - Flexibility scores above 50 cm (there were values of 185 cm and 213 cm) are impossible data entry typos.
- **Result**: Exactly **28 rows (0.2%)** are flagged and removed, leaving 13,365 valid rows. The clean data is exported as `bodyPerformance_clean.csv`.

```r
# lines 198-208: Shapiro-Wilk Normality Test
set.seed(123)
shapiro_p <- sapply(body[num_vars], function(x) shapiro.test(sample(x, 5000))$p.value)
```
- **What this does**: R's `shapiro.test()` function has a limit of 5,000 observations. The script takes a random sample of 5,000 rows and computes the test. All p-values are tiny ($p < 10^{-16}$). This officially rejects exact normality, but because our sample size is over 13,000, the **Central Limit Theorem** guarantees that sample means are normally distributed, allowing us to safely use t-tests and ANOVA.

---

## 4. Part c: Blood Pressure Comparison by Gender (Lines 211–311)

```r
# lines 216-224
body_c <- subset(body, diastolic > 0 & systolic > 0 & !is.na(gender))
male <- subset(body_c, gender == "Male")
female <- subset(body_c, gender == "Female")
```
- **What this does**: Splits the dataset into two separate groups: `male` (8,460 observations) and `female` (4,905 observations).

```r
# lines 234-263 & 266-282
save_figure("q1c_histograms", ...)
save_figure("q1c_boxplots", ...)
```
- **What this does**: Generates histograms and side-by-side boxplots for systolic and diastolic blood pressure.
- **Key Takeaways**:
  - Systolic blood pressure: Males average 130.2 mmHg, while females average 117.0 mmHg (a difference of about 13 mmHg).
  - Diastolic blood pressure: Males average 80.8 mmHg, while females average 74.1 mmHg (a difference of about 6.7 mmHg).
  - Both distributions are unimodal and symmetric, but male curves are shifted noticeably to the right.

---

## 5. Part d: Variance Test & Two-Sample t-Tests (Lines 313–356)

```r
# lines 318-325: Testing Equal Variances (F-Test)
f_sys <- var.test(male$systolic, female$systolic)
f_dia <- var.test(male$diastolic, female$diastolic)
```
- **What this does**: Tests whether male and female variances are identical:
  - $H_0: \sigma^2_{\text{male}} = \sigma^2_{\text{female}}$
  - For **systolic pressure**: $p < 0.05$. We reject equal variances! Therefore, we must use **Welch's t-test**.
  - For **diastolic pressure**: $p > 0.05$. We fail to reject equal variances. Therefore, standard **Student's t-test** is appropriate.

```r
# lines 332-355: Two-Sample t-tests
t_sys <- t.test(male$systolic, female$systolic, var.equal = FALSE)
t_dia <- t.test(male$diastolic, female$diastolic, var.equal = TRUE)
```
- **What this does**: Computes the difference between male and female means.
- **The Gap to Discuss in Today's Meeting**:
  - The script currently stores the 95% confidence interval for the **difference** between males and females (`CI_lower` and `CI_upper`).
  - However, the question says: *"Construct 95% confidence intervals for the mean systolic blood pressure of the two gender groups"* (plural).
  - **The fix**: We need to also compute and display the separate 95% confidence intervals for females ($[116.7, 117.3]$) and males ($[129.9, 130.5]$).

---

## 6. Part e: Categorizing Age into 4 Groups (Lines 358–386)

```r
# lines 363-366
body$age_cat <- cut(body$age,
                    breaks = c(-Inf, 30, 40, 50, Inf),
                    labels = c("<30", "30-39", "40-49", "50+"),
                    right = FALSE)
```
- **What this does**: Uses R's `cut()` function to split continuous age into 4 discrete groups:
  - `<30` (ages 21 to 29)
  - `30-39` (ages 30 to 39)
  - `40-49` (ages 40 to 49)
  - `50+` (ages 50 to 64)
  - Setting `right = FALSE` ensures left-closed intervals $[a, b)$, meaning someone who is exactly 30 years old falls into `"30-39"`.

---

## 7. Part f: Chi-Square Tests of Independence (Lines 388–438)

```r
# lines 394-409
tab_class  <- table(body$age_cat, body$class)
tab_gender <- table(body$age_cat, body$gender)
chi_class  <- chisq.test(tab_class)
chi_gender <- chisq.test(tab_gender)
```
- **What this does**:
  1. Creates two contingency tables:
     - `tab_class`: $4 \text{ age groups} \times 4 \text{ performance classes} = 16 \text{ cells}$.
     - `tab_gender`: $4 \text{ age groups} \times 2 \text{ genders} = 8 \text{ cells}$.
  2. Runs Pearson's Chi-Square Test of Independence on both tables.
- **Key Results**:
  - Age vs. Class: $\chi^2 = 724.87, \text{df} = 9, p < 10^{-16}$. Age and performance class are strongly dependent! Older groups have a much higher percentage of people in class D (worst) and very few in class A (best).
  - Age vs. Gender: $\chi^2 = 25.13, \text{df} = 3, p = 1.45 \times 10^{-5}$. Also statistically significant, showing slight differences in gender balance across age brackets.
  - **Cochran's Assumption Check**: Line 418 checks that all expected cell counts are $\ge 5$. The minimum expected count is over 400, so the test is completely reliable.

---

## 8. Part g: Two-Sample t-Tests for Physical Tests (Lines 440+) — CRITICAL GAP

- **Current State**: `Q1.R` ends at line 442 right after Part f. **Part g is completely missing from the script!**
- **What is required**:
  - Run two-sample t-tests comparing males and females across the 4 physical tests:
    1. Grip force (`grip_force`)
    2. Sit-and-bend flexibility (`sit_bend_cm`)
    3. Sit-ups (`sit_ups`)
    4. Standing broad jump (`broad_jump_cm`)
  - Test variance equality with `var.test()` for each variable first to select between Student's t-test and Welch's t-test.
  - Interpret which gender performs better on each test.
- **Ready Proposal**: We have prepared the complete R code and empirical numbers for this missing part in [`q1g-proposed-solution.md`](file:///Users/siminshoeibizadeh/My%20Drive/uni/sem1/uni%20projects/sem1/SMDE/doc/homeworks-overview/question-1/q1g-proposed-solution.md).
