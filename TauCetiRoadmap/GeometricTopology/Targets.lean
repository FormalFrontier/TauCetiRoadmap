import Mathlib

/-!
# Geometric topology and the Kirby-list problems: target signatures

The narrative roadmap is in `README.md`: eleven layers of differential and geometric
topology built bottom-up from current Mathlib (the manifold buildout and structure
groups; locally flat embeddings; diffeomorphism-group topologies; knot theory; Dehn
surgery; knot concordance and 4D cobordism; Riemannian volume and hyperbolic structures;
geometric decomposition; Heegaard genus; foliations; triangulations and collapse), each
attached to the solved Kirby-list problems it would let us *state*. Knot theory and the
concordance foundations (layers 4 and 6) are owned here; the homological concordance
invariants (`τ`, `s`) are consumed from the
[combinatorial Heegaard Floer roadmap](../CombinatorialHeegaardFloer/Targets.lean), which
in turn consumes the knot types defined here.

Mathlib has the smooth-manifold-and-tangent-bundle substrate (`ModelWithCorners`,
`IsManifold`, `TangentBundle`, `Diffeomorph`, the structure groupoids, `IsCoveringMap`,
`HomotopyGroup`, singular homology, and the metric-and-distance layer of the Riemannian
library), but **none** of the geometric-topology primitives the Kirby statements need:
no connected sum or boundary gluing, no locally flat embeddings, no diffeomorphism-group
topology, no knot theory beyond `Quandle`, no Dehn surgery, no Riemannian volume or
hyperbolic structures, no Heegaard genus, no foliation Euler class, no
triangulation-of-a-manifold. So, exactly as in the Heegaard Floer and Universal Covers
roadmaps, there are no compiled targets to state against the pin yet: the whole point of
the issue is that these theorems are not statable today.

As the prerequisite *types* land in `TauCeti/` (layer 1's gluing and connected sum first,
then surgery, then the volume measure), state each layer's milestones here with `sorry`
(human-owned roadmap territory, so `sorry` is allowed). The natural first new targets, in
dependency order, have these shapes:

  -- Layer 1, the gluing engine and its first invariant:
  -- def connectedSum (M N : Manifold ...) : Manifold ... := ...
  -- theorem connectedSum_sphere (M : Manifold ...) : connectedSum M (sphere n) ≃ₘ M
  --
  -- Layer 3, the Smale conjecture, once Diff carries the C^∞ topology:
  -- theorem smale_conjecture : Diff (sphere 3) ≃ₜ* orthogonalGroup 4 ...   -- [Kir97, 4.34]
  --
  -- Layer 4, topological sliceness stated cleanly (knot theory owned here):
  -- theorem freedman_alexanderOne_slice (K : Knot) (h : alexander K = 1) :
  --     IsTopologicallySlice K                                             -- [Kir97, 1.36]
  --
  -- Layer 5, Dehn surgery recovering known manifolds (the convention check):
  -- theorem surgery_unknot_zero : dehnSurgery unknot (0 : Slope) ≃ₘ (circle ×ₘ sphere 2)
  --
  -- Layer 7, the Weeks manifold as the volume minimiser:
  -- theorem weeks_minimal_volume (M : ClosedHyperbolic3Manifold) :
  --     volume weeksManifold ≤ volume M                                    -- [Kir97, 3.60]
-/

namespace TauCetiRoadmap.GeometricTopology

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.GeometricTopology
