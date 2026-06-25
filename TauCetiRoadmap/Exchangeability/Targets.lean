import Mathlib

/-!
# Exchangeability and de Finetti: target signatures

The narrative roadmap, the library spine, the layer-by-layer build plan (Layers 0–8), the
worked examples, and the references are in `README.md`.

This file holds the **Layer 0** target signatures: the core symmetry notions (sequence
laws, finite and full exchangeability, contractability), the directing-measure object
(`ConditionallyIID`, with `ν : Ω → ProbabilityMeasure α`), path-space data (`pathLaw`,
`prefixProj`, `shift`), finite-dimensional marginal uniqueness (an ℕ-prefix wrapper over
Mathlib's `FiniteDimensionalLaws`), and the easy bridges among the symmetry classes; the
implication lattice and the adjacent-transposition and strictly-increasing-map
characterizations are described in `README.md`. These elaborate
against the pinned Mathlib and are stated with `sorry` (allowed in this human-owned roadmap
library).

Layer 0 needs only Mathlib, not any not-yet-chosen Tau Ceti API. Later layers add their
milestones here as their types become expressible:

* Layer 1 (product kernels, conditional independence, mixtures): consume Mathlib's
  cylinder/π-system facts (`generateFrom_pi`, `generateFrom_squareCylinders`); build the
  random product-kernel measurability and the common ending
  `conditional_iid_from_directing_measure`.
* Layer 2 (process tails and path-space dynamics): `tailFamily`, `tailProcess`, and the
  shift-invariant σ-algebra.
* Layer 3 (L² averaging and the standard-Borel de Finetti route, with the real-valued L²
  convergence theorem as the intermediate analytic step): `deFinetti_viaL2`.
* Layer 4 (reverse martingales and conditional-expectation limits): `condExp_tendsto_iInf`
  for antitone filtrations.
* Layer 5 (Koopman operators and invariant σ-algebras): the positive/unital Markov-operator
  API, multiplicativity for deterministic Koopman operators, and `deFinetti_viaKoopman`.
* Layer 6 (directing measures and the de Finetti representation): the default `deFinetti`,
  `deFinetti_RyllNardzewski_equivalence`, the directing-measure API (a.e. uniqueness, the
  factorization identity), and the empirical-measure and mixture forms.
* Layer 8 (generalized exchangeability and representation theorems): finite de Finetti bounds,
  other countable index types, ergodic decomposition, Markov exchangeability, and
  Aldous–Hoover.

These are roadmap-local target shapes; the implementation in `TauCeti/` may refine names and
namespaces, but the statements below pin the intended early milestones and dependency order.
-/

noncomputable section

open MeasureTheory

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

/-- **Layer 0, finite-marginal uniqueness.** Two finite measures on path space agreeing on
every finite-dimensional prefix marginal are equal. This and the probability variant below
are roadmap-local ℕ-prefix wrappers over Mathlib's general
`ProbabilityTheory.map_eq_iff_forall_finset_map_restrict_eq`, not new measure theory; the
`sorry` is the thin `Fin n`-prefix ↔ finite-subset adapter. -/
example {μ ν : Measure (ℕ → α)} [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    (h : ∀ (n : ℕ) (S : Set (Fin n → α)), MeasurableSet S →
      μ.map (prefixProj α n) S = ν.map (prefixProj α n) S) :
    μ = ν := by
  sorry

/-- **Layer 0, finite-marginal uniqueness (probability version).** -/
example {μ ν : Measure (ℕ → α)} [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
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

end TauCetiRoadmap.Exchangeability
