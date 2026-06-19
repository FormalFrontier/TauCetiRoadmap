# Roadmap: one-parameter semigroups, completely monotone and positive-definite functions, and Bochner-type representations

Operator semigroups are the analytic backbone of evolution equations (heat, Fokker–Planck,
Schrödinger) and of Markov-process theory. Mathlib has the *static* functional-analysis
stack — Banach/Hilbert spaces, bounded operators, `spectrum` and `resolvent`, the
holomorphic functional calculus, the Bochner integral, Fourier theory, unbounded operators
via `LinearPMap` — but **not the dynamical layer**: strongly continuous (C₀) semigroups,
their generators and resolvents, the **Hille–Yosida** generation theorem, the theory of
**completely monotone** functions and **Bernstein's** representation theorem, **continuous
positive-definite functions** and **Bochner's** theorem, or the **Berg–Christensen–Ressel
(BCR)** representation for positive-definite functions on involutive semigroups.

The goal is to **build the reusable theory of these objects**, not to race to a handful of
named theorems. The bar for "done": a researcher in evolution equations, Markov semigroups,
or harmonic analysis finds the objects defined at their natural generality, equipped with
the basic API (closure properties, the standard identities, the connections to existing
Mathlib structures), so that the headline theorems are *consequences of a developed theory*
rather than isolated endpoints. A PR that proves a headline theorem but leaves the
surrounding object without its basic API is not yet what we want.

Suggested home: `TauCeti/Analysis/Semigroups/`, `TauCeti/Analysis/CompletelyMonotone/`,
`TauCeti/Analysis/PositiveDefinite/`, `TauCeti/Analysis/Bochner/`.

## Generality bar (decide these up front; do not silently specialize)

- **Semigroups: general C₀ first, contraction as a subclass.** Define general strongly
  continuous semigroups with a growth bound `‖S t‖ ≤ M e^{ω t}`; contraction semigroups
  (`M = 1, ω = 0`) are a subclass. State the Hille–Yosida bounds at the general `(M, ω)`
  level (`‖R(λ,A)ⁿ‖ ≤ M / (λ−ω)ⁿ`); the contraction case is the corollary, never the
  silent default.
- **Generators are unbounded.** The generator carries a **dense domain**; model it as a
  `LinearPMap` / submodule, never a total operator, and **relate its resolvent to Mathlib's
  existing `resolvent`/`spectrum`** (and to the bounded-operator resolvent when the
  generator is bounded), rather than introducing a parallel notion.
- **Bochner at its natural generality.** A continuous positive-definite function lives on a
  **general finite-dimensional real inner-product space** `V` (so `ℝ²` as `ℝ × ℝ`, or any
  finite-dim space, is covered) — *not* on hard-coded `Fin d` coordinates. State Bochner for
  such `V`. **Stretch goal:** a locally compact abelian group via Pontryagin duality (gated
  on Mathlib's LCA/Pontryagin support). The BCR involutive-semigroup representation is then
  stated over `[0,∞) × V`.
- **Spell hypotheses out; never bundle.** Positive-definiteness, complete monotonicity, the
  involution, growth bounds — each is a named predicate, stated explicitly, not folded into
  a conclusion.

## What Mathlib already has (consume, and connect to)

- **Operators & spectrum:** `ContinuousLinearMap`, operator norm, `spectrum`, **`resolvent`**,
  the holomorphic functional calculus; **unbounded operators** via `LinearPMap` (closure,
  adjoint, cores). The generator, its domain, and its resolvent should be *tied to* these,
  not duplicated.
- **The Bochner integral** (`MeasureTheory/Integral/Bochner/*`): the resolvent
  `∫₀^∞ e^{−λt} S t dt` is a Bochner integral of an operator-valued map; dominated
  convergence, Fubini, the `Ioi`/`integral_comp_add_right` lemmas.
- **Fourier analysis** (`Analysis/Fourier/*`): `FourierTransform`, inversion, Plancherel,
  and characteristic-function uniqueness of finite measures — the spatial half of Bochner.
  ⚠ Mind Mathlib's `2π` convention (`e^{-2πi⟨·,·⟩}`, unitary, no prefactors).
- **Measure theory:** `Measure`/`IsFiniteMeasure`, `charFun`
  (`Measure/CharacteristicFunction`), **Lévy continuity** (`Probability/CentralLimitTheorem`),
  **Prokhorov** (`Measure/Prokhorov`), **Riesz–Markov–Kakutani**
  (`Integral/RieszMarkovKakutani`) — the measure-extraction toolkit.
- **Real analysis:** `Real.exp`, Taylor's theorem with integral remainder, monotone/dominated
  convergence, `deriv`/iterated derivatives — for the completely-monotone theory.

## What is missing (build here)

The whole dynamical / representation-theoretic layer below is **absent upstream**. Build it
as developed theories, in dependency order (this is not a strict schedule). Each part lists
the **API to develop**, then the **representation theorem** as a milestone, then **acceptance
examples**.

---

## Part A — Strongly continuous semigroups

**Objects.** `StronglyContinuousSemigroup` (general C₀, with a growth bound), its subclass
`ContractionSemigroup`; the **generator** `A` with its dense domain `D(A)` (a `LinearPMap`);
the **resolvent** `R(λ,A)`.

**API to develop.**
- The semigroup laws, strong continuity, and the growth bound `‖S t‖ ≤ M e^{ω t}`
  (`existsGrowthBound`); the generator as the strong derivative at `0` on `D(A)`.
- **The generator determines the semigroup uniquely** (a generator-uniqueness theorem).
- **Resolvent theory**, tied to Mathlib's `resolvent`/`spectrum`:
  - `R(λ,A) = ∫₀^∞ e^{−λt} S t dt` as a Bochner integral, defined for `Re λ > ω`;
  - the **resolvent identity** `R(λ,A) − R(μ,A) = (μ − λ) R(λ,A) R(μ,A)`;
  - **analyticity** of `λ ↦ R(λ,A)` on the resolvent set;
  - the **derivative / power formulas** `R(λ,A)ⁿ = ∫₀^∞ tⁿ⁻¹/(n−1)! · e^{−λt} S t dt`;
  - the **iterated-resolvent bounds** `‖R(λ,A)ⁿ‖ ≤ M / (λ − ω)ⁿ` (Hille–Yosida bound, general
    `(M, ω)`; contraction `‖R(λ,A)‖ ≤ 1/λ` is the corollary).

**Milestone — Hille–Yosida generation theorem.** A densely-defined operator with the
resolvent bounds above generates a C₀ semigroup; the contraction case via **Lumer–Phillips**:
densely-defined dissipative `A` with a **range condition** (`∃ λ₀ > 0` with `λ₀ − A`
surjective) generates a contraction semigroup. ⚠ **Genuinely open / build-here.** Discharge
via **Yosida approximation**: `Aλ = λ² R(λ,A) − λI` (bounded, by the resolvent API); show each
`Aλ` generates `e^{tAλ}` and that `e^{tAλ} x` converges uniformly on compacts to `S(t)x` with
generator `A`. Sub-lemmas: generator-domain density; the approximation estimates +
convergence of the exponentials. Refs: Engel–Nagel II.3.5–3.8; Pazy Ch. 1.

```lean
variable {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]

-- resolvent identity, analyticity, power bounds (the developed API), then:
-- theorem hilleYosida_generation (A : DenseLinearOperator X)
--     (hbound : ∀ n (l : ℝ), ω < l → ‖resolvent A l ^ n‖ ≤ M / (l - ω) ^ n) :
--     ∃ S : StronglyContinuousSemigroup X, S.generator = A ∧ S.HasGrowthBound M ω
-- theorem lumerPhillips (A : DenseLinearOperator X)
--     (hd : A.IsDissipative) (hr : ∃ l₀ > 0, Surjective (l₀ • 1 - A)) :
--     ∃ S : ContractionSemigroup X, S.generator = A
```

**Acceptance examples.** The multiplication semigroup `S t f = e^{−t·m} f` (generator `−m`)
and `e^{tA}` for bounded `A`; the resolvent matches the Neumann series `R(λ) = (λ−A)⁻¹`; the
resolvent identity and `‖R(λ)‖ ≤ 1/λ` hold on these concretely.

## Part B — Completely monotone (and Bernstein) functions

**Objects.** `IsCompletelyMonotone` (`(−1)ⁿ f⁽ⁿ⁾ ≥ 0` on `(0,∞)`); the related
**Bernstein functions** (nonnegative with completely monotone derivative).

**API to develop.**
- Closure: completely monotone functions are closed under **sums, nonnegative scalar
  multiples, products, and pointwise limits**; **composition** `g ∘ f` of completely monotone
  `g` with a Bernstein function `f` is completely monotone; derivative/integral closure.
- The **extreme rays**: the functions `t ↦ e^{−tx}` (`x ≥ 0`) are the building blocks, and the
  representation below realizes a general completely monotone function as a mixture of them.
- The **Stieltjes / Bernstein-function relationships** (completely monotone ↔ Bernstein via
  the standard correspondences).

**Milestone — Bernstein's theorem.** `f` is completely monotone **iff** it is the Laplace
transform of a (unique) finite positive measure on `[0,∞)`. Develop both directions and the
uniqueness (Laplace-transform injectivity); measure extraction via Prokhorov tightness.

```lean
-- theorem bernstein (f : ℝ → ℝ) :
--     IsCompletelyMonotone f ↔
--       ∃! μ : Measure ℝ, IsFiniteMeasure μ ∧ μ.support ⊆ Set.Ici 0 ∧
--         ∀ t ≥ 0, f t = ∫ x, Real.exp (-t * x) ∂μ
```

**Acceptance examples.** `e^{−t} → δ₁`; `1/(1+t) → e^{−x}dx`; closure used to build new
completely monotone functions from these.

## Part C — Positive-definite functions and Bochner's theorem

**Objects.** Continuous **positive-definite** functions on a finite-dimensional real
inner-product space `V` (stretch: an LCA group); the **semigroup–group** positive-definite
predicate `IsSemigroupGroupPD` on `[0,∞) × V`, with its involution `(t, a) ↦ (t, −a)` stated
explicitly.

**API to develop.**
- Basic properties of positive-definite functions: **closure under sums, products, Schur
  (pointwise) products, and pointwise limits**; `F(0) ≥ |F(a)|`; **continuity at `0` ⇒ uniform
  continuity**; conjugate symmetry.
- The bridge lemma: a finite measure's Fourier transform is continuous positive-definite
  (`pd_quadratic_form_of_measure`).

**Milestone 1 — Bochner's theorem on `V`.** A function on a finite-dimensional real
inner-product space `V` is continuous and positive-definite **iff** it is the Fourier
transform of a finite positive measure on `V`. State it for general `V`, with `ℝᵈ` as a
corollary.

⚠ **Verified absent from Mathlib (v4.31):** Mathlib's "Bochner" is the *integral*, and its
positive-definiteness is only for *matrices* / quadratic forms — there is no
continuous-positive-definite-*function* notion, and no Bochner representation. So this is
build-here. Two routes: (i) the positive linear functional `f ↦ ∫ f̂ · φ` + Riesz–Markov, or
(ii) `charFun` + Lévy/Prokhorov tightness. **Stretch:** an LCA group via Pontryagin duality.

**Milestone 2 — BCR semigroup–Bochner (Berg–Christensen–Ressel 4.1.13).** A bounded
continuous positive-definite function on the involutive semigroup `[0,∞) × V` is the
Laplace–Fourier transform of a unique finite measure; develop existence (consuming Milestone
1) and uniqueness (`laplaceFourier_unique`, Fourier/Laplace injectivity, Mathlib-only).

```lean
variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]

-- theorem bochner (F : V → ℂ) (hcont : Continuous F) (hpd : IsPositiveDefinite F) :
--     ∃! μ : Measure V, IsFiniteMeasure μ ∧ ∀ a, F a = ∫ q, Complex.exp (I * ⟪a, q⟫) ∂μ
-- theorem bcr_semigroup_bochner (F : ℝ × V → ℂ) (hpd : IsSemigroupGroupPD F) … :
--     ∃! μ : Measure (ℝ × V), IsFiniteMeasure μ ∧ … ∧
--       ∀ t ≥ 0, ∀ a, F (t, a) = ∫ (p, q), Real.exp (-t * p) * Complex.exp (I * ⟪a, q⟫) ∂μ
```

**Acceptance examples.** Bochner on `V = ℝ` recovers the classical statement; the case
`V = 0` (no spatial variable) collapses BCR back to Bernstein; a Gaussian `a ↦ e^{−‖a‖²}` is
positive-definite, with the expected Gaussian representing measure.

---

## Dependency ordering

Part A (semigroups) and Part B (completely monotone) are independent and can proceed in
parallel; the Hille–Yosida resolvent API and the Bernstein representation are good early
targets. Part A's **generation theorem** (Yosida approximation) is build-here and can follow
the resolvent API. Part C builds on B for the `V = 0` consistency check; its **Bochner
theorem on `V`** (Milestone 1) is build-here and **gates** the BCR existence half, while BCR
uniqueness is independent and portable early.

## References

- K.-J. Engel, R. Nagel, *One-Parameter Semigroups for Linear Evolution Equations* (GTM 194,
  2000); A. Pazy, *Semigroups of Linear Operators and Applications to PDE* (1983) —
  C₀-semigroups, generators, resolvent theory, Hille–Yosida, Lumer–Phillips.
- R. Schilling, R. Song, Z. Vondraček, *Bernstein Functions: Theory and Applications* (de
  Gruyter, 2nd ed. 2012) — completely monotone / Bernstein functions and their structure.
- W. Rudin, *Fourier Analysis on Groups* (1962); G. Folland, *A Course in Abstract Harmonic
  Analysis* (2nd ed. 2016) — Bochner's theorem, positive-definite functions, Pontryagin
  duality (the stretch generality).
- C. Berg, J. P. R. Christensen, P. Ressel, *Harmonic Analysis on Semigroups* (GTM 100, 1984)
  — Theorem 4.1.13, positive-definite functions on involutive semigroups.
