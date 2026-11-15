# SMDE Homework 1 — General Overview

This document explains Homework Assignment 1 in simple, clear Upper B2 English.

---

## 1. What is Homework 1?

- **Course**: Statistical Modelling and Design of Experiments (SMDE), UPC-FIB.
- **Weight**: 40% of the final course grade.
- **Deadline**: Thursday, November 19, 2026, at 23:59 CET.
- **Dataset**: `bodyPerformance.csv` (13,393 original rows, 12 columns; 12,742 rows after cleaning in Question 1b).
- **Page Limit**: Maximum **12 pages** for the main report body (from Section 1 to the end of Section 3). The title page, table of contents, appendix, and references do not count toward the 12-page limit.

---

## 2. The Three Questions in Homework 1

| Question | Topic | Weight | Assigned Team Member |
| :--- | :--- | :--- | :--- |
| **Question 1** | Visualisation, Chi-Square, and t-Test | 50% of HW1 | **Tosia** (Code + Report) |
| **Question 2** | Analysis of Variance (ANOVA) | 25% of HW1 | **Xiang** (R Code) + **Simin** (Report & Analysis) |
| **Question 3** | Simple & Multiple Linear Regression | 25% of HW1 | **Xiang** (Code + Report) |

---

## 3. Repository Structure (`SMDE-Labs`)

- **`R/Q1.R`, `R/Q2.R`, `R/Q3.R`**: One R script per question. Running them generates:
  - Console logs in `R/logs/Q1.log`, `Q2.log`, `Q3.log`
  - Result tables in `report/tables/q*.csv`
  - Figures in `report/figures/q*.png`
- **`report/`**: The LaTeX report folder:
  - `ociamthesismain.tex`: Main LaTeX file.
  - `sections/q1.tex`, `sections/q2.tex`, `sections/q3.tex`: One section file per question.
  - `sections/appendix.tex`: Appendix A (Tables), Appendix B (Figures), and Appendix C (R Code and Outputs).
  - `README.md`: Strict writing rules for the LaTeX report.
