# Roadmap: exchangeability and de Finetti

This roadmap adds **de Finetti's theorem about exchangeable sequences** to Tau Ceti, along
with the prerequisites it rests on: finite-dimensional exchangeability, contractability,
conditionally i.i.d. sequences, tail σ-algebras for processes, reverse-martingale
convergence along decreasing filtrations, the Koopman mean-ergodic bridge, and the
de Finetti–Ryll-Nardzewski equivalence. It builds on Mathlib's substantial probability and
analysis stack, which provides finite and product measures, kernels, `Measure.bind`,
conditional expectation, filtrations and martingales, `Lp` spaces, Hilbert-space
projections, measure-preserving maps, and the mean ergodic theorem, but none of the
exchangeability theory on top.

The source project
[`cameronfreer/exchangeability`](https://github.com/cameronfreer/exchangeability)
formalizes Kallenberg's Theorem 1.1 (in *Probabilistic Symmetries and Invariance
Principles*) for infinite sequences on standard Borel spaces,

```text
contractable ↔ exchangeable ↔ conditionally i.i.d.
```

and carries three complete proof routes: reverse martingales, L² contractability bounds,
and Koopman / mean ergodic theory. We migrate the mathematics in layers, separating
general-purpose probability infrastructure from the final exchangeability-specific
theorem.

Suggested homes:

```text
TauCeti/Probability/Exchangeability/
TauCeti/Probability/DeFinetti/
TauCeti/Probability/Process/
TauCeti/Probability/Martingale/
TauCeti/Probability/Ergodic/
TauCeti/MeasureTheory/Measure/
```

Migration sources, pinned at
[`e0532e59ceff23edab44dda9ab0655debbc9cc22`](https://github.com/cameronfreer/exchangeability/tree/e0532e59ceff23edab44dda9ab0655debbc9cc22):

The map below tracks the primary Lean sources. Source README, work-plan, and note files are
background only.

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
the conditional distributions live; the sample space `Ω` needs only a measurable structure
here. If the martingale proof routes the directing measure through `condExpKernel` (or
through `condDistrib` specialized to an identity-valued kernel with value space `Ω`), it
may temporarily also require `[StandardBorelSpace Ω]`, which is a constraint of that route
rather than of the statement.

The default public theorem should eventually use the reverse-martingale proof. The L²
route remains as a lighter real-valued theorem, and the Koopman route remains as the
ergodic-theory route with reusable operator-theoretic infrastructure.

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

---

## The build, in layers

The ordering below is the dependency order. As each layer makes the next layer's *types*
expressible in `TauCeti/`, state its milestones in `Targets.lean` with `sorry`.

### Layer 0: core exchangeability and finite marginals

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

### Layer 1: product kernels and the common ending

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

### Layer 2: tail σ-algebras and path-space shift

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

### Layer 3: the L² contractability proof

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

### Layer 4: reverse martingales and Lévy downward theorem

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
proof.

### Layer 5: Koopman and mean ergodic machinery

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

### Layer 6: the martingale proof of de Finetti

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

These are not prerequisites for the v1 theorem.

## Worked examples

Discharge these alongside the layers; they are checks against vacuous definitions.

* A conditionally i.i.d. sequence is exchangeable.
* An exchangeable sequence is contractable.
* Finite-dimensional marginals determine a probability measure on `ℕ → α`.
* The tail-family of a process is antitone.
* Lévy downward theorem for an eventually constant decreasing filtration.
* Koopman projection equals conditional expectation for the trivial shift.
* The L² theorem applies to a bounded real-valued exchangeable sequence.
* The default `deFinetti` theorem applies to a standard-Borel exchangeable sequence.

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

This roadmap is based on Cameron Freer's `exchangeability` formalization. It also benefits
from the anonymous reviewers of Cameron Freer, *Three Roads to de Finetti's Theorem in
Lean* (short paper), whose feedback helped golf and simplify the library and make fuller
use of Mathlib. Ported files should preserve source attribution and document any
substantial API changes made during migration to Tau Ceti.
