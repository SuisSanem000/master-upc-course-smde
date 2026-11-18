# Statistics guides (R)

Practical R guides for the SMDE course, written from the course slides. Each
guide follows the same format:

1. **When to use it**: the question the method answers.
2. **Setup**: the data frame and the packages the code expects.
3. **Steps**: R code, the hypotheses (H0 / H1) and how to read the result.
4. **Assumptions checklist**: what must hold and how to check it in R.
5. **Worked example from the slides**: the lecture example reproduced in R, so
   you can check your numbers against the slides.

| Guide | Slides |
|---|---|
| [Probability distributions](probability-distributions.md) | Random variables (binomial, Poisson, exponential, uniform, normal, expected value, variance) |
| [Hypothesis testing and t-tests](hypothesis-testing.md) | Hypothesis testing: confidence intervals, two-sample t-test, F-test for variances |
| [ANOVA](anova.md) | Introduction to ANOVA, ANOVA exercises by hand |
| [Simple linear regression](simple-linear-regression.md) | Simple linear regression |
| [Multiple linear regression](multiple-linear-regression.md) | Multiple linear regression |
| [First assignment: methods and assumptions](assignment-methods.md) | Model and assumptions of each part of Q1 and Q2 |

## Which method do I need?

| Question | Variables | Method | R |
|---|---|---|---|
| Is the mean of one group equal to a value? | 1 numeric | One-sample t-test | `t.test(x, mu = m)` |
| Do two groups have the same mean? | numeric + factor with 2 levels | Two-sample t-test | `t.test(y ~ g, var.equal = ...)` |
| Do two groups have the same variance? | numeric + factor with 2 levels | F-test | `var.test(y ~ g)` |
| Do 3 or more groups have the same mean? | numeric + factor with 3+ levels | One-way ANOVA | `aov(y ~ g)` |
| Which groups differ after ANOVA? | same | Post-hoc tests | `TukeyHSD()`, `pairwise.t.test()` |
| Are two numeric variables linearly related? | 2 numeric | Correlation test | `cor.test(x, y)` |
| Predict a numeric variable from one predictor | 2 numeric | Simple linear regression | `lm(y ~ x)` |
| Predict a numeric variable from several predictors | numeric + several predictors | Multiple linear regression | `lm(y ~ x1 + x2 + ...)` |
| Are two categorical variables associated? | 2 factors | Chi-square test of independence (not in these slides) | `chisq.test(table(a, b))` |

## Packages

Base R covers most of the code. The assumption tests need three extra
packages (install them once):

```r
install.packages(c("lmtest", "car", "tolerance"))
```

| Package | Used for |
|---|---|
| `lmtest` | `dwtest()` (Durbin-Watson, independence), `bptest()` (Breusch-Pagan, equal variance) |
| `car` | `leveneTest()` (equal variance between groups), `vif()` (multicollinearity) |
| `MASS` | `boxcox()` (Box-Cox transformation), comes with R |
| `tolerance` | `regtol.int()` (tolerance intervals in regression) |

## Reading a p-value

Every test in these guides follows the same rule, at the usual significance
level α = 0.05:

- **p-value ≤ 0.05**: reject H0. The data give evidence for H1.
- **p-value > 0.05**: do not reject H0. There is not enough evidence against it
  (this does not prove that H0 is true).

The p-value is the probability of getting a test statistic at least as extreme
as the observed one **if H0 were true**.
