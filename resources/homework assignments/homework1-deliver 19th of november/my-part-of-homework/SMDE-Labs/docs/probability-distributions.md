# Probability distributions

[← Back to the guides](README.md)

## When to use it

To compute probabilities, quantiles and expected values of random variables:
"what is the probability of 4 purchases out of 10 customers?", "what is the
probability that the next car arrives within 6 minutes?", or to simulate data.

- **Discrete** random variables take countable values (counts, yes/no, dice):
  binomial, Poisson.
- **Continuous** random variables take any value in an interval (weight, blood
  pressure, time): uniform, exponential, normal. The probability of one exact
  value is 0; only intervals have a probability (an area under the density).

## The four R functions of every distribution

Each distribution has four functions. Replace `xxx` with its R name (`binom`,
`pois`, `exp`, `unif`, `norm`, `t`, `f`, `chisq`):

| Function | Meaning | Example |
|---|---|---|
| `dxxx(x, ...)` | Discrete: P(X = x). Continuous: density f(x) | `dbinom(4, 10, 0.3)` |
| `pxxx(q, ...)` | Cumulative distribution function F(q) = P(X ≤ q) | `pnorm(1.96)` |
| `qxxx(p, ...)` | Quantile: the value q with P(X ≤ q) = p | `qt(0.975, df = 8)` |
| `rxxx(n, ...)` | n random values | `rnorm(100, 0, 1)` |

Upper tail: `1 - pxxx(q)` or `pxxx(q, lower.tail = FALSE)`, which is P(X > q).
For discrete variables, P(X ≥ k) = `1 - pxxx(k - 1)`.

## Steps

### 1. Discrete distributions

**Binomial** B(n, p): number of successes in n independent yes/no trials with
success probability p. Mean np, variance np(1 − p).

```r
dbinom(4, size = 10, prob = 0.3)       # P(X = 4): 4 purchases out of 10 customers
pbinom(4, size = 10, prob = 0.3)       # P(X <= 4)
1 - pbinom(3, size = 10, prob = 0.3)   # P(X >= 4)
```

**Poisson** P(λ): number of events in a fixed period, with mean λ. Mean and
variance are both λ.

```r
dpois(2, lambda = 3)                   # P(X = 2): 2 customers in a minute, mean 3 per minute
ppois(2, lambda = 3)                   # P(X <= 2)
```

**Poisson approximation to the binomial**: if n is large and p small, B(n, p)
≈ P(λ = np).

```r
pbinom(2, size = 1000, prob = 0.0006)  # exact:       0.9769
ppois(2, lambda = 1000 * 0.0006)       # approximate: 0.9769
```

**Any discrete distribution given as a table**: store values and
probabilities in two vectors.

```r
x <- c(10, 11, 12, 13, 14)             # ships arriving per day
p <- c(0.4, 0.2, 0.2, 0.1, 0.1)
sum(p)                                 # must be 1 (and every p >= 0)
sum(p[x > 12])                         # P(X > 12)
cumsum(p)                              # CDF: P(X <= x) for each x
```

### 2. Continuous distributions

**Uniform** U(a, b): all values in [a, b] equally likely, density 1/(b − a).

```r
punif(0.75, min = 0, max = 1) - punif(0.5, min = 0, max = 1)   # P(0.5 <= X <= 0.75) = 0.25
```

**Exponential** Exp(λ): time between events of a Poisson process with rate λ.
Mean 1/λ. P(T ≤ t) = 1 − e^(−λt).

```r
pexp(2, rate = 1)                      # P(X <= 2) = 1 - e^-2 = 0.865
1 - pexp(0.1, rate = 10)               # 10 cars/hour: P(next car takes more than 0.1 h)
```

**Normal** N(μ, σ):

```r
pnorm(130, mean = 120, sd = 10)        # P(X <= 130)
qnorm(0.975)                           # 1.96: critical value of a 95% two-sided z interval
```

**Distributions used by the tests** (critical values instead of tables):

```r
qt(0.975, df = 8)                      # t_{0.025, 8} = 2.306
qf(0.95, df1 = 2, df2 = 12)            # F_{0.05, 2, 12} = 3.885
qchisq(0.95, df = 3)                   # chi-square critical value
```

### 3. Expected value and variance

For a discrete variable, E(X) = Σ x·p(x) and Var(X) = E(X²) − E(X)².

```r
x <- 1:6; p <- rep(1/6, 6)             # roll of a die
EX  <- sum(x * p)                      # 3.5
VarX <- sum(x^2 * p) - EX^2            # 2.92
sqrt(VarX)                             # standard deviation 1.71
```

Rules: E(cX) = cE(X), E(X + Y) = E(X) + E(Y),
Var(c + X) = Var(X), Var(cX) = c²Var(X), and Var(X + Y) = Var(X) + Var(Y)
**only if X and Y are independent** (otherwise add 2·Cov(X, Y)).

### 4. Plot a distribution

```r
# density / probability mass function
curve(dnorm(x, 0, 1), from = -3, to = 3, ylab = "f(x)")          # continuous
plot(0:10, dbinom(0:10, 10, 0.3), type = "h", ylab = "P(X = x)") # discrete

# CDF
curve(pexp(x, rate = 1), from = 0, to = 5, ylab = "F(x)")
```

## Checklist

- Is the variable discrete (use `d` for P(X = x)) or continuous (only
  intervals have a probability)?
- P(X ≤ q) is `p…(q)`; P(X > q) is `1 - p…(q)`; for a discrete X,
  P(X ≥ k) is `1 - p…(k - 1)`.
- A probability table must have every p(x) ≥ 0 and Σ p(x) = 1.

## Worked examples from the slides

| Slide question | R | Result |
|---|---|---|
| 4 purchases out of 10, p = 0.3 | `dbinom(4, 10, 0.3)` | 0.2001 |
| 2 customers per minute, mean 3 | `dpois(2, 3)` | 0.2240 |
| ≤ 2 cancer cases, n = 1000, p = 0.0006 | `pbinom(2, 1000, 0.0006)` / `ppois(2, 0.6)` | 0.9769 / 0.9769 |
| Exp(1): P(X ≤ 2) | `pexp(2, 1)` | 0.8647 |
| Ships: P(X > 12) | `sum(p[x > 12])` | 0.4 |
| Die: E(X), Var(X), SD | see step 3 | 3.5, 2.92, 1.71 |
| Roulette: E(X) betting 1 € on odd | `sum(c(1, -1) * c(18, 20) / 38)` | −0.053 |
