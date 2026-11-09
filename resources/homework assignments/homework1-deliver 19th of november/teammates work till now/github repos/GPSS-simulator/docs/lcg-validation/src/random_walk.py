"""Drunkard's walk: simple symmetric random walk on the Z^2 / Z^3 lattice.

At every step the drunkard moves one unit in one of the 2*dim axis directions,
each with probability 1/(2*dim), chosen from a uniform number u as
floor(u * 2*dim).

Known results used to validate the simulation:
  * E|X_N|^2 = N in any dimension (RMS distance = sqrt(N)).
  * E|X_N|  ~ sqrt(2N/dim) Gamma((dim+1)/2) / Gamma(dim/2)
             (= 0.886 sqrt(N) in 2D, 0.921 sqrt(N) in 3D).
  * Polya (1921): the walk returns to the origin with probability 1 in 2D
    (recurrent) but only ~0.3405 in 3D (transient).
"""
from dataclasses import dataclass

import numpy as np
from scipy.special import gammaln

POLYA_3D = 0.340537


def unit_steps(dim):
    """The 2*dim unit vectors +-e_1, ..., +-e_dim."""
    eye = np.eye(dim, dtype=np.int64)
    return np.vstack([eye, -eye])


def expected_mean_distance(n, dim):
    """Asymptotic E|X_n| for the dim-dimensional lattice walk."""
    n = np.asarray(n, dtype=np.float64)
    return np.sqrt(2 * n / dim) * np.exp(gammaln((dim + 1) / 2) - gammaln(dim / 2))


@dataclass
class WalkResult:
    dim: int
    n_steps: int
    mean_sq_dist: np.ndarray    # E|X_t|^2,  t = 0..n_steps
    mean_dist: np.ndarray       # E|X_t|,    t = 0..n_steps
    first_return: np.ndarray    # step of first return to origin per walker (-1 = never)
    final: np.ndarray           # final positions, shape (n_walkers, dim)
    paths: np.ndarray           # full paths of the first few walkers (k, n_steps+1, dim)

    def return_fraction(self, steps=None):
        """Fraction of walkers that went back to the origin within each step budget."""
        steps = np.arange(self.n_steps + 1) if steps is None else np.asarray(steps)
        fr = self.first_return[self.first_return > 0]
        return np.searchsorted(np.sort(fr), steps, side="right") / len(self.first_return)


def simulate_walks(uniforms, n_walkers, n_steps, dim, chunk=500, keep_paths=5):
    """Simulate n_walkers independent walks of n_steps steps.

    uniforms(n_walkers, length) must return an (n_walkers, length) array of
    U[0,1) numbers, one row per walker (e.g. LCGStreams or rng.random).
    Steps are processed in chunks to keep memory bounded.
    """
    steps = unit_steps(dim)
    pos = np.zeros((n_walkers, dim), dtype=np.int64)
    first_return = np.full(n_walkers, -1, dtype=np.int64)
    msd = np.zeros(n_steps + 1)
    md = np.zeros(n_steps + 1)
    paths = np.zeros((min(keep_paths, n_walkers), n_steps + 1, dim), dtype=np.int64)

    done = 0
    while done < n_steps:
        L = min(chunk, n_steps - done)
        u = uniforms(n_walkers, L)
        moves = np.minimum((u * 2 * dim).astype(np.int64), 2 * dim - 1)
        traj = pos[:, None, :] + np.cumsum(steps[moves], axis=1)    # (W, L, dim)

        sq = np.sum(traj ** 2, axis=2)                              # |X_t|^2
        msd[done + 1:done + L + 1] = sq.mean(axis=0)
        md[done + 1:done + L + 1] = np.sqrt(sq).mean(axis=0)

        at_origin = sq == 0
        hit = at_origin.any(axis=1) & (first_return < 0)
        first_return[hit] = done + 1 + at_origin[hit].argmax(axis=1)

        paths[:, done + 1:done + L + 1] = traj[:len(paths)]
        pos = traj[:, -1]
        done += L

    return WalkResult(dim, n_steps, msd, md, first_return, pos, paths)
