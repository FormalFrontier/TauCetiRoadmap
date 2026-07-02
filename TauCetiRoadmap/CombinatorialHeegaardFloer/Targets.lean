import Mathlib

/-!
# Combinatorial Heegaard Floer and grid homology: target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is
`README.md`. The statements here suggest Lean forms for particular milestones, so that
contributors and reviewers converge on names and signatures; discharging all of them
finishes neither a layer nor the roadmap.

The narrative roadmap is in `README.md`: the combinatorial bodies of theory that are
formalizable now — grid homology (Lane G), bigraded and filtered homological algebra
(Lane ALG), knot-theory reconciliation (Lane K), lattice homology (Lane L), and the
Ozsváth–Stipsicz–Szabó stable `HF̂` of 3-manifolds (Lane H). The analytic tower lives
in the sibling `HeegaardFloer` roadmap, which also owns the reconciliation theorems
that match each invariant here to its holomorphic counterpart (they are
analytic-blocked, so they are tracked with the slower track).

Nothing knot-theoretic or Floer-theoretic exists in Mathlib yet, so there are no
compiled targets to state against the pin. As the prerequisite *types* land in
`TauCeti/` (grid diagrams and grid states first; then bigraded complexes over
`𝔽₂[V₁,…,Vₙ]`; then plumbing lattices), state each lane's milestones here with
`sorry` (human-owned roadmap territory, so `sorry` is allowed). The natural first new
theorems (Lane G.3–G.5) are

  `∂² = 0` for the fully blocked grid complex over `𝔽₂`,
  `χ(GĤ K) = Δ_K(t)`, and
  `GH' G ≅ GH' G'` for grids related by commutation and stabilization moves.
-/

namespace TauCetiRoadmap.CombinatorialHeegaardFloer

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.CombinatorialHeegaardFloer
