import Mathlib

/-!
# Exchangeability and de Finetti: target signatures

The narrative roadmap, the library spine, the layer-by-layer build plan (Layers 0–7), the
worked examples, and the references are in `README.md`.

Mathlib already has much of the ambient probability and analysis stack: finite products
of measures, kernels and `Measure.bind`, conditional expectation, filtrations and
martingales, `Lp` spaces, Hilbert-space projections, measure-preserving maps, and the
mean ergodic theorem. What is missing is the exchangeability/de Finetti library on top:
exchangeable and contractable sequences, conditionally i.i.d. sequences, tail σ-algebras
for processes, reverse martingale convergence along decreasing filtrations, the Koopman
projection/conditional-expectation bridge, and the de Finetti–Ryll-Nardzewski theorem.

As each layer makes the next layer's *types* expressible in `TauCeti/`, state that layer's
milestones here with `sorry` (human-owned roadmap territory, so `sorry` is allowed).

Natural first targets, in order:

* Layer 0: `Exchangeable`, `FullyExchangeable`, `Contractable`, finite-dimensional
  marginal uniqueness on `ℕ → α`, `exchangeable_iff_fullyExchangeable`, and
  `contractable_of_exchangeable`.
* Layer 1: product kernels, conditional independence, and mixtures — product-kernel
  measurability `Measurable fun ω => Measure.pi fun _ : Fin m => ν ω` and the common ending
  `conditional_iid_from_directing_measure`.
* Layer 2: `tailFamily`, `tailProcess`, `tailFamily_antitone`, path-space `shift`, and
  `shiftInvariantSigma`.
* Layer 3: the L² averaging library and real-valued de Finetti —
  `conditionallyIID_of_contractable_viaL2` and `deFinetti_viaL2`.
* Layer 4: reverse martingales and conditional-expectation limits, starting with
  `condExp_tendsto_iInf` for antitone filtrations.
* Layer 5: Koopman operators and invariant σ-algebras, ending in `deFinetti_viaKoopman`.
* Layer 6: directing measures and the de Finetti representation, ending in the default
  `deFinetti` and `deFinetti_RyllNardzewski_equivalence`.
* Layer 7: the public API surface (`Exchangeable`, `FullyExchangeable`, `Contractable`,
  `ConditionallyIID`, and the route theorems) together with the worked examples.

Compiled `sorry`-signatures (the Layer 0 core API and the easy bridges between the symmetry
notions) come in a follow-up PR; this file stays a placeholder while the roadmap stance is
settled.
-/

namespace TauCetiRoadmap.Exchangeability

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.Exchangeability
