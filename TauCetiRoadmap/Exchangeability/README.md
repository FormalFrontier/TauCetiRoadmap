# Roadmap: exchangeability and de Finetti

Exchangeability is the first large probability-symmetry theory missing from Mathlib:
finite-dimensional laws invariant under permutations, spreadability/contractability, tail
σ-algebras for processes, random directing measures, and the conditional-product
representation of invariant laws. Mathlib supplies the ambient stack this rests on: finite
and product measures, kernels, `Measure.bind`, conditional expectation, filtrations and
martingales, `Lp` spaces, Hilbert-space projections, measure-preserving maps, and the mean
ergodic theorem. It does not, however, carry the exchangeability theory on top.

The first summit is the de Finetti–Ryll-Nardzewski theorem for sequences on a standard
Borel space:

```text
contractable ↔ exchangeable ↔ conditionally i.i.d.
```

It has three classical proof routes: reverse martingales, L² contractability bounds, and
Koopman / mean ergodic theory. This roadmap builds the reusable probability-symmetry
library those routes need, in dependency order, with de Finetti as its first summit theorem.

A completed Lean formalization exists in
[`cameronfreer/exchangeability`](https://github.com/cameronfreer/exchangeability); it is a
migration source and API-warning map (see [Migration source](#migration-source)), not the
specification. The specification here is Kallenberg's theorem and the reusable library
needed to state and prove it.

Suggested homes:

```text
TauCeti/Probability/Exchangeability/
TauCeti/Probability/DeFinetti/
TauCeti/Probability/Process/
TauCeti/Probability/Martingale/
TauCeti/Probability/Ergodic/
TauCeti/MeasureTheory/Measure/
```

## The end goal (v1)

For a probability space `(Ω, μ)` and a measurable sequence

```lean
X : ℕ → Ω → α
```

with `α` a standard Borel space, prove the de Finetti–Ryll-Nardzewski equivalence:

```lean
-- the shape we are building toward, once the definitions land in TauCeti:
-- theorem deFinetti_RyllNardzewski_equivalence
--     {Ω : Type*} [MeasurableSpace Ω]
--     {α : Type*} [MeasurableSpace α] [StandardBorelSpace α] [Nonempty α]
--     {μ : Measure Ω} [IsProbabilityMeasure μ]
--     (X : ℕ → Ω → α)
--     (hX_meas : ∀ i, Measurable (X i)) :
--     Contractable μ X ↔ Exchangeable μ X ∧ ConditionallyIID μ X
--
-- theorem deFinetti
--     {Ω : Type*} [MeasurableSpace Ω]
--     {α : Type*} [MeasurableSpace α] [StandardBorelSpace α] [Nonempty α]
--     {μ : Measure Ω} [IsProbabilityMeasure μ]
--     (X : ℕ → Ω → α)
--     (hX_meas : ∀ i, Measurable (X i))
--     (hX_exch : Exchangeable μ X) :
--     ConditionallyIID μ X
```

The standard-Borel hypothesis is on the value space `α`, where the directing measure and
the conditional distributions live; the public statement keeps `Ω` with only a measurable
structure. Build the tail-conditional path law via `condDistrib` on `ℕ → α` (standard Borel
because `α` is), which needs standard Borel only on its codomain; the directing measure is
the one-coordinate conditional law extracted from that conditional path law, with the product
factorization proved separately. An extra `[StandardBorelSpace Ω]` would arise only from
`condExpKernel` (or `condDistrib` specialized to an identity-valued kernel with value space
`Ω`); such a hypothesis is internal to that route and does not appear in the public
statement.

The default public theorem should eventually use the reverse-martingale proof. The L²
route remains as a lighter real-valued theorem, and the Koopman route remains as the
ergodic-theory route with reusable operator-theoretic infrastructure.

## The library spine

The deliverable is a reusable probability-symmetry library, not just a proof script for one
theorem. The de Finetti–Ryll-Nardzewski theorem is the summit of this spine, not its only
output. The spine is:

1. sequence laws and finite-dimensional marginals;
2. exchangeability, full exchangeability, spreadability/contractability, and the bridges
   between the process-level and path-law formulations;
3. product kernels and mixtures of finite product measures;
4. conditional independence and conditionally i.i.d. APIs;
5. process-relative tail σ-algebras and path-space shifts;
6. reverse martingales for arbitrary decreasing filtrations;
7. Koopman operators and invariant σ-algebras for arbitrary measure-preserving maps.

Each item is worth building for its own sake, so that a later probability-symmetry roadmap
(exchangeable arrays, Markov exchangeability, ergodic decomposition) can consume it directly.

## Standing hypotheses

Spell hypotheses out; do not bundle them.

The basic definitions should be as hypothesis-light as possible:

* `Exchangeable μ X`: invariance of finite-dimensional laws under permutations of `Fin n`.
* `FullyExchangeable μ X`: invariance of the path law under all permutations of `ℕ`.
* `Contractable μ X`: invariance under strictly increasing finite subsequences.
* `ConditionallyIID μ X`: existence of a measurable random probability measure whose
  finite product kernels give the finite-dimensional laws. Pin the directing-measure API
  before stating it: either `ν : Ω → ProbabilityMeasure α` (with Mathlib's
  `ProbabilityMeasure.pi`, and `ProbabilityMeasure.toMeasure_pi` / `ProbabilityMeasure.pi_pi`
  for the bridge to `Measure.pi` and rectangle evaluation), or a raw `ν : Ω → Measure α`
  together with an explicit `∀ ω, IsProbabilityMeasure (ν ω)` hypothesis. A
  `ConditionallyIIDWith μ X ν` relation plus an existential wrapper keeps the directing
  measure nameable in proofs.

The standard-Borel hypotheses belong in the directing-measure construction and final
de Finetti theorem, not in every elementary definition. Similarly, L² assumptions belong
only in the L² route, and shift-preservation assumptions belong only in the Koopman /
ergodic-theory lane.

Index the v1 theorem by `ℕ`. General exchangeability over other countable index types,
exchangeable arrays, Aldous–Hoover, Markov exchangeability, and finite de Finetti bounds
are long-horizon generalizations, not prerequisites for v1.

## What Mathlib already has (consume)

* **Finite products and path laws:** `Measure.map`, finite product measurable spaces,
  `Measure.pi`, and product-measure API.
* **π-system uniqueness:** measure extension / uniqueness from a generating π-system,
  used to prove that finite-dimensional marginals determine laws on sequence space.
* **Kernels and bind:** `Kernel`, `Measure.bind`, and the Giry-style measure API needed
  for mixtures of finite product measures.
* **Conditional expectation:** `μ[f | m]`, tower properties, `condExpL2`, and
  conditional-expectation estimates.
* **Filtrations and martingales:** `Filtration`, martingales, submartingales, and the
  available upcrossing machinery.
* **`Lp` and Hilbert-space machinery:** `MemLp`, `Lp`, orthogonal projections, symmetric
  idempotents, and conditional expectation as an `L²` projection.
* **Ergodic and operator theory:** measure-preserving maps, composition with a
  measure-preserving map on `Lp`, and the mean ergodic theorem for suitable continuous
  linear maps.

Consume these directly rather than re-proving Mathlib's product-measure,
conditional-expectation, Hilbert-space, or mean-ergodic infrastructure.

## What is missing (build here)

The missing pieces are:

* finite-dimensional exchangeability and full exchangeability for sequence laws;
* contractability and the proof `Exchangeable → Contractable`;
* finite-dimensional marginal uniqueness on `ℕ → α`;
* product-kernel measurability for random finite product measures;
* the common de Finetti ending turning a directing-measure bridge into `ConditionallyIID`;
* process-relative tail σ-algebras and their antitone filtration structure;
* reverse martingale convergence for conditional expectations along decreasing filtrations;
* Koopman operators and the identification of the mean-ergodic projection with conditional
  expectation onto the invariant σ-algebra;
* the L², Koopman, and reverse-martingale proof routes for de Finetti.

State the general infrastructure at full generality: reverse martingales for arbitrary
decreasing filtrations, and Koopman machinery for arbitrary measure-preserving
transformations, before specializing to path-space shifts.

## Migration source

A completed Lean formalization of this theory exists at
[`cameronfreer/exchangeability`](https://github.com/cameronfreer/exchangeability), pinned at
[`e0532e59ceff23edab44dda9ab0655debbc9cc22`](https://github.com/cameronfreer/exchangeability/tree/e0532e59ceff23edab44dda9ab0655debbc9cc22).
Use it as a source of sorry-free proof scripts to migrate or adapt, a declaration map for
the three proof routes, an API-warning source (where a local definition was convenient but
should be generalized for Tau Ceti), and an attribution source for ported files. It is
**not** the mathematical specification: the specification is the standalone library above,
with Kallenberg, Aldous, Hewitt–Savage, and Ryll-Nardzewski as references. The map below is
"where to look", not "what is correct"; judge each milestone on its own terms. Source
README, work-plan, and note files are background only.

* Layer 0: `Exchangeability/Core.lean`, `Exchangeability/Contractability.lean`,
  `Exchangeability/ConditionallyIID.lean`, `Exchangeability/Util/StrictMono.lean`, and
  `Exchangeability/Util/ProductBounds.lean`.
* Layer 1: `Exchangeability/Probability/MeasureKernels.lean`,
  `Exchangeability/Probability/InfiniteProduct.lean`,
  `Exchangeability/Probability/CondIndep.lean`, the
  `Exchangeability/Probability/CondIndep/` subtree, and
  `Exchangeability/DeFinetti/CommonEnding.lean`.
* Layer 2: `Exchangeability/Tail/*.lean`, `Exchangeability/PathSpace/*.lean`, and
  `Exchangeability/Probability/SigmaAlgebraHelpers.lean`.
* Layer 3: `Exchangeability/DeFinetti/ViaL2.lean`,
  `Exchangeability/DeFinetti/ViaL2/*.lean`, `Exchangeability/DeFinetti/L2Helpers.lean`,
  `Exchangeability/DeFinetti/TheoremViaL2.lean`,
  `Exchangeability/Bridge/CesaroToCondExp.lean`,
  `Exchangeability/Probability/CenteredVariables.lean`,
  `Exchangeability/Probability/IntegrationHelpers.lean`, and
  `Exchangeability/Probability/LpNormHelpers.lean`.
* Layer 4: `Exchangeability/Probability/Martingale.lean`,
  `Exchangeability/Probability/Martingale/Reverse.lean`,
  `Exchangeability/Probability/Martingale/Convergence.lean`,
  `Exchangeability/Probability/Martingale/Crossings/*.lean`, and
  `Exchangeability/Probability/TimeReversalCrossing.lean`. These source crossing and
  convergence files are the reverse-direction delta; consume Mathlib for the forward
  upcrossing and convergence API per the build plan below.
* Layer 5: `Exchangeability/Ergodic/*.lean` and
  `Exchangeability/DeFinetti/ViaKoopman.lean`,
  `Exchangeability/DeFinetti/ViaKoopman/*.lean`, and
  `Exchangeability/DeFinetti/TheoremViaKoopman.lean`.
* Layer 6: `Exchangeability/DeFinetti/ViaMartingale.lean`,
  `Exchangeability/DeFinetti/ViaMartingale/*.lean`,
  `Exchangeability/DeFinetti/MartingaleHelpers.lean`, and
  `Exchangeability/DeFinetti/TheoremViaMartingale.lean`.
* Layer 7: `Exchangeability/DeFinetti/BridgeProperty.lean`,
  `Exchangeability/DeFinetti/Theorem.lean`, `Exchangeability/DeFinetti.lean`, and top-level
  `Exchangeability.lean`.
* Cross-layer helpers: `Exchangeability/Probability/CondExp.lean`,
  `Exchangeability/Probability/TripleLawDropInfo.lean`, and the
  `Exchangeability/Probability/TripleLawDropInfo/` subtree. Pull these into whichever Tau
  Ceti layer first needs the corresponding general-purpose facts.

Credit `cameronfreer/exchangeability` in each ported or adapted file, and record when a
Tau Ceti file intentionally diverges from this source API.

---

## The build, in layers

The ordering below is the dependency order. As each layer makes the next layer's *types*
expressible in `TauCeti/`, state its milestones in `Targets.lean` with `sorry`.

### Layer 0: sequence laws, finite marginals, and symmetry notions

Suggested home:

```text
TauCeti/Probability/Exchangeability/Basic.lean
TauCeti/Probability/Exchangeability/Contractability.lean
TauCeti/Probability/Exchangeability/FullyExchangeable.lean
```

Build:

* `Exchangeable μ X`;
* `FullyExchangeable μ X`;
* `ExchangeableAt μ X n`;
* `Contractable μ X`;
* `pathLaw μ X`;
* prefix projections and prefix cylinders;
* finite-dimensional marginal uniqueness for laws on `ℕ → α`;
* finite approximation of infinite permutations;
* extension of strictly monotone finite selections to finite permutations.

`Contractable` (invariance under strictly increasing finite subsequences) is the first
formal target for this spreadability notion; `Spreadable` is the standard synonym, mentioned
for orientation. The roadmap commits to the single `Contractable` API, not two parallel ones.

Key milestones:

```lean
measure_eq_of_fin_marginals_eq
measure_eq_of_fin_marginals_eq_prob
exchangeable_iff_fullyExchangeable
exists_perm_extending_strictMono
contractable_of_exchangeable
Contractable.map_single
Contractable.map_pair
Contractable.comp
```

⚠ **API warning.** Do not define exchangeability as a property of a measure on path space
only, or as a property of a process only, without bridges. Both viewpoints are useful:
the process-level statements are what users want, while the path-law statements make
π-system and shift arguments cleaner.

### Layer 1: product kernels, conditional independence, and mixtures

Suggested home:

```text
TauCeti/MeasureTheory/Measure/ProductKernel.lean
TauCeti/Probability/DeFinetti/CommonEnding.lean
```

Build general product-kernel infrastructure:

* measurable rectangles form a π-system;
* measurable rectangles generate the finite product σ-algebra;
* measurability of `ω ↦ Measure.pi fun _ : Fin m => ν ω`;
* the AE-measurable version needed for `Measure.bind_apply`;
* rectangle evaluation for finite product measures;
* equality of finite measures from agreement on rectangles.

Then build the common de Finetti ending:

```lean
conditional_iid_from_directing_measure
```

The intended bridge hypothesis is an indicator-product factorization: for every finite
injective selection `k : Fin m → ℕ` and measurable rectangle `B`, the law of
`(X (k i))ᵢ` equals the mixture of product measures induced by `ν`.

This layer is shared by the L² and Koopman routes, and also useful for the martingale
route's final finite-product step.

### Layer 2: process tails and path-space dynamics

Suggested home:

```text
TauCeti/Probability/Process/Tail.lean
TauCeti/Probability/PathSpace/Shift.lean
TauCeti/Probability/Ergodic/ShiftInvariantSigma.lean
```

Build process-relative tails:

```lean
tailFamily X n
tailProcess X
tailFamily_antitone
tailProcess_le_tailFamily
tailProcess_le_ambient
tailProcess_eq_iInf_revFiltration
```

Build path-space shift:

```lean
shift : (ℕ → α) → (ℕ → α)
shift_measurable
shift_iterate_measurable
```

Build shift-invariant σ-algebras:

```lean
isShiftInvariant
shiftInvariantSigma
shiftInvariantSigma_le
mem_shiftInvariantSigma_iff
shiftInvariantSigma_measurable_shift_eq
shiftInvariant_implies_shiftInvariantMeasurable
```

⚠ **Tail vs invariant σ-algebra.** Do not silently identify the tail σ-algebra with the
shift-invariant σ-algebra. For one-sided sequences, the relationship runs through
invariance, almost invariance, and completions. State exactly the theorem each proof
route needs.

### Layer 3: L² averaging library and real-valued de Finetti

Suggested home:

```text
TauCeti/Probability/Exchangeability/L2/Covariance.lean
TauCeti/Probability/Exchangeability/L2/BlockAverages.lean
TauCeti/Probability/DeFinetti/ViaL2.lean
```

This is the first proof route to port after the shared layers. It is real-valued and
requires L² assumptions.

Build:

* equality of means and integrals from equal one-dimensional laws;
* equality of pair covariances from equal two-dimensional laws;
* the uniform covariance structure of a contractable L² sequence;
* two-window L² bounds for block averages;
* long-average versus tail-average bounds;
* L¹ convergence of weighted block averages;
* the directing-measure bridge;
* the call to `conditional_iid_from_directing_measure`.

Key milestones:

```lean
contractable_covariance_structure
l2_bound_two_windows_uniform
l2_bound_long_vs_tail
weighted_sums_converge_L1
directing_measure_satisfies_requirements
conditionallyIID_of_contractable_viaL2
deFinetti_viaL2
deFinetti_RyllNardzewski_equivalence_viaL2
```

The final route should make clear that it proves a real-valued L² theorem, not the full
standard-Borel theorem.

### Layer 4: reverse martingales and conditional-expectation limits

Suggested home:

```text
TauCeti/Probability/Martingale/Reverse.lean
TauCeti/Probability/Martingale/AntitoneUpcrossing.lean
TauCeti/Probability/Martingale/LevyDownward.lean
```

Mathlib already provides the upcrossing API (`upcrossingsBefore`, `upcrossings`, and the
submartingale upcrossing bound in `Mathlib/Probability/Martingale/Upcrossing.lean`) and the
forward, upward convergence theorems (`Submartingale.ae_tendsto_limitProcess` and
`tendsto_ae_condExp` in `Mathlib/Probability/Martingale/Convergence.lean`). What it does not
have is the downward theorem along an antitone filtration. Consume the former, and build
only the reversal, the antitone adapter, and the `⨅ n, 𝔽 n` identification:

1. **Finite-horizon reversal.**

   ```lean
   revFiltration
   revCEFinite
   revCEFinite_martingale
   ```

   For an antitone filtration `𝔽 : ℕ → MeasurableSpace Ω`, the finite-horizon reversal
   `n ↦ 𝔽 (N - n)` is an ordinary filtration, and the reversed conditional expectations
   form a martingale by the tower property.

2. **Antitone adapter for the upcrossing bound.**

   ```lean
   upcrossings_bdd_uniform
   ```

   Apply Mathlib's upcrossing bound to the reversed finite-horizon martingale to get a
   uniform crossing bound for the antitone sequence `n ↦ μ[f | 𝔽 n]`. The crossing counts
   are Mathlib's; only this adapter is new.

3. **Existence and identification of the limit.**

   ```lean
   condExp_exists_ae_limit_antitone
   ae_limit_is_condexp_iInf
   condExp_tendsto_iInf
   ```

Target theorem:

```lean
theorem condExp_tendsto_iInf
    [IsProbabilityMeasure μ]
    {𝔽 : ℕ → MeasurableSpace Ω}
    (h_filtration : Antitone 𝔽)
    (h_le : ∀ n, 𝔽 n ≤ (inferInstance : MeasurableSpace Ω))
    (f : Ω → ℝ)
    (h_f_int : Integrable f μ) :
    ∀ᵐ ω ∂μ,
      Tendsto
        (fun n => μ[f | 𝔽 n] ω)
        atTop
        (𝓝 (μ[f | ⨅ n, 𝔽 n] ω))
```

This theorem should be independent of exchangeability and later consumed by the martingale
proof. The L¹ and Lᵖ convergence forms (for `f ∈ L¹` / `Lᵖ`, using Mathlib's
uniform-integrability and eLp-norm conditional-expectation tools) are follow-up Layer 4
targets; the L¹ form is what most uses want.

### Layer 5: Koopman operators and invariant σ-algebras

Suggested home:

```text
TauCeti/Probability/Ergodic/Koopman.lean
TauCeti/Probability/Ergodic/InvariantSigma.lean
TauCeti/Probability/DeFinetti/ViaKoopman.lean
```

Build the generic operator-theoretic lane first:

```lean
koopman
koopman_isometry
fixedSpace
metProjection
birkhoffAverage_tendsto_metProjection
```

Then specialize to path-space shift and identify the projection:

```lean
fixedSubspace
metProjectionShift
condexpL2
koopman_eq_self_of_shiftInvariant
aestronglyMeasurable_shiftInvariant_of_koopman
lpMeas_eq_fixedSubspace
proj_eq_condexp
metProjectionShift_tendsto
```

Finally build the exchangeability-specific bridge:

```lean
pathSpace_contractable_of_contractable
measure_map_shift_eq_of_contractable
pathSpace_shift_preserving_of_contractable
conditionallyIID_transfer
conditionallyIID_bind_of_contractable
deFinetti_viaKoopman
```

⚠ **Warning.** The mean ergodic theorem gives convergence to an orthogonal projection, and
the probabilistic statement still needs that projection identified with conditional
expectation onto the invariant σ-algebra. That identification is a separate theorem, not a
simp step.

### Layer 6: directing measures and de Finetti representation

Suggested home:

```text
TauCeti/Probability/DeFinetti/ViaMartingale/ContractionIndependence.lean
TauCeti/Probability/DeFinetti/ViaMartingale/FutureFiltration.lean
TauCeti/Probability/DeFinetti/ViaMartingale/DirectingMeasure.lean
TauCeti/Probability/DeFinetti/ViaMartingale/FiniteProduct.lean
TauCeti/Probability/DeFinetti/ViaMartingale.lean
TauCeti/Probability/DeFinetti/Theorem.lean
```

Build:

* Kallenberg's contraction-independence lemma;
* future filtrations and their relation to `tailProcess X`;
* conditional-law convergence by `condExp_tendsto_iInf`;
* the directing measure from tail conditional laws;
* finite-product factorization;
* the final theorem wrappers.

Key milestones:

```lean
conditionallyIID_of_contractable
deFinetti
deFinetti_equivalence
deFinetti_RyllNardzewski_equivalence
```

This is the default route for the final public API.

### Layer 7: public API and examples

Suggested home:

```text
TauCeti/Probability/Exchangeability.lean
TauCeti/Probability/DeFinetti.lean
TauCeti/Examples/Probability/DeFinetti.lean
```

Expose:

```lean
Exchangeable
FullyExchangeable
Contractable
ConditionallyIID

exchangeable_iff_fullyExchangeable
contractable_of_exchangeable
exchangeable_of_conditionallyIID

conditionallyIID_of_contractable
deFinetti
deFinetti_equivalence
deFinetti_RyllNardzewski_equivalence

deFinetti_viaL2
deFinetti_viaKoopman
```

Route-specific theorem names should keep their suffixes. The unsuffixed theorem should be
the general martingale route.

### Long horizon

After v1:

* finite de Finetti bounds;
* de Finetti for other countable index types;
* exchangeable arrays and Aldous–Hoover;
* Markov exchangeability;
* ergodic decomposition of exchangeable laws;
* Mathlib extraction of general infrastructure.

Optional extensions of the core theory, valuable but not part of v1:

* the empirical-measure and mixture forms of de Finetti (the law-of-large-numbers form
  `(1/n) Σ_{i<n} δ_{Xᵢ} ⇒ ν` in `P(α)`, and `pathLaw X = ∫ p^{⊗ℕ} dπ(p)` with `π` unique on
  `P(α)`);
* the Hewitt–Savage zero-one law (triviality of the symmetric σ-algebra for i.i.d.
  sequences) and the extreme-point / ergodic-decomposition corollary;
* the full Koopman Markov-operator API (positive, unital, multiplicative on `L^∞`);
* the detailed directing-measure API: a.e. uniqueness, measurability with respect to the
  tail/exchangeable σ-algebra, and the conditional-factorization identity
  `E[∏_j f_j(X_{i_j}) | σ(ν)] = ∏_j ∫ f_j dν`;
* a boundary worked example marking the limits of the theory: a stationary-not-exchangeable
  two-state Markov chain (`P(0→0) = P(1→1) = q`, `0 < q < 1`, `q ≠ ½`).

These are not prerequisites for the v1 theorem.

## Worked examples

Discharge these alongside the layers; they check that the API describes real probability
objects, not just the final theorem.

* The law of an i.i.d. sequence is `ConditionallyIID`, `Exchangeable`, and `Contractable`.
* A mixture of i.i.d. `Bool`-valued laws, parameterized by a random `θ`, is exchangeable,
  with `ω ↦ κ (θ ω)` (`κ` a two-point kernel) as the directing measure. The directing
  measure is the random probability measure induced by `θ`, not `θ` itself; phrasing it via
  the two-point kernel keeps the example independent of a mature `Bernoulli` API.
* Finite-dimensional prefix marginals determine a probability measure on `ℕ → α`.
* Full exchangeability of a path law implies shift-preservation.
* The tail-family of a process is antitone.
* The Lévy downward theorem specializes correctly to an eventually constant decreasing
  filtration (a test of `condExp_tendsto_iInf`, not a de Finetti example).
* In the real-valued L² lane, bounded observables give `MemLp 2` automatically.

## Ordering

Layer 0 first: all proof routes need the core definitions and finite-marginal uniqueness.
Layer 1 next: product kernels and the common ending are shared by the proof routes.
Layer 2 next: tails and shifts are needed by the martingale and Koopman routes.

After that, the L² route can land first because it validates the common ending with the
least global infrastructure. Reverse martingales and Koopman can proceed in parallel as
general infrastructure. The martingale de Finetti proof comes after reverse martingales
and becomes the default public theorem.

## References

* Olav Kallenberg, *Probabilistic Symmetries and Invariance Principles*, Springer, 2005,
  Chapter 1, Theorem 1.1.
* David Aldous, *Exchangeability and related topics*, École d'Été de Probabilités de
  Saint-Flour XIII, 1983.
* Bruno de Finetti, "La prévision : ses lois logiques, ses sources subjectives", 1937.
* Czesław Ryll-Nardzewski, "On stationary sequences of random variables and the de
  Finetti's equivalence", 1957.
* Edwin Hewitt and Leonard Savage, "Symmetric measures on Cartesian products", 1955.
* Cameron Freer, *Three Roads to de Finetti's Theorem in Lean* (short paper),
  [ITP 2026](https://itp-conference-2026.github.io/program.html).
* `cameronfreer/exchangeability`, Lean 4 formalization of exchangeability and de Finetti.

## Acknowledgements

This roadmap uses Cameron Freer's `exchangeability` formalization as its primary migration
source. It also benefits
from the anonymous reviewers of Cameron Freer, *Three Roads to de Finetti's Theorem in
Lean* (short paper), whose feedback helped golf and simplify the library and make fuller
use of Mathlib. Ported files should preserve source attribution and document any
substantial API changes made during migration to Tau Ceti.
