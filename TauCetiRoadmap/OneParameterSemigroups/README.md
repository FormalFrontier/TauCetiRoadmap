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
  `LinearPMap` / submodule, never a total operator. Mathlib's `resolvent`/`spectrum` are
  **Banach-algebra-only**, so an unbounded generator needs its **own** resolvent notion
  (`λ ∈ ρ(A)` iff `λ·I − A : D(A) → X` is a bijection with bounded inverse); add a **bridge
  lemma** identifying it with Mathlib's `resolvent` in the bounded (`domain = ⊤`) case, rather
  than duplicating effort.
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
  adjoint, cores). Tie the generator and its domain to these; the generator's resolvent needs
  its own notion (it is not a Banach-algebra element — see the generality bar), bridged to
  Mathlib's `resolvent` in the bounded case rather than duplicated.
- **The Bochner integral** (`MeasureTheory/Integral/Bochner/*`): the resolvent is a
  **pointwise** `X`-valued Bochner integral `R(λ)x = ∫₀^∞ e^{−λt} S(t)x dt`. ⚠ A general C₀
  semigroup is only *strongly* continuous, so `t ↦ S(t)` need not be norm-measurable as a
  `ContinuousLinearMap` (`B(X)` is generally non-separable) — integrate **pointwise** in `x`,
  then bundle the result into a `ContinuousLinearMap`. Plus dominated convergence, Fubini,
  the `Ioi`/`integral_comp_add_right` lemmas.
- **Fourier analysis** (`Analysis/Fourier/*`): `FourierTransform`, inversion, Plancherel,
  and characteristic-function uniqueness of finite measures — the spatial half of Bochner.
  ⚠ Mind Mathlib's `2π` convention (`e^{-2πi⟨·,·⟩}`, unitary, no prefactors).
- **Measure theory:** `Measure`/`IsFiniteMeasure`, `charFun`
  (`MeasureTheory/Measure/CharacteristicFunction`), **Lévy continuity**, **Prokhorov**
  (`MeasureTheory/Measure/Prokhorov`), **Riesz–Markov–Kakutani**
  (`MeasureTheory/Integral/RieszMarkovKakutani`) — the measure-extraction toolkit. *(Confirm
  the exact module paths against the pinned Mathlib commit before relying on them.)*
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
- **The generator determines the semigroup uniquely**; the generator is **closed**, with
  `S(t)·D(A) ⊆ D(A)` and `A S(t)x = S(t) A x`, and `t ↦ S(t)x` differentiable for `x ∈ D(A)`.
- **Bounded ↔ uniformly continuous:** `A` is bounded (`domain = ⊤`) iff the semigroup is
  uniformly (norm-) continuous; plus the bounded-perturbation theorem.
- **Resolvent theory** (its own unbounded-resolvent notion + the bridge lemma above):
  - `R(λ,A)x = ∫₀^∞ e^{−λt} S(t)x dt` (pointwise Bochner integral) for **real** `λ > ω` (use
    a complexification for the complex resolvent set and the analyticity below);
  - the **resolvent identity** `R(λ,A) − R(μ,A) = (μ − λ) R(λ,A) R(μ,A)`;
  - **analyticity** of `λ ↦ R(λ,A)` on the resolvent set;
  - the **derivative / power formulas** (for `n ≥ 1`) `R(λ,A)ⁿ x = ∫₀^∞ tⁿ⁻¹/(n−1)! · e^{−λt}
    S(t)x dt`, with `dᵏR(λ,A)/dλᵏ = (−1)ᵏ k! · R(λ,A)^{k+1}`;
  - the **iterated-resolvent bounds** (for `λ > ω`, `n ≥ 1`) `‖R(λ,A)ⁿ‖ ≤ M / (λ − ω)ⁿ`
    (Hille–Yosida bound, general `(M, ω)`; contraction `‖R(λ,A)‖ ≤ 1/λ` is the corollary).

**Milestone — Hille–Yosida generation theorem.** A densely-defined operator with the
resolvent bounds above generates a C₀ semigroup; the contraction case via **Lumer–Phillips**:
densely-defined dissipative `A` with a **range condition** (`∃ λ₀ > 0` with `λ₀ − A`
surjective) generates a contraction semigroup. ⚠ **Genuinely open / build-here.** Discharge
via **Yosida approximation**: `Aλ = λ² R(λ,A) − λI` (bounded, by the resolvent API), each
generating a uniformly continuous contraction semigroup `e^{tAλ}`. ⚠ `S` does not exist yet,
so do not phrase this as convergence "to `S(t)x`": instead prove the `e^{tAλ}x` are **Cauchy
uniformly on compact `t`-intervals**, *define* `S(t)x` as the limit, and then identify its
generator as `A`. Sub-lemmas: generator-domain density; the stability/approximation estimates
+ the Cauchy property of the exponentials.
Refs: Engel–Nagel II.3.5–3.8; Pazy Ch. 1.

```lean
variable {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]

-- resolvent identity, analyticity, power bounds (the developed API), then:
-- variable (M ω : ℝ)   -- growth constants; 1 ≤ M
-- theorem hilleYosida_generation (A : DenseLinearOperator X)
--     (hρ : ∀ l : ℝ, ω < l → l ∈ resolventSet A)          -- (ω,∞) ⊆ ρ(A)
--     (hbound : ∀ n, 1 ≤ n → ∀ l : ℝ, ω < l → ‖resolvent A l ^ n‖ ≤ M / (l - ω) ^ n) :
--     ∃ S : StronglyContinuousSemigroup X, S.generator = A ∧ S.HasGrowthBound M ω
-- theorem lumerPhillips (A : DenseLinearOperator X)
--     (hd : A.IsDissipative)
--     (hr : ∃ l₀ > 0, Surjective (l₀ • 1 - A))    -- surjectivity of (λ₀·I − A) : D(A) → X
--     : ∃ S : ContractionSemigroup X, S.generator = A
```

**Acceptance examples.** The multiplication semigroup `S t f = e^{−t·m} f` (generator `−m`)
and `e^{tA}` for bounded `A`; the resolvent matches the Neumann series `R(λ) = (λ−A)⁻¹`; the
resolvent identity and `‖R(λ)‖ ≤ 1/λ` hold on these concretely.

## Part B — Completely monotone (and Bernstein) functions

**Objects.** `IsCompletelyMonotone` — **bundle smoothness** with the sign condition:
`ContDiffOn ℝ ⊤ f (Set.Ici 0) ∧ ∀ n, ∀ t ≥ 0, 0 ≤ (−1)ⁿ · iteratedDeriv n f t`. ⚠ The
smoothness clause is essential: `iteratedDeriv` is total and defaults to `0` where `f` is not
differentiable, so `0 ≤ 0` would let a non-smooth `f` pass *vacuously*. The related
**Bernstein functions** (nonnegative, with completely monotone derivative).

**API to develop.**
- Closure: completely monotone functions are closed under **sums, nonnegative scalar
  multiples, products, and pointwise limits**; **composition** `g ∘ f` of completely monotone
  `g` with a Bernstein function `f` is completely monotone; derivative/integral closure.
- The **extreme rays**: the functions `t ↦ e^{−tx}` (`x ≥ 0`) are the building blocks, and the
  representation below realizes a general completely monotone function as a mixture of them.
- The **Stieltjes / Bernstein-function relationships** (completely monotone ↔ Bernstein via
  the standard correspondences); the **Lévy–Khinchine representation** of Bernstein functions.

**Milestone — Bernstein's theorem.** `f` completely monotone **on the closed `[0,∞)`** (so
`f(0⁺) < ∞`) **iff** it is the Laplace transform of a unique **finite** positive measure on
`[0,∞)`. ⚠ Complete monotonicity on the *open* `(0,∞)` alone yields only a general (possibly
infinite) positive measure — e.g. `1/t = ∫₀^∞ e^{−tx} dx` is completely monotone with the
infinite Lebesgue representing measure (Hausdorff–Bernstein–Widder). Finiteness is exactly the
`f(0⁺) < ∞` criterion, which our `Set.Ici 0` definition above builds in. Develop both
directions and uniqueness (Laplace-transform injectivity); measure extraction via Prokhorov
tightness.

```lean
-- theorem bernstein (f : ℝ → ℝ) :
--     IsCompletelyMonotone f ↔
--       ∃! μ : Measure ℝ, IsFiniteMeasure μ ∧ μ.support ⊆ Set.Ici 0 ∧
--         ∀ t ≥ 0, f t = ∫ x, Real.exp (-t * x) ∂μ
```

**Acceptance examples.** `e^{−t} → δ₁`; `1/(1+t) → e^{−x}dx`; closure used to build new
completely monotone functions from these.

## Part C — Positive-definite functions and Bochner's theorem

**Objects.** Continuous **positive-definite** functions. Define `IsPositiveDefinite`
**generically on `[AddCommMonoid M] [StarAddMonoid M]`**, then instantiate: on a
finite-dimensional real inner-product space `V` (involution `a⋆ = −a`), and on `ℝ≥0 × V`,
where the **product `StarAddMonoid` automatically supplies the BCR involution** `(t,a)⋆ = (t,−a)`
(`ℝ≥0` carries the trivial involution, `V` the negation) — no hand-coding. `IsSemigroupGroupPD`
is then this predicate on `ℝ≥0 × V`. (Stretch: an LCA group.)

**API to develop.**
- Basic properties: **closure under sums, products, Schur (pointwise) products**; for
  `F : M → ℂ`, conjugate symmetry, `(F 0).im = 0`, `0 ≤ (F 0).re`, and `‖F a‖ ≤ (F 0).re`
  (the Lean-typed form of `F(0) ≥ |F(a)|`); **continuity at `0` ⇒ uniform continuity**.
  ⚠ Pointwise limits preserve positive-definiteness but **not** continuity — that needs an
  extra hypothesis (e.g. locally uniform convergence).
- The **PD-function ↔ PD-kernel** equivalence (`K(a,b) = F(a − b)`), pullbacks, and the
  GNS/Kolmogorov decomposition; normalization `F(0) = 1`.
- The bridge lemma: a finite measure's Fourier transform is continuous positive-definite
  (`pd_quadratic_form_of_measure`).

**Milestone 1 — Bochner's theorem on `V`.** A function on a finite-dimensional real
inner-product space `V` is continuous and positive-definite **iff** it is the Fourier
transform of a finite positive measure on `V`. State it for general `V`, with `ℝᵈ` as a
corollary.

⚠ **Checked against the Mathlib source (v4.31, 2026-06-18; re-confirm against the pinned
commit before relying on it):** Mathlib's "Bochner" is the *integral*, and its
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
-- Mathlib Fourier convention (e^{-2πi⟨·,·⟩}); the real inner product is coerced to ℂ.
-- (Alternatively phrase via `fourierChar`/`charFun` directly.)

-- theorem bochner (F : V → ℂ) (hcont : Continuous F) (hpd : IsPositiveDefinite F) :
--     ∃! μ : Measure V, IsFiniteMeasure μ ∧
--       ∀ a, F a = ∫ q, Complex.exp (-2 * π * Complex.I * (⟪a, q⟫_ℝ : ℂ)) ∂μ
-- -- time lives in ℝ≥0, so the representing measure has the right support automatically:
-- theorem bcr_semigroup_bochner (F : ℝ≥0 × V → ℂ) (hpd : IsSemigroupGroupPD F) … :
--     ∃! μ : Measure (ℝ≥0 × V), IsFiniteMeasure μ ∧
--       ∀ t a, F (t, a) = ∫ (p, q), (Real.exp (-(t : ℝ) * p) : ℂ) *
--         Complex.exp (-2 * π * Complex.I * (⟪a, q⟫_ℝ : ℂ)) ∂μ
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
