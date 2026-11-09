"""Spectral test for LCGs (theoretical test, Knuth TAOCP vol. 2, sec. 3.3.4).

Marsaglia (1968): overlapping t-tuples (u_i, ..., u_{i+t-1}) of an LCG fall on
a family of parallel hyperplanes  s . u = const (mod 1), where s is a nonzero
integer vector of the dual lattice

    L*_t = { s in Z^t :  s_1 + s_2 a + ... + s_t a^(t-1) = 0 (mod m) }.

The spectral test value is nu_t = min ||s|| over L*_t; the distance between
adjacent hyperplanes is d_t = 1 / nu_t (small d_t = good). The normalised
figure of merit is  S_t = nu_t / (gamma_t^(1/2) m^(1/t))  in (0, 1], where
gamma_t is Hermite's constant (S_t close to 1 = good).
"""
from dataclasses import dataclass
from fractions import Fraction
from math import ceil, floor, sqrt

import numpy as np

# gamma_t^t (Hermite constants, known exactly for t <= 8)
_HERMITE_POW_T = {2: 4 / 3, 3: 2, 4: 4, 5: 8, 6: 64 / 3, 7: 64, 8: 256}


def dual_lattice_basis(m, a, t):
    """Rows generate L*_t: (m, 0, ..., 0) and e_j - (a^j mod m) e_1, j=1..t-1."""
    B = [[0] * t for _ in range(t)]
    B[0][0] = m
    for j in range(1, t):
        B[j][0] = -pow(a, j, m)
        B[j][j] = 1
    return B


def _dot(u, v):
    return sum(x * y for x, y in zip(u, v))


def _gram_schmidt(B):
    """Exact Gram-Schmidt: returns (squared norms of b*_i, mu coefficients)."""
    n = len(B)
    Bs = [[Fraction(x) for x in b] for b in B]
    mu = [[Fraction(0)] * n for _ in range(n)]
    norms = [Fraction(0)] * n
    for i in range(n):
        for j in range(i):
            mu[i][j] = _dot(B[i], Bs[j]) / norms[j]
            Bs[i] = [x - mu[i][j] * y for x, y in zip(Bs[i], Bs[j])]
        norms[i] = Fraction(_dot(Bs[i], Bs[i]))
    return norms, mu


def lll_reduce(B, delta=Fraction(3, 4)):
    """LLL lattice reduction with exact rational arithmetic (small t only)."""
    B = [list(b) for b in B]
    n, k = len(B), 1
    norms, mu = _gram_schmidt(B)
    while k < n:
        for j in range(k - 1, -1, -1):                  # size reduction
            q = round(mu[k][j])
            if q:
                B[k] = [x - q * y for x, y in zip(B[k], B[j])]
                norms, mu = _gram_schmidt(B)
        if norms[k] >= (delta - mu[k][k - 1] ** 2) * norms[k - 1]:
            k += 1
        else:                                           # Lovasz condition fails
            B[k], B[k - 1] = B[k - 1], B[k]
            norms, mu = _gram_schmidt(B)
            k = max(k - 1, 1)
    return B


def shortest_vector(B):
    """Exact shortest nonzero vector of the lattice spanned by rows of B.

    LLL first, then Fincke-Pohst enumeration of all x with ||x B|| <= best.
    """
    B = lll_reduce(B)
    n = len(B)
    norms, mu = _gram_schmidt(B)
    norms = [float(x) for x in norms]
    mu = [[float(x) for x in row] for row in mu]
    best = min(_dot(b, b) for b in B)
    best_vec = min(B, key=lambda b: _dot(b, b))
    x = [0] * n

    def search(i, partial):
        nonlocal best, best_vec
        centre = -sum(x[j] * mu[j][i] for j in range(i + 1, n))
        radius = sqrt(max(best - partial, 0) / norms[i]) + 1e-9
        for xi in range(ceil(centre - radius), floor(centre + radius) + 1):
            x[i] = xi
            length = partial + (xi - centre) ** 2 * norms[i]
            if length > best * (1 + 1e-9):
                continue
            if i > 0:
                search(i - 1, length)
            elif any(x):
                v = [sum(x[r] * B[r][c] for r in range(n)) for c in range(n)]
                nv = _dot(v, v)                          # exact integer norm
                if 0 < nv < best:
                    best, best_vec = nv, v
        x[i] = 0

    search(n - 1, 0.0)
    if best_vec[0] < 0 or (best_vec[0] == 0 and next(c for c in best_vec if c) < 0):
        best_vec = [-c for c in best_vec]                # canonical sign
    return best_vec, best


@dataclass
class SpectralResult:
    t: int
    s: list            # normal vector of the hyperplane family
    nu: float          # ||s||
    d: float           # distance between adjacent hyperplanes = 1/nu
    S: float           # normalised figure of merit

    @property
    def max_hyperplanes(self):
        """Upper bound on the number of hyperplanes that cover [0,1)^t."""
        return sum(abs(c) for c in self.s)


def spectral_test(m, a, t):
    """Spectral test of an LCG with modulus m and multiplier a in dimension t.
    (The increment c only shifts the lattice, so it does not matter.)"""
    s, nu2 = shortest_vector(dual_lattice_basis(m, a, t))
    nu = sqrt(nu2)
    S = nu / (_HERMITE_POW_T[t] ** (1 / (2 * t)) * m ** (1 / t))
    return SpectralResult(t=t, s=s, nu=nu, d=1 / nu, S=S)


def overlapping_tuples(u, t):
    """Rows (u_i, u_{i+1}, ..., u_{i+t-1}) used by the spectral test plots."""
    return np.lib.stride_tricks.sliding_window_view(np.asarray(u), t)
