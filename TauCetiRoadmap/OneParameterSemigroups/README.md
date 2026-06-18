# Roadmap: one-parameter semigroups, completely monotone functions, and BCR Bochner

Operator semigroups are the analytic backbone of evolution equations (heat, Fokker–Planck,
Schrödinger) and of Markov-process theory. Mathlib has the static functional-analysis stack
(Banach/Hilbert spaces, bounded operators, spectrum, the Bochner integral, Fourier theory)
but **not** the dynamical layer: strongly continuous (C₀) semigroups, their generators and
resolvents, the Hille–Yosida generation theorem, Bernstein's theorem on completely monotone
functions, or the Berg–Christensen–Ressel (BCR) Bochner theorem for positive-definite
functions on involutive semigroups.

The bar for "done": a researcher in evolution equations or Markov semigroups looks at this
material and says *"the C₀-semigroup / generator / resolvent API is here, in reusable form,
and the Hille–Yosida and Bochner-type representation theorems are available."*

> **Provenance note.** A substantial AI-authored development of this material already exists
> (`mrdouglasny/hille-yosida`, sorry-free, 0 project axioms), covering the Hille–Yosida
> resolvent identities, Bernstein's theorem, and the BCR semigroup-Bochner theorem. It is a
> natural source for "make existing material ready to Tau Ceti" PRs. Two adaptation tasks:
> it targets Lean v4.29.0 (Tau Ceti is on v4.31.0 — a Mathlib bump is needed), and its BCR
> *existence* half depends on a separate Bochner–Minlos package, so the **resolvent and
> Bernstein items below are the cleanly Mathlib-only first targets**; the BCR existence item
> needs a Mathlib-only route to the spatial Bochner theorem first.

## The end goal (v1)

The three pillars, each a standalone, reusable theorem about contraction C₀-semigroups on a
Banach space and the representation of the functions that arise from them.

```lean
-- the shapes we are building toward (state in Targets.lean as the supporting types land):
variable {X : Type*} [NormedAddCommGroup X] [NormedSpace ℝ X] [CompleteSpace X]

-- A strongly continuous semigroup and its (unbounded) generator.
-- structure C0Semigroup (X) : ...                 -- S 0 = id, S (s+t) = S s ∘ S t, strong continuity
-- def C0Semigroup.generator (S : C0Semigroup X) : X →ₗ.[ℝ] X        -- A u = lim (S t u - u)/t

-- 1. Hille–Yosida resolvent: for a contraction semigroup, R λ = ∫₀^∞ e^{-λt} S t dt
--    inverts (λ - A) and is a contraction-scale bound.
-- theorem resolvent_right_inverse (S : ContractionC0Semigroup X) {λ : ℝ} (hλ : 0 < λ) :
--     (λ • 1 - S.generator) ∘L S.resolvent λ = 1
-- theorem resolvent_norm_le (S : ContractionC0Semigroup X) {λ : ℝ} (hλ : 0 < λ) :
--     ‖S.resolvent λ‖ ≤ 1 / λ

-- 2. Hille–Yosida generation theorem (converse / Lumer–Phillips): a densely-defined
--    dissipative operator whose range condition holds generates a contraction semigroup.
-- theorem generates_of_dissipative (A : DenseLinearOperator X)
--     (hdiss : A.IsDissipative) (hrange : ∀ λ > 0, Surjective (λ • 1 - A)) :
--     ∃ S : ContractionC0Semigroup X, S.generator = A

-- 3a. Bernstein's theorem: a completely monotone function on [0,∞) is the Laplace transform
--     of a unique finite positive measure.
-- theorem bernstein (f : ℝ → ℝ) (hcm : IsCompletelyMonotone f) :
--     ∃! μ : Measure ℝ, IsFiniteMeasure μ ∧ μ.support ⊆ Ici 0 ∧
--       ∀ t ≥ 0, f t = ∫ x, Real.exp (-t * x) ∂μ

-- 3b. BCR Bochner (Berg–Christensen–Ressel 4.1.13): a bounded continuous positive-definite
--     function on [0,∞) × ℝᵈ is the Laplace–Fourier transform of a unique finite measure.
-- theorem bcr_semigroup_bochner (d : ℕ) (F : (ℝ × EuclideanSpace ℝ (Fin d)) → ℂ)
--     (hpd : IsSemigroupGroupPD d F) :
--     ∃! μ : Measure (ℝ × EuclideanSpace ℝ (Fin d)), IsFiniteMeasure μ ∧ ... ∧
--       ∀ t ≥ 0, ∀ a, F (t, a) = ∫ (p, q), Real.exp (-t * p) * Complex.exp (I * ⟪a, q⟫) ∂μ
```

## Standing hypotheses (spell them out; never bundle)

- **Contraction vs general C₀.** State the resolvent identities for **contraction**
  semigroups (`‖S t‖ ≤ 1`); the general bounded case (`‖S t‖ ≤ M e^{ωt}`) is a separate,
  later generalization via rescaling — carry `M, ω` explicitly, do not assume contraction
  silently.
- **Generator domain.** The generator is **unbounded**: track its dense domain as a genuine
  `LinearPMap` / submodule, never as a total operator.
- **Completely monotone** means `(-1)ⁿ f⁽ⁿ⁾ ≥ 0` for all `n` on `(0,∞)`; keep the endpoint
  and finiteness hypotheses explicit (the measure is finite, supported on `[0,∞)`).
- **Positive-definite** on a semigroup-with-involution: state the BCR hypothesis as a named
  predicate (`IsSemigroupGroupPD`), not bundled into the conclusion.

## Inventory: what Mathlib master gives us (consume)

- Banach/Hilbert spaces, `ContinuousLinearMap`, operator norm, `spectrum`, the holomorphic
  functional calculus; **unbounded operators** via `LinearPMap` (closure, adjoint, cores).
- The **Bochner integral**, `MeasureTheory.integral`, dominated convergence, Fubini — the
  resolvent `∫₀^∞ e^{-λt} S t dt` is a Bochner integral of an operator-valued map.
- **Fourier theory**: `Real.fourierIntegral`, inversion, Plancherel; characteristic-function
  uniqueness for finite measures — the spatial half of BCR.
- **Laplace transforms** and `Real.exp`; Stieltjes/`Measure` API; Prokhorov tightness for the
  measure-extraction in Bernstein.

## Roadmap items

1. **C₀-semigroup API** — `C0Semigroup`, generator, domain, strong continuity, basic laws.
   *(Ready: `hille-yosida` `StronglyContinuousSemigroup.lean`.)*
2. **Hille–Yosida resolvent** — `resolvent`, `resolvent_right_inverse`, `resolvent_norm_le`.
   *(Ready: `hilleYosidaResolventBound`, `ContractingSemigroup.resolventRightInv`.)* **← suggested first PR.**
3. **Generation theorem / Lumer–Phillips converse** — dissipative + range ⇒ generates.
   *(Partial: `Future/GenerationTheorem.lean`; the `IsDissipative` scaffold exists.)*
4. **Bernstein's theorem** — completely monotone ⇒ Laplace transform of a unique finite
   measure. *(Ready: `bernstein_theorem`.)*
5. **BCR Bochner (d = 0, then general)** — semigroup/Laplace positive-definite representation.
   *(Existence depends on a Bochner-theorem prerequisite — needs a Mathlib-only route to the
   spatial Bochner step before porting; uniqueness `laplaceFourier_unique` is Mathlib-only.)*

## Suggested home

`TauCeti/Analysis/Semigroups/` (C₀ API, resolvent, generation) with
`TauCeti/Analysis/CompletelyMonotone/` (Bernstein) and `TauCeti/Analysis/BCR/` (the
Bochner-type representations).
