# Simple Summary & Answers (Nov 18 Revision)

## 1. What Is This Change? (In Simple Words)

Only **4 lines** in one file (**`report/sections/q2.tex`**) were updated — and nothing else:

1. **Part (a) — Slight Skew in Broad Jump (`line 31`):**
   - Earlier we wrote that the mean and median were close in *every* group.
   - Actually, for `broad_jump_cm` in age `30-39`, the median (`213` cm) is `8.62` cm higher than the mean (`204.38` cm), so the text now notes this **slight left skew** (`In most groups ... except for broad_jump_cm...`).
2. **Part (b) — More Careful Wording (`line 77`):**
   - Changed *"avoids the false positives of unadjusted LSD"* to *"avoids the **possible** false positives of unadjusted LSD"*, because in statistics we say a test *may* produce false positives rather than claiming it with 100% certainty.
3. **Part (c) — Clearer Numbers & Complete Age Pattern (`lines 109–110`):**
   - Fixed a double negative: wrote *"drops by `6.15`"* (and `2.62`, `8.55`, `2.59`) instead of *"drops by `-6.15`"*.
   - Added what happens next from `30-39` to `40-49`: here men actually drop faster than women (`6.70` vs `4.26` in `sit_ups` and `12.10` vs `8.18` cm in `broad_jump_cm`), before both genders decline at similar speeds into `50+`.

---

## 2. Did I Add Any `TODO` Comments?

**No.** I did **not** add any `TODO` comments inside your teammates' `.tex` files or in `q2.tex`, because:
- Xiang already hid all comments and task prompts (`\showtodofalse` and `\showtaskfalse` in `report/macros.tex`, and removed old `TODO`s on `main` in commit `7653417`).
- Both Xiang and Tosia asked in today's WhatsApp chat (`13:57–13:59`) to **text them any feedback in WhatsApp** rather than editing or adding comments inside their files.

---

## 3. What Was Found After Reviewing Everything?

- **Question 2 (`report/sections/q2.tex`):** All numbers, table links, and plot references are 100% verified against `R/Q2.R` outputs and the 10 Q2 tables / 5 Q2 plots.
- **Appendix (`report/sections/appendix.tex`):** All Q2 tables and figures are already cleanly formatted and wired (`a)`, `b)`, `c)` captions updated by Xiang on `main`).
- **Question 1 (`report/sections/q1.tex`):** Leftover `TODO` comments and updated numbers from `R/Q1.R` are already handled in Tosia's open **PR #3** (`origin/q1`, commit `242dde6`), which she said she is reviewing today.
- **Question 3 (`report/sections/q3.tex`):** Checked against `R/Q3.R` outputs — all numbers and conclusions match cleanly (only a small formatting note: `tab:q3d-comparison` is shown inline in Section 3.4 while other tables are in Appendix A, which is completely fine since the body fits in 11 pages).
- **Full PDF Build (`ociamthesismain.pdf`):** Compiles cleanly with **0 errors**, **0 undefined references**, and **11 pages** of main body text (under the 12-page limit).

---

## 4. What You Need to Push for Your Teammates

**Yes — you only need to deliver this single updated file: [`SMDE-Labs/report/sections/q2.tex`](../SMDE-Labs/report/sections/q2.tex).**

You can do it in either of two ways:
1. **From your local `SMDE-Labs` repo:** `git pull` latest `main`, copy `my-part-of-homework/SMDE-Labs/report/sections/q2.tex` into `SMDE-Labs/report/sections/q2.tex`, then commit and push **only `report/sections/q2.tex`**.
2. **Or on GitHub:** Open `https://github.com/xiangfengyepan/SMDE-Labs/pull/4` and click **Merge pull request** (it contains these exact same 4-line edits).
