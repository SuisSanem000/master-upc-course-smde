# My Q2 Revisions, Meeting Summary & How to Deliver (Nov 18)

## 1. Exact Changes Applied in `report/sections/q2.tex`

Only **1 file** was changed in `my-part-of-homework/SMDE-Labs/`: **`report/sections/q2.tex`** (matching the verified fixes from PR #4).

### Change 1 — Part (a): Shape and spread (line 31)
- **Before:**
  > In every group of both factors, the mean and the median are very close (...), indicating approximately symmetric distributions within each group.
- **After:**
  > In most groups the mean and the median are close (...), indicating approximately symmetric distributions, except for `broad_jump_cm`, whose median is up to 8.62 cm above the mean (`30-39`), a slight left skew.
- **Why (verified in `q2a_summary_age.csv`):** For `broad_jump_cm` in `<30` and `30-39`, the median (`206` and `213` cm) is noticeably higher than the mean (`203.15` and `204.38` cm; difference `213 - 204.38 = 8.62` cm), which shows a slight left skew rather than perfect symmetry.

### Change 2 — Part (b): Conclusions (line 77)
- **Before:**
  > ... avoids the false positives of unadjusted LSD ...
- **After:**
  > ... avoids the possible false positives of unadjusted LSD ...
- **Why:** Because we do not know the true population difference with certainty, *"possible false positives"* is the accurate statistical phrasing.

### Change 3 — Part (c): Interpretation and post-hoc comparisons (lines 109–110)
- **Before:**
  > Specifically, from `<30` to `30-39`, the mean of `sit_ups` drops by `-6.15` in women against `-2.62` in men, and the mean of `broad_jump_cm` drops by `-8.55` cm in women against only `-2.59` cm in men (...). After age 40, the lines of both genders decrease with similar slopes down to `50+`.
- **After:**
  > Specifically, from `<30` to `30-39`, the mean of `sit_ups` drops by `6.15` in women against `2.62` in men, and the mean of `broad_jump_cm` drops by `8.55` cm in women against only `2.59` cm in men (...). From `30-39` to `40-49` the pattern reverses, with a steeper decline for men (`6.70` against `4.26` in `sit_ups` and `12.10` against `8.18` cm in `broad_jump_cm`), while from `40-49` to `50+` the lines of both genders decrease with similar slopes.
- **Why (verified in `q2c_posthoc.csv`):**
  1. Saying *"drops by -6.15"* is a double negative (a positive number after *"drops by"* is clearer).
  2. In `q2c_posthoc.csv`, the `40-49 vs 30-39` difference is indeed steeper for men than women in both `sit_ups` (`-6.7` vs `-4.26`) and `broad_jump_cm` (`-12.1` vs `-8.18` cm), before both genders drop with similar slopes into `50+`.

---

## 2. What to Tell Your Teammates in Tonight's 9:00 PM Meeting

> *"I checked the `main` updates (the compact 12-page layout, hidden comments/tasks, and updated appendix captions) and reviewed PR #4 for Q2. I verified all three points against the R tables: the slight left skew in `broad_jump_cm` (median 8.62 cm above mean in `30-39`), the softer wording ('possible false positives'), and removing the double negatives plus adding the `30-39` to `40-49` slope reversal between men and women. Everything in Q2 is checked and ready to merge, and the compiled PDF builds cleanly within the 12-page limit."*

---

## 3. Two Easy Ways to Deliver This to Your Team's GitHub Repo

Since only `report/sections/q2.tex` changed and those exact edits are already in PR #4:

- **Option A — Merge PR #4 directly on GitHub (1 click):**
  1. Open `https://github.com/xiangfengyepan/SMDE-Labs/pull/4`.
  2. Click **Merge pull request** → **Confirm merge**.

- **Option B — Copy, commit, and push from your local `SMDE-Labs` repo:**
  1. Copy `my-part-of-homework/SMDE-Labs/report/sections/q2.tex` over `report/sections/q2.tex` in your local `SMDE-Labs` repo.
  2. Pull latest `main`, then commit and push `report/sections/q2.tex`.
