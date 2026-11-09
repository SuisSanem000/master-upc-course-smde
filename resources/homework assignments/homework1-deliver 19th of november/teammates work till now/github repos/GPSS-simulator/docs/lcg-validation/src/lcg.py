"""Linear congruential generators (Lehmer, 1951).

    Z_i = (a * Z_{i-1} + c) mod m          U_i = Z_i / m  in [0, 1)

m is the modulus, a the multiplier, c the increment and Z_0 the seed.
c > 0 gives a mixed LCG, c = 0 a multiplicative LCG.
"""
from math import ceil, gcd

import numpy as np

_INT64_MAX = 2**63 - 1


def prime_factors(n):
    """Distinct prime factors of n (trial division, fine for n up to ~2^40)."""
    factors, p = [], 2
    while p * p <= n:
        if n % p == 0:
            factors.append(p)
            while n % p == 0:
                n //= p
        p += 1
    if n > 1:
        factors.append(n)
    return factors


def hull_dobell(m, a, c):
    """Check the Hull-Dobell theorem: the mixed LCG has full period m iff
    1) c and m are coprime,
    2) every prime q dividing m also divides a - 1,
    3) if 4 divides m, then 4 divides a - 1.
    """
    conditions = {
        "gcd(c, m) = 1": gcd(c, m) == 1,
        "q | m  =>  q | a-1": all((a - 1) % q == 0 for q in prime_factors(m)),
        "4 | m  =>  4 | a-1": m % 4 != 0 or (a - 1) % 4 == 0,
    }
    return all(conditions.values()), conditions


def affine_power(a, c, m, k):
    """Coefficients (A, C) such that k LCG steps equal  z -> (A*z + C) mod m.

    Computed by repeated squaring of the affine map, so it costs O(log k).
    """
    A, C = 1, 0                # identity map
    base_a, base_c = a % m, c % m
    while k > 0:
        if k & 1:
            A, C = (base_a * A) % m, (base_a * C + base_c) % m
        base_a, base_c = (base_a * base_a) % m, (base_a * base_c + base_c) % m
        k >>= 1
    return A, C


class LCG:
    """Linear congruential generator Z_i = (a Z_{i-1} + c) mod m."""

    def __init__(self, m, a, c, seed, name=None):
        if not (m > 0 and 0 < a < m and 0 <= c < m and 0 <= seed < m):
            raise ValueError("need 0 < m, 0 < a < m, 0 <= c < m, 0 <= seed < m")
        if c == 0 and seed == 0:
            raise ValueError("a multiplicative LCG (c = 0) cannot start at seed 0")
        self.m, self.a, self.c = m, a, c
        self.seed = self.state = seed
        self.name = name or f"LCG(m={m}, a={a}, c={c})"

    def __repr__(self):
        return f"{self.name} [seed={self.seed}]"

    def reset(self, seed=None):
        if seed is not None:
            self.seed = seed
        self.state = self.seed
        return self

    # ---- scalar interface ---------------------------------------------------
    def next_int(self):
        self.state = (self.a * self.state + self.c) % self.m
        return self.state

    def random(self):
        """One U(0,1) number."""
        return self.next_int() / self.m

    def jump(self, k):
        """Advance the state k steps in O(log k) without generating them."""
        A, C = affine_power(self.a, self.c, self.m, k)
        self.state = (A * self.state + C) % self.m
        return self

    # ---- vectorised interface -----------------------------------------------
    def _fits_int64(self):
        return self.a * (self.m - 1) + self.c <= _INT64_MAX

    def integers(self, n):
        """The next n values Z_i, identical to calling next_int() n times.

        The sequence is split into W consecutive blocks whose starting states
        are found with jump-ahead; the blocks are then advanced together with
        NumPy, which is ~100x faster than a Python loop.
        """
        if not self._fits_int64():           # products would overflow int64
            return np.array([self.next_int() for _ in range(n)], dtype=object)
        W = min(1024, n)
        L = ceil(n / W)
        A, C = affine_power(self.a, self.c, self.m, L)
        starts = np.empty(W, dtype=np.int64)
        s = self.state
        for j in range(W):
            starts[j] = s
            s = (A * s + C) % self.m
        out = np.empty((W, L), dtype=np.int64)
        z = starts
        for t in range(L):
            z = (self.a * z + self.c) % self.m
            out[:, t] = z
        out = out.ravel()[:n]
        self.state = int(out[-1])
        return out

    def uniforms(self, n):
        """The next n numbers U_i = Z_i / m in [0, 1)."""
        return self.integers(n).astype(np.float64) / self.m

    def period(self, max_steps=10**7):
        """Length of the cycle reached from the seed (Brent's algorithm).
        Returns None if it is longer than max_steps."""
        f = lambda z: (self.a * z + self.c) % self.m
        power = lam = 1
        tortoise, hare = self.seed, f(self.seed)
        while tortoise != hare:
            if power == lam:
                tortoise, power, lam = hare, power * 2, 0
            hare = f(hare)
            lam += 1
            if lam > max_steps:
                return None
        return lam


class LCGStreams:
    """W independent, non-overlapping substreams of one LCG.

    Stream j starts block_len * j steps after the seed, so as long as each
    stream draws at most block_len numbers they never overlap. Used to drive
    many random walkers in parallel.
    """

    def __init__(self, lcg, n_streams, block_len):
        if not lcg._fits_int64():
            raise ValueError("vectorised streams need a*(m-1)+c < 2^63")
        if n_streams * block_len > lcg.m:
            raise ValueError("streams would exceed the generator period")
        self.lcg, self.block_len = lcg, block_len
        A, C = affine_power(lcg.a, lcg.c, lcg.m, block_len)
        self.state = np.empty(n_streams, dtype=np.int64)
        s = lcg.seed
        for j in range(n_streams):
            self.state[j] = s
            s = (A * s + C) % lcg.m
        self.used = 0

    def __call__(self, n_streams, length):
        """(n_streams, length) array of uniforms; matches the walk interface."""
        if n_streams != len(self.state):
            raise ValueError("number of streams is fixed at construction")
        if self.used + length > self.block_len:
            raise ValueError("stream exhausted: increase block_len")
        a, c, m = self.lcg.a, self.lcg.c, self.lcg.m
        out = np.empty((len(self.state), length), dtype=np.float64)
        z = self.state
        for t in range(length):
            z = (a * z + c) % m
            out[:, t] = z
        self.state = z
        self.used += length
        return out / m


def schrage_next(z, a, m):
    """One step of the multiplicative LCG z -> a*z mod m without overflow
    (Schrage's method): every intermediate value stays below m."""
    q, r = m // a, m % a
    k = z // q
    z = a * (z - k * q) - r * k
    return z + m if z < 0 else z


# ---- Generators used in the slides ------------------------------------------
def slides_lcg16(seed=7):
    """Full-period toy example of the slides: m=16, a=5, c=3, Z0=7."""
    return LCG(16, 5, 3, seed, name="LCG(16, 5, 3)")


def minstd(seed=1):
    """Park & Miller 'minimal standard': LCG(2^31-1, 16807, 0)."""
    return LCG(2**31 - 1, 16807, 0, seed, name="MINSTD")


def simscript(seed=1):
    """SIMSCRIPT generator: LCG(2^31-1, 630360016, 0) (Chi-square example)."""
    return LCG(2**31 - 1, 630360016, 0, seed, name="SIMSCRIPT")


def lcg32(seed=1):
    """Full-period mixed LCG(2^32, 1664525, 1013904223) from Numerical Recipes:
    m = 2^32, a = 4k+1, c odd, so Hull-Dobell gives period 2^32."""
    return LCG(2**32, 1664525, 1013904223, seed, name="LCG(2^32)")


def randu(seed=1):
    """IBM RANDU: LCG(2^31, 65539, 0); famous for its 15 planes in 3D."""
    return LCG(2**31, 65539, 0, seed, name="RANDU")
