# Roadmap: weighted orthogonal L² bases — completeness, Hilbert-basis structure, and product bases of orthogonal systems

## Overview

Mathlib has several families of orthogonal polynomials as **algebraic** objects
(`Polynomial.hermite`, `Polynomial.Chebyshev`, `Polynomial.shiftedLegendre`) and a complete
abstract Hilbert-basis API (`HilbertBasis`, `mkOfOrthogonalEqBot`, `tsum_inner_mul_inner`), but
**no bridge between them**: nothing turns a polynomial **orthogonality relation**
`∫ pₘ(x) pₙ(x) w(x) dx = cₙ · δₘₙ` into a complete orthonormal **basis** of an L² space, and nothing
assembles one-dimensional bases into a basis of an L² product measure.

This area builds that **L² Hilbert-basis layer** for orthogonal systems:

- a **completeness** toolkit (moment determinacy / Fourier uniqueness) — the step that upgrades
  "orthogonal" to "complete orthonormal basis";
- the **orthogonality-relation → `HilbertBasis`** bridge (the √w normalization + Parseval);
- the **L²-product-basis** lemma (a Hilbert basis of `L²(μ ⊗ ν)` from bases of the factors).

The **Hermite basis of `L²(ℝ)`** is the worked anchor (**Part A**, the v1 deliverable) from which the
family-agnostic spine (**Part B**) is abstracted; the same spine then yields further classical
bases (Laguerre, Jacobi; **Part C**, future) and the multidimensional Hermite basis.

### Scope boundary (what this area is, and is not)

This area provides **Hilbert-space structure**: completeness, `HilbertBasis`, Parseval, product
bases. It treats each family's **orthogonality relation** `∫ pₘ pₙ w = cₙδ` and the polynomial
calculus (recurrences, generating functions, Rodrigues) as **inputs** — consumed from Mathlib's
existing polynomial API where available, not re-derived here. The line is: an *integral identity*
("these polynomials are orthogonal w.r.t. `w`") is an input; a *Hilbert-space theorem* ("...hence
the normalized functions are a complete orthonormal basis of L²") is the contribution.

## Generality bar (decide up front; do not silently specialize)

- **The basis layer is family-agnostic and scalar-generic.** Bases are stated through the
  measure-generic `HilbertBasis ι 𝕜 (Lp 𝕜 2 μ)` API over `[RCLike 𝕜]` (the real pointwise
  functions cast via `algebraMap ℝ 𝕜`); do **not** duplicate the API for `ℝ` and `ℂ` separately.
- **Orthogonality relations are inputs.** Part B's bridge takes the relation `∫ pₘ pₙ w = cₙδ`
  (with `cₙ > 0`) and a polynomial-density/completeness hypothesis as **arguments**; it does not
  fix a family. Per-family identities (recurrences, generating functions, Rodrigues) are out of
  scope — built elsewhere and consumed.
- **Weights are classical and determinate.** Gaussian `e^{-x²}` (Hermite); later `x^α e^{-x}` on
  `[0,∞)` (Laguerre) and `(1-x)^α(1+x)^β` on `[-1,1]` (Jacobi). The completeness route requires the
  weight's moment problem to be determinate — concretely, finite exponential moments (Gaussian-type
  decay) or compact support — stated as an explicit hypothesis of the general completeness lemma.
- **Measures named explicitly.** `volume` on `ℝ`/intervals, `Measure.pi`/`Measure.prod` for
  products — never inferred — so the product-basis lemma and the multi-d instances are extensions,
  not refactors.
- **Deliberately out of scope:** the general orthogonal-polynomials-**of-a-measure** construction
  (Gram–Schmidt), Favard's theorem / three-term recurrences, and every per-family identity. Those
  are the polynomial-identity layer, not the L²-basis layer this area owns.

## What Mathlib already has (consume)

- Algebraic families: `Polynomial.hermite` (+ `hermite_succ`, `deriv_gaussian_eq_hermite_mul_gaussian`),
  `Polynomial.Chebyshev`, `Polynomial.shiftedLegendre`.
- Hilbert-basis API: `HilbertBasis`, `HilbertBasis.mkOfOrthogonalEqBot`,
  `HilbertBasis.hasSum_inner_mul_inner`, `HilbertBasis.tsum_inner_mul_inner`; `Orthonormal`; `MemLp.toLp`.
- `OrthonormalBasis.tensorProduct` — **finite-dimensional only** (the algebraic tensor of finite
  bases); there is no completed / `L²(Measure.pi)` product-basis API.
- `integral_gaussian`; the Fourier-transform API (`Fourier.fourierIntegral`) for the determinacy proof.

## What is missing (build here)

The completeness toolkit, the relation→`HilbertBasis` bridge, the L²-product-basis lemma, and the
per-family completeness+basis (Hermite now; Laguerre/Jacobi later).

## Part A — The Hermite basis of `L²(ℝ)` (the v1 anchor)

The concrete milestone and the worked instance from which Part B is abstracted. The Hermite
functions are `ψₙ(x) = cₙ · Hₙ(x√2) · e^{-x²/2}` with `cₙ = (n!·√π)^{-1/2}` and
`Hₙ = Polynomial.hermite n` (probabilists'; built on Mathlib's existing family, *not* a new
polynomial). They are the eigenfunctions of the quantum harmonic oscillator and the canonical
orthonormal basis of `L²(ℝ)`. Part A ships first and develops the full object API; Part B is then
factored out of A1–A3's proofs.

*Placement:* polynomial facts (A1) mirror Mathlib's `RingTheory/Polynomial/Hermite/…`; the
analytic facts (A2–A3) live under `Analysis/SpecialFunctions/…`. Names describe the conclusion.

### A1 — Hermite polynomial API
- `derivative_hermite_succ : derivative (hermite (n+1)) = (n+1) • hermite n` (+ `@[simp]`); Mathlib's
  `degree_hermite` is reused (it makes the polynomials span the moment space in A3).
- Integrability of a polynomial against the Gaussian weight:
  `Integrable (fun x => aeval x p * Real.exp (-(x²/2)))`.
- The one-step weighted-pairing recursion `∫ p·H_{n+1}·w = ∫ p'·Hₙ·w` (one IBP via Rodrigues
  `(Hₙ·w)' = -(H_{n+1}·w)`); and the **generating function** `∑' n, Hₙ(x)·tⁿ/n! = e^{x·t - t²/2}`.
- **Milestone** `integral_hermite_mul_hermite_mul_gaussian`:
  `∫ x, Hₘ(x)·Hₙ(x)·e^{-x²/2} = if m = n then n!·√(2π) else 0`.
- *Acceptance:* `H₀=1, H₁=X, H₂=X²-1`; `⟨H₀,H₀⟩=⟨H₁,H₁⟩=√(2π)`; `⟨H₀,H₂⟩=0`; gen. fn. at `t=0` is `1`.

### A2 — The Hermite functions `ψₙ : ℝ → ℝ`
- `hermiteFunction n x = cₙ · aeval (x·√2) (hermite n) · e^{-x²/2}`, with regularity:
  `Continuous`, `ContDiff ℝ ⊤`, `MemLp _ 2 volume`, and a `SchwartzMap ℝ ℝ` with this underlying
  function. Companion API: parity `ψₙ(-x)=(-1)ⁿψₙ(x)`, `ψ₀`/`ψ₁` `@[simp]` forms, `‖ψₙ‖₂=1`.
- **Ladder relations** (pointwise/Schwartz-level): `x·ψₙ = √((n+1)/2)ψ_{n+1} + √(n/2)ψ_{n-1}` and
  `ψₙ' = √(n/2)ψ_{n-1} - √((n+1)/2)ψ_{n+1}`, whence `aψₙ=√n ψ_{n-1}`, `a†ψₙ=√(n+1)ψ_{n+1}`.
  Packaging `a, a†` as operators on `L²` with `[a,a†]=1` is a deliberate downstream target.
- **Milestones:** pointwise orthonormality `integral_hermiteFunction_mul_hermiteFunction`
  (`∫ ψₘψₙ = if m=n then 1 else 0`); the oscillator eigen-equation
  `-ψₙ'' + x²ψₙ = (2n+1)ψₙ`.
- *Acceptance:* `ψ₀ = π^{-1/4}e^{-x²/2}` (`n=0` boundary; `aψ₀=0`); `ψ₁=√2·x·ψ₀`; `a†ψ₀=ψ₁`.

### A3 — The Hermite basis of `L²(ℝ; 𝕜)`
- `hermiteFunctionLp (𝕜) : ℕ → Lp 𝕜 2 volume` (real `ψₙ` cast via `algebraMap ℝ 𝕜`);
  `Orthonormal 𝕜 (hermiteFunctionLp 𝕜)`.
- **Completeness** (the instance of **B1**): `(∀ n, ∫ x, f x·ψₙ(x) = 0) → f =ᵐ[volume] 0`, proved over
  `ℝ` by the **Fourier-integral route** of B1 — set `g := f·e^{-x²/2}`, which is `L¹` *and has every
  exponential moment finite* (`∫ e^{a|x|}|f|e^{-x²/2} ≤ ‖f‖₂·‖e^{a|x|}e^{-x²/2}‖₂ < ∞`, Cauchy–Schwarz),
  so `𝓕 g` (`Fourier.fourierIntegral`) is entire with all Taylor coefficients (= the moments) zero,
  hence `g = 0`. *Stay in the `fourierIntegral` API — do not detour through a finite-signed-measure API.*
- **Headline milestone** (for every `[RCLike 𝕜]`):
  `hermiteHilbertBasis 𝕜 : HilbertBasis ℕ 𝕜 (Lp 𝕜 2 volume)` (via `mkOfOrthogonalEqBot`), with
  Parseval in `tsum_inner_mul_inner` orientation `∑' n, ⟪f,ψₙ⟫·⟪ψₙ,g⟫ = ⟪f,g⟫`. `𝕜=ℝ` and `𝕜=ℂ`
  are one theorem.
- *Acceptance:* Parseval for an explicit `f`; coordinates of `ψ₀` are `Finsupp.single 0 1`;
  `‖f‖² = ∑' n, ‖⟪ψₙ,f⟫‖²`; both `ℝ` and `ℂ` instantiate.

## Part B — The family-agnostic spine (the reusable layer)

The three pieces that Part A's completeness/basis argument factors into, stated without reference to
any particular family.

### B1 — Moment determinacy / completeness toolkit
An `L¹` function `g` *all of whose exponential moments are finite* (`∫ e^{a|x|}·|g| < ∞` for every
`a ≥ 0` — and a single positive `a`, giving strip-analyticity, already suffices for uniqueness) and
all of whose polynomial moments vanish is a.e. `0` — because that integrability makes `𝓕 g`
**entire**, with the moments as its Taylor coefficients at `0`, so `𝓕 g ≡ 0`. **The decay
hypothesis is this weighted-`L¹` integrability, *not* a pointwise bound `|g| ≤ C·e^{-x²/2}`** — the
distinction matters because the completeness instance `g = (basis test fn)·√w` with an `L²` factor
is *not* pointwise-bounded, but *does* have finite exponential moments (Cauchy–Schwarz against the
Gaussian `√w`). *This is the load-bearing analytic content.*

**Weight-role note** (state explicitly): the completeness used by the
basis is in **`L²(dx)` with the `√w` envelope** — `g ∈ L²(dx)` orthogonal to every `pₙ·√w` ⟹ `g = 0`
— reduced to the moment lemma via `h := g·√w`. Do *not* conflate it with `L²(w)`-orthogonality (test
integrand `w`, not `√w`); they correspond under `g ↔ g·√w` but are distinct statements.

### B2 — Orthogonality relation → `HilbertBasis`
Given polynomials `p : ℕ → ℝ[X]`, a weight `w` with `0 ≤ w` **and `0 < w` a.e.** (else `g·√w = 0`
fails to force `g = 0`), the relation `∫ pₘ pₙ w ∂μ = cₙ δ` with `cₙ > 0`, and completeness (B1),
the √w-normalized functions `x ↦ pₙ(x)·√(w x)/√(cₙ)` are orthonormal in `L²(μ)` and, with
completeness, form a `HilbertBasis ℕ 𝕜 (Lp 𝕜 2 μ)` (cast via `algebraMap ℝ 𝕜`), with Parseval —
**for any σ-finite reference measure `μ` on `ℝ`**, so Laguerre (`μ = volume.restrict (Ici 0)`) and
Jacobi (`μ = volume.restrict (Icc (-1) 1)`) instantiate on their own supports, not just `volume`.
The √w rescaling + `mkOfOrthogonalEqBot` plumbing, once, for any family. **Instantiation carries a
change of variables when the family is defined on a rescaled argument:** the Hermite case uses
`w = e^{-x²}`, `pₙ = Hₙ(·√2)`, `cₙ = n!√π` (so `pₙ·√w/√cₙ = ψₙ`), which is A1's probabilists'
relation transported by `u = x√2` — *not* `w = e^{-x²/2}` read off A1 directly.

### B3 — L²-product basis
A Hilbert basis of `L²(μ)` and one of `L²(ν)` give a Hilbert basis of `L²(μ ⊗ ν)` indexed by the
product; iterated, a basis of `L²(Measure.pi μ)` indexed by `Π i, κ i`. (Mathlib has only the
finite-dim algebraic `OrthonormalBasis.tensorProduct`.) Not special-function-specific.

**Acceptance.** B1 applied to the envelope `√w = e^{-x²/2}` (i.e. `g = f·e^{-x²/2}`, `f ∈ L²`); B2
reproducing Part A's basis from the orthogonality relation; B3 giving an ON basis of
`L²(volume.prod volume)` from two copies of a 1-D basis.

## Part C — Further instances (future; consume B)

*Not v1; recorded so Parts A/B are built generically enough to instantiate.*

- **Multidimensional Hermite basis** of `L²(ℝᵈ)` — `Ψ_α(x) = ∏ᵢ ψ_{αᵢ}(xᵢ)` — as the immediate
  B3 ∘ A instantiation.
- **Laguerre basis** of `L²([0,∞), x^α e^{-x})` and **Jacobi basis** of `L²([-1,1], (1-x)^α(1+x)^β)`:
  each is B2 applied to that family's orthogonality relation plus its completeness (B1, or
  Weierstrass density on the compact Jacobi interval). **Only the completeness + basis** is in scope
  here; the Laguerre/Jacobi polynomial identities are inputs.

## Dependency ordering

Build **A concretely first** (it is the v1 and the proving ground for the determinacy argument),
then **factor B1/B2 out** of A's completeness/orthonormality proofs into the family-agnostic lemmas
— so B is validated by reproducing A, not speculative. **B3** is independent of A/B1/B2 and can land
in parallel. **C** consumes A + B and is out of the v1 milestone.

## References

- G. Szegő, *Orthogonal Polynomials*, AMS Colloq. 23 (Chs. II–V).
- N. I. Akhiezer, *The Classical Moment Problem* (determinacy).
- B. Simon, *Szegő's Theorem and Its Descendants* (orthogonal polynomials and L² completeness).
- M. Reed, B. Simon, *Methods of Modern Mathematical Physics II*, §X.6.
- G. B. Folland, *Harmonic Analysis in Phase Space*, §1.
