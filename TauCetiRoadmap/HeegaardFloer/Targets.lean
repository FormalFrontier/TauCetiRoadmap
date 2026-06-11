import Mathlib

/-!
# Heegaard Floer and knot Floer homology: target signatures

The narrative roadmap is in `README.md`: two families of lanes — combinatorial
(grid homology, lattice homology, the Ozsváth–Stipsicz–Szabó stable `HF̂`) and
analytic (Morse homology, Fredholm/Sard–Smale, the Cauchy–Riemann elliptic
package, J-holomorphic curves, Lagrangian Floer homology, `HF̂` via `Sym^g`) —
meeting at precisely-stated reconciliation theorems.

Nothing knot-theoretic or Floer-theoretic exists in Mathlib yet, so there are no
compiled targets to state against the pin. As the prerequisite *types* land in
`TauCeti/` (grid diagrams and grid states first; then bigraded complexes over
`𝔽₂[V₁,…,Vₙ]`; then plumbing lattices; then the analytic substrate), state each
lane's milestones here with `sorry` (human-owned roadmap territory, so `sorry` is
allowed) and hand them to the AIs to discharge. The natural first new theorems
(Lane G.3–G.5) are

  `∂² = 0` for the fully blocked grid complex over `𝔽₂`,
  `χ(GĤ K) = Δ_K(t)`, and
  `GH' G ≅ GH' G'` for grids related by commutation and stabilization moves.
-/

namespace TauCetiRoadmap.HeegaardFloer

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.HeegaardFloer
