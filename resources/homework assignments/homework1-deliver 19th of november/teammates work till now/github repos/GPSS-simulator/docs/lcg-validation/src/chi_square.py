"""Chi-square based empirical tests for U[0,1) generators.

* Chi-square uniformity test: split [0,1) into k equal intervals (k > 100,
  n/k >= 5), count f_j per interval and compare with the expected n/k:

      chi2 = k/n * sum_j (f_j - n/k)^2   ~  chi2(k-1)   under H0: U_i iid U(0,1)

* Serial test: the same on non-overlapping d-tuples, i.e. on k^d cells of [0,1)^d.
* Gap test: lengths of the gaps between visits to [a, b) must be geometric.
* Runs-up test: lengths of ascending runs (Knuth's statistic R ~ chi2(6)).
"""
from dataclasses import dataclass
import warnings

import numpy as np
from scipy import stats


@dataclass
class ChiSquareResult:
    statistic: float
    df: int
    critical: float
    p_value: float
    alpha: float
    freqs: np.ndarray
    expected: object          # float (equiprobable cells) or np.ndarray

    @property
    def reject(self):
        return self.statistic > self.critical

    def __str__(self):
        verdict = "REJECT H0" if self.reject else "accept H0"
        return (f"chi2 = {self.statistic:.1f}  df = {self.df}  "
                f"chi2_crit(1-{self.alpha}) = {self.critical:.1f}  "
                f"p = {self.p_value:.4f}  ->  {verdict}")


def _result(statistic, df, alpha, freqs, expected):
    return ChiSquareResult(
        statistic=float(statistic),
        df=df,
        critical=float(stats.chi2.ppf(1 - alpha, df)),
        p_value=float(stats.chi2.sf(statistic, df)),
        alpha=alpha,
        freqs=freqs,
        expected=expected,
    )


def _check_unit_interval(u):
    u = np.asarray(u, dtype=np.float64)
    if u.min() < 0 or u.max() >= 1:
        raise ValueError("values must lie in [0, 1)")
    return u


def _bin_index(u, k):
    """Interval index 0..k-1 of each u (guard u*k rounding up to k)."""
    return np.minimum((u * k).astype(np.int64), k - 1)


def bin_counts(u, k):
    """Frequencies f_1..f_k of u in k equal-width bins of [0,1)."""
    return np.bincount(_bin_index(_check_unit_interval(u), k), minlength=k)


def chi_square_uniformity(u, k, alpha=0.10):
    """Chi-square test of H0: u ~ iid U(0,1) using k equal bins."""
    n = len(u)
    expected = n / k
    if expected < 5:
        warnings.warn(f"n/k = {expected:.2f} < 5: the chi-square approximation is poor")
    f = bin_counts(u, k)
    statistic = k / n * np.sum((f - expected) ** 2)
    return _result(statistic, k - 1, alpha, f, expected)


def serial_test(u, k, d=2, alpha=0.10):
    """Serial test: Chi-square on the non-overlapping d-tuples
    U_1 = (u_1..u_d), U_2 = (u_{d+1}..u_{2d}), ...  in k^d equal cells:

        chi2(d) = k^d/n * sum (f_{j1..jd} - n/k^d)^2  ~  chi2(k^d - 1)

    where n is the number of tuples.
    """
    u = _check_unit_interval(u)
    n = len(u) // d
    cells = k ** d
    expected = n / cells
    if expected < 5:
        warnings.warn(f"n/k^d = {expected:.2f} < 5: the chi-square approximation is poor")
    idx = _bin_index(u[:n * d], k).reshape(n, d)
    cell = np.ravel_multi_index(idx.T, (k,) * d)
    f = np.bincount(cell, minlength=cells)
    statistic = cells / n * np.sum((f - expected) ** 2)
    return _result(statistic, cells - 1, alpha, f, expected)


def gap_lengths(u, a, b):
    """Gap lengths between successive values falling in [a, b): the number of
    values outside [a, b) between two consecutive values inside it.
    (The slides' 'distance' between the two hits is gap length + 1.)"""
    hits = np.flatnonzero((u >= a) & (u < b))
    return np.diff(hits) - 1


def gap_test(u, a=0.4, b=0.7, t=10, alpha=0.10):
    """Gap test: under H0 the gap length r is geometric with p = b - a,
    P(r) = p (1-p)^r for r = 0..t-1 and P(r >= t) = (1-p)^t.
    Chi-square with t + 1 classes, df = t."""
    u = _check_unit_interval(u)
    p = b - a
    gaps = gap_lengths(u, a, b)
    n = len(gaps)
    f = np.bincount(np.minimum(gaps, t), minlength=t + 1)
    probs = np.append(p * (1 - p) ** np.arange(t), (1 - p) ** t)
    expected = n * probs
    if expected.min() < 5:
        warnings.warn("some expected gap counts are < 5: reduce t")
    statistic = np.sum((f - expected) ** 2 / expected)
    return _result(statistic, t, alpha, f, expected)


def run_lengths(u):
    """Lengths of the ascending runs ('runs up') of the sequence u."""
    u = np.asarray(u)
    starts = np.r_[0, np.flatnonzero(u[1:] < u[:-1]) + 1, len(u)]
    return np.diff(starts)


# Knuth (TAOCP vol. 2, 3.3.2 G) / Law & Kelton constants for the runs-up test.
RUNS_A = np.array([
    [4529.4,   9044.9,  13568.0,  18091.0,  22615.0,  27892.0],
    [9044.9,  18097.0,  27139.0,  36187.0,  45234.0,  55789.0],
    [13568.0, 27139.0,  40721.0,  54281.0,  67852.0,  83685.0],
    [18091.0, 36187.0,  54281.0,  72414.0,  90470.0, 111580.0],
    [22615.0, 45234.0,  67852.0,  90470.0, 113262.0, 139476.0],
    [27892.0, 55789.0,  83685.0, 111580.0, 139476.0, 172860.0],
])
RUNS_B = np.array([1 / 6, 5 / 24, 11 / 120, 19 / 720, 29 / 5040, 1 / 840])


def runs_up_counts(u):
    """r_1..r_6: number of runs up of length 1..5 and of length >= 6."""
    return np.bincount(np.minimum(run_lengths(u), 6) - 1, minlength=6)


def runs_up_test(u, alpha=0.10):
    """Runs-up test of independence:

        R = 1/n * sum_i sum_j a_ij (r_i - n b_i)(r_j - n b_j)  ~  chi2(6)

    (approximation valid for n >= 4000)."""
    u = np.asarray(u, dtype=np.float64)
    n = len(u)
    if n < 4000:
        warnings.warn("n < 4000: R is not yet chi-square(6) distributed")
    r = runs_up_counts(u)
    dev = r - n * RUNS_B
    statistic = dev @ RUNS_A @ dev / n
    return _result(statistic, 6, alpha, r, n * RUNS_B)
