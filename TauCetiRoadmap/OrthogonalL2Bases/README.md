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
- the **weight↔measure isometry** `L²(w·μ) ≃ₗᵢ L²(μ)` (multiplication by `√w`), so each family's
  basis is available in **both normalizations** — the bare polynomials as an ONB of the weighted
  measure `L²(w·μ)`, and their `√w`-envelope functions as an ONB of `L²(μ)` — from one construction;
- the **L²-product-basis** lemma (a Hilbert basis of `L²(μ ⊗ ν)` from bases of the factors).

Which normalization a consumer wants depends on the space they work over — a weighted / probability
`L²` (orthogonal-polynomial and polynomial-chaos expansions, moment and spectral problems) or
`L²(dx)` (eigenfunction expansions: the Hermite functions and QHO eigenstates, Sturm–Liouville / PDE,
signal processing). The two are isometric but are different `HilbertBasis` objects on different
spaces, so the area provides **both**, related by the isometry, rather than privileging one.

The **Hermite basis of `L²(ℝ)`** is the worked anchor (**Part A**, the v1 deliverable) from which the
family-agnostic spine (**Part B**) is abstracted. The spine is then **exercised by a second family —
the Chebyshev basis of `L²([-1,1])`** (**Part C**), whose orthogonality relation is already in
Mathlib and which tests the bridge on a compact weighted measure (not the Gaussian); and it
yields the **multidimensional Hermite basis** (**Part D**, a later milestone here). Laguerre and Jacobi are a
*separate* future roadmap — Mathlib has neither family, so grounding them means defining the
polynomials first.

### Scope boundary (what this area is, and is not)

This area provides **Hilbert-space structure**: completeness, `HilbertBasis`, Parseval, product
bases. The split is by *kind of statement*, and **everything is grounded** — it either exists in
Mathlib or is a target here (no dangling external dependencies):

- The family's **orthogonality relation** `∫ pₘ pₙ w = cₙδ` is an existing Mathlib lemma where one
  exists, and otherwise a **target of this roadmap**. For Hermite it is **A1**
  (`integral_hermite_mul_hermite_mul_gaussian`, below): Mathlib has `Polynomial.hermite` and
  `integral_gaussian`, but *not* the weighted orthogonality integral, so this roadmap proves it.
- The family's **polynomial calculus** (recurrences, generating functions, Rodrigues) is taken from
  Mathlib's `Polynomial.*` API where present; the Hermite-specific pieces Mathlib lacks (the
  derivative identity, the generating function) are likewise **A1 targets**.
- The general bridge **B2** takes the orthogonality relation as a *lemma hypothesis* — so it is
  family-agnostic and grounded by construction (a parametrized theorem, not a dependency).

The line is: an *integral identity* is consumed (as a Mathlib lemma or a roadmap target); a
*Hilbert-space theorem* ("...hence the normalized functions are a complete orthonormal basis of
L²") is this area's contribution.

## Generality bar (decide up front; do not silently specialize)

- **The basis layer is family-agnostic and scalar-generic.** Bases are stated through the
  measure-generic `HilbertBasis ι 𝕜 (Lp 𝕜 2 μ)` API over `[RCLike 𝕜]` (the real pointwise
  functions cast via `algebraMap ℝ 𝕜`); do **not** duplicate the API for `ℝ` and `ℂ` separately.
- **Pin the domain.** The polynomial bridge (B2) and the Hermite/Chebyshev instances fix the
  reference measure to **`μ : Measure ℝ`** — the bridge evaluates `Polynomial.eval` (needs `ℝ`), and
  `ℝ` is where the compact-support and interval families (and the Laguerre/Jacobi-on-subsets follow-on)
  live. The `weightL2Isometry` primitive itself is **not** specialized — it is measure-theoretic and
  stated over an arbitrary measurable space; only the polynomial-facing layers are `ℝ`. Product/`pi`
  bases (B3) are over generic measurable factors.
- **Every basis milestone exports its element-level `coe_*`, not just the bundled term.** A
  `HilbertBasis` shipped only as a bundled term — without `⇑basis = explicit family` — is
  near-vacuous: bare existence of an `ℕ`- (resp. `ι×κ`-) indexed Hilbert basis is just a
  separability/cardinality fact and carries none of the Hermite/Chebyshev/tensor content. So
  each basis target below additionally exports a **named** element-level lemma (`coe_*`),
  immediate from `HilbertBasis.coe_mkOfOrthogonalEqBot`, which downstream `coe_*` discharge
  obligations (e.g. the Gaussian Hilbert / Wiener-chaos consumer) consume — a bundle-only
  export is green but undischargeable.
- **The bridge is parametrized by the orthogonality relation.** Part B's bridge (B2) takes the
  relation `∫ pₘ pₙ w = cₙδ` (with `cₙ > 0`) and a polynomial-density/completeness hypothesis as
  **arguments** — family-agnostic and grounded by construction. The Hermite instance supplies that
  relation from **A1** (a target here); each family's polynomial identities are reused from
  Mathlib where present, and otherwise are targets (Hermite's are A1).
- **Weights are classical; one completeness mechanism.** Gaussian `e^{-x²}` (Hermite) and the
  Chebyshev weight `(√(1-x²))⁻¹` on `[-1,1]` both complete via B1's moment determinacy — its
  hypothesis (finite exponential moments) holds for Gaussian decay *and* automatically for compact
  support. (Laguerre `x^α e^{-x}` / Jacobi `(1-x)^α(1+x)^β` are a separate roadmap.)
- **Measures named explicitly.** `volume` on `ℝ`/intervals, `Measure.pi`/`Measure.prod` for
  products — never inferred — so the product-basis lemma and the multi-d instances are extensions,
  not refactors.
- **Deliberately out of scope:** the general orthogonal-polynomials-**of-a-measure** construction
  (Gram–Schmidt), Favard's theorem / three-term recurrences, and every per-family identity. Those
  are the polynomial-identity layer, not the L²-basis layer this area owns.

## What Mathlib already has (consume)

- Algebraic families: `Polynomial.hermite` (+ `hermite_succ`, `deriv_gaussian_eq_hermite_mul_gaussian`),
  `Polynomial.Chebyshev.T`, `Polynomial.shiftedLegendre`.
- **Chebyshev orthogonality, already proved** (Part C's input), w.r.t.
  `measureT = (volume.withDensity (√(1-x²))⁻¹).restrict (Ioc (-1) 1)`:
  `integral_eval_T_real_mul_eval_T_real_measureT_of_ne` (off-diagonal `= 0`),
  `integral_eval_T_real_mul_self_measureT_zero` (`= π`),
  `integral_T_real_mul_self_measureT_of_ne_zero` (`= π/2`), and `T_real_cos`
  (`(T ℝ n).eval (cos θ) = cos (n θ)`).
- Hilbert-basis API: `HilbertBasis`, `HilbertBasis.mkOfOrthogonalEqBot`,
  `HilbertBasis.hasSum_inner_mul_inner`, `HilbertBasis.tsum_inner_mul_inner`; `Orthonormal`; `MemLp.toLp`.
- `OrthonormalBasis.tensorProduct` — **finite-dimensional only** (the algebraic tensor of finite
  bases); there is no completed / `L²(Measure.pi)` product-basis API.
- `integral_gaussian`; the Fourier-transform API (`Fourier.fourierIntegral`) for the determinacy proof.
- `ProbabilityTheory.gaussianReal` (+ `gaussianReal_of_var_ne_zero`,
  `integral_withDensity_eq_integral_smul`) for the measure-side basis (A3′). **Gaps the isometry
  enhancement fills:** there is no transport of a `HilbertBasis` along a `≃ₗᵢ` (only `ofRepr`), and no
  `L²(withDensity w) ≃ₗᵢ L²(μ)` change-of-measure isometry.

## What is missing (build here)

The completeness toolkit (the moment-determinacy mechanism), the relation→`HilbertBasis` bridge, and the L²-product-basis
lemma; plus their instances: the Hermite basis (Part A) and the Chebyshev basis (Part C), and the
multidimensional Hermite basis (Part D). (Laguerre/Jacobi are a separate future roadmap.)

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
- **Milestone (Lebesgue form)** `integral_hermite_mul_hermite_mul_gaussian`:
  `∫ x, Hₘ(x)·Hₙ(x)·e^{-x²/2} = if m = n then n!·√(2π) else 0`.
- **Milestone (Gaussian-measure form)** `integral_hermite_mul_hermite_gaussianReal`:
  `∫ x, Hₘ(x)·Hₙ(x) ∂(gaussianReal 0 1) = if m = n then n! else 0` — the Lebesgue form above divided by
  the `√(2π)` density (`integral_withDensity_eq_integral_smul`); the form the measure-side basis (A3,
  below) consumes directly.
- *Acceptance:* `H₀=1, H₁=X, H₂=X²-1`; `⟨H₀,H₀⟩=⟨H₁,H₁⟩=√(2π)`; `⟨H₀,H₂⟩=0`; gen. fn. at `t=0` is `1`.

### A2 — The Hermite functions `ψₙ : ℝ → ℝ`
- `hermiteFunction n x = cₙ · aeval (x·√2) (hermite n) · e^{-x²/2}`, with regularity:
  `Continuous`, `ContDiff ℝ ⊤`, `MemLp _ 2 volume`, and a `SchwartzMap ℝ ℝ` with this underlying
  function. Companion API: parity `ψₙ(-x)=(-1)ⁿψₙ(x)`, `ψ₀`/`ψ₁` `@[simp]` forms, `‖ψₙ‖₂=1`.
- **Ladder relations** (pointwise/Schwartz-level): `x·ψₙ = √((n+1)/2)ψ_{n+1} + √(n/2)ψ_{n-1}` and
  `ψₙ' = √(n/2)ψ_{n-1} - √((n+1)/2)ψ_{n+1}`, whence `aψₙ=√n ψ_{n-1}`, `a†ψₙ=√(n+1)ψ_{n+1}`.
  Packaging `a, a†` as operators on `L²` with `[a,a†]=1` is a deliberate downstream target — state
  these ladder identities at the pointwise/`SchwartzMap` level so they elevate to continuous linear
  operators on `𝒮(ℝ)` later (the GFF / tempered-distribution use) without re-proving.
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
  The `𝕜 = ℂ` case reduces to this real one: each `ψₙ` is real, so `f ∈ L²(ℝ;ℂ)` orthogonal to every
  `ψₙ` forces `Re f` and `Im f` each orthogonal to every `ψₙ`, hence both vanish — the step that
  makes "`ℝ` and `ℂ` are one theorem" literally true.
- **Fourier eigenfunction** (a target; the key structural fact about this basis after
  orthonormality/completeness, and not in Mathlib): the Hermite functions diagonalize the Fourier
  transform, `𝓕 ψₙ = (-i)ⁿ ψₙ`. **Pin the convention:** `(-i)ⁿ` is the eigenvalue for the *unitary
  angular-frequency* transform; under Mathlib's `Fourier.fourierIntegral` (the `e^{-2πixξ}`
  convention A3's completeness already uses), `e^{-x²/2}` is **not** self-dual (the self-dual scale
  is `e^{-πx²}`), so state the eigen-relation for the `2π`-scaled functions or carry the dilation.
  The `fourierIntegral` machinery is already imported here.
- **Headline milestone** (for every `[RCLike 𝕜]`):
  `hermiteHilbertBasis 𝕜 : HilbertBasis ℕ 𝕜 (Lp 𝕜 2 volume)` (via `mkOfOrthogonalEqBot`), with
  Parseval in `tsum_inner_mul_inner` orientation `∑' n, ⟪f,ψₙ⟫·⟪ψₙ,g⟫ = ⟪f,g⟫`. `𝕜=ℝ` and `𝕜=ℂ`
  are one theorem. (Over `ℂ` the inner product is sesquilinear, so the Parseval proof for the
  `algebraMap ℝ 𝕜`-lifted *real* basis carries `starRingEnd` bookkeeping even though the `ψₙ` are
  real — a known boilerplate cost, not a design issue.)
- **Element-level export** (a named deliverable, not just the bundled term):
  `coe_hermiteHilbertBasis : ⇑(hermiteHilbertBasis 𝕜) = hermiteFunctionLp 𝕜` — immediate from
  `HilbertBasis.coe_mkOfOrthogonalEqBot`. This is what makes the headline non-vacuous (the
  bundled `HilbertBasis ℕ` alone is a separability fact); the Gaussian/Wiener-chaos consumer
  discharges its `coe_*` obligation against this lemma.
- *Acceptance:* Parseval for an explicit `f`; coordinates of `ψ₀` are `Finsupp.single 0 1`;
  `‖f‖² = ∑' n, ‖⟪ψₙ,f⟫‖²`; both `ℝ` and `ℂ` instantiate.

### A3′ — The Gaussian Hermite basis (measure side; the enhancement's named instance)
The bare-polynomial ONB on the **probability measure** rather than `L²(dx)` — the ONB any `L²(N(0,1))`
expansion is taken against.
- **`gaussianHermiteHilbertBasis 𝕜 : HilbertBasis ℕ 𝕜 (Lp 𝕜 2 (gaussianReal 0 1))`** — the bare
  normalized `Hₙ/√(n!)`; the immediate instance of `hilbertBasisOfWeightedMeasure` (B2) with
  `μ = volume`, `w = gaussianPDFReal 0 1`, `cₙ = n!` (since `gaussianReal 0 1 = volume.withDensity
  (gaussianPDF 0 1)`, `gaussianReal_of_var_ne_zero`), the orthogonality being the A1 measure form.
- **`coe_gaussianHermiteHilbertBasis`** —
  `⇑(gaussianHermiteHilbertBasis n) =ᵐ[N(0,1)] fun x => algebraMap ℝ 𝕜 (aeval x (hermite n)/√(n!))`.
- **`memLp_hermite_gaussianReal (n) (v : ℝ≥0)`** — variance-general `L²` membership of `Hₙ/√(n!)`
  under `gaussianReal 0 v` (the `Hₙ` of a centered Gaussian of any variance).
- **Relation to the Lebesgue Hermite-function basis — note the dilation.** Applying
  `weightL2Isometry` (multiplication by `√(gaussianPDFReal 0 1) = (2π)^{-1/4} e^{-x²/4}`) to
  `gaussianHermiteHilbertBasis` does **not** give the A3 `hermiteHilbertBasis` *as is*: the image is
  `x ↦ (2π)^{-1/4} Hₙ(x) e^{-x²/4} / √(n!) = 2^{-1/4} · ψₙ(x/√2)`, the **dilated** Hermite-function
  basis, because v1's `ψₙ(x) = (n!√π)^{-1/2} Hₙ(x√2) e^{-x²/2}` is built on the rescaled argument
  `x√2`. So the two named bases are related by `weightL2Isometry` **plus the `u = x√2` dilation**, not
  by the isometry alone. The corresponding Lean lemma
  `weightL2Isometry_gaussianHermiteHilbertBasis_apply` (image `= 2^{-1/4} ψₙ(·/√2)`) lands together
  with the A2 `ψₙ` object API it references. (One could instead base the
  weighted side on `w = e^{-x²}`, `pₙ = Hₙ(·√2)`, i.e. `N(0,½)`, to make the image exactly `ψₙ`; we
  keep the standard `N(0,1)` normalization that consumers expect and carry the dilation explicitly.)
- *Acceptance:* `⟨H₀,H₀⟩=⟨H₁,H₁⟩=1`, `⟨H₀,H₂⟩=0` under `N(0,1)`; and the dilation relation above
  holds (image `= 2^{-1/4} ψₙ(·/√2)`).

## Part B — The family-agnostic spine (the reusable layer)

The three pieces that Part A's completeness/basis argument factors into, stated without reference to
any particular family.

### B1 — Completeness toolkit (moment determinacy)
*A polynomial-dense weighted system is complete in its L² space. One lemma covers both families
below — the Gaussian (unbounded support) and the Chebyshev (compact support) cases.*

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

**Compact support (e.g. Chebyshev) uses the *same* lemma — no separate route.**
A compactly-supported `g` has *all* exponential moments finite automatically (`∫ e^{a|x|}|g| < ∞`
over a bounded interval), so the entire-`𝓕` / vanishing-moments argument above applies unchanged.
Chebyshev (Part C) therefore consumes B1 directly; it exercises the spine through B2's
**σ-finite-`μ` genericity** (a compact weighted measure, not the Gaussian) rather than through a
second completeness mechanism. (So no Stone–Weierstrass route is needed.)

### B2 — Orthogonality relation → `HilbertBasis`
Given polynomials `p : ℕ → ℝ[X]`, a weight `w` with `0 ≤ w` **and `0 < w` a.e.** (else `g·√w = 0`
fails to force `g = 0`), the relation `∫ pₘ pₙ w ∂μ = cₙ δ` with `cₙ > 0`, and completeness (B1),
the √w-normalized functions `x ↦ pₙ(x)·√(w x)/√(cₙ)` are orthonormal in `L²(μ)` and, with
completeness, form a `HilbertBasis ℕ 𝕜 (Lp 𝕜 2 μ)` (cast via `algebraMap ℝ 𝕜`), with Parseval —
**for any σ-finite reference measure `μ` on `ℝ`**, so the **Chebyshev** instance (Part C) lands on
`[-1,1]` — either as `μ = μ_T` (the Chebyshev measure) with `w = 1`, or as `μ = volume.restrict
[-1,1]` with `w = (√(1-x²))⁻¹` — not just `volume` on `ℝ`. The √w rescaling +
`mkOfOrthogonalEqBot` plumbing, once, for any family. **Instantiation carries a
change of variables when the family is defined on a rescaled argument:** the Hermite case uses
`w = e^{-x²}`, `pₙ = Hₙ(·√2)`, `cₙ = n!√π` (so `pₙ·√w/√cₙ = ψₙ`), which is A1's probabilists'
relation transported by `u = x√2` — *not* `w = e^{-x²/2}` read off A1 directly.

**Element-level export** (a named deliverable): the bridge ships `coe_*` for its output
basis — `⇑(ofOrthogonality …) = fun n => ((pₙ · √w / √cₙ : ℝ → ℝ) cast to Lp 𝕜 2 μ)`, the
normalized family — so the Hermite (A3) and Chebyshev (Part C) instances obtain their
`coe_*` by **specialization**, not re-derivation. Free from
`HilbertBasis.coe_mkOfOrthogonalEqBot`; required because a bundle-only bridge output is green
but undischargeable downstream.

**Both normalizations via the weight↔measure isometry (the enhancement).** Two new primitives — both
genuine Mathlib gaps — make B2's basis available on either side without re-proof:
- **`weightL2Isometry (μ : Measure α) (w) (hwpos) (hwm) : L²(w·μ) ≃ₗᵢ[𝕜] L²(μ)`**, multiplication by
  `√w` (`w·μ := μ.withDensity (ENNReal.ofReal ∘ w)`); an *equivalence* exactly because `0 < w` a.e.
  (`‖√w·f‖²_{L²(μ)} = ∫ w|f|² = ‖f‖²_{L²(w·μ)}`). The isometry is purely measure-theoretic, so stated
  over an **arbitrary** measurable `α` (only the polynomial bridge below needs `Measure ℝ`); it ships
  the element-level `weightL2Isometry_apply` (a.e. `= √w · f`) as its anti-vacuity pin. Both this and
  `mapₗᵢ` are general-purpose and are flagged as **upstream-Mathlib candidates**.
- **`HilbertBasis.mapₗᵢ (b) (e : E ≃ₗᵢ F) : HilbertBasis ι 𝕜 F`** with `@[simp] mapₗᵢ_apply`
  (`ofRepr (e.symm.trans b.repr)`; Mathlib has `ofRepr` but no `≃ₗᵢ`-transport).

So alongside the `√w`-envelope basis of `L²(μ)` above, the bridge also yields the **bare-polynomial
basis of the weighted measure** `hilbertBasisOfWeightedMeasure : HilbertBasis ℕ 𝕜 (Lp 𝕜 2 (w·μ))` (the
`pₙ/√cₙ`, with its own `coe_*` — orthogonal polynomials are *natively* an ONB of their weighted `L²`,
so this needs no rescaling). The two are `mapₗᵢ`-images of each other under `weightL2Isometry` — **up
to the rescaling-argument change of variables noted above**: for a family defined on a rescaled
argument (Hermite's `Hₙ(x√2)`) the function-side basis carries a dilation, so the bare isometry image
of the weighted-measure basis is the *dilated* function basis, not the un-dilated one (see A3′). A
consumer picks the normalization their space wants. (Chebyshev, Part C, lands its basis directly on
the weighted `measureT` this way — no dilation, since `Tₙ` is not on a rescaled argument; the Gaussian
instance is A3′.)

### B3 — L²-product basis
**The load-bearing milestone is completeness, not orthonormality.** Orthonormality of the products
`ψᵢ(x)·φⱼ(y)` is the easy Fubini half; the real theorem is that the algebraic tensor
`L²(μ) ⊗ L²(ν)` is **dense** in `L²(μ ⊗ ν)` (equivalently, the products are a *complete* orthonormal
system), which needs `μ, ν` **σ-finite** — state `[SigmaFinite μ] [SigmaFinite ν]` explicitly.
Mathlib's `OrthonormalBasis.tensorProduct` is the abstract tensor with *finite-index* hypotheses
(`[Fintype ι₁] [Fintype ι₂]`), so it does **not** give the concrete `L²(μ.prod ν)` statement — this
density result is the gap B3 fills, and the milestone must read as that, not as cheaper.

**Element-level export** (a named deliverable):
`coe_productHilbertBasis : ⇑(productHilbertBasis b c) = fun ij => (b ij.1) ⊗ (c ij.2)` — the
pointwise product `(x, y) ↦ (b i) x · (c j) y` in `Lp 𝕜 2 (μ.prod ν)` — so the multi-index
`Π i, ℕ` and the `B3 ∘ A` multi-dimensional Hermite instances inherit their `coe_*` by
iteration rather than re-proving the tensor characterization each time.

**Index-generic** (this resolves the `ℕ`-vs-product question): for Hilbert bases of `L²(μ)` and
`L²(ν)` indexed by *arbitrary* types `ι₁, ι₂`, B3 produces a Hilbert basis of `L²(μ ⊗ ν)` indexed
by `ι₁ × ι₂`; iterated over a finite family, a basis of `L²(Measure.pi μ)` indexed by `Π i, κ i`.
The family bridges (B2) are indexed by `ℕ` (degree), and B3 **consumes** those as the `ι = ℕ` case —
so the multidimensional basis is indexed by `Π i, ℕ` (multi-indices), and **B2 need not be
generalized away from `ℕ`**: the lift to products lives entirely in B3. Not special-function-specific.

**Acceptance.** B1 applied to the envelope `√w = e^{-x²/2}` (i.e. `g = f·e^{-x²/2}`, `f ∈ L²`); B2
reproducing Part A's basis from the orthogonality relation; B3 giving an ON basis of
`L²(volume.prod volume)` from two copies of a 1-D basis.

## Part C — A second family: the Chebyshev basis of `L²([-1,1])`

A second instantiation, so the abstract spine (B1–B3) is **exercised by more than one family** —
the point of building the spine at all. The **orthogonality relation is an existing Mathlib input**;
the basis assembly + completeness are the targets (named below). Chebyshev differs from Hermite not
in the completeness *mechanism* (it reuses B1) but in **B2's measure** — a compact weighted measure
rather than the Gaussian — so it tests the σ-finite-`μ` genericity of the bridge.

- **Inputs (existing Mathlib).** The polynomials `Polynomial.Chebyshev.T` (`ℤ`-indexed; the basis
  uses `n : ℕ`), orthogonal w.r.t. the Chebyshev measure
  `measureT = (volume.withDensity (√(1-x²))⁻¹).restrict (Ioc (-1) 1)`. The orthogonality is already
  proved: `integral_eval_T_real_mul_eval_T_real_measureT_of_ne` (off-diagonal `= 0`, `n ≠ m`),
  `integral_eval_T_real_mul_self_measureT_zero` (`= π`), and `integral_T_real_mul_self_measureT_of_ne_zero`
  (`= π/2`). (`integral_eval_T_real_mul_eval_T_real_measureT` is the product-to-sum identity, not the
  vanishing.) Also `T_real_cos` (`(T ℝ n).eval (cos θ) = cos (n θ)`).
- **Completeness reuses B1** (no new route): `measureT` is compactly supported, so a `g ∈ L²(measureT)`
  orthogonal to every `Tₙ` yields a compactly-supported `L¹` function with all exponential moments
  finite and all polynomial moments zero — exactly B1's hypothesis — hence `g = 0`.
- **Milestone:** `chebyshevHilbertBasis 𝕜 : HilbertBasis ℕ 𝕜 (Lp 𝕜 2 measureT)` (roadmap target) —
  the normalized `Tₙ/√cₙ` (`c₀ = π`, `cₙ = π/2`), assembled by **B2** from the Mathlib orthogonality
  + B1 completeness: the bridge demonstrated on a non-Gaussian measure.
- **Open targets this entails** (so "grounded" is honest): `IsFiniteMeasure measureT` (derivable,
  currently no instance); the compactly-supported instance of B1's moment lemma; and the
  real→`[RCLike 𝕜]` cast of the completeness.
- *Acceptance:* `⟨T₀,T₀⟩ = π`, `⟨T₁,T₁⟩ = π/2`, `⟨T₀,T₁⟩ = 0`; and (a *target*, via
  `integral_measureT_eq_integral_cos` + a unitary-transfer statement, not from `T_real_cos` alone)
  `chebyshevHilbertBasis` corresponds to the cosine basis under `x = cos θ`.

## Part D — The multidimensional Hermite basis (a later milestone of this roadmap; consumes B3)

*A grounded, sequenced milestone — not "future"/optional: it consumes only B3 (which lands in this
enhancement) and `A`/`A3′`, and its targets `piHilbertBasis` / `gaussianHermitePiBasis` are stated in
`Targets.lean`. Sequenced after B3, but in scope here.*

- **Multidimensional Hermite basis** of `L²(ℝᵈ)` — `Ψ_α(x) = ∏ᵢ ψ_{αᵢ}(xᵢ)`, `α : ι → ℕ` — the
  immediate `B3 ∘ A` instantiation: B3 over `ι` copies of the 1-D Hermite basis (A3), a
  `HilbertBasis (ι → ℕ) 𝕜 (Lp 𝕜 2 (Measure.pi (fun _ => volume)))`.
- **Measure-side multidimensional basis** `gaussianHermitePiBasis (ι) [Fintype ι] : HilbertBasis
  (ι → ℕ) 𝕜 (Lp 𝕜 2 (Measure.pi (fun _ => gaussianReal 0 1)))` — `Ψ_α = ∏ᵢ Hₐᵢ/√(αᵢ!)` on `L²(γ^ι)`,
  the `B3 ∘ A3′` instantiation (with `coe_gaussianHermitePiBasis`); the standard Gaussian
  measure-side analogue of the basis above — related to it by the **coordinatewise** `weightL2Isometry`
  + `u = xᵢ√2` dilation (same caveat as A3′, per coordinate), not by the isometry alone.

**A separate future roadmap:** Laguerre and Jacobi L² bases. Unlike Chebyshev, **Mathlib has neither
the Laguerre nor the Jacobi polynomials**, so grounding them means defining the families first —
which belongs in its own roadmap, not here.

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
