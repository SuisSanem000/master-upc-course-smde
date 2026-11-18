# What I Did for Question 2 (Short Summary)

If your teammates ask what you did to prepare the Question 2 report, you can share this short list:

- **Ran the R scripts (`R/Q1.R` and `R/Q2.R`)** to generate the cleaned dataset (`12,742` rows), the console log (`R/logs/Q2.log`), and all **10 tables** and **5 plots** for Question 2.
- **Reviewed all Q2 outputs** (summary tables, ANOVA tables, assumption tests, post-hoc tables, boxplots, Q-Q plots, and interaction plots) and verified every number against the logs and CSV files.
- **Wrote the Question 2 report in [`report/sections/q2.tex`](SMDE-Labs/report/sections/q2.tex)** covering parts **(a)**, **(b)**, and **(c)**, matching the team's LaTeX conventions (`one sentence per line`, `\texttt{}` for variable names, and citing appendix tables/figures).
- **Updated [`report/sections/appendix.tex`](SMDE-Labs/report/sections/appendix.tex)** by adding `\subsection{Question 2}` with all 10 Q2 tables and 5 Q2 figures so every `\autoref{...}` link compiles cleanly.
- **Tested the full LaTeX build** (`ociamthesismain.tex`) to make sure there are no missing references or compilation errors, and pushed only `report/sections/q2.tex` and `report/sections/appendix.tex` to `main`.

---

## What Is Inside the Q2 Report?

The Question 2 section (`\section{ANOVA}`) has three subsections matching the three parts of the assignment on the **12,742** cleaned records:

1. **Part (a) — Distributions by Age Group and Performance Class (`\subsection{Distributions by Age Group and Performance Class}`)**:
   - Compares four fitness/body measurements (`body_fat_pct`, `diastolic`, `sit_ups`, `broad_jump_cm`) across 4 age groups (`<30`, `30-39`, `40-49`, `50+`) and 4 performance classes (`D`, `C`, `B`, `A`).
   - Shows that `sit_ups` and `broad_jump_cm` drop strongly with age and rise from `D` to `A`; `body_fat_pct` rises with age and drops from `D` to `A`; `diastolic` barely changes; and group distributions are symmetric with variance ratios below 2.
2. **Part (b) — One-Way ANOVA & Post-Hoc Tests (`\subsection{Effect of Age Group and Performance Class (One-Way ANOVA)}`)**:
   - Explains why no extra outliers were removed (Q1 already cleaned impossible/unhealthy values).
   - Reports 8 one-way ANOVA models (all significant, $p < 10^{-12}$), using $\eta^2$ to show which effects are strong (`sit_ups` and `broad_jump_cm` by `age_cat`) vs. negligible (`diastolic ~ class`, 0.5%).
   - Checks normality (Shapiro-Wilk + Q-Q plots), equal variances (Levene, Breusch-Pagan, and variance ratio $< 2$), and independence (Durbin-Watson).
   - Compares **Tukey HSD**, **Bonferroni**, and **Fisher's LSD** across all 6 group pairs in each model, highlighting the two small-difference pairs where unadjusted LSD disagrees with Tukey and Bonferroni (`body_fat_pct ~ age_cat` for `30-39 vs <30`, and `diastolic ~ class` for `A vs C`).
3. **Part (c) — Two-Way ANOVA (`\subsection{Effect of Age and Gender Together (Two-Way ANOVA)}`)**:
   - Tests `age_cat * gender` on `sit_ups` and `broad_jump_cm` using Type II F-tests (because groups are unbalanced).
   - Shows that the interaction `age_cat:gender` is statistically significant ($p < 0.05$) with a tiny effect size ($\le 0.5\%$), checks assumptions across the 8 `age_cat x gender` groups, and explains that the interaction happens mainly between `<30` and `30-39`, where women drop more than men.

---

## How We Wrote the Report

1. **Followed the exact template & style of `q3.tex` and `report/README.md`**:
   - Kept the `\task{...}` prompt box under each subsection, organized each part with `\paragraph{...}` headings, wrote **one sentence per line**, used `\texttt{}` for R variable names, and cited every table and figure with `\autoref{...}`.
2. **Filled every claim directly from `R/Q2.R` outputs**:
   - Used only the exact numbers from `R/logs/Q2.log` and the 10 CSV tables in `report/tables/q2*.csv`, matching the 5 PNG plots in `report/figures/q2*.png`.
3. **Wired all Q2 tables and figures into `report/sections/appendix.tex`**:
   - Added `\subsection{Question 2}` with all 10 `\csvtable` entries and 5 `\begin{figure}` entries so every `\autoref{...}` in `q2.tex` links cleanly to the appendix.
