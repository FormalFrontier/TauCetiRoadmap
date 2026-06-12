# Roadmap: effective arithmetic bounds and geometry of numbers

Mathlib has Minkowski's convex-body theorem, the canonical embedding, the Minkowski
bound, and even the qualitative summit — Minkowski's lower bound on the discriminant
(`NumberField.abs_discr_ge`) and **Hermite's finiteness theorem**
(`NumberField.finite_of_discr_bdd`) — but it stops short of the **effective, explicit
estimates** that geometry of numbers exists to produce: a discriminant bound from a basis
of integers, an explicit class number bound, the index of squares in the unit group, an
explicit ideal count, and — the summit — an **effective Hermite–Minkowski**: an explicit
upper bound on the *number* of number fields of bounded discriminant, not just their
finiteness. **We do not wait: we build the effective bounds here in `TauCeti/`, with
geometry of numbers as the engine.**

The spine is the chain of explicit bounds; geometry of numbers is the tool, not the goal.

Suggested homes: `TauCeti/NumberTheory/EffectiveBounds/` (the bounds) and
`TauCeti/NumberTheory/GeometryOfNumbers/` (the lattice-point engine).

Several Layer-1 bounds already exist, sorry-free, inside
[kim-em/erdos-unit-distance](https://github.com/kim-em/erdos-unit-distance) (the
formalization of Alpöge's disproof of the uniform-constant Erdős unit-distance
conjecture), stated over an arbitrary number field. The first targets here **migrate**
them; credit that source in each ported file.

Migration sources, pinned at commit `140edda5974ec5afb8beefdbb3014d93d92bdc64`:
- `ErdosUnitDistance/Discriminant.lean` — `abs_discr_le_of_basis_isIntegral` and the
  trace-form helper `trace_eq_zero_of_sq_ratCast`.
- `ErdosUnitDistance/ClassNumber.lean` — `card_ideal_absNorm_le` (the explicit ideal
  count), `classNumber_le_bound`, `index_powMonoidHom_two_le_of_closure` (the abstract
  group lemma), `units_sq_index_le`.
- `ErdosUnitDistance/GeometricCore.lean` — the measure-free packing/doubling candidates
  for Layer 0 (after the `ZLattice` reconciliation below).

## Standing hypotheses

Work over a number field `F` (`[NumberField F]`), degree `n = [F : ℚ]`. State each bound
in the generality the proof needs — a discriminant bound needs only an integral basis, the
class number bound needs Minkowski's theorem and an ideal count, the unit-square index
needs Dirichlet's unit theorem — rather than bundling a single "number field with all its
invariants" hypothesis.

## What Mathlib already has (consume)

- **The Minkowski engine:** `Mathlib/Algebra/Module/ZLattice/Basic.lean` and
  `…/Covolume.lean` (lattices, covolume), `Mathlib/MeasureTheory/Group/GeometryOfNumbers.lean`
  (Minkowski's convex-body theorem).
- **The canonical embedding and discriminant:**
  `Mathlib/NumberTheory/NumberField/CanonicalEmbedding/*` (the Minkowski space, the
  convex-body bound), `Mathlib/NumberTheory/NumberField/Discriminant/*` (the Minkowski
  bound on `|d_F|`, `|d_F| > 1` for `F ≠ ℚ`).
- **Ideal counting (reconcile notation, but expect to build the bound):**
  `Mathlib/NumberTheory/NumberField/Ideal/Asymptotics.lean` gives the *asymptotic* count
  of ideals by norm — eventual and non-explicit, so the uniform explicit count Layer 1
  needs does **not** follow from it. Reconcile names and API with it; the count itself is
  a fresh elementary lemma (see Layer 1).
- **Class group and unit theorem:** `Mathlib/RingTheory/ClassGroup.lean`,
  `Mathlib/NumberTheory/NumberField/ClassNumber.lean` (in particular
  `NumberField.exists_ideal_in_class_of_norm_le`, the Minkowski-bound input to the class
  number bound), `Mathlib/NumberTheory/NumberField/Units/DirichletTheorem.lean` (the unit
  rank, `fundSystem`).
- **The qualitative summit (consume, do not re-prove):**
  `Mathlib/NumberTheory/NumberField/Discriminant/Basic.lean` has Minkowski's lower bound
  `NumberField.abs_discr_ge` (`(4/9)·(3π/4)ⁿ ≤ |d_F|`), the degree bound
  `rank_le_rankOfDiscrBdd`, and **Hermite's theorem** `NumberField.finite_of_discr_bdd`
  (the number fields inside a fixed extension `A/ℚ` with `|d| ≤ N` form a finite set).
  And `Mathlib/NumberTheory/NumberField/Units/Regulator.lean` already *defines* the
  regulator as the covolume of the unit lattice.

## What is missing (build here)

The explicit, effective forms: `|d_F| ≤ |disc b|` from any `ℚ`-basis `b` of algebraic
integers (an actual integral basis — a `ℤ`-basis of `O_F` — gives equality; the upper
bound is the useful general form); the explicit ideal count
`#{I ≠ ⊥ : N(I) ≤ X} ≤ X²·2ⁿ`; `h_F ≤ |d_F|·4ⁿ`; `[O_F^× : (O_F^×)²] ≤ 2ⁿ`; a clean
measure-free lattice-point packing/doubling API (reconciled with `ZLattice`); and an
explicit bound on the number of number fields of discriminant `≤ B` (Mathlib has the
finiteness, not a count). None of these explicit bounds is upstream.

---

## The build, in layers

As a layer makes the next layer's *types* expressible in `TauCeti/`, state its milestones
in `Targets.lean` (with `sorry`) and hand them to the AIs to discharge.

### Layer 0: the geometry-of-numbers engine
- Measure-free lattice-point **packing** and **doubling** bounds in boxes/polydiscs (a
  separated set in a box is small; `#(Λ ∩ 2·B) ≤ C·#(Λ ∩ B)`). The erdos
  `GeometricCore` lemmas are the migration candidate.
  ⚠ **Reconcile with `ZLattice` first.** Before porting, map every proposed definition to
  the existing `ZLattice`/covolume API and **drop any `box`/separation definition that is
  just a Mathlib wrapper**; migrate only genuinely measure-free cardinal/doubling lemmas
  not already expressible cleanly upstream.

### Layer 1: effective upper bounds (the first migration targets)
- **Discriminant from a basis of integers.** `|d_F| ≤ |disc b|` for any `ℚ`-basis `b` of
  algebraic integers (the index of `b` in a maximal order is a nonzero integer, and
  `disc b = index² · d_F`). (erdos `abs_discr_le_of_basis_isIntegral`.) The helper
  `trace_eq_zero_of_sq_ratCast` (an element with `x² ∈ ℚ`, `x ∉ ℚ` has trace zero) is not
  needed for the bound itself, but it diagonalises the trace form on square-root bases —
  it is how the `ℚ(i)` worked example below evaluates `|disc b|`.
- **Explicit ideal count.** `#{I : Ideal O_F | I ≠ ⊥, N(I) ≤ X} ≤ X²·2ⁿ` for `X ≥ 1`
  (erdos `card_ideal_absNorm_le`, a Rankin-style argument:
  `∑_{N𝔞 ≤ X} 1 ≤ X² ∑ N𝔞⁻² ≤ X²·ζ(2)ⁿ ≤ X²·2ⁿ`). ⚠ This is the genuinely new counting
  lemma; it does **not** follow from the asymptotic count in `Ideal/Asymptotics`.
- **Class number bound.** `h_F ≤ |d_F|·4ⁿ`, from two inputs: Mathlib's
  `NumberField.exists_ideal_in_class_of_norm_le` — every class contains an integral ideal
  of norm `≤ (4/π)^{r₂} · (n!/nⁿ) · √|d_F|`, the Minkowski constant; the prefactor is
  `≤ 1`, but the migrated proof simply carries it — and the explicit ideal count above
  with `X` that Minkowski norm bound. (erdos `classNumber_le_bound`.)
- **Unit-square index.** `[O_F^× : (O_F^×)²] ≤ 2ⁿ`, from Dirichlet's unit theorem and a
  squaring-map index computation. (erdos `units_sq_index_le`; the abstract group lemma
  `index_powMonoidHom_two_le_of_closure` migrates independently.)

### Layer 2: effective Hermite–Minkowski (the summit)
- ⚠ **Mathlib already has the qualitative theorems — consume them, do not re-prove.**
  Minkowski's lower bound on `|d_F|` growing with `n` is `NumberField.abs_discr_ge`, the
  bounded-degree consequence is `rank_le_rankOfDiscrBdd`, and Hermite's finiteness
  theorem is `NumberField.finite_of_discr_bdd` (number fields inside a fixed `A/ℚ` with
  `|d| ≤ N` form a finite set), all in `Discriminant/Basic.lean`.
- What this layer builds is the **effective count**: an explicit upper bound on the
  number of number fields (in a fixed `A/ℚ`) of discriminant `≤ B`. Mathlib's finiteness
  proof already runs through a generator of bounded height; the work is extracting and
  counting — bound the defining polynomial's coefficients explicitly, count the
  polynomials.

### Layer 3: regulators and unit-lattice volume
- Mathlib already *defines* the regulator as the covolume of the unit lattice
  (`NumberField.Units.regulator = ZLattice.covolume (unitLattice F)`, in
  `Units/Regulator.lean`). What is missing is the effective side: explicit lower bounds
  on the regulator, and the volume computations feeding the analytic class number
  formula.

### Long horizon (aspiration)
**Brauer–Siegel**: `log(h_F · R_F) ∼ log √|d_F|`; effective bounds with explicit
constants.

## Worked examples (acceptance criteria — keep the bounds honest)

- The class number bound is non-vacuous on a small field: for `ℚ(√−5)` (`d = −20`,
  `n = 2`, `h = 2`), `2 ≤ 20·16`.
- A concrete lattice-doubling instance for a rank-2 lattice in `ℝ²`, exercising the
  Layer-0 engine.
- The discriminant bound recovers `|d_{ℚ(i)}| = 4` from the basis `{1, i}`.

## Ordering

Layer 1 first — the explicit upper bounds are direct migrations and validate the pipeline
(within it: the discriminant bound is the most self-contained, then the abstract group
lemma and the unit-square index, then the ideal count and the class number bound that
consumes it). Layer 0 (the engine) is best done after its `ZLattice` reconciliation
spike, since that determines what is even worth porting. Layer 2 (the effective count) is
the summit; it consumes Mathlib's `abs_discr_ge` and `finite_of_discr_bdd` rather than
re-proving them. As each milestone's prerequisite *types* exist in `TauCeti/`, state it
in `Targets.lean` (with `sorry`).

## References

- J. Neukirch, *Algebraic Number Theory*, Ch. I §5–6, III §2 (Minkowski theory, the
  discriminant and class number bounds, Hermite–Minkowski).
- H. Cohen, *A Course in Computational Algebraic Number Theory* (effective bounds).
- W. Narkiewicz, *Elementary and Analytic Theory of Algebraic Numbers* (Brauer–Siegel).

## Acknowledgements

The Layer-1 bound lemmas are migrated from
[kim-em/erdos-unit-distance](https://github.com/kim-em/erdos-unit-distance), where they
were written for the formalization of Alpöge's disproof of the uniform-constant Erdős
unit-distance conjecture. Thanks to its authors.
