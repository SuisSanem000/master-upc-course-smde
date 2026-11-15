# My Assigned Task: Question 2 (ANOVA) Report

This file explains strictly what **you (Simin)** are responsible for in Homework 1. You do **not** need to worry about Question 1 or Question 3, and you do **not** need to write R code because Xiang already pushed the complete `R/Q2.R` script.

---

## 1. Your Exact Deliverable

You are responsible for **writing the Question 2 report in LaTeX**:
1. **`report/sections/q2.tex`**:
   - Write the full analysis and interpretation for Question 2:
     - **Section 2.1 (`\label{sec:q2a}`)**: Distributions of `body_fat_pct`, `diastolic`, `sit_ups`, and `broad_jump_cm` by `age_cat` and by `class`.
     - **Section 2.2 (`\label{sec:q2b}`)**: One-way ANOVA of the 4 variables by `age_cat` and by `class` (8 models), outlier handling, residual assumption checks (Shapiro-Wilk, Q-Q plots, Levene, Breusch-Pagan, Durbin-Watson), and comparison of the 3 post-hoc tests (Tukey HSD, Bonferroni, and LSD).
     - **Section 2.3 (`\label{sec:q2c}`)**: Two-way ANOVA of `sit_ups` and `broad_jump_cm` by `age_cat * gender` (Type II tests, interaction significance, interaction plots, assumption checks, and post-hoc tests by gender).
2. **`report/sections/appendix.tex`**:
   - Add `\subsection{Question 2}` under Appendix A (`Tables`) and Appendix B (`Figures`) so that every `\autoref{tab:q2...}` and `\autoref{fig:q2...}` cited in `q2.tex` compiles cleanly.

---

## 2. Rules Your Report Must Follow (From `report/README.md`)

1. **One sentence per line** in `.tex` files (press Enter after every `.`).
2. **Verbatim task statements**: Each subsection starts with `\task{...}` containing the exact question statement from the assignment PDF.
3. **Variable names in monospace**: Always write R variable names as `\texttt{body\_fat\_pct}`, `\texttt{diastolic}`, `\texttt{sit\_ups}`, `\texttt{broad\_jump\_cm}`, `\texttt{age\_cat}`, `\texttt{class}`, and `\texttt{gender}`. Never use casual words like "blood pressure" or "body fat" in your analysis sentences.
4. **No repeating full tables in text**: Cite the appendix tables (`\autoref{tab:q2...}`) and figures (`\autoref{fig:q2...}`) and state the statistical conclusions and key effect sizes ($\eta^2$).
5. **Formatting units and ranges**: Use `\,` before units (`25.93\,\%`), `--` for ranges (`30--39`), and math mode for negative numbers (`$-19.04$`).
