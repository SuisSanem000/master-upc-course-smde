# First assignment: methods and assumptions

[← Back to the guides](README.md)

The model (or method) of each part of the first assignment, and the
assumptions it needs, with the test or plot that checks each one.

## Question 1: Visualisation, Chi-Square and t-Test

| Part | Model / method | Assumptions (how to check) |
|---|---|---|
| Q1.a | Import and variable types (no model) | — |
| Q1.b | Descriptive statistics + normality of each variable | Normality (Shapiro-Wilk, histogram, Q-Q plot) |
| Q1.c | Graphs by gender, after removing the zero values (no model) | — |
| Q1.d | t confidence interval for the mean, per gender | Normality (Shapiro-Wilk, Q-Q plot) or large n (central limit theorem); independent observations |
| Q1.e | Age groups with `cut()` (no model) | — |
| Q1.f | Chi-square test of independence (age group × class, age group × gender) | Expected count ≥ 5 in every cell (`chisq.test()$expected`); independent observations |
| Q1.g | Two-sample t-test (pooled or Welch) per performance test, by gender | Normality of each group (Shapiro-Wilk, Q-Q plot) or large n; equal variances (F-test): pooled if equal, Welch if not; independent observations |

## Question 2: ANOVA

| Part | Model / method | Assumptions (how to check) |
|---|---|---|
| Q2.a | Descriptive statistics and graphs by age group and by class (no model) | — |
| Q2.b | One-way ANOVA (each variable by age group and by class) + 3 post-hoc tests (Tukey, Bonferroni, LSD) | Normality of the residuals (Shapiro-Wilk, Q-Q plot); equal variances (Levene, Breusch-Pagan); independence (Durbin-Watson); no outliers (boxplot) |
| Q2.c | Two-way ANOVA with interaction (age group × gender) | Normality of the residuals (Shapiro-Wilk, Q-Q plot); equal variances (Levene, Breusch-Pagan); independence (Durbin-Watson) |

If an assumption fails: Welch's t-test or Welch's ANOVA (unequal variances),
Wilcoxon or Kruskal-Wallis tests (non-normal data), or a transformation of the
variable (e.g. log).

See the [hypothesis testing](hypothesis-testing.md) and [ANOVA](anova.md)
guides for the R code of each test.
