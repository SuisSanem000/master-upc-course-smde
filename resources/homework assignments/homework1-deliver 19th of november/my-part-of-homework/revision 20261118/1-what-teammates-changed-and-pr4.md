# What Teammates Changed & What PR #4 Is (Nov 15 – Nov 18)

## 1. Updates Already Done on `main` (Homework 1: `SMDE-Labs`)

Right after the November 15 meeting, **Xiang** already applied the general formatting and appendix fixes directly on `main` (latest commit `7653417`):

- **`R/Q1.R` & `report/sections/appendix.tex`:** Converted the remaining Question 1 tables (`q1c_summary`, `q1d_t_test`, `q1g_t_test`) into auto-generated CSV tables (`\csvtable`) and removed the `TODO` comments and unused `grip_force` row in the reference table.
- **Appendix captions (`report/sections/appendix.tex`):** Prefixed all table and figure captions with `a)`, `b)`, `c)`, etc., and shortened two long Question 2 captions (`tab:q2b-posthoc-age` and `tab:q2b-posthoc-class`).
- **`report/refs.bib`:** Cleaned the bibliography file down to the 3 cited references (`clevelandclinic_bp`, `clevelandclinic_bmi`, `ace_bodyfat`).
- **`report/macros.tex`:** Switched `\showtodofalse` and `\showtaskfalse` so draft comments and question prompt boxes are hidden in the final PDF.
- **`report/ociamthesismain.tex`:** Reduced the main font size to `11pt`, set `2.5 cm` page margins (`geometry`), and tightened list/float/paragraph spacing so the report body fits inside the **12-page limit**.

> **Note about Xiang's Nov 16 WhatsApp messages:**
> His messages on November 16 (`"implement the antlr engine"` and `"implementation design in docs/diagrams"`) belong to the separate **`GPSS-simulator`** repository, **not** Homework 1 (`SMDE-Labs`).

---

## 2. Pull Request #4 (`q2` branch) — What Was Asked from You

At `21:52` on November 15, Xiang ran an AI review on each section and opened **PR #4** for you to review and apply if needed:
- **Q1 (Tosia):** `https://github.com/xiangfengyepan/SMDE-Labs/pull/3`
- **Q2 (You):** `https://github.com/xiangfengyepan/SMDE-Labs/pull/4`

All three changes in **PR #4** (`report/sections/q2.tex`, commit `30d6190`) were checked against the generated Question 2 CSV tables (`q2a_summary_age.csv` and `q2c_posthoc.csv`) and are **100% accurate**:

1. **Part (a) (`Shape and spread`):** Notes that `broad_jump_cm` is slightly left-skewed because in `30-39` its median (`213` cm) is `8.62` cm above its mean (`204.38` cm).
2. **Part (b) (`Conclusions`):** Changes *"false positives"* to *"possible false positives"* (more careful statistical wording).
3. **Part (c) (`Interpretation and post-hoc comparisons`):** Fixes the double negative (*"drops by 6.15"* instead of *"drops by -6.15"*) and describes the reversal between `30-39` and `40-49`, where men decline more steeply than women (`6.70` vs `4.26` in `sit_ups`, and `12.10` vs `8.18` cm in `broad_jump_cm`).
