# 2. ANOVA

*(This is a Markdown preview of your compiled Question 2 LaTeX report in [`report/sections/q2.tex`](SMDE-Labs/report/sections/q2.tex) and its Q2 Appendix tables and figures in [`report/sections/appendix.tex`](SMDE-Labs/report/sections/appendix.tex).)*

---

## 2.1 Distributions by Age Group and Performance Class

> **Task:** *Check the distribution of the variables "body fat (%), diastolic blood pressure, number of sit ups in a set time, broad jump distance (cm)" for each age group and for each performance class. Interpret your findings.*

**Data.**
We analyzed the four variables (`body_fat_pct`, `diastolic`, `sit_ups` and `broad_jump_cm`) on the 12,742 observations of the cleaned data set (Section 1.2), grouped by `age_cat` (Section 1.5) and by `class`.

**Distributions by `age_cat`.**
The summary statistics and boxplots across the four levels of `age_cat` are shown in **Table A.1** and **Figure A.1**.
The mean of `body_fat_pct` increases with age, barely changing between `<30` and `30-39` and rising more markedly from age 40 upward (from 21.60% in `<30` to 25.93% in `50+`).
The mean of `diastolic` increases slightly from `<30` (77.47 mmHg) to `40-49` (81.82 mmHg) and remains almost unchanged in `50+`.
Conversely, `sit_ups` decreases steadily across every age group, from a mean of 46.39 in `<30` down to 27.35 in `50+`.
The mean of `broad_jump_cm` is nearly the same in `<30` and `30-39` (around 204 cm), and then drops sharply in `40-49` and `50+` (down to 160.19 cm).

**Distributions by `class`.**
The summary statistics and boxplots across the four levels of `class` (`D` < `C` < `B` < `A`) are shown in **Table A.2** and **Figure A.2**.
As the performance class improves from `D` to `A`, the mean of `body_fat_pct` decreases from 26.88% in `D` to 20.51% in `A`, with the largest drop between `D` and `C`.
The distribution of `diastolic` is nearly identical across all four classes, with its mean changing by less than 2 mmHg between `D` and `A`.
In contrast, both `sit_ups` and `broad_jump_cm` increase steadily from `D` to `A` (from 30.67 to 47.91 for `sit_ups`, and from 176.56 to 203.01 cm for `broad_jump_cm`).

**Shape and spread.**
In every group of both factors, the mean and the median are very close (**Table A.1** and **Table A.2**), indicating approximately symmetric distributions within each group.
The standard deviations are also similar across groups, with the ratio between the largest and smallest group variances remaining below 2 in all cases (**Table A.4**, column `Var_ratio`, at most 1.86 for `sit_ups` by `class`).

---

## 2.2 Effect of Age Group and Performance Class (One-Way ANOVA)

> **Task:** *Analyze whether the variables "diastolic blood pressure", "body fat", "number of sit ups" and "broad jump distance" are affected from age factor (age_cat) and from performance class by using proper method. Eliminate outlying observations if required and test the assumptions of the statistical method by using corresponding tests and plots. Write your conclusions.*

**Outliers.**
We did not remove any additional outlying observations before fitting the models.
Section 1.2 already removed the impossible values and those outside the adult reference ranges, and the remaining extreme points in **Figure A.1** and **Figure A.2** are plausible values.

**One-way ANOVA models.**
To test whether the group means of each variable are equal across the four levels of `age_cat` and of `class` ($H_0: \mu_1 = \mu_2 = \mu_3 = \mu_4$ against $H_1$: at least one mean differs), we fitted the eight one-way ANOVA models (**Table A.3**).
All eight models reject $H_0$ at a 95% confidence level ($p < 10^{-16} < 0.05$ for seven models, and $p = 2.58 \times 10^{-13} < 0.05$ for `diastolic ~ class`).
Because with 12,742 observations even very small differences are statistically significant, we also report $\eta^2 = \mathrm{SSB}/\mathrm{SST}$, the share of the total variability explained by the factor (**Table A.3**, column `Eta_sq`).
By `age_cat`, the factor explains 30.0% of the variability of `sit_ups` and 21.0% of `broad_jump_cm`, but only 6.4% of `body_fat_pct` and 3.2% of `diastolic`.
By `class`, it explains 19.7% of the variability of `sit_ups`, 11.4% of `body_fat_pct` and 6.1% of `broad_jump_cm`, and a negligible 0.5% of `diastolic`.

**Assumptions.**
We checked the assumptions of the eight models on their residuals (**Table A.4** and **Figure A.3**):

1. **Normality of the residuals:** the Shapiro-Wilk test on a random sample of 5,000 residuals rejects normality at a 95% confidence level in all eight models ($p \le 2.87 \times 10^{-10} < 0.05$), but the Q-Q plots follow the normal line closely except in the tails (**Figure A.3**), and with large group sizes ANOVA is robust to mild departures from normality.
2. **Homoscedasticity:** the Levene test rejects equal variances at a 95% confidence level in seven models ($p < 0.05$), except for `diastolic ~ class` ($p = 0.0618 > 0.05$), and the Breusch-Pagan test rejects it in seven models, except for `broad_jump_cm ~ age_cat` ($p = 0.199 > 0.05$). However, the ratio between the largest and smallest group variances is between 1.06 and 1.86 (**Table A.4**, column `Var_ratio`), below the rule-of-thumb threshold of 2 from the course slides, so the heteroscedasticity detected by the tests is small.
3. **Independence of the residuals:** the Durbin-Watson test does not reject the absence of autocorrelation at a 95% confidence level in seven models ($p \ge 0.224 > 0.05$), and barely rejects it in `sit_ups ~ age_cat` ($p = 0.0201 < 0.05$).

**Post-hoc tests.**
Since all eight ANOVA models reject $H_0$, we applied three post-hoc tests to compare the $\binom{4}{2} = 6$ pairs of groups in each model: Tukey HSD, Bonferroni and LSD (**Table A.5** for `age_cat`, **Table A.6** for `class`, and the summary count of significant pairs in **Table A.7**).
Across all models, LSD gives the smallest p-values because it does not adjust for multiple comparisons, Bonferroni gives the largest p-values as the most conservative method, and Tukey HSD lies between the two.

For five of the eight models (`diastolic` and `sit_ups` by `age_cat`, and `body_fat_pct`, `sit_ups` and `broad_jump_cm` by `class`), all three post-hoc tests agree that all 6 pairs of groups differ significantly at a 95% confidence level (**Table A.7**).
For `broad_jump_cm ~ age_cat`, all three tests agree that 5 of the 6 pairs differ significantly, while `30-39` vs `<30` (a difference of 1.23 cm) is not significant in any test ($p \ge 0.139 > 0.05$).
The three post-hoc methods disagree at the $\alpha = 0.05$ threshold in only two small-difference pairs:

- In `body_fat_pct ~ age_cat`, the pair `30-39` vs `<30` (difference 0.36%) is significant according to LSD ($p = 0.0246 < 0.05$), but not according to Tukey HSD ($p = 0.111 > 0.05$) or Bonferroni ($p = 0.148 > 0.05$).
- In `diastolic ~ class`, all three tests find no difference between `B` and `C` (0.08 mmHg, $p \ge 0.745 > 0.05$), while the pair `A` vs `C` ($-0.59$ mmHg) is significant according to LSD ($p = 0.0157 < 0.05$) but not according to Tukey HSD ($p = 0.0741 > 0.05$) or Bonferroni ($p = 0.0941 > 0.05$).

**Conclusions.**
Both `age_cat` and `class` have a statistically significant effect on all four variables, with the largest effects on `sit_ups` and `broad_jump_cm`, a moderate effect on `body_fat_pct`, and a very small effect on `diastolic`.
Controlling for multiple comparisons with Tukey HSD and Bonferroni avoids the false positives of unadjusted LSD on the small differences between `<30` and `30-39` for `body_fat_pct` and between classes `A` and `C` for `diastolic`.

---

## 2.3 Effect of Age and Gender Together (Two-Way ANOVA)

> **Task:** *Analyze the effect of age and gender together on number of sit ups and broad jump distance. Analyze whether the interaction of two term is significant. Interpret your findings.*

**Two-way ANOVA models.**
We fitted the two-way ANOVA models with interaction, `sit_ups ~ age_cat * gender` and `broad_jump_cm ~ age_cat * gender`.
Because the eight `age_cat × gender` groups are unbalanced and the two factors are not independent (Section 1.6), we tested the main effects with Type II F-tests, where each main effect is adjusted for the other (**Table A.8**).

For both `sit_ups` and `broad_jump_cm`, the interaction `age_cat:gender` is statistically significant at a 95% confidence level ($p = 4.17 \times 10^{-15} < 0.05$ for `sit_ups` and $p = 1.99 \times 10^{-6} < 0.05$ for `broad_jump_cm`), alongside the main effects of `age_cat` and `gender` ($p < 10^{-16} < 0.05$ in both models).
However, the partial $\eta^2$ of the interaction is very small (0.5% for `sit_ups` and 0.2% for `broad_jump_cm`), whereas the main effects of `age_cat` (partial $\eta^2$ of 33.9% and 31.7%) and `gender` (26.7% and 57.5%) account for the vast majority of the explained variability.

**Assumptions.**
We checked the assumptions of the two models on their residuals across the eight `age_cat × gender` cells (**Table A.9** and **Figure A.5**):

1. **Normality of the residuals:** the Shapiro-Wilk test rejects normality at a 95% confidence level in both models ($p \le 1.96 \times 10^{-16} < 0.05$), but the Q-Q plots follow the normal line closely except in the tails (**Figure A.5**).
2. **Homoscedasticity:** the Levene and Breusch-Pagan tests reject equal variances at a 95% confidence level in both models ($p \le 2.92 \times 10^{-12} < 0.05$), but the ratio between the largest and smallest cell variances is only 1.43 for `sit_ups` and 1.41 for `broad_jump_cm` (**Table A.9**, column `Var_ratio`), well below 2.
3. **Independence of the residuals:** the Durbin-Watson test does not reject the absence of autocorrelation for `broad_jump_cm` ($p = 0.854 > 0.05$) and barely rejects it for `sit_ups` ($p = 0.0461 < 0.05$).

**Interpretation and post-hoc comparisons.**
Because the interaction is significant, we examined the effect of `age_cat` separately within each level of `gender` using the interaction plots (**Figure A.4**) and one-way post-hoc comparisons per gender (**Table A.10**).
In every age group, men have higher means than women in both `sit_ups` and `broad_jump_cm`, and both variables decrease with age in each gender (**Figure A.4**).
Within each gender, all 6 pairs of age groups differ significantly at a 95% confidence level according to Tukey HSD, Bonferroni and LSD for both `sit_ups` and `broad_jump_cm` (**Table A.10**).

The interaction appears primarily between `<30` and `30-39`, where the lines in **Figure A.4** are less parallel because the decline from `<30` to `30-39` is steeper for women than for men.
Specifically, from `<30` to `30-39`, the mean of `sit_ups` drops by $-6.15$ in women against $-2.62$ in men, and the mean of `broad_jump_cm` drops by $-8.55$ cm in women against only $-2.59$ cm in men (**Table A.10**).
After age 40, the lines of both genders decrease with similar slopes down to `50+`.

---

# Appendix — Question 2 Tables & Figures

### Table A.1 — Summary statistics by `age_cat` (`q2a_summary_age.csv`)

| Variable | Group | n | Mean | SD | Median |
| --- | --- | --- | --- | --- | --- |
| body_fat_pct | <30 | 5485 | 21.6 | 6.9 | 21.3 |
| body_fat_pct | 30-39 | 2551 | 21.96 | 6.19 | 21.5 |
| body_fat_pct | 40-49 | 1782 | 23.57 | 6.44 | 23.4 |
| body_fat_pct | 50+ | 2924 | 25.93 | 6.83 | 25.45 |
| diastolic | <30 | 5485 | 77.47 | 9.46 | 77 |
| diastolic | 30-39 | 2551 | 80.19 | 9.81 | 80 |
| diastolic | 40-49 | 1782 | 81.82 | 10.1 | 82 |
| diastolic | 50+ | 2924 | 81.02 | 9.85 | 81 |
| sit_ups | <30 | 5485 | 46.39 | 11.29 | 48 |
| sit_ups | 30-39 | 2551 | 43.96 | 11.9 | 45 |
| sit_ups | 40-49 | 1782 | 36.66 | 11.92 | 37 |
| sit_ups | 50+ | 2924 | 27.35 | 12.21 | 28 |
| broad_jump_cm | <30 | 5485 | 203.15 | 35.07 | 206 |
| broad_jump_cm | 30-39 | 2551 | 204.38 | 34.1 | 213 |
| broad_jump_cm | 40-49 | 1782 | 187.65 | 34.18 | 194 |
| broad_jump_cm | 50+ | 2924 | 160.19 | 34.55 | 162 |

### Table A.2 — Summary statistics by `class` (`q2a_summary_class.csv`)

| Variable | Group | n | Mean | SD | Median |
| --- | --- | --- | --- | --- | --- |
| body_fat_pct | D | 3048 | 26.88 | 6.82 | 26.9 |
| body_fat_pct | C | 3233 | 22.6 | 6.24 | 22.2 |
| body_fat_pct | B | 3239 | 22 | 6.61 | 21.6 |
| body_fat_pct | A | 3222 | 20.51 | 6.36 | 20.2 |
| diastolic | D | 3048 | 80.57 | 10.1 | 80 |
| diastolic | C | 3233 | 79.25 | 9.74 | 79 |
| diastolic | B | 3239 | 79.33 | 9.81 | 79 |
| diastolic | A | 3222 | 78.66 | 9.74 | 78 |
| sit_ups | D | 3048 | 30.67 | 14.78 | 31 |
| sit_ups | C | 3233 | 38.92 | 12.63 | 40 |
| sit_ups | B | 3239 | 42.67 | 11.74 | 44 |
| sit_ups | A | 3222 | 47.91 | 10.83 | 49 |
| broad_jump_cm | D | 3048 | 176.56 | 40.29 | 182 |
| broad_jump_cm | C | 3233 | 189.56 | 38.44 | 195 |
| broad_jump_cm | B | 3239 | 195.54 | 36.35 | 200 |
| broad_jump_cm | A | 3222 | 203.01 | 35.97 | 203 |

### Figure A.1 — Boxplots by `age_cat`
![Boxplots by age_cat](SMDE-Labs/report/figures/q2a_boxplots_age.png)

### Figure A.2 — Boxplots by `class`
![Boxplots by class](SMDE-Labs/report/figures/q2a_boxplots_class.png)

---

### Table A.3 — One-way ANOVA models (`q2b_anova.csv`)

| Variable | Factor | Df | F | p_value | Eta_sq |
| --- | --- | --- | --- | --- | --- |
| body_fat_pct | age_cat | 3 | 291.8 | < 1e-16 | 0.064 |
| diastolic | age_cat | 3 | 141.5 | < 1e-16 | 0.032 |
| sit_ups | age_cat | 3 | 1823.9 | < 1e-16 | 0.3 |
| broad_jump_cm | age_cat | 3 | 1128.7 | < 1e-16 | 0.21 |
| body_fat_pct | class | 3 | 547.6 | < 1e-16 | 0.114 |
| diastolic | class | 3 | 20.6 | 2.58e-13 | 0.005 |
| sit_ups | class | 3 | 1044.2 | < 1e-16 | 0.197 |
| broad_jump_cm | class | 3 | 274 | < 1e-16 | 0.061 |

### Table A.4 — One-way ANOVA assumption checks (`q2b_assumptions.csv`)

| Variable | Factor | Shapiro_p | Levene_p | BP_p | DW_p | Var_ratio |
| --- | --- | --- | --- | --- | --- | --- |
| body_fat_pct | age_cat | 9.43e-14 | < 1e-16 | 2.35e-12 | 0.79 | 1.24 |
| diastolic | age_cat | < 1e-16 | 0.000315 | 8.47e-05 | 0.618 | 1.14 |
| sit_ups | age_cat | < 1e-16 | 4e-07 | 3.44e-05 | 0.0201 | 1.17 |
| broad_jump_cm | age_cat | < 1e-16 | 0.000111 | 0.199 | 0.454 | 1.06 |
| body_fat_pct | class | 2.87e-10 | 1.71e-08 | 6.59e-08 | 0.522 | 1.19 |
| diastolic | class | < 1e-16 | 0.0618 | 0.0359 | 0.481 | 1.07 |
| sit_ups | class | < 1e-16 | < 1e-16 | < 1e-16 | 0.325 | 1.86 |
| broad_jump_cm | class | < 1e-16 | 1.44e-05 | 7.98e-16 | 0.224 | 1.25 |

### Table A.5 — Post-hoc comparisons by `age_cat` (`q2b_posthoc_age.csv`)

| Variable | Pair | Diff | Tukey_p | Bonferroni_p | LSD_p |
| --- | --- | --- | --- | --- | --- |
| body_fat_pct | 30-39 vs <30 | 0.36 | 0.11070 | 0.14772 | 0.02462 |
| body_fat_pct | 40-49 vs <30 | 1.97 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | 50+ vs <30 | 4.33 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | 40-49 vs 30-39 | 1.61 | < 1e-7 | 3.87e-14 | 6.46e-15 |
| body_fat_pct | 50+ vs 30-39 | 3.97 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | 50+ vs 40-49 | 2.36 | < 1e-7 | < 1e-16 | < 1e-16 |
| diastolic | 30-39 vs <30 | 2.72 | < 1e-7 | < 1e-16 | < 1e-16 |
| diastolic | 40-49 vs <30 | 4.34 | < 1e-7 | < 1e-16 | < 1e-16 |
| diastolic | 50+ vs <30 | 3.55 | < 1e-7 | < 1e-16 | < 1e-16 |
| diastolic | 40-49 vs 30-39 | 1.62 | 3.81e-07 | 3.82e-07 | 6.37e-08 |
| diastolic | 50+ vs 30-39 | 0.83 | 0.00886 | 0.00979 | 0.00163 |
| diastolic | 50+ vs 40-49 | -0.79 | 0.03324 | 0.03940 | 0.00657 |
| sit_ups | 30-39 vs <30 | -2.43 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | 40-49 vs <30 | -9.73 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | 50+ vs <30 | -19.04 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | 40-49 vs 30-39 | -7.3 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | 50+ vs 30-39 | -16.61 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | 50+ vs 40-49 | -9.31 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | 30-39 vs <30 | 1.23 | 0.44979 | 0.83376 | 0.13896 |
| broad_jump_cm | 40-49 vs <30 | -15.51 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | 50+ vs <30 | -42.97 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | 40-49 vs 30-39 | -16.74 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | 50+ vs 30-39 | -44.2 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | 50+ vs 40-49 | -27.46 | < 1e-7 | < 1e-16 | < 1e-16 |

### Table A.6 — Post-hoc comparisons by `class` (`q2b_posthoc_class.csv`)

| Variable | Pair | Diff | Tukey_p | Bonferroni_p | LSD_p |
| --- | --- | --- | --- | --- | --- |
| body_fat_pct | C vs D | -4.28 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | B vs D | -4.88 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | A vs D | -6.37 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | B vs C | -0.6 | 0.00123 | 0.00129 | 0.000214 |
| body_fat_pct | A vs C | -2.09 | < 1e-7 | < 1e-16 | < 1e-16 |
| body_fat_pct | A vs B | -1.49 | < 1e-7 | < 1e-16 | < 1e-16 |
| diastolic | C vs D | -1.32 | 7.24e-07 | 7.27e-07 | 1.21e-07 |
| diastolic | B vs D | -1.24 | 3.90e-06 | 3.92e-06 | 6.53e-07 |
| diastolic | A vs D | -1.91 | < 1e-7 | 1.10e-13 | 1.83e-14 |
| diastolic | B vs C | 0.08 | 0.98818 | 1.00000 | 0.745444 |
| diastolic | A vs C | -0.59 | 0.07405 | 0.09414 | 0.015690 |
| diastolic | A vs B | -0.67 | 0.03111 | 0.03671 | 0.006118 |
| sit_ups | C vs D | 8.25 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | B vs D | 12 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | A vs D | 17.24 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | B vs C | 3.75 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | A vs C | 8.99 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | A vs B | 5.24 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | C vs D | 13.01 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | B vs D | 18.98 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | A vs D | 26.45 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | B vs C | 5.98 | < 1e-7 | 1.22e-09 | 2.03e-10 |
| broad_jump_cm | A vs C | 13.44 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | A vs B | 7.47 | < 1e-7 | 1.23e-14 | 2.04e-15 |

### Table A.7 — Significant pairs count (out of 6) (`q2b_posthoc_summary.csv`)

| Variable | Factor | Tukey | Bonferroni | LSD |
| --- | --- | --- | --- | --- |
| body_fat_pct | age_cat | 5 | 5 | 6 |
| broad_jump_cm | age_cat | 5 | 5 | 5 |
| diastolic | age_cat | 6 | 6 | 6 |
| sit_ups | age_cat | 6 | 6 | 6 |
| body_fat_pct | class | 6 | 6 | 6 |
| broad_jump_cm | class | 6 | 6 | 6 |
| diastolic | class | 4 | 4 | 5 |
| sit_ups | class | 6 | 6 | 6 |

### Figure A.3 — Normal Q-Q plots of the one-way ANOVA models
![One-way ANOVA Q-Q plots](SMDE-Labs/report/figures/q2b_qqplots.png)

---

### Table A.8 — Type II two-way ANOVA models (`q2c_anova.csv`)

| Variable | Term | Df | F | p_value | Eta_sq_partial |
| --- | --- | --- | --- | --- | --- |
| sit_ups | age_cat | 3 | 2178 | < 1e-16 | 0.339 |
| sit_ups | gender | 1 | 4644.6 | < 1e-16 | 0.267 |
| sit_ups | age_cat:gender | 3 | 23.4 | 4.17e-15 | 0.005 |
| broad_jump_cm | age_cat | 3 | 1973.2 | < 1e-16 | 0.317 |
| broad_jump_cm | gender | 1 | 17231.9 | < 1e-16 | 0.575 |
| broad_jump_cm | age_cat:gender | 3 | 9.8 | 1.99e-06 | 0.002 |

### Table A.9 — Two-way ANOVA assumption checks (`q2c_assumptions.csv`)

| Variable | Shapiro_p | Levene_p | BP_p | DW_p | Var_ratio |
| --- | --- | --- | --- | --- | --- |
| sit_ups | 1.96e-16 | < 1e-16 | 2.68e-16 | 0.0461 | 1.43 |
| broad_jump_cm | < 1e-16 | 6.29e-16 | 2.92e-12 | 0.854 | 1.41 |

### Table A.10 — One-way post-hoc comparisons of `age_cat` within each `gender` (`q2c_posthoc.csv`)

| Variable | Gender | Pair | Diff | Tukey_p | Bonferroni_p | LSD_p |
| --- | --- | --- | --- | --- | --- | --- |
| sit_ups | Female | 30-39 vs <30 | -6.15 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Female | 40-49 vs <30 | -10.41 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Female | 50+ vs <30 | -19.97 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Female | 40-49 vs 30-39 | -4.26 | < 1e-7 | 8.86e-12 | 1.48e-12 |
| sit_ups | Female | 50+ vs 30-39 | -13.82 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Female | 50+ vs 40-49 | -9.56 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 30-39 vs <30 | -2.62 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 40-49 vs <30 | -9.32 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 50+ vs <30 | -16.75 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 40-49 vs 30-39 | -6.7 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 50+ vs 30-39 | -14.13 | < 1e-7 | < 1e-16 | < 1e-16 |
| sit_ups | Male | 50+ vs 40-49 | -7.43 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Female | 30-39 vs <30 | -8.55 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Female | 40-49 vs <30 | -16.73 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Female | 50+ vs <30 | -38.54 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Female | 40-49 vs 30-39 | -8.18 | < 1e-7 | 1.08e-10 | 1.81e-11 |
| broad_jump_cm | Female | 50+ vs 30-39 | -30 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Female | 50+ vs 40-49 | -21.81 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Male | 30-39 vs <30 | -2.59 | 0.000429 | 0.000443 | 7.39e-05 |
| broad_jump_cm | Male | 40-49 vs <30 | -14.69 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Male | 50+ vs <30 | -38.88 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Male | 40-49 vs 30-39 | -12.1 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Male | 50+ vs 30-39 | -36.28 | < 1e-7 | < 1e-16 | < 1e-16 |
| broad_jump_cm | Male | 50+ vs 40-49 | -24.19 | < 1e-7 | < 1e-16 | < 1e-16 |

### Figure A.4 — Interaction plots (`age_cat * gender`)
![Interaction plots](SMDE-Labs/report/figures/q2c_interaction.png)

### Figure A.5 — Normal Q-Q plots of the two-way ANOVA models
![Two-way ANOVA Q-Q plots](SMDE-Labs/report/figures/q2c_qqplots.png)
