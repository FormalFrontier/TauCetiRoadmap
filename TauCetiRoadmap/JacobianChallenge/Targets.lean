import Mathlib

/-!
# Jacobian challenge (AG version): target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is
`README.md`. The statements here suggest Lean forms for particular milestones, so that
contributors and reviewers converge on names and signatures; discharging all of them
finishes neither a layer nor the roadmap.

The narrative roadmap, the prerequisite tower (Layers A–E), and the acceptance
criteria are in `README.md`. Almost none of the prerequisites are in Mathlib; the tower
is built in `TauCeti/AlgebraicGeometry/`.

As each layer makes the next layer's *types* expressible in `TauCeti/`, state that
layer's milestones here with `sorry` (human-owned roadmap territory, so `sorry` is
allowed), starting with Layer A (the Picard group and the degree map) and building up to
`noncomputable def JacobianVariety` and the universal property of the Abel–Jacobi map.

Note the name clash flagged in `README.md`: Mathlib's `WeierstrassCurve.Jacobian`
means Jacobian *coordinates*, not the Jacobian *variety*, so use `JacobianVariety`.
-/

namespace TauCetiRoadmap.JacobianChallenge

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.JacobianChallenge
