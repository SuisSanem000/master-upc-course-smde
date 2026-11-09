# 8:00 PM Team Meeting Cheat Sheet — November 9, 2026

Use this 1-page cheat sheet during your online meeting at 8:00 PM. It gives you the exact numbers from the team's code, answers to likely questions, and questions you can ask your teammates.

---

## 1. Quick Facts & Exact Numbers (Quote These to Sound Prepared!)

| Question / Metric | Exact Number from `R/logs/Q1.log` | What it Means in Real Words |
| :--- | :--- | :--- |
| **Data Cleaning (Q1.b)** | **28 rows removed** (leaving 13,365 rows) | We only removed medically impossible rows (systolic $< 70$, diastolic $< 40$, inverted BP, body fat $< 2\%$, unperformed tests with 0). |
| **Systolic BP Means (Q1.c)** | **Female: 124.02 mmHg**<br>**Male: 133.90 mmHg** | Men have an average systolic blood pressure that is about 10 mmHg higher than women. |
| **Diastolic BP Means (Q1.c)** | **Female: 75.61 mmHg**<br>**Male: 80.69 mmHg** | Men have an average diastolic blood pressure about 5 mmHg higher than women. |
| **Systolic F-Test (Q1.d)** | $F = 0.875, \; p = 1.26 \times 10^{-7}$ | Variances are **unequal** ($p < 0.05$), so we must use **Welch's t-test**. |
| **Diastolic F-Test (Q1.d)** | $F = 0.962, \; p = 0.130$ | Variances are **equal** ($p > 0.05$), so Student's t-test is appropriate. |
| **95% CIs for Systolic (Q1.d)** | **Female CI: [123.62, 124.42]**<br>**Male CI: [133.61, 134.19]** | **They do not overlap at all!** This proves there is a true, statistically significant difference between men and women. |
| **Age Groups (Q1.e)** | `<30`: 43.3%, `30-39`: 19.9%, `40-49`: 13.9%, `50+`: 22.9% | Well-balanced cohorts across all 4 age categories. |
| **Chi-Square Age vs. Class (Q1.f)** | $\chi^2 = 124.79, \; df = 9, \; p < 10^{-16}$ | Very strong relationship: performance class drops noticeably as age increases. |
| **Question 1(g) Status** | **0% coded in `Q1.R`** | Completely missing. Worth 2.5 points (25% of Q1). |

---

## 2. Likely Questions from Teammates & Your Answers

### Q1: "Simin, did you check the data cleaning in Q1.b?"
> **Your Answer**: *"Yes! I think removing the 28 impossible records was the right choice. Instead of blindly dropping all points outside the boxplot whiskers, using medical rules (like blood pressure below 70/40 and body fat below essential limits) dropped only 0.2% of the data while keeping real athletic variation."*

### Q2: "What do you think about Xiang's WhatsApp message regarding Q1.d (confidence intervals)?"
> **Your Answer**: *"I completely agree with Xiang. The assignment prompt says 'Construct 95% confidence intervals' in plural. Currently, `Q1.R` gives the confidence interval for the difference between the two means [9.38, 10.37]. We should add the separate intervals: [123.62, 124.42] for women and [133.61, 134.19] for men, and point out that because they don't overlap, the difference is statistically significant."*

### Q3: "Did you notice any missing parts in Question 1?"
> **Your Answer**: *"Yes, I noticed that subquestion 1(g) is completely missing from `Q1.R` right now. It is worth 2.5 points. We need to run two-sample t-tests on the four fitness tests (grip force, sit and bend, sit-ups, and broad jump) across gender, check equal variances with F-tests, and generate a 4-panel boxplot."*

### Q4: "How should we split the work for Questions 2 and 3?"
> **Your Answer**: *"Since Question 1 is almost done and Question 2 is ANOVA, I would love to take on Question 3 (Linear Regression to predict broad jump). I reviewed the lab materials from Session 10 and Session 12 (screening numerical variables, fitting the simple and multiple regression models, adding age and gender dummy variables, and validating with a 70/30 train/test split). I can start drafting that once we wrap up Q1."*

---

## 3. Two Smart Questions You Can Ask in the Meeting

1. **On the 12-Page Limit and Report Structure**:
   > *"In the LaTeX template right now, all tables and figures are in the appendix. But Prof. Nihan's instructions say: 'The report should maximum consists of 12 pages... The tables and figures in the body of the text should be numbered and titled.' Should we move the main summary tables and multi-panel figures directly into the text body so we make sure we don't violate the 12-page limit?"*

2. **On Scheduling**:
   > *"Our deadline is Thursday, November 19 at 23:59. If we finish Question 1 tonight, should our goal be to have Question 2 and Question 3 initial drafts ready by Friday, so we have the weekend to combine and polish the LaTeX report?"*

