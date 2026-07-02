import Mathlib

/-!
# Heegaard Floer homology, analytically: target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is
`README.md`. The statements here suggest Lean forms for particular milestones, so that
contributors and reviewers converge on names and signatures; discharging all of them
finishes neither a layer nor the roadmap.

The narrative roadmap is in `README.md`: the analytic tower — Morse homology
(Lane M), the Fredholm/Sard–Smale substrate (Lane F0), the Cauchy–Riemann elliptic
package (Lane F1), J-holomorphic curves (Lane F2), exact Lagrangian Floer homology
(Lane F3), and `HF̂` via holomorphic disks in `Sym^g(Σ)` (Lanes F4–F5). The
combinatorial bodies of theory live in the sibling `CombinatorialHeegaardFloer`
roadmap; the reconciliation theorems that join each combinatorial invariant to its
holomorphic counterpart are owned here, since they depend on this analytic tower.

Nothing Floer-theoretic exists in Mathlib yet, so there are no compiled targets to
state against the pin. As the prerequisite *types* land in `TauCeti/` (the analytic
substrate: finite-dimensional Sard and Fredholm operators first; then the
Cauchy–Riemann package; then almost complex structures and `Sym^g(Σ)`), state each
lane's milestones here with `sorry` (human-owned roadmap territory, so `sorry` is
allowed). The natural first new theorems are Morse homology's `∂² = 0` and its
isomorphism with Mathlib's singular homology (Lane M), then `HF(L, φ(L)) ≅ H_*(L)`
for exact Lagrangians in `T*M` (Lane F3).
-/

namespace TauCetiRoadmap.HeegaardFloer

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.HeegaardFloer
