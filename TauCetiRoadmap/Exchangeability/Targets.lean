import Mathlib

/-!
# Exchangeability and de Finetti: target signatures

**`README.md` is the definitive roadmap document**: the narrative plan, the library spine,
the layer-by-layer build (Layers 0–8), the worked examples, and the references all live
there. This file is **not** the roadmap and is **not exhaustive**: it records suggested Lean
forms for *particular* milestones, as their types become expressible, so that contributors
and reviewers converge on names and signatures. Discharging every statement here neither
finishes a layer nor the roadmap; what the area asks for is what `README.md` says.

This file currently holds suggested forms for: **Layer 0** (the core symmetry notions,
landed in `TauCeti/Probability/Exchangeability/`), **Layer 1** (the random product kernel
and the common de Finetti ending), **Layer 2** (process tails, the shift-invariant and
exchangeable σ-algebras, Hewitt–Savage), **Layer 4** (the Lévy downward theorem), and the
**Layer 6 summit** (de Finetti and the Ryll-Nardzewski equivalence, expressible since
Layer 0). These elaborate against the pinned Mathlib and are stated with `sorry` (allowed
in this human-owned roadmap library).

Later layers add suggested forms here as their types become expressible:

* Layer 3 (L² averaging and the standard-Borel de Finetti route, with the real-valued L²
  convergence theorem as the intermediate analytic step): `deFinetti_viaL2`.
* Layer 5 (Koopman operators and invariant σ-algebras): the positive/unital Markov-operator
  API, multiplicativity for deterministic Koopman operators, and `deFinetti_viaKoopman`.
* Layer 6 (directing measures and the de Finetti representation, beyond the summit shapes
  below): the directing-measure API (a.e. uniqueness, the factorization identity), and the
  empirical-measure and mixture forms (the latter need the infinite product measure and the
  weak topology on `ProbabilityMeasure α`).
* Layer 8 (generalized exchangeability and representation theorems): finite de Finetti bounds,
  other countable index types, ergodic decomposition, Markov exchangeability, and
  Aldous–Hoover.

These are roadmap-local target shapes; the implementation in `TauCeti/` may refine names and
namespaces, but the statements below pin the intended early milestones and dependency order.
-/

noncomputable section

open MeasureTheory Filter Topology

namespace TauCetiRoadmap.Exchangeability

variable {Ω α : Type*} [MeasurableSpace Ω] [MeasurableSpace α]

/-- **Layer 0, finite exchangeability at `n`.** The law of the first `n` coordinates is
invariant under permutations of `Fin n`. -/
def ExchangeableAt (μ : Measure Ω) (X : ℕ → Ω → α) (n : ℕ) : Prop :=
  ∀ σ : Equiv.Perm (Fin n),
    μ.map (fun ω => fun i : Fin n => X (σ i).val ω) =
      μ.map (fun ω => fun i : Fin n => X i.val ω)

/-- **Layer 0, finite exchangeability.** Exchangeable means `ExchangeableAt` at every `n`
(not a single-`n` statement). -/
def Exchangeable (μ : Measure Ω) (X : ℕ → Ω → α) : Prop :=
  ∀ n, ExchangeableAt μ X n

/-- **Layer 0, full exchangeability.** The path law is invariant under all permutations of
`ℕ`. -/
def FullyExchangeable (μ : Measure Ω) (X : ℕ → Ω → α) : Prop :=
  ∀ π : Equiv.Perm ℕ,
    μ.map (fun ω => fun i : ℕ => X (π i) ω) = μ.map (fun ω => fun i : ℕ => X i ω)

/-- **Layer 0, contractability.** Invariance under strictly increasing finite subsequences.
(Equivalently, invariance under the monoid of strictly increasing maps `ℕ → ℕ`;
`Spreadable` is the standard synonym, with `Contractable` the first formal target.) -/
def Contractable (μ : Measure Ω) (X : ℕ → Ω → α) : Prop :=
  ∀ (m : ℕ) (k : Fin m → ℕ), StrictMono k →
    μ.map (fun ω => fun i : Fin m => X (k i) ω) =
      μ.map (fun ω => fun i : Fin m => X i.val ω)

/-- **Layer 0, path law.** The law of the whole process as a measure on `ℕ → α`. -/
def pathLaw (μ : Measure Ω) (X : ℕ → Ω → α) : Measure (ℕ → α) :=
  μ.map (fun ω => fun i => X i ω)

/-- **Layer 0, prefix projection** to the first `n` coordinates. -/
def prefixProj (α : Type*) (n : ℕ) (x : ℕ → α) : Fin n → α := fun i => x i.val

/-- **Layer 0, left shift** on path space. -/
def shift (α : Type*) (x : ℕ → α) : ℕ → α := fun n => x (n + 1)

/-- **Layer 0, conditionally i.i.d.** There is a measurable random probability measure
`ν : Ω → ProbabilityMeasure α` so that every finite block of distinct coordinates is
distributed as the `ν`-mixture of the corresponding product measure (the explicit
finite-index factorization; `ProbabilityMeasure.pi` supplies the product). -/
def ConditionallyIID (μ : Measure Ω) (X : ℕ → Ω → α) : Prop :=
  ∃ ν : Ω → ProbabilityMeasure α, Measurable ν ∧
    ∀ (m : ℕ) (k : Fin m → ℕ), Function.Injective k →
      μ.map (fun ω => fun i : Fin m => X (k i) ω) =
        μ.bind (fun ω => (ProbabilityMeasure.pi (fun _ : Fin m => ν ω)).toMeasure)

/-- **Layer 0, finite-marginal uniqueness.** Two measures on path space, with `μ` finite,
agreeing on every finite-dimensional prefix marginal are equal (`ν`'s finiteness is forced by
the conclusion). This is a roadmap-local ℕ-prefix wrapper over Mathlib's projective-limit
machinery (`IsProjectiveLimit.unique`), not new measure theory; the `sorry` is the thin
`Fin n`-prefix ↔ finite-subset adapter. Assuming only `[IsFiniteMeasure μ]` covers probability
applications too, via the `IsProbabilityMeasure → IsFiniteMeasure` instance, so no separate
probability wrapper is needed. -/
example {μ ν : Measure (ℕ → α)} [IsFiniteMeasure μ]
    (h : ∀ (n : ℕ) (S : Set (Fin n → α)), MeasurableSet S →
      μ.map (prefixProj α n) S = ν.map (prefixProj α n) S) :
    μ = ν := by
  sorry

variable {μ : Measure Ω} {X : ℕ → Ω → α}

/-- **Layer 0 bridge, finite ↔ full exchangeability** for a measurable process under a
probability law. -/
example [IsProbabilityMeasure μ] (hX : ∀ i, Measurable (X i)) :
    Exchangeable μ X ↔ FullyExchangeable μ X := by
  sorry

/-- **Layer 0 bridge, exchangeable ⇒ contractable.** -/
example (hX : ∀ i, Measurable (X i)) (h : Exchangeable μ X) : Contractable μ X := by
  sorry

/-- **Layer 0 bridge, conditionally i.i.d. ⇒ exchangeable.** Permutation invariance of the
finite product measures; will later move to the product-kernel layer once that lands. -/
example (hX : ∀ i, Measurable (X i)) (h : ConditionallyIID μ X) : Exchangeable μ X := by
  sorry

/-- **Layer 0 bridge, full exchangeability ⇒ shift-preservation** of the path law (the link
from symmetry to the Koopman lane). -/
example [IsProbabilityMeasure μ] (hX : ∀ i, Measurable (X i)) (h : FullyExchangeable μ X) :
    MeasurePreserving (shift α) (pathLaw μ X) (pathLaw μ X) := by
  sorry

/-! ## Layer 1: product kernels and the common de Finetti ending

Layer 0 landed in `TauCeti/Probability/Exchangeability/`; per `README.md`, Layer 1 builds
only the de Finetti-facing adapters over Mathlib's cylinder/π-system infrastructure, plus
the common ending every proof route calls last.
-/

/-- **Layer 1, random product-kernel measurability.** The finite product of a measurable
random probability measure is measurable into `Measure (Fin m → α)`, the measurability
input `Measure.bind` needs in every mixture identity. -/
example (ν : Ω → ProbabilityMeasure α) (hν : Measurable ν) (m : ℕ) :
    Measurable fun ω => (ProbabilityMeasure.pi fun _ : Fin m => ν ω).toMeasure := by
  sorry

/-- **Layer 1, the common de Finetti ending.** A measurable random probability measure whose
mixtures match the finite-dimensional laws on measurable rectangles is a directing measure:
rectangle agreement upgrades to the full `ConditionallyIID` factorization by the π-system
argument. Shared by the L², Koopman, and martingale routes. -/
example [IsProbabilityMeasure μ] (hX : ∀ i, Measurable (X i))
    (ν : Ω → ProbabilityMeasure α) (hν : Measurable ν)
    (h : ∀ (m : ℕ) (k : Fin m → ℕ), Function.Injective k →
      ∀ B : Fin m → Set α, (∀ i, MeasurableSet (B i)) →
        μ.map (fun ω => fun i : Fin m => X (k i) ω) (Set.univ.pi B) =
          μ.bind (fun ω => (ProbabilityMeasure.pi fun _ : Fin m => ν ω).toMeasure)
            (Set.univ.pi B)) :
    ConditionallyIID μ X := by
  sorry

/-! ## Layer 2: process tails, path-space σ-algebras, and Hewitt–Savage -/

/-- **Layer 2, the σ-algebra of the process from time `n` on**: `σ(X i : i ≥ n)`. -/
@[reducible] def tailFamily (X : ℕ → Ω → α) (n : ℕ) : MeasurableSpace Ω :=
  ⨆ i ≥ n, MeasurableSpace.comap (X i) inferInstance

/-- **Layer 2, the tail σ-algebra of the process**: `⋂ n, σ(X i : i ≥ n)`. -/
@[reducible] def tailProcess (X : ℕ → Ω → α) : MeasurableSpace Ω :=
  ⨅ n, tailFamily X n

/-- **Layer 2, the shift-invariant σ-algebra** on path space. The strictly shift-invariant
measurable sets already form a σ-algebra; `generateFrom` just packages them. -/
@[reducible] def shiftInvariantSigma (α : Type*) [MeasurableSpace α] : MeasurableSpace (ℕ → α) :=
  MeasurableSpace.generateFrom {s | MeasurableSet s ∧ shift α ⁻¹' s = s}

/-- **Layer 2, the exchangeable (symmetric) σ-algebra** on path space: measurable sets
invariant under every finitely supported permutation of the coordinates. -/
@[reducible] def exchangeableSigma (α : Type*) [MeasurableSpace α] : MeasurableSpace (ℕ → α) :=
  MeasurableSpace.generateFrom
    {s | MeasurableSet s ∧
      ∀ π : Equiv.Perm ℕ, {i | π i ≠ i}.Finite →
        (fun x : ℕ → α => fun i => x (π i)) ⁻¹' s = s}

/-- **Layer 2, tail-family antitonicity.** -/
example (X : ℕ → Ω → α) : Antitone (tailFamily X) := by
  sorry

/-- **Layer 2, the process tail is a sub-σ-algebra** for a measurable process. -/
example (hX : ∀ i, Measurable (X i)) :
    tailProcess X ≤ (inferInstance : MeasurableSpace Ω) := by
  sorry

/-- **Layer 2, the path-space σ-algebras are sub-σ-algebras.** (Do not silently identify
them: for one-sided sequences the tail, shift-invariant, and exchangeable σ-algebras are
related through invariance, almost invariance, and completions; see `README.md`.) -/
example : shiftInvariantSigma α ≤ (inferInstance : MeasurableSpace (ℕ → α)) ∧
    exchangeableSigma α ≤ (inferInstance : MeasurableSpace (ℕ → α)) := by
  sorry

/-- **Layer 2, the Hewitt–Savage zero-one law.** For an i.i.d. sequence the exchangeable
σ-algebra is trivial. Stronger than Kolmogorov's tail 0-1 law (which needs only
independence); the identically-distributed hypothesis is essential. Input to the Layer 6
extreme-point corollary. -/
example [IsProbabilityMeasure μ] (hX : ∀ i, Measurable (X i))
    (h_indep : ProbabilityTheory.iIndepFun X μ)
    (h_ident : ∀ i, ProbabilityTheory.IdentDistrib (X i) (X 0) μ μ)
    {s : Set (ℕ → α)} (hs : MeasurableSet[exchangeableSigma α] s) :
    pathLaw μ X s = 0 ∨ pathLaw μ X s = 1 := by
  sorry

/-! ## Layer 4: reverse martingales -/

/-- **Layer 4, the Lévy downward theorem** along an antitone filtration. Independent of
exchangeability: consume Mathlib's upcrossing API and build only the reversal, the
antitone adapter, and the `⨅ n, 𝔽 n` identification; the martingale route consumes this.
The L¹ and Lᵖ convergence forms are follow-up Layer 4 targets. -/
example [IsProbabilityMeasure μ] {𝔽 : ℕ → MeasurableSpace Ω}
    (h_filtration : Antitone 𝔽) (h_le : ∀ n, 𝔽 n ≤ (inferInstance : MeasurableSpace Ω))
    (f : Ω → ℝ) (h_f_int : Integrable f μ) :
    ∀ᵐ ω ∂μ,
      Tendsto (fun n => (μ[f|𝔽 n]) ω) atTop (𝓝 ((μ[f|⨅ n, 𝔽 n]) ω)) := by
  sorry

/-! ## The summit (Layer 6): de Finetti and Ryll-Nardzewski

Expressible since Layer 0, so the suggested forms are pinned now; the proof routes and the
directing-measure API (Layers 3–6 in `README.md`) land in between. The unsuffixed public
theorem should be the reverse-martingale route.
-/

/-- **Layer 6 summit, de Finetti's theorem** on a standard Borel state space: an
exchangeable sequence is conditionally i.i.d. -/
example [IsProbabilityMeasure μ] [StandardBorelSpace α] [Nonempty α]
    (hX : ∀ i, Measurable (X i)) (h_exch : Exchangeable μ X) :
    ConditionallyIID μ X := by
  sorry

/-- **Layer 6 summit, the de Finetti–Ryll-Nardzewski equivalence**:
`contractable ↔ exchangeable ↔ conditionally i.i.d.` for sequences on a standard Borel
state space. -/
example [IsProbabilityMeasure μ] [StandardBorelSpace α] [Nonempty α]
    (hX : ∀ i, Measurable (X i)) :
    Contractable μ X ↔ Exchangeable μ X ∧ ConditionallyIID μ X := by
  sorry

end TauCetiRoadmap.Exchangeability
