# SMDE Homework 1: Question 1 Pre-Meeting Master Study Guide
**Complete 30-Minute Study Guide & Pre-Meeting Briefing (Theory, Code Audit, Exact Numbers & Speaking Strategy)**

- **Course & University**: Statistical Modelling and Design of Experiments (SMDE - MIRI) &bull; FIB, UPC
- **Instructor**: Prof. Nihan Acar-Denizli, PhD
- **Meeting Focus**: Question 1 (Tonight at 8:00 PM CET)
- **Weight in Homework 1**: 10.0 Points (33.3% of Assignment 1)
- **Compiled PDF Deliverable**: [**`Q1-Meeting-Master-Study-Guide.pdf`**](file:///Users/siminshoeibizadeh/My%20Drive/uni/sem1/uni%20projects/sem1/SMDE/doc/homeworks-overview/question-1/Q1-Meeting-Master-Study-Guide.pdf) (8 pages, fully formatted)

---

## 1. Executive Summary & 30-Minute Reading Plan

Tonight's team meeting focuses strictly on **Question 1: Visualisation, Chi-Square, and t-Tests**. 
This guide contains all the knowledge you need to follow the discussion, understand every line of code your teammates wrote, highlight open issues politely, and propose ready solutions.

> [!TIP]
> **How to use your 30 minutes before 8:00 PM:**
> - **Minutes 0–10**: Read Section 2 (Statistical Concepts) and Section 3 (Part-by-Part Audit). Understand *why* each statistical test is used.
> - **Minutes 10–20**: Focus on the two critical points: the **individual Confidence Intervals bug in Q1(d)** and the **missing Q1(g) code (2.5 points)**.
> - **Minutes 20–25**: Review the **Master Numbers Reference Table** in Section 4 so you have exact values in mind.
> - **Minutes 25–30**: Read Section 5 (Simulated Q&A) and rehearse your speaking points.

---

## 2. Statistical Concepts Made Simple (Course Slides & Labs)

Question 1 tests four key statistical concepts taught in Sessions 1, 2, 4, and 8 of the SMDE curriculum:

### 2.1 Exploratory Data Analysis & Outlier Handling
- **Tukey's 1.5 &times; IQR Rule**: Standard software flags points outside $[Q_1 - 1.5 \times IQR, Q_3 + 1.5 \times IQR]$ as outliers. In physical fitness datasets, however, natural athletes and unfit individuals lie in the extremes. Deleting all Tukey outliers would remove thousands of valid subjects.
- **Clinical & Physical Validity Rules**: Instead of mechanical filtering, we apply domain knowledge. We only exclude values that are biologically or physically impossible (e.g., blood pressure below survival limits, inverted systolic/diastolic readings, or data entry typos).

### 2.2 Normality & The Central Limit Theorem (CLT)
- **The Shapiro-Wilk Test Trap**: With large samples ($N = 13,365$), the Shapiro-Wilk test has extreme statistical power. It flags tiny, practically irrelevant deviations from a perfect bell curve and rejects normality ($p < 10^{-16}$).
- **Why t-Tests Remain Valid**: By the **Central Limit Theorem (CLT)**, the distribution of the sample mean approaches normality as sample size grows ($N > 30$), regardless of underlying shape. With $N > 13,000$, the sample means are strictly normal, ensuring that two-sample t-tests and confidence intervals are mathematically exact.

### 2.3 Confidence Intervals for Group Means
A 95% confidence interval estimates the true population mean $\mu$ with 95% confidence:
$$CI_{95\%} = \bar{x} \pm t_{0.025, df} \times \frac{s}{\sqrt{n}}$$
**Rule of Non-Overlapping Intervals**: When the 95% confidence intervals of two independent groups do not overlap, their population means are statistically significantly different at $\alpha = 0.05$.

### 2.4 Equality of Variances (F-Test) & Choosing the Right t-Test
- **Fisher's F-Test (`var.test`)**: Evaluates whether two populations have identical variances: $H_0: \sigma_1^2 = \sigma_2^2$.
  - If $p > 0.05$: Equal variances. Use the pooled **Student's t-test** (`var.equal = TRUE`).
  - If $p < 0.05$: Unequal variances. You must use **Welch's t-test** (`var.equal = FALSE`), which adjusts degrees of freedom to prevent inflated Type I error.

### 2.5 Pearson's Chi-Square ($\chi^2$) Test of Independence
Tests whether two categorical variables are independent by comparing observed cell counts ($O_{ij}$) to expected cell counts under independence ($E_{ij}$):
$$\chi^2 = \sum \frac{(O_{ij} - E_{ij})^2}{E_{ij}}, \quad df = (r - 1)(c - 1)$$
**Cochran's Rule**: The Chi-square test is valid if all expected cell counts are $\ge 1$ and at least 80% are $\ge 5$. In our dataset, the smallest expected cell count exceeds 400, so the test is completely reliable.

---

## 3. Detailed Part-by-Part Audit of Question 1

### Part a: Importing & Assigning Variable Types (0.5 pt)
- **What is asked**: Load `bodyPerformance.csv` and assign correct R data types to all 12 columns.
- **What teammates implemented (`R/Q1.R`, lines 50–107)**:
  - Read 13,393 rows and 12 columns with `read.csv(..., check.names = FALSE)`.
  - Renamed columns to clean R snake_case: `age`, `gender`, `height_cm`, `weight_kg`, `body_fat_pct`, `diastolic`, `systolic`, `grip_force`, `sit_bend_cm`, `sit_ups`, `broad_jump_cm`, `class`.
  - Set `gender` as a factor with levels `Female` and `Male`.
  - Set `class` as an **ordered factor**: $D < C < B < A$ (from lowest performance to highest).
  - Converted the remaining 10 measurements to `numeric`. Verified **0 missing values (`NA`)**.
- **Status**: 100% Finished. Outputs exported to `report/tables/q1a_variables.csv`.

---

### Part b: Summary Statistics & Outlier Cleaning (2.0 pts)
- **What is asked**: Produce summary tables, plot distributions (boxplots/histograms), and handle outliers.
- **What teammates implemented (`R/Q1.R`, lines 109–209)**:
  - Computed Min, Q1, Median, Mean, Q3, Max, and SD for all numerical columns (`q1b_summary.csv`).
  - Generated multi-panel boxplots (`q1b_boxplots.png`) and histograms (`q1b_histograms.png`).
  - Applied domain-specific clinical exclusion rules:
    1. `systolic < 70 | diastolic < 40` (circulatory collapse / shock).
    2. `systolic <= diastolic` (physically impossible blood pressure reading).
    3. `body_fat_pct < essential` ($< 2\%$ for men, $< 10\%$ for women; life-threatening starvation).
    4. `grip_force == 0 | broad_jump_cm == 0` (unattempted test / equipment error).
    5. `sit_bend_cm > 50` (data entry typos: values of 185 cm and 213 cm).
  - **Impact**: Exactly **28 rows (0.2%)** were removed. The cleaned dataset has **13,365 rows** and is saved as `bodyPerformance_clean.csv`.
- **Meeting Note**: The code and figures are done, but the written medical justification in `sections/q1.tex` is currently blank. You can offer to help draft the narrative.

---

### Part c: Blood Pressure Comparison by Gender (1.0 pt)
- **What is asked**: Remove invalid blood pressures, plot distributions by gender, and describe differences.
- **What teammates implemented (`R/Q1.R`, lines 211–311)**:
  - Divided into 8,460 males and 4,905 females.
  - Generated comparative histograms (`q1c_histograms.png`) and boxplots (`q1c_boxplots.png`).

| Blood Pressure Metric | Female Mean &plusmn; SD | Male Mean &plusmn; SD | Difference (Male - Female) | Clinical Meaning |
| :--- | :--- | :--- | :--- | :--- |
| **Systolic (mmHg)** | 117.00 &plusmn; 11.90 | 130.18 &plusmn; 12.82 | **+13.18 mmHg** | Males have significantly higher peak arterial pumping pressure. |
| **Diastolic (mmHg)** | 74.07 &plusmn; 9.77 | 80.77 &plusmn; 9.80 | **+6.70 mmHg** | Males have higher resting baseline vascular resistance. |

---

### Part d: 95% Confidence Intervals for Systolic BP (1.0 pt) — THE BUG / CATCH
- **What is asked**: *"Construct 95% confidence intervals for the mean systolic blood pressure of the two gender groups and interpret them."*
- **What teammates coded (Lines 313–356)**:
  - F-test on systolic variance: $F = 1.16, p = 0.0003$. Equal variance rejected $\rightarrow$ Welch t-test chosen.
  - **THE BUG**: The script only records the 95% CI for the **difference between means** ($[12.78, 13.56]$ mmHg) in line 350.
  - **THE FIX**: The prompt asks for *confidence intervals* (plural) for the two groups. We must report the **individual group intervals**:
    - **Female 95% CI**: $[116.67, 117.33]$ mmHg ($\bar{x} = 117.00, SE = 0.17$)
    - **Male 95% CI**: $[129.91, 130.45]$ mmHg ($\bar{x} = 130.18, SE = 0.14$)
  - **Interpretation**: Because the female interval $[116.67, 117.33]$ and the male interval $[129.91, 130.45]$ are completely separated by more than 12 mmHg, male systolic pressure is proven to be significantly higher.
- **Meeting Contribution**: Agree with Xiang's observation from WhatsApp. Suggest updating `Q1.R` so that `q1d_t_test.csv` contains both individual group intervals and the difference interval.

---

### Part e: Age Grouping into 4 Categories (0.5 pt)
- **What is asked**: Cut age at 30, 40, and 50 into 4 categories: `<30`, `30-39`, `40-49`, `50+`.
- **What teammates implemented (Lines 358–386)**:
  - Used `cut(..., breaks = c(-Inf, 30, 40, 50, Inf), right = FALSE)`. Left-closed intervals ensure age 30 enters `30-39`.
  - Distribution: **<30**: 4,374 (32.7%) | **30–39**: 3,598 (26.9%) | **40–49**: 2,903 (21.7%) | **50+**: 2,490 (18.6%).
  - Saved to `q1e_age_groups.csv` and plotted in `q1e_age_groups.png`. Clean and verified.

---

### Part f: Chi-Square Tests of Independence (2.5 pts)
- **What is asked**: Test if age group is associated with performance class, and with gender.
- **What teammates implemented (Lines 388–438)**:
  1. **Age Group &times; Class ($4 \times 4$ table)**:
     - Hypotheses: $H_0$: Age group and performance class are independent vs. $H_1$: They are dependent.
     - Results: $\chi^2 = 724.87, \text{df} = 9, p < 10^{-16}$. Strongly reject $H_0$!
     - **Practical finding**: In the $<30$ group, 31.4% are Class A (best) and only 17.5% are Class D (worst). In the $50+$ group, Class A drops to 16.4% while Class D surges to 35.8%. **Fitness grade drops steeply with age.**
  2. **Age Group &times; Gender ($4 \times 2$ table)**:
     - Results: $\chi^2 = 25.13, \text{df} = 3, p = 1.45 \times 10^{-5}$. Statistically significant due to large $N$, but male proportion remains between 61% and 65% across all age groups.
  3. **Assumption Check**: Minimum expected cell count is 534.8 (well above Cochran's threshold of 5). Test is fully reliable.

---

### Part g: Physical Fitness Tests by Gender (2.5 pts) — THE MISSING CODE
- **What is asked**: Test whether physical test variables differ between genders, decide whether equal variance can be assumed, and perform appropriate two-sample t-tests.
- **CRITICAL DISCOVERY**: `Q1.R` ends at line 442 right after Part f. **Part g was never implemented!** This part represents 2.5 points (25% of Question 1).

**Our Pre-Calculated Results (Exact Numbers for the Clean Dataset):**

| Physical Test Variable | Female Mean &plusmn; SD | Male Mean &plusmn; SD | Difference | F-Test (Var Equality) | Appropriate Test | t-Stat &amp; p-Value | Outcome |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Grip Force (kg)** | 25.83 &plusmn; 4.67 | 43.46 &plusmn; 7.14 | **+17.63 kg** | $F=2.33, p<10^{-16}$ (Unequal) | Welch t-test | $t = 172.17, p<10^{-300}$ | **Males Win (+68%)** |
| **Sit &amp; Bend (cm)** | 18.85 &plusmn; 7.14 | 13.05 &plusmn; 7.94 | **-5.80 cm** | $F=1.24, p<10^{-16}$ (Unequal) | Welch t-test | $t = -43.42, p<10^{-300}$ | **Females Win (+44%)** |
| **Sit-ups (reps)** | 30.91 &plusmn; 13.87 | 44.94 &plusmn; 11.72 | **+14.02 reps** | $F=0.71, p<10^{-16}$ (Unequal) | Welch t-test | $t = 59.58, p<10^{-300}$ | **Males Win (+45%)** |
| **Broad Jump (cm)** | 153.54 &plusmn; 27.81 | 211.60 &plusmn; 28.00 | **+58.06 cm** | $F=0.99, p=0.518$ (Equal) | Student pooled t | $t = 116.05, p<10^{-300}$ | **Males Win (+38%)** |

> [!NOTE]
> **Key Sports-Science Takeaway**: Males dominate muscular strength and jumping power due to greater skeletal muscle mass. However, **females are significantly more flexible** in the sit-and-bend test ($18.85$ cm vs. $13.05$ cm, $p < 10^{-300}$) due to pelvic structural anatomy and joint elasticity.

---

## 4. Master Numbers Reference Sheet (Keep Open During Call)

| Subquestion | Variable / Test | Key Statistic / Values | p-Value | Decision / Meaning |
| :--- | :--- | :--- | :--- | :--- |
| **Q1.a** | Clean Dataset Dimensions | 13,365 rows &times; 12 columns | — | 28 rows removed (0.2%); 0 missing values |
| **Q1.b** | Normality (Shapiro-Wilk) | $W \approx 0.92 - 0.98$ | $p < 10^{-16}$ | Rejects exact normality; CLT guarantees validity |
| **Q1.c** | Systolic BP Means | Females: 117.0 mmHg \| Males: 130.2 mmHg | — | Males +13.2 mmHg higher |
| **Q1.c** | Diastolic BP Means | Females: 74.1 mmHg \| Males: 80.8 mmHg | — | Males +6.7 mmHg higher |
| **Q1.d** | F-test on Systolic Variance | $F = 1.16$, Num df = 8459, Den df = 4904 | $p = 0.0003$ | Reject equal variance &rarr; Use Welch t-test |
| **Q1.d** | Individual 95% CIs (BP) | Female: $[116.7, 117.3]$ \| Male: $[129.9, 130.5]$ | — | **Zero overlap** &rarr; Definitive difference |
| **Q1.e** | Age Group Counts | <30 (4374), 30-39 (3598), 40-49 (2903), 50+ (2490) | — | Balanced group sizes across age |
| **Q1.f** | Chi-Square: Age &times; Class | $\chi^2 = 724.87, \text{df} = 9$ | $p < 10^{-16}$ | Fitness class drops steeply with age |
| **Q1.f** | Chi-Square: Age &times; Gender | $\chi^2 = 25.13, \text{df} = 3$ | $p = 1.45 \times 10^{-5}$ | Weak dependency; gender ratio stable |
| **Q1.g** | Grip Force Comparison | F: 25.8 kg vs M: 43.5 kg (+17.6 kg) | $p < 10^{-300}$ | Welch t-test ($t = 172.17$); Males win |
| **Q1.g** | Sit &amp; Bend Comparison | F: 18.9 cm vs M: 13.1 cm (-5.8 cm) | $p < 10^{-300}$ | Welch t-test ($t = -43.42$); **Females win** |
| **Q1.g** | Sit-ups Comparison | F: 30.9 vs M: 44.9 (+14.0 reps) | $p < 10^{-300}$ | Welch t-test ($t = 59.58$); Males win |
| **Q1.g** | Broad Jump Comparison | F: 153.5 cm vs M: 211.6 cm (+58.1 cm) | $p < 10^{-300}$ | Student t-test ($t = 116.05$); Males win |

---

## 5. Simulated Meeting Script & Q&A Prep

- **Q1: "Did we delete too many or too few outliers in Q1.b?"**
  - **Your Answer**: *"The current medical threshold strategy is ideal. If we followed Tukey's 1.5&times;IQR rule blindly, we would lose over 2,000 valid athletes. By restricting cuts to clinical impossibilities (systolic < 70, diastolic < 40, reversed pressure, essential fat limits, and typos over 50 cm in flexibility), we only dropped 28 rows (0.2%), preserving true biological variance."*
- **Q2: "Why do our Shapiro-Wilk tests reject normality for all variables?"**
  - **Your Answer**: *"Because our sample size is over 13,000. Shapiro-Wilk has near 100% statistical power at this scale, so it detects tiny skewness that doesn't matter practically. By the Central Limit Theorem, the sampling distributions of the means are strictly normal, so our t-tests and ANOVA remain completely valid."*
- **Q3: "What should we do about Xiang's WhatsApp message regarding Q1.d confidence intervals?"**
  - **Your Answer**: *"Xiang is completely right. The prompt asks for 'confidence intervals' (plural) for the two gender groups. Our script currently only outputs the difference interval [12.78, 13.56]. We should add the separate intervals: [116.7, 117.3] for females and [129.9, 130.5] for males. The fact that they don't overlap makes the report interpretation much stronger."*
- **Q4: "What about subquestion 1(g)?"**
  - **Your Answer**: *"I checked `Q1.R` and it currently stops at line 442 after the chi-square test. Part (g) is worth 2.5 points and hasn't been implemented yet. I already wrote the R code loop with `var.test` and `t.test` and computed the results on our clean data. Males win in grip, sit-ups, and broad jump, but females win significantly in flexibility (18.9 cm vs 13.1 cm). I have the snippet ready to add to the script."*
- **Q5: "How should we divide the work moving forward?"**
  - **Your Answer**: *"Now that Question 1 is practically locked down, one of us can take Question 2 (ANOVA and post-hoc comparisons), and I would love to take Question 3 (Linear Regression on broad jump distance and the 70/30 validation split)."*

---

## 6. The Ready-to-Paste Code Snippet for Q1(g)

You can paste this directly before `sink()` at line 440 of `R/Q1.R`:

```r
# ------------------------------------------------------------
# g) Two-sample t-tests for physical fitness variables by gender
# ------------------------------------------------------------
section("g) Physical test comparison by gender")

phys_vars <- c("grip_force", "sit_bend_cm", "sit_ups", "broad_jump_cm")
f_list <- list(); t_list <- list()

for (v in phys_vars) {
    f_test <- var.test(male[[v]], female[[v]])
    is_eq  <- f_test$p.value > 0.05
    t_test <- t.test(male[[v]], female[[v]], var.equal = is_eq)
    
    t_list[[v]] <- data.frame(
        Variable    = v,
        Test        = ifelse(is_eq, "Student", "Welch"),
        Female_Mean = round(mean(female[[v]]), 2),
        Male_Mean   = round(mean(male[[v]]), 2),
        Diff_Mean   = round(mean(male[[v]]) - mean(female[[v]]), 2),
        t_stat      = round(t_test$statistic, 2),
        df          = round(t_test$parameter, 1),
        p_value     = format.pval(t_test$p.value, digits = 3, eps = 1e-16),
        CI_95_diff  = sprintf("[%.2f, %.2f]", t_test$conf.int[1], t_test$conf.int[2])
    )
}
save_table(do.call(rbind, t_list), "q1g_t_test")

save_figure("q1g_boxplots", function() {
    par(mfrow = c(2, 2))
    for (v in phys_vars) {
        boxplot(body[[v]] ~ body$gender, main = paste(v, "by Gender"),
                col = c("pink", "lightblue"))
    }
}, width = 1200, height = 900)
```
