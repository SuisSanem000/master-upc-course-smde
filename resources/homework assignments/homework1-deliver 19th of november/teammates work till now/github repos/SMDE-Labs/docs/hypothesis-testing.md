# Hypothesis testing and t-tests

[← Back to the guides](README.md)

## When to use it

- **Confidence interval for a mean**: a range that contains the population mean
  μ with probability 1 − α (usually 95%).
- **One-sample t-test**: is the mean equal to a given value?
- **Two-sample t-test**: do two groups (configurations, populations) have the
  same mean?
- **F-test**: do two groups have the same variance? It decides which
  two-sample t-test to use.

## Setup

The code assumes a data frame `df` with a numeric response `y` and a factor
`g` with **two** levels, or two numeric vectors `a` and `b`:

```r
df <- data.frame(y = my_data$my_numeric_variable,
                 g = factor(my_data$my_group_variable))

a <- df$y[df$g == levels(df$g)[1]]   # first group
b <- df$y[df$g == levels(df$g)[2]]   # second group
```

## The four steps of every test

1. **Hypotheses**: H0 contains the equality (=, ≤, ≥); H1 is what you want to
   show (≠, <, >).
2. **Significance level** α (usually 0.05) and decision rule.
3. **Test statistic**, computed from the sample.
4. **Decision**:
   - *p-value approach*: reject H0 if p-value ≤ α;
   - *critical value approach*: reject H0 if the statistic falls in the
     rejection region (critical value from `qt()`, `qf()`, ...).

|  | H0 true | H0 false |
|---|---|---|
| **Reject H0** | Type I error (α, false positive) | Correct (power 1 − β) |
| **Do not reject H0** | Correct (1 − α) | Type II error (β, false negative) |

The `alternative` argument of the R tests sets H1:

| H1 | R |
|---|---|
| μ_A ≠ μ_B (two-sided, default) | `alternative = "two.sided"` |
| μ_A > μ_B | `alternative = "greater"` |
| μ_A < μ_B | `alternative = "less"` |

With the formula `y ~ g`, "greater" means *first level > second level*.

## Steps

### 1. Confidence interval for a mean

Variance unknown (the usual case): x̄ ± t_{α/2, n−1} · s / √n.

```r
t.test(df$y, conf.level = 0.95)$conf.int

# by hand
n <- length(df$y)
mean(df$y) + c(-1, 1) * qt(0.975, df = n - 1) * sd(df$y) / sqrt(n)
```

Variance known (σ given): x̄ ± z_{α/2} · σ / √n, with `qnorm(0.975)` instead
of `qt()`.

Interpretation: if we repeated the sampling many times, 95% of the intervals
built this way would contain the true mean μ.

### 2. One-sample t-test

```r
t.test(df$y, mu = 54)                          # H0: mu = 54, H1: mu != 54
t.test(df$y, mu = 2000, alternative = "greater")   # H0: mu <= 2000, H1: mu > 2000
```

### 3. Check the assumptions of the two-sample test

**Normality** of each group (or a large sample, by the Central Limit Theorem):

```r
shapiro.test(a)        # H0: group A is normally distributed
shapiro.test(b)        # H0: group B is normally distributed

par(mfrow = c(1, 2))
qqnorm(a, main = "Group A"); qqline(a, col = "red")
qqnorm(b, main = "Group B"); qqline(b, col = "red")
par(mfrow = c(1, 1))
```

`shapiro.test()` accepts 3 to 5000 values: for larger groups, test a random
sample (`shapiro.test(sample(a, 5000))`) and rely on the Q-Q plot.

**Equal variances**: F-test, F = s_A² / s_B² with (n_A − 1, n_B − 1) degrees
of freedom.

```r
var.test(y ~ g, data = df)   # H0: sigma_A^2 = sigma_B^2, H1: they are different
```

- p > 0.05: equal variances can be assumed → step 4a.
- p ≤ 0.05: variances differ → step 4b.

`var.test()` is sensitive to non-normality; with non-normal data use
`car::leveneTest(y ~ g, data = df)` instead (same hypotheses).

### 4a. Two-sample t-test, equal variances (pooled)

t = (ȳ_A − ȳ_B) / (s_p √(1/n_A + 1/n_B)), with n_A + n_B − 2 degrees of
freedom and pooled variance s_p² = ((n_A − 1)s_A² + (n_B − 1)s_B²) / (n_A + n_B − 2).

```r
t.test(y ~ g, data = df, var.equal = TRUE)                          # H1: mu_A != mu_B
t.test(y ~ g, data = df, var.equal = TRUE, alternative = "greater") # H1: mu_A > mu_B
```

### 4b. Two-sample t-test, unequal variances (Welch)

t' = (ȳ_A − ȳ_B) / √(s_A²/n_A + s_B²/n_B), with adjusted degrees of freedom.

```r
t.test(y ~ g, data = df, var.equal = FALSE)   # Welch test (R's default)
```

### 5. Read the result

```
t = 2.7418, df = 18, p-value = 0.006702
95 percent confidence interval: ...
sample estimates: mean of x  mean of y
```

- **t, df, p-value**: the test. p ≤ 0.05 → reject H0, the means differ (or are
  ordered as in H1).
- **Confidence interval** for μ_A − μ_B: if it does not contain 0, the means
  differ at that confidence level.

### 6. If the assumptions fail (not in the slides)

- **Non-normal, small samples**: Wilcoxon rank-sum (Mann-Whitney) test,
  `wilcox.test(y ~ g, data = df)` (H0: same distribution).
- **Paired data** (the same individuals measured twice):
  `t.test(before, after, paired = TRUE)`.
- **Heavy skew**: try a transformation (e.g. `log(y)`) and test again.

## Checklist

| Assumption | How to check | If it fails |
|---|---|---|
| Independent observations | Study design (random sample, no repeated measures) | Paired test or another design |
| Normality of each group | `shapiro.test()`, Q-Q plot, histogram (or large n) | Transformation or `wilcox.test()` |
| Equal variances (pooled test only) | `var.test()` or `car::leveneTest()` | Welch test (`var.equal = FALSE`) |

## Worked example from the slides

Two configurations, 10 observations each. H0: μ_A ≤ μ_B, H1: μ_A > μ_B.

```r
A <- c(24.3, 25.6, 26.7, 22.7, 24.8, 23.8, 25.9, 26.4, 25.8, 25.4)
B <- c(24.4, 21.5, 25.1, 22.8, 25.2, 23.5, 22.2, 23.5, 23.3, 24.7)

c(mean(A), mean(B))        # 25.14, 23.62
c(sd(A), sd(B))            # 1.242, 1.237

var.test(A, B)             # F = 1.008, p = 0.99 -> equal variances
t.test(A, B, var.equal = TRUE, alternative = "greater")
# t = 2.742, df = 18, p-value = 0.0067

qt(0.95, df = 18)          # critical value t_{0.05, 18} = 1.734
```

t = 2.74 > 1.734 (and p = 0.0067 < 0.05): reject H0, configuration A has a
higher mean than B.

Slides' F-test example: s_B² / s_A² = 2.18 / 1.54 = 1.42 < `qf(0.95, 9, 9)` =
3.18 → equal variances; with s_B² = 16.3, F = 10.58 > 3.18 → different variances.
