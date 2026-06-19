# Roadmap: geometric topology and the solved Kirby-list problems

A useful exercise while building the topology problems in
[`leanprover/lean-eval`](https://github.com/leanprover/lean-eval) has been to walk Rob
Kirby's problem list (`[Kir97]`, *Problems in Low-Dimensional Topology*) and its recent
successor lists, pick out problems that have since been **solved** (sometimes by proving
the negation of Kirby's question), and ask a narrower question than "can we prove this":
can we even *state* the resolved theorem in Lean today?

For a good fraction of them the answer is no. Not because the proof is hard, but because
the *statement* needs primitives Mathlib does not have: Dehn surgery, knot concordance,
hyperbolic volume, Heegaard genus, foliation Euler classes, locally flat embeddings,
diffeomorphism-group topologies. This roadmap builds, on top of Mathlib, everything
needed to *state* (not prove) these theorems faithfully.

To be clear about scope: this is about **statements**, not proofs. A faithful, idiomatic
statement of "the Weeks manifold has the smallest volume among closed orientable
hyperbolic 3-manifolds" is already a large, valuable target, independent of any hope of
proving it. Several of the layers below (the manifold buildout, gluing, surgery, the
diffeomorphism-group topology) are reusable library infrastructure whose value does not
depend on any one Kirby problem.

Suggested homes: `TauCeti/Geometry/Manifold/` (gluing, connected sum, tubular
neighbourhoods, structure groups), `TauCeti/Geometry/Diffeomorphism/` (the C^∞ topology),
`TauCeti/LowDimTopology/` (Dehn surgery, Heegaard splittings, foliations),
`TauCeti/Geometry/Hyperbolic/` (constant-curvature structures and volume),
`TauCeti/Topology/PL/` (triangulations, collapse).

## Relationship to the Heegaard Floer roadmaps

This roadmap **owns knot theory done properly** (layer 4) and the **concordance and
cobordism foundations** (layer 6): the many presentations of a knot or link as first-class
types, the maps between them, smoothly and topologically slice as clean definitions, the
knot polynomials with the algorithms that compute them, the concordance group, and the
cobordism category. These are foundational geometric topology that Dehn surgery (layer 5),
concordance, and grid homology all build on, so they live here rather than inside any one
homology theory. (An earlier draft deferred them to the combinatorial Heegaard Floer
roadmap; they are more naturally ours, and that roadmap already treats knot theory as a
non-prerequisite side-lane.)

The [combinatorial Heegaard Floer roadmap](../CombinatorialHeegaardFloer/README.md)
*consumes* these knot types and *contributes* homological invariants of them: its
grid-homology spine builds the concordance invariant `τ` and the slice-genus bound
`|τ(K)| ≤ g_s(K)`, and its Lane K reconciles grid diagrams (one more presentation) with
the presentations built here, via Cromwell's theorem. The dependency runs from there to
here for the *definitions*, and from here to there for the *invariants*: this roadmap
states `|τ(K)| ≤ g_s(K)` as a consumer of that roadmap's `τ`, and that roadmap states "a
grid diagram presents this knot" as a consumer of this roadmap's presentation types. The
shared convention is "a knot has no privileged representation".

## Principles

- **Connected all the way down to Mathlib.** Every layer starts exactly where Mathlib
  leaves off today, with no floating definitions. Where a primitive already exists
  (`ModelWithCorners`, the tangent bundle, `IsCoveringMap`, `HomotopyGroup`, singular
  homology, the nascent Riemannian-metric library) we consume it; where it does not, the
  roadmap adds it as an explicit dependency. The deliverable is a dependency graph rooted
  in current Mathlib, not a wishlist. The inventories below name the exact files we build
  on.
- **Maximum generality where it is natural.** We do not specialise to dimensions 3 and 4
  just because the Kirby problems live there. Build manifolds-with-boundary, gluing,
  tubular neighbourhoods, and surgery in general dimension; work with arbitrary structure
  groups (Top, PL, Diff, and `O(n)`, `SO(n)`) rather than hard-coding the smooth
  orthogonal case; build the diffeomorphism-group topology for general manifolds rather
  than just `S³`. The low-dimensional statements then fall out as instances. It is more
  work up front, but it is the difference between a library and a pile of special cases.
- **Treat the foundations as first-class goals.** A lot of the gap is just missing
  differential and geometric topology. The roadmap treats "build connected sums" or
  "build Dehn surgery" as library goals that happen to unlock several problems, not as
  one-off scaffolding for a single theorem.
- **Statements stay unbundled.** As in the PDE and Heegaard Floer roadmaps, named
  hypotheses (locally flat vs smooth, Top vs PL vs Diff structure group, orientable vs
  not) stay separate rather than bundled into one structure, so a theorem can be restated
  in a neighbouring category without rebuilding the topology.

## Inventory: what Mathlib gives us (consume)

Verified against the pinned Mathlib (`Mathlib/`, commit `9caeba1`, Lean `v4.31.0-rc1`).

- **Smooth manifolds with boundary and corners.** `ModelWithCorners` and `IsManifold` in
  `Mathlib/Geometry/Manifold/IsManifold/Basic.lean`; boundary and interior
  (`ModelWithCorners.boundary`, `ModelWithCorners.interior`, `IsInteriorPoint`,
  `IsBoundaryPoint`, and `univ_eq_interior_union_boundary`) in
  `Mathlib/Geometry/Manifold/IsManifold/InteriorBoundary.lean`; the half-space and
  quadrant models `modelWithCornersEuclideanHalfSpace` and
  `modelWithCornersEuclideanQuadrant` in `Mathlib/Geometry/Manifold/Instances/Real.lean`;
  `ChartedSpace` in `Mathlib/Geometry/Manifold/ChartedSpace.lean`.
- **Tangent bundles, smooth maps, derivatives.** `TangentBundle` and `TangentSpace` in
  `Mathlib/Geometry/Manifold/VectorBundle/Tangent.lean`; `ContMDiff` in
  `Mathlib/Geometry/Manifold/ContMDiff/Defs.lean`; bundled smooth maps in
  `Mathlib/Geometry/Manifold/ContMDiffMap.lean`; `mfderiv` in
  `Mathlib/Geometry/Manifold/MFDeriv/`.
- **Structure groupoids.** `StructureGroupoid` in
  `Mathlib/Geometry/Manifold/StructureGroupoid.lean`; `contDiffGroupoid` and
  `analyticGroupoid` in `Mathlib/Geometry/Manifold/IsManifold/Basic.lean`;
  `continuousGroupoid` (the topological-manifold structure group) and `HasGroupoid` in
  `Mathlib/Geometry/Manifold/HasGroupoid.lean`.
- **Diffeomorphisms.** The type `Diffeomorph` (notation `M ≃ₘ⟮I, I'⟯ M'`) in
  `Mathlib/Geometry/Manifold/Diffeomorph.lean`; smooth embeddings (`IsSmoothEmbedding`) in
  `Mathlib/Geometry/Manifold/SmoothEmbedding.lean`. No group topology yet (see below).
- **Point-set topology of maps.** `Homeomorph` in `Mathlib/Topology/Homeomorph/Defs.lean`;
  `IsEmbedding`, `IsOpenEmbedding`, `IsClosedEmbedding` in `Mathlib/Topology/Maps/Basic.lean`.
- **Spheres.** The analytic manifold and Lie-group structure on `Metric.sphere` (via
  stereographic projection, and the circle as a Lie group) in
  `Mathlib/Geometry/Manifold/Instances/Sphere.lean`.
- **Algebraic topology.** `FundamentalGroup` and `FundamentalGroupoid` in
  `Mathlib/AlgebraicTopology/FundamentalGroupoid/`; higher homotopy groups
  (`HomotopyGroup`) in `Mathlib/Topology/Homotopy/HomotopyGroup.lean`; covering maps
  (`IsCoveringMap`) in `Mathlib/Topology/Covering/Basic.lean` with homotopy lifting in
  `Mathlib/Topology/Homotopy/Lifting.lean`; singular homology in
  `Mathlib/AlgebraicTopology/SingularHomology/Basic.lean`; CW complexes in
  `Mathlib/Topology/CWComplex/Abstract/Basic.lean` and
  `Mathlib/Topology/CWComplex/Classical/Basic.lean`.
- **Simplicial machinery.** Abstract simplicial complexes in
  `Mathlib/AlgebraicTopology/SimplicialComplex/Basic.lean`; geometric simplicial
  complexes in a real vector space in `Mathlib/Analysis/Convex/SimplicialComplex/Basic.lean`;
  simplicial sets and the geometric-realization adjunction (`toTopHomeo`,
  `|Δ[n]| ≅ stdSimplex`) in `Mathlib/AlgebraicTopology/SimplicialSet/TopAdj.lean`.
- **Riemannian metrics.** `RiemannianBundle`, `IsRiemannianManifold`, the induced
  `riemannianEDist`, and `EMetricSpace.ofRiemannianMetric` in
  `Mathlib/Geometry/Manifold/Riemannian/Basic.lean`; path length in
  `Mathlib/Geometry/Manifold/Riemannian/PathELength.lean`. This is the engine for layer 7,
  but it stops at the metric-and-distance level: no volume, no curvature (see below).
- **Lie groups and matrix groups.** `LieGroup` in
  `Mathlib/Geometry/Manifold/Algebra/LieGroup.lean`; `Matrix.orthogonalGroup` and
  `Matrix.specialOrthogonalGroup` in `Mathlib/LinearAlgebra/UnitaryGroup.lean`.
- **Knot-adjacent algebra.** `Quandle` (the only knot-adjacent file upstream) in
  `Mathlib/Algebra/Quandle.lean`; presented monoids (the seed for braid groups, from
  Hannah Fechtner's program) in `Mathlib/Algebra/PresentedMonoid/Basic.lean`. Both feed
  layer 4's knot theory (colourings and braid groups), built here and consumed in turn by
  the combinatorial Heegaard Floer roadmap's Lane K.

## Inventory: what is missing (build)

Everything geometric-topological past the smooth-manifold-and-tangent-bundle level. In
rough dependency order:

- **PL and Top manifold categories as structure groups.** Mathlib has the `contDiff`,
  `analytic`, and `continuous` groupoids, but no piecewise-linear groupoid and no
  category-of-structure-groups API tying Top, PL, and Diff together. Smoothing and
  triangulation theory (the obstruction theory relating the three) is entirely absent.
- **Gluing and surgery primitives.** Connected sum, gluing two manifolds along
  diffeomorphic boundary pieces, tubular neighbourhoods, handle attachment, and
  Dehn-style surgery (cut out a tubular neighbourhood of a submanifold, reglue by a
  diffeomorphism of the boundary). None of this exists; it is the load-bearing core of
  layers 1 and 5.
- **Locally flat embeddings** in general dimension (a topological embedding that is
  locally a flat slice in a chart). Absent.
- **Diffeomorphism groups as topological groups** with the C^∞ topology, and the
  smooth-families ↔ continuous-maps-into-`Diff` correspondence. The `Diffeomorph` *type*
  exists; the group object and its topology do not.
- **Knot theory beyond `Quandle`**: the presentations of a knot or link as first-class
  types, the maps between them and the adequacy theorems, smoothly and topologically slice,
  and the knot polynomials with algorithms. Absent, and owned here (layer 4).
- **Knot complements as manifolds**, slopes, solid-torus gluing (Dehn surgery proper).
  Absent; built on layer 4's knots and layer 1's gluing.
- **The 4-dimensional topology behind topological sliceness** (Freedman's theory): topologically
  locally flat surfaces in the 4-ball, and topological slice discs. Absent.
- **Riemannian volume and curvature.** The metric-and-distance layer exists; the Riemannian
  volume measure, sectional and Ricci curvature, complete constant-curvature metrics,
  hyperbolic structures, and the volume of a hyperbolic manifold are all missing.
- **Thurston geometries and geometric decomposition** (the eight model geometries, the
  JSJ decomposition, the statement of a geometric structure on a piece). Absent.
- **Heegaard splittings and Heegaard genus** of a 3-manifold. Absent.
- **Foliations and their Euler class.** Absent.
- **Geometric realization of abstract simplicial complexes** as topological spaces (the
  realization functor exists for simplicial *sets*, but not the triangulation-of-a-manifold
  notion), PL structures, and simplicial or CW collapse. Absent.

## The layers, bottom-up from Mathlib

Ordered roughly from "closest to Mathlib" to "furthest". The early layers are
high-leverage and close to Mathlib; the geometric-structures layers are the hardest. Each
layer below records what it starts from (in Mathlib or an earlier layer), what to build
(with illustrative target shapes, not yet compiled), the design pitfalls, and the Kirby
problems it would let us *state*. The ordering and granularity are a first cut, offered to
be argued with: layers 1 and 5 in particular could be split further, and layers 7 and 8
share a Riemannian substrate that could be its own node.

PL topology runs through two of these layers and the two accounts must agree: layer 1
builds it the chart-based way (a `PLGroupoid` of piecewise-linear transition maps, parallel
to `contDiffGroupoid`), and layer 11 builds it the simplicial way (combinatorial manifolds,
the complexes whose vertex links are spheres or balls). The reconciliation theorem
(layer 11) that the polyhedron of a combinatorial manifold is a PL manifold, and
conversely, is what ties them together, and is the reason layer 1's `PLGroupoid` should be
shaped with that proof in mind.

### Layer 1: manifold-library buildout (general dimension, general structure group)

This is the spine. Almost everything below needs to cut a manifold open along a
submanifold and reglue, and none of it exists in Mathlib today. The work splits into a
*gluing* track and a *structure-group* track. The comparison between the smooth, PL, and
topological structures, where the two tracks would meet, is a major sub-project in its own
right and is flagged separately below rather than treated as a quick deliverable.

**From Mathlib.** `ModelWithCorners 𝕜 E H` and `IsManifold I n M`
(`Mathlib/Geometry/Manifold/IsManifold/Basic.lean`); the boundary and interior of a
manifold as sets, `I.boundary M : Set M`, `I.interior M`, with `I.IsBoundaryPoint`,
`I.IsInteriorPoint`, and `univ_eq_interior_union_boundary`
(`Mathlib/Geometry/Manifold/IsManifold/InteriorBoundary.lean`); the half-space and
quadrant models `modelWithCornersEuclideanHalfSpace n` and `modelWithCornersEuclideanQuadrant n`
(`Mathlib/Geometry/Manifold/Instances/Real.lean`); `StructureGroupoid H`, `Pregroupoid H`,
and the constructor `Pregroupoid.groupoid` (`Mathlib/Geometry/Manifold/StructureGroupoid.lean`);
`contDiffGroupoid`, `analyticGroupoid`, and `continuousGroupoid`.

**What to build, gluing track.**
- **Boundary as a manifold.** `I.boundary M` is currently only a set; promote it to a
  boundaryless `C^n` manifold one dimension lower, with its inclusion a smooth embedding.
  This is the prerequisite for every gluing below.
- **Collar neighbourhoods.** A boundary component has a neighbourhood diffeomorphic to
  `∂M × [0, 1)` (the collar theorem; Hirsch, *Differential Topology*, GTM 33, §4.6; Lee,
  *Introduction to Smooth Manifolds*, GTM 218, 2nd ed., Theorem 9.25). Collars are what make
  a gluing smooth rather than merely topological, and they feed the well-definedness proofs.
- **Gluing along a piece of the boundary.** The general operation glues a codimension-0
  submanifold-with-corners `A ⊆ ∂M` to one `B ⊆ ∂N` along a diffeomorphism `f : A ≃ₘ B`,
  producing `M ∪_f N` with corners along `∂A`. Full-boundary gluing is the special case
  `A = ∂M`, `B = ∂N`; **handle attachment** is `N` a handle `Dᵏ × Dⁿ⁻ᵏ` glued along
  `Sᵏ⁻¹ × Dⁿ⁻ᵏ ⊆ ∂N`; and partial gluings (a rectangle onto a disc along two of its edges,
  say) are the same def with `A`, `B` proper faces. Set this up for arbitrary manifolds, not
  only handles, because everything downstream (surgery, handlebodies, cobordism
  composition) is a special case of it.
- **Tubular neighbourhoods.** A closed submanifold has a neighbourhood diffeomorphic to the
  total space of its normal bundle (tubular neighbourhood theorem; Hirsch GTM 33, §4.5; Lee
  GTM 218, Theorem 6.24), consuming Mathlib's smooth vector bundles; the disc- and
  sphere-bundle versions are the surgery interface for layer 5.
- **Connected sum, with the choices explicit.** The definition must *take* the data it
  depends on: an orientation on each summand and an embedding of the closed `n`-ball into
  each, inducing opposite orientations; `M # N` deletes the open balls and glues along the
  resulting spheres. Independence of the balls is then a *theorem*, not part of the
  definition, proved from the disc theorem (any two orientation-compatible ball embeddings
  into a connected manifold are ambient isotopic; Palais, *Extending diffeomorphisms*, Proc.
  AMS 11 (1960) 274–277; Hirsch GTM 33, §8.3, Theorem 8.3.1). A downstream wrapper then
  picks the balls on a connected oriented manifold and inherits well-definedness from that
  theorem.

```lean
-- the boundary is a boundaryless manifold one dimension down
-- instance : IsManifold (I.boundaryModel) n (I.boundary M)
-- gluing along a piece of the boundary (faces A ⊆ ∂M, B ⊆ ∂N); produces corners along ∂A
-- def glue (M N) (A : Face (I.boundary M)) (B : Face (I.boundary N)) (f : A ≃ₘ⟮…⟯ B) : Manifold …
-- handle attachment and full-boundary gluing are special cases of `glue`
-- def attachHandle (M) (k) (φ : Embedding (sphere (k-1) ×ₘ ball (n-k)) (I.boundary M)) : Manifold …
--
-- connected sum TAKES the balls; independence is a theorem, not baked into the def
-- def connectedSum (e₁ : Embedding (closedBall n) M) (e₂ : Embedding (closedBall n) N)
--     (h : OrientationReversing e₁ e₂) : Manifold …
-- theorem connectedSum_indep (e₁ e₁' e₂ e₂' …) : connectedSum e₁ e₂ _ ≃ₘ connectedSum e₁' e₂' _
-- the picking wrapper, on connected oriented summands, and its first identity
-- noncomputable def connSum (M N) [Connected M] [Connected N] [Oriented M] [Oriented N] : Manifold …
-- theorem connSum_sphere (M) : connSum M (sphere n) ≃ₘ M
```

**What to build, structure-group track.**
- **The PL pregroupoid, spelled out.** Capitalised `PLPregroupoid`. The underlying predicate
  is *not* "affine on the pieces of a finite triangulation": open subsets of the model are
  non-compact, so the right notion is local and locally finite. A continuous `f : U → model`
  on an open `U` is PL if every point of `U` has a neighbourhood on which `f` is affine on
  each cell of a *locally finite* polyhedral subdivision, equivalently (Rourke–Sanderson,
  *Introduction to PL Topology*, Chapters 1–2) if the graph of `f` near each point is a
  polyhedron. This predicate is what must satisfy Mathlib's `Pregroupoid` laws (locality,
  restriction to opens, closure under composition, identity), and the locally-finite
  formulation is exactly what makes restriction-to-opens and composition hold; a
  finite-pieces formulation fails restriction. Build the predicate for the half-space and
  quadrant models too, so PL manifolds-with-corners are available. Then
  `PLGroupoid := PLPregroupoid.groupoid`, and a PL manifold is `HasGroupoid M PLGroupoid`.
- **The one genuine groupoid inclusion**, `PLGroupoid ≤ continuousGroupoid` (PL maps are
  continuous), giving the forgetful "PL implies Top". ⚠ There is *no* inclusion
  `contDiffGroupoid ≤ PLGroupoid`: a smooth transition map is not literally PL. The relation
  between smooth and PL structures is the Whitehead smoothing comparison below, a map between
  structures rather than a containment of groupoids, and it is not cheap.

**The smoothing-and-triangulation comparison (a sub-project, flagged).** Relating the three
categories is a major undertaking, arguably its own roadmap, and is *not* a quick layer-1
deliverable. Stage it, hardest part last:
1. **Smooth implies PL.** Every smooth manifold has an essentially unique PL structure (a
   smooth triangulation, Whitehead). References: J. H. C. Whitehead, *On C¹-complexes*, Ann.
   of Math. 41 (1940) 809–824; the full modern development in J. Munkres, *Elementary
   Differential Topology* (Annals of Math. Studies 54, 1966), the smoothing-of-triangulations
   and uniqueness sections. Classical and self-contained, but already a substantial body of
   work (Whitney/Cairns triangulation plus the uniqueness argument).
2. **PL implies Top.** The forgetful direction, immediate from the groupoid inclusion above.
3. **Top to PL, the smoothing obstruction.** The deep, far-horizon part: the
   Kirby–Siebenmann obstruction in `H⁴(M; ℤ/2)` to a PL structure, and the failure of the
   Hauptvermutung. Reference: R. Kirby, L. Siebenmann, *Foundational Essays on Topological
   Manifolds, Smoothings, and Triangulations* (Annals of Math. Studies 88, 1977), Essays
   IV–V. Treat this as genuinely speculative, and keep each direction a separate named target
   so the easy ones are never blocked on the hard one.

**Design notes.** Keep orientability a separate predicate, not bundled into the manifold
(the connected-sum API above already depends on this). State gluing in the corners category
from the start, since gluing along a proper face of the boundary *produces* corners along
the seam, so the API must already live there to compose with itself. Define `PLGroupoid` so
that layer 11's link-condition definition of a combinatorial manifold can be *proved
equivalent* to it (the "combinatorial manifold = PL manifold" reconciliation; Rourke–Sanderson,
Chapter 3); this is the concrete sense in which the chart-based and simplicial accounts of
PL topology must agree, and it is why the locally-finite predicate above is the right one, a
triangulation gives exactly locally finite affine pieces.

**Unlocks.** Smoothability of `⋆RP⁴ # ⋆CP²`, `[Kir97, Problem 4.82]` (connected sum plus a
smooth structure on a fake `RP⁴`), and, as infrastructure, every gluing and surgery below.

### Layer 2: locally flat embeddings in general dimension

Topological manifolds have embeddings that are pathological in ways smooth embeddings are
not (wild arcs, the Alexander horned sphere), so the statements in this corner of topology
quantify over *locally flat* embeddings: a topological embedding `f : N → M` is locally
flat if every point of `f(N)` has a chart of `M` in which `f(N)` is a coordinate slice
`ℝⁿ ⊆ ℝᵐ`. lean-eval already carries a usable encoding via partial-homeomorphism model
charts; this layer generalises it to a reusable definition.

**From Mathlib / earlier layers.** `Homeomorph`, `IsEmbedding`, `IsOpenEmbedding`
(`Mathlib/Topology/Maps/Basic.lean`); the chart machinery of `ChartedSpace` and the
topological-manifold structure group `continuousGroupoid` (layer 1).

**What to build.**
- The predicate **`IsLocallyFlat f`** for a topological embedding `f : N → M` of
  topological manifolds, via "a slice chart exists at every image point", with the basic
  closure properties (restriction, composition with homeomorphisms).
- **Local flatness vs the smooth and PL cases**: a smooth or PL embedding is locally flat,
  stated against layer 1's structure groups, so the low-codimension subtleties are isolated
  in exactly one definition.
- The **product-region statement**: a locally flat embedded `Sⁿ⁻¹ × [0,1]` between two
  parallel locally flat spheres bounds a region homeomorphic to `Sⁿ⁻¹ × [0,1]` (the shape
  of the Annulus Conjecture).

```lean
-- def IsLocallyFlat (f : N → M) : Prop := IsEmbedding f ∧ ∀ x, ∃ chart …, sliceAt chart (f x)
-- theorem isLocallyFlat_of_smoothEmbedding … : IsLocallyFlat f
-- theorem annulus_conjecture … : -- two parallel locally flat spheres cobound a product
```

**Design notes.** Codimension matters: local flatness is automatic in high codimension but
substantive in codimension 1 and 2, so do not bake a codimension assumption into the
definition. The companion notion, a **locally flat submanifold with a normal bundle**
(topological tubular neighbourhood), is the topological analogue of layer 1's tubular
neighbourhoods and is what layer 5's topological surgery would consume; flag it as a
dependency rather than building it here.

**Unlocks.** The Annulus Conjecture (Kirby 1969 in dimension `≥ 5`; Quinn 1982 in
dimension 4; no Kirby number): two parallel locally flat spheres cobound a product region.

### Layer 3: diffeomorphism groups with the C^∞ topology

The Smale conjecture and its 4-dimensional cousin are statements about the *homotopy type*
of the group `Diff(M)` of self-diffeomorphisms. To state them we need `Diff(M)` as a
topological group, with the C^∞ (weak Whitney) topology, for general manifolds. Mathlib has
the `Diffeomorph` type but no group object and no topology on it; lean-eval currently dodges
this with an ad-hoc "relative parameterized" form, which this layer is meant to retire.

**From Mathlib / earlier layers.** `Diffeomorph` (`structure Diffeomorph extends M ≃ M'`,
notation `M ≃ₘ^n⟮I, I'⟯ M'`) in `Mathlib/Geometry/Manifold/Diffeomorph.lean`; bundled
smooth maps `ContMDiffMap` (`Mathlib/Geometry/Manifold/ContMDiffMap.lean`); the
topological-group and uniform-space API from Mathlib's algebra-and-topology libraries;
`HomotopyGroup` (`Mathlib/Topology/Homotopy/HomotopyGroup.lean`) for the conclusions.

**What to build.**
- The **group** `Diff(M) := M ≃ₘ^∞⟮I, I⟯ M` under composition (the `Group` instance is
  routine from the existing `Diffeomorph` composition and inverse).
- The **C^∞ topology** on `Diff(M)`, for `M` compact as the first case (uniform convergence
  of all derivatives in charts), making it a topological group, and the same topology on
  `Diff(M, ∂M)` (diffeomorphisms fixing the boundary) for the relative statements.
- The **smooth-families correspondence**: a smooth map `P × M → M` that is a
  diffeomorphism in the `M` variable for each `p` is the same as a continuous map
  `P → Diff(M)`. This is the property the whole layer exists to provide, since it turns
  "smooth family" (what proofs produce) into "map into the group" (what homotopy-type
  statements need).
- The reference inclusion `O(n+1) → Diff(Sⁿ)` (consume `Matrix.orthogonalGroup`, layer 7's
  isometry action, and the sphere instance) as a continuous group homomorphism.

```lean
-- instance : Group (Diff I M)
-- instance : TopologicalGroup (Diff I M)   -- the C^∞ topology, M compact
-- def smoothFamilyEquiv : C(P, Diff I M) ≃ {f : P × M → M // …}   -- families ↔ maps
-- theorem smale_conjecture : Nonempty (HomotopyEquiv (Diff 𝓘 (sphere 3)) (orthogonalGroup 4 ℝ))
```

**Design notes.** State the Smale conjecture as a homotopy equivalence of the underlying
spaces, not as an isomorphism of homotopy groups, so it is not silently weaker; the
inclusion `O(4) → Diff(S³)` being a homotopy equivalence is the sharp form. For Watanabe's
disproof, the right target is that a specific element of `π_k(Diff(D⁴, ∂))` (a Hatcher–Wagoner
or graph-clasper class) is nonzero, which needs `Diff(M, ∂M)` and its homotopy groups, not
just `π₀`. Keep "compact `M`" and "`M` with boundary, fixing the boundary" as separate
named setups.

**Unlocks.** The Smale conjecture `Diff(S³) ≃ O(4)` (Hatcher), `[Kir97, Problem 4.34]`, and
Watanabe's disproof of the 4-dimensional Smale conjecture, `[Kir97, Problem 4.126]`.

### Layer 4: knot theory, done properly (owned here)

This is a whole subproject and the most glaring gap: Mathlib has nothing knot-theoretic
beyond `Quandle`. The lean-eval Piccirillo and Conway-knot statements are, frankly, an
ad-hoc disaster, and cleaning them up means building real foundations. The design
commitment, shared with the combinatorial Heegaard Floer roadmap, is **no privileged
representation**: a knot is not "an embedding `S¹ ↪ S³`" any more than it is "a diagram",
and the content is in the *types of presentation*, the *maps between them*, and the
theorems saying when two presentations give the same knot.

**From Mathlib / earlier layers.** `Quandle` (`Mathlib/Algebra/Quandle.lean`) as the seed
for diagram colourings; `PresentedMonoid` (`Mathlib/Algebra/PresentedMonoid/Basic.lean`,
from Hannah Fechtner's braid program) for braid groups; smooth embeddings
(`IsSmoothEmbedding`) and the sphere instance for the geometric presentation; layer 1's
manifolds for complements (handed on to layer 5).

**What to build.**
- **The presentations, as first-class types.** Smooth and PL embeddings `S¹ ↪ S³` (or
  `ℝ³`); PL polylines; braid closures (over `PresentedMonoid` braid groups with the
  Artin relations); knot diagrams as 4-valent planar graphs with crossing signs, and the
  equivalent oriented PD codes and Gauss codes. Each is a `Type`, with the forgetful and
  realization maps between them (a braid word closes to a diagram; a diagram realizes to a
  PL knot).
- **Equivalence in each presentation, and that they agree.** Ambient isotopy for the
  geometric presentations; Reidemeister moves for diagrams; Markov moves for braids;
  stellar/PL moves for polylines. The **adequacy theorems** state that these match:
  Reidemeister's theorem (diagram equivalence = isotopy of the realization), the Markov
  theorem (braid closures up to Markov moves = links), and that all of these present the
  same equivalence on the geometric knot. These are exactly where Isabelle/AFP and the Lean
  `leanknot` experiment stalled, so state them as named targets and let the rest of the
  layer not wait on them.
- **Slice-ness, stated cleanly.** `IsSmoothlySlice K` (`K` bounds a smoothly embedded disc
  in `D⁴`) and `IsTopologicallySlice K` (a *locally flat* disc, consuming layer 2 and the
  4-manifold input below); the slice genus `g_s(K)` and the topological slice genus. These
  replace the lean-eval monstrosities with one-line definitions.
- **Knot polynomials, with algorithms.** The Alexander polynomial with the Conway
  normalization (from a Seifert matrix, and via the Conway skein relation), Jones (via the
  Kauffman bracket on a diagram), and HOMFLY; each as both an invariant and an *algorithm*
  computing it from a particular presentation (braid word, Seifert matrix), so the
  acceptance criteria can evaluate them on small knots.
- **The 4-manifold input to topological sliceness** that Freedman's theorem needs:
  topologically locally flat surfaces in `D⁴` and the existence of locally flat slice discs
  for Alexander-polynomial-one knots. This is the piece the combinatorial Heegaard Floer
  roadmap assumes; it is built here because it is 4-dimensional topology, not homology.

```lean
-- def Knot.SmoothEmbedded : Type := …      -- one presentation; others as separate types
-- def Knot.Diagram : Type := …
-- def closes : BraidWord n → Knot.Diagram   -- a map between presentations
-- theorem reidemeister : (D ≈ D') ↔ Isotopic (realize D) (realize D')   -- adequacy
-- def IsTopologicallySlice (K : Knot) : Prop := ∃ d : LocallyFlatDisc D⁴, ∂ d = K
-- def alexander (K : Knot) : LaurentPolynomial ℤ := …   -- Conway-normalized
-- theorem freedman_alexanderOne_slice (K) (h : alexander K = 1) : IsTopologicallySlice K
```

**Design notes.** Pin the convention table before stating anything: orientation, framing
(blackboard vs Seifert), and the Conway normalization of Alexander are all conventions that
later theorems silently depend on. Keep "smoothly slice" and "topologically slice"
rigorously separate; the gap between them is the entire point of `[Kir97, 1.41]` and
`[Kir97, 1.36]`. Coordinate the braid-group and diagram-calculus work with the combinatorial
Heegaard Floer roadmap's Lane K (which adds the grid-diagram presentation and Cromwell's
theorem) rather than duplicating it; that roadmap's `τ` is a consumer of these types.

**Unlocks.** `0`-shake genus vs slice genus, `[Kir97, Problem 1.41]` (Piccirillo, via the
Conway knot, jointly with the combinatorial Heegaard Floer roadmap's `τ`);
Alexander-polynomial-one knots are topologically slice, `[Kir97, Problem 1.36]` (Freedman).

### Layer 5: Dehn surgery

Surgery cuts out a tubular neighbourhood of a knot and reglues a solid torus by a boundary
diffeomorphism; the gluing class is the *slope*. This is the central construction of
3-manifold topology and the source of most of the Property-P-family Kirby problems. It is a
direct application of layer 1's gluing to layer 4's knots, plus the slope bookkeeping.

**From Mathlib / earlier layers.** Layer 1's manifold-with-boundary, tubular
neighbourhoods, and boundary-gluing; layer 4's knots and links; the torus as a manifold and
`H₁` of the boundary torus for slopes; layer 1's connected sum for the surgery-description
calculus.

**What to build.**
- **The complement** of a knot or link as a compact manifold-with-boundary: delete an open
  tubular neighbourhood (layer 1), with the boundary a torus per component. This is the
  layer-4-to-layer-5 handoff that lean-eval lacks.
- **Slopes**: isotopy classes of essential simple closed curves on the boundary torus,
  equivalently primitive classes in `H₁(∂)`, parametrized as `p/q ∈ ℚ ∪ {∞}` once a
  meridian-longitude framing is fixed.
- **Dehn filling / surgery**: glue a solid torus to the complement sending its meridian to
  a chosen slope (layer 1's gluing); `n`-surgery, rational surgery, and surgery on framed
  links. General-dimension surgery on a framed embedded `Sᵏ` (cut `Sᵏ × Dⁿ⁻ᵏ`, glue
  `Dᵏ⁺¹ × Sⁿ⁻ᵏ⁻¹`) specialises to the 3-dimensional case.
- **The convention-fixing identities**: surgery on the unknot recovers known manifolds (see
  the acceptance criteria), pinning the meridian-longitude and slope conventions.

```lean
-- def complement (L : Link) : Manifold …                 -- compact, torus boundary
-- def Slope (T : BoundaryTorus) : Type := …              -- ℚ ∪ {∞} after a framing
-- def dehnFilling (M : Manifold …) (s : Slope …) : Manifold …
-- theorem surgery_unknot_zero : dehnFilling (complement unknot) 0 ≃ₘ (circle ×ₘ sphere 2)
-- theorem surgery_unknot_pq : dehnFilling (complement unknot) (p/q) ≃ₘ lensSpace p q
```

**Design notes.** Fix the framing convention (the `0`-framing from the Seifert surface)
once and prove the unknot identities against it before stating any Kirby target, because
every surgery statement inherits that choice. Property P and Property R are statements about
*all* nontrivial knots, so they quantify over layer 4's knot type; keep "the surgered
manifold is not simply connected / is not `S¹ × S²`" as the conclusion shape. Cosmetic
surgery compares two fillings of the *same* complement, so state it as a property of the
slope pair, not of two abstract manifolds.

**Unlocks.** Property P `[Kir97, Problem 1.15]`, Property R `[Kir97, Problem 1.82]`,
Akbulut–Kirby `0`-surgery concordance `[Kir97, Problem 1.19]`, and chirally cosmetic
surgery `[Kir97, Problem 1.81]`.

### Layer 6: knot concordance and 4D cobordism (owned here)

Two knots are concordant if they cobound a smoothly (or locally flatly) embedded annulus in
`S³ × [0,1]`; concordance classes form a group under connected sum. This layer owns the
concordance group and the cobordism category, building on layer 4's knots and layer 1's
gluing, and *consumes* the homological concordance invariants (`τ`, and ideally `s`) from
the combinatorial Heegaard Floer roadmap.

**From Mathlib / earlier layers.** Layer 4's knots, slice-ness, and Seifert surfaces; layer
1's gluing and connected sum; the combinatorial Heegaard Floer roadmap's `τ` (a homomorphism
on the concordance group). The classical signature invariant is built here from layer 4's
Seifert matrix.

**What to build.**
- The **concordance relation** and the **concordance group** `C` (smooth and topological
  variants), with connected sum as the group operation and the reverse mirror as inverse;
  the slice knots as the identity coset.
- The **4D cobordism category** in general dimension: oriented cobordisms between manifolds,
  composition by gluing (layer 1), and knot/link cobordisms as surfaces in `S³ × [0,1]`,
  with genus giving the concordance and slice genera.
- **Concordance invariants**: the Tristram–Levine signature function from layer 4's Seifert
  matrix (built here), and the import of `τ : C → ℤ` and `s` as consumers of the
  combinatorial Heegaard Floer roadmap.
- **Mutation** as an operation on knots (Conway mutation by a `(±1)`-tangle replacement) and
  the statement that it does *not* preserve the smooth concordance class.

```lean
-- def Concordant (K K' : Knot) : Prop := ∃ Σ : Annulus (S³ ×ₘ I), ∂ Σ = K ⊔ K'.mirror
-- instance : Group (ConcordanceClass)         -- # as operation
-- def signature (K : Knot) (ω : Circle) : ℤ   -- Tristram–Levine, from the Seifert form
-- theorem mutation_not_concordance_invariant : ∃ K, ¬ Concordant K (mutate K)
-- theorem levine_homologySphere_not_S3 : -- a knot in a homology sphere not smoothly concordant to any in S³
```

**Design notes.** Keep smooth and topological concordance separate from the start; the
Levine and mutation results are about the smooth category specifically. The signature is
elementary and self-contained (a good first target); `τ` and `s` arrive later as imports,
so state the signature results without waiting on them. Concordance in homology spheres
(`[Kir97, 1.31]`) needs the knot type generalized to ambient homology spheres, which is a
small extension of layer 4's geometric presentation; note it as a dependency.

**Unlocks.** Conway mutation does not preserve concordance, `[Kir97, Problem 1.53]`;
concordance of knots in homology spheres to knots in `S³`, `[Kir97, Problem 1.31]` (Levine,
disproved smoothly).

### Layer 7: Riemannian geometric structures and volume

Mathlib's Riemannian library reaches the metric-and-distance level but stops short of
volume and curvature, which is exactly what the hyperbolic-geometry Kirby problems need. To
state "the Weeks manifold has the smallest volume" we need a Riemannian volume measure, a
notion of hyperbolic (complete, constant curvature `−1`) structure, and the resulting
volume invariant. This is the hardest layer that is still close to existing Mathlib.

**From Mathlib / earlier layers.** `RiemannianBundle` and `IsRiemannianManifold`, the
induced `riemannianEDist`, and `EMetricSpace.ofRiemannianMetric`
(`Mathlib/Geometry/Manifold/Riemannian/Basic.lean`); path length in
`Mathlib/Geometry/Manifold/Riemannian/PathELength.lean`; Mathlib's measure theory and the
`volume` measure on `ℝⁿ`; layer 1's manifolds; `Matrix.orthogonalGroup` for isometry
groups.

**What to build.**
- The **Riemannian volume measure** from the metric (the density `√det g` in charts,
  assembled with a partition of unity), and its invariance under isometries; the total
  **volume** of a closed Riemannian manifold as a real number.
- **Curvature**: the Levi-Civita connection, the Riemann curvature tensor, and sectional
  and Ricci curvature, enough to *state* "constant sectional curvature `κ`".
- **Hyperbolic structures**: the model `ℍⁿ`, complete constant-curvature `−1` metrics, and
  `IsHyperbolic M` (`M` carries a complete hyperbolic metric); hyperbolic volume as the
  volume of that metric, well-defined by Mostow rigidity in dimension `≥ 3` (the
  well-definedness is itself a target, and the deep input).
- **Fibering and Haken-ness** for layer 7's second problem: a 3-manifold *fibers over the
  circle* (is a mapping torus), is *Haken* (contains an incompressible surface), and is
  *virtually* so (a finite cover is).

```lean
-- noncomputable def riemannianVolume (M) [IsRiemannianManifold I M] : Measure M := …
-- noncomputable def volume (M) [Closed M] [IsRiemannianManifold I M] : ℝ := (riemannianVolume M) univ
-- def IsHyperbolic (M) : Prop := ∃ g : RiemannianMetric M, Complete g ∧ sectionalCurvature g = -1
-- theorem weeks_minimal_volume (M) (h : ClosedOrientableHyperbolic3 M) : hypVolume weeksManifold ≤ hypVolume M
-- theorem agol_virtually_fibered (M) (h : ClosedHyperbolic3 M) : ∃ N, FiniteCover N M ∧ FibersOverCircle N
```

**Design notes.** Volume well-definedness for hyperbolic manifolds rides on Mostow
rigidity, so state hyperbolic volume against an *explicit* complete hyperbolic metric and
make Mostow-invariance a separate theorem rather than baking it into the definition. The
Weeks manifold needs a concrete construction (as a surgery on the Whitehead link, layer 5,
or by face-pairings of a polytope); pick one and make "this is the Weeks manifold" a
definition, not a black box. Keep "fibers over `S¹`", "Haken", and "virtually X" as
separate predicates; Agol's theorem is a chain of them.

**Unlocks.** Virtual fibering and virtually Haken, `[Kir97, Problem 3.51]` (Agol); the
smallest-volume closed orientable hyperbolic 3-manifold is the Weeks manifold,
`[Kir97, Problem 3.60]` (Gabai–Meyerhoff–Milley).

### Layer 8: Thurston geometries and the JSJ / geometric decomposition

Geometrization is much harder to *state* than the Poincaré conjecture, because its
conclusion is structural: not "homeomorphic to a fixed model" but "cut along canonical
tori, every piece carries one of eight geometries". So the work here is mostly in the
definitions, and stating the theorem faithfully is the deliverable.

**From Mathlib / earlier layers.** Layer 7's Riemannian and hyperbolic structures and
isometry groups; layer 5's torus complements and gluing; layer 1's manifolds; Lie groups
(`Mathlib/Geometry/Manifold/Algebra/LieGroup.lean`) for the model-geometry isometry groups.

**What to build.**
- The **eight model geometries** as homogeneous Riemannian 3-manifolds `(X, Isom X)`:
  `S³`, `E³`, `ℍ³`, `S² × ℝ`, `ℍ² × ℝ`, `SL₂~`, `Nil`, `Sol`, each with its maximal
  isometry group; a **geometric structure** on `M` as a complete locally homogeneous metric
  modeled on one of them (equivalently `M = X / Γ` for a discrete `Γ ≤ Isom X`).
- **Incompressible tori** and the **JSJ decomposition**: a minimal collection of disjoint
  incompressible tori cutting `M` into Seifert-fibered and atoroidal pieces, with existence
  and uniqueness (the decomposition is canonical).
- **Geometrization** as the statement that each piece of the JSJ decomposition of a closed
  orientable prime 3-manifold admits a geometric structure (after also splitting along the
  prime/connected-sum decomposition, which is layer 1).

```lean
-- structure ModelGeometry where X : Manifold …; isom : LieGroup …; homogeneous : …
-- def HasGeometricStructure (M) (G : ModelGeometry) : Prop := ∃ metric, LocallyHomogeneous metric G
-- def JSJ (M : ClosedOrientablePrime3) : Finset (IncompressibleTorus M)   -- canonical
-- theorem geometrization (M : ClosedOrientablePrime3) :
--     ∀ piece ∈ pieces (JSJ M), ∃ G : ModelGeometry, HasGeometricStructure piece G
```

**Design notes.** State the prime decomposition (connected-sum, layer 1) and the JSJ
(torus, here) as two separate canonical decompositions, then geometrization as "each atomic
piece is geometric"; bundling them obscures which uniqueness theorem is doing the work. The
eight geometries are a *closed* list, so encode them as an enumeration with proofs that
each is genuinely homogeneous, not as an open-ended class. The Poincaré conjecture is the
special case "`S³` is the only simply-connected closed 3-manifold" and falls out as an
instance.

**Unlocks.** Geometrization, `[Kir97, Problem 3.45]` (Perelman).

### Layer 9: Heegaard splittings and Heegaard genus

Every closed 3-manifold splits into two handlebodies glued along a surface; the minimal
genus of such a surface is the Heegaard genus, a basic 3-manifold invariant. Waldhausen
asked whether it equals the rank of the fundamental group; the answer is no, and stating
the disproof needs the genus and the rank side by side.

**From Mathlib / earlier layers.** Layer 1's handlebodies (a handlebody is a boundary-sum
of solid tori, built from layer 1's gluing) and boundary-gluing; `FundamentalGroup`
(`Mathlib/AlgebraicTopology/FundamentalGroupoid/`) and `Group.rank` for the rank side; the
surface (closed orientable 2-manifold) classification for the splitting surface.

**What to build.**
- **Handlebodies** of each genus and the **Heegaard splitting** of a closed 3-manifold as
  a decomposition `M = H₁ ∪_φ H₂` along a genus-`g` surface, with `φ` a surface
  diffeomorphism (consume layer 3's surface mapping classes).
- **Heegaard genus** `g(M)` as the minimum genus over all splittings, with existence (every
  closed 3-manifold has a splitting, from a triangulation or a Morse function) so the
  minimum is over a nonempty set.
- The **rank** of `π₁(M)` (minimal number of generators) and the inequality
  `rank π₁(M) ≤ g(M)`, which is the easy direction; Waldhausen asked about equality.

```lean
-- def Handlebody (g : ℕ) : Manifold …
-- structure HeegaardSplitting (M) where g : ℕ; glue : (Handlebody g).boundary ≃ₘ (Handlebody g).boundary; iso : M ≃ₘ …
-- noncomputable def heegaardGenus (M : ClosedOrientable3) : ℕ := ⨅ s : HeegaardSplitting M, s.g
-- theorem rank_le_heegaardGenus (M) : Group.rank (FundamentalGroup M) ≤ heegaardGenus M
-- theorem waldhausen_false : ∃ M, Group.rank (FundamentalGroup M) < heegaardGenus M
```

**Design notes.** Define the genus as an infimum over a `Nonempty` set of splittings, and
prove existence first, so `heegaardGenus` is not silently `0`. The disproof is an
inequality, so the target is a witness `M` with strict inequality, not a general formula.

**Unlocks.** Waldhausen's rank-versus-genus conjecture (disproved by Li; no Kirby number).

### Layer 10: foliations and their Euler class

A codimension-one foliation slices a 3-manifold into surfaces (leaves); its tangent plane
field is an oriented 2-plane bundle with an Euler class in `H²(M)`. Thurston conjectured a
bound on this class; Gabai and Yazdi disproved it, and stating that needs foliations and
the Euler class as first-class objects.

**From Mathlib / earlier layers.** The tangent bundle and `mfderiv`
(`Mathlib/Geometry/Manifold/`); singular and the implied de Rham / `H²` cohomology for the
Euler class; vector bundles and their (to-be-built) Euler class; layer 1's manifolds.

**What to build.**
- A **foliation** of `M` as an integrable subbundle of `TM` (a distribution closed under
  Lie bracket), equivalently a maximal atlas of flat charts; **leaves** as the maximal
  integral submanifolds; **taut** foliations (a closed transversal through every leaf).
- The **Euler class** of an oriented plane bundle in `H²(M; ℤ)` (a small standalone
  addition to Mathlib's bundle theory), specialized to the tangent field of a
  codimension-one foliation.
- The **Euler-class bound** statement: for a taut foliation `F` of a closed hyperbolic
  3-manifold, the conjectured inequality `|⟨e(F), [S]⟩| ≤ −χ(S)` on every leaf-or-surface
  `S`, and a witness foliation violating it.

```lean
-- structure Foliation (M) where dist : Subbundle (TangentBundle M); integrable : Involutive dist
-- def eulerClass (E : OrientedPlaneBundle M) : H2 M ℤ := …
-- theorem gabai_yazdi : ∃ (M : ClosedHyperbolic3) (F : Foliation M), Taut F ∧ ¬ EulerClassBounded F
```

**Design notes.** The Euler-class layer is small and reusable on its own; build it against
Mathlib's vector bundles independently of foliations, then specialize. State Thurston's
conjecture as the *bounded* predicate and the Gabai–Yazdi result as its negation on an
explicit example, so the disproof is a witness rather than a universal statement.

**Unlocks.** Gabai–Yazdi's disproof of Thurston's foliation Euler-class conjecture (no
Kirby number).

### Layer 11: triangulations, PL structures, and collapse

This layer is the simplicial counterpart of layer 1's chart-based PL groupoid, and the two
must be proved to agree. A triangulation presents a space as the polyhedron of a simplicial
complex; a *combinatorial* manifold is a complex whose local structure (the links) forces
the polyhedron to be a manifold. Manolescu's theorem is that some topological manifolds are
not triangulable at all, and Zeeman's conjecture is about simplicial collapse, so both need
this simplicial vocabulary.

**From Mathlib / earlier layers.** Abstract simplicial complexes `AbstractSimplicialComplex`
(`Mathlib/AlgebraicTopology/SimplicialComplex/Basic.lean`); geometric simplicial complexes
in a real vector space with their underlying polyhedron `SimplicialComplex.space`
(`Mathlib/Analysis/Convex/SimplicialComplex/Basic.lean`); the simplicial-set realization
adjunction `toTopHomeo`, `|Δ[n]| ≅ stdSimplex`
(`Mathlib/AlgebraicTopology/SimplicialSet/TopAdj.lean`); layer 1's manifolds and PL
groupoid.

**What to build.**
- **Geometric realization of an abstract simplicial complex** as a topological space (the
  polyhedron `|K|`), with the basic API (faces, the star and **link** of a simplex,
  subdivision), reusing the simplicial-set realization where the indexing allows and the
  geometric `SimplicialComplex.space` otherwise.
- **Triangulation of a space** in the general sense: `IsTriangulable M := ∃ K, Nonempty (|K| ≃ₜ M)`.
  This is the notion in Manolescu's theorem, and it is *weaker* than asking for a
  combinatorial or PL structure.
- **Combinatorial manifolds via the link condition** (Kim's point, the simplicial side of
  PL topology). Define, recursively in dimension, a **combinatorial `n`-sphere** and
  **combinatorial `n`-ball** (a complex PL-homeomorphic, after subdivision, to the boundary
  of the standard `(n+1)`-simplex, respectively the standard `n`-simplex), bottoming out at
  the combinatorial `0`-sphere (two points) and `0`-ball (one point). Then `K` is a
  **combinatorial `n`-manifold** if the link of every vertex is a combinatorial
  `(n-1)`-sphere (interior point) or `(n-1)`-ball (boundary point). This is the definition
  that "has the correct links to be a manifold".
- **The reconciliation with layer 1.** Prove that the polyhedron of a combinatorial
  `n`-manifold is a PL `n`-manifold in the sense of layer 1's `PLGroupoid`, and conversely
  that every PL manifold admits a combinatorial triangulation (Whitehead). This is the
  theorem that makes "PL manifold via charts" and "simplicial complex with correct links"
  the same notion, and it is the concrete reason layer 1's `PLGroupoid` should be defined to
  make this proof natural. ⚠ This is genuinely subtle and not merely bookkeeping: recognizing
  a combinatorial sphere is undecidable in high dimensions (Novikov), the Hauptvermutung
  (any two triangulations have a common subdivision) is *false* for topological manifolds in
  general (so a triangulation need not give a PL structure), and a non-combinatorial
  triangulation of a manifold can exist where no combinatorial one does. Keep "triangulable",
  "combinatorially triangulable / PL", and "smoothable" as three separate predicates with
  the implications, not equalities, between them.
- **Simplicial collapse** (an elementary collapse removes a free face; `K` is collapsible if
  it collapses to a point), and **Zeeman's conjecture**: for a contractible `2`-complex `K`,
  the product `K × I` is collapsible.

```lean
-- def realize (K : AbstractSimplicialComplex ι) : TopCat := …      -- the polyhedron |K|
-- def link (K) (σ : K.faces) : AbstractSimplicialComplex ι := …
-- def IsCombinatorialManifold (K) (n : ℕ) : Prop := ∀ v, IsCombinatorialSphereOrBall (link K {v}) (n-1)
-- theorem realize_combinatorialManifold_isPL (K) (h : IsCombinatorialManifold K n) : HasGroupoid (realize K) PLGroupoid
-- def IsTriangulable (M : TopCat) : Prop := ∃ K, Nonempty (realize K ≃ₜ M)
-- theorem manolescu_not_triangulable : ∃ M : ClosedTopological5Manifold, ¬ IsTriangulable M
-- def Collapsible (K) : Prop := …
-- theorem zeeman_conjecture (K) (h : Contractible2Complex K) : Collapsible (K ×ₛ I)   -- [Kir97, 5.2]
```

**Design notes.** The combinatorial-sphere recursion is the crux; get the base cases and
the subdivision relation right before anything depends on it, since the whole link
definition rests on it. State Manolescu's theorem against the *general* triangulability
predicate (homeomorphism to any simplicial complex), not the combinatorial one, since that
is what is false. Zeeman's conjecture remains open, so it is stated, not attached to a
solver; it belongs here because it is the cleanest target exercising the collapse API.

**Unlocks.** Manolescu's disproof of the triangulation conjecture (no Kirby number); the
Zeeman collapsibility conjecture, `[Kir97, Problem 5.2]`.

## Acceptance criteria (checks along the way)

Concrete checks that rule out vacuous or mis-stated definitions:

- **Gluing computes.** `S³` presented as two solid tori glued along their boundary, and
  `S^n # S^n ≃ S^n` (connected sum with a sphere is trivial): both should be theorems, not
  just definitions, on the layer-1 API.
- **Knot theory is not vacuous.** The Alexander polynomial of the trefoil and the
  figure-eight match their known values (`t − 1 + t⁻¹` and `−t + 3 − t⁻¹`), computed by the
  layer-4 algorithm from a braid word or Seifert matrix; the unknot is smoothly slice; the
  trefoil is not; and a presentation-changing map (a braid closes to a diagram) is checked
  on a small example. The convention table is pinned by these.
- **Surgery recovers known manifolds.** `0`-surgery and `∞`-surgery on the unknot give
  `S¹ × S²` and `S³` respectively; `(p/q)`-surgery on the unknot gives the lens space
  `L(p, q)`. These pin down the layer-5 slope-and-gluing conventions.
- **The diffeomorphism-group topology is non-trivial.** `π₀ Diff(S³)` and the inclusion
  `O(4) → Diff(S³)` are stateable, and the Smale-conjecture target elaborates (layer 3).
- **Volume is an invariant.** The hyperbolic volume of a closed hyperbolic 3-manifold is
  well-defined and isometry-invariant, and the Weeks-manifold target elaborates (layer 7).
- **Realization round-trips.** The geometric realization of the boundary of the standard
  `n`-simplex is homeomorphic to `S^{n-1}` (layer 11), reusing the simplicial-set
  realization where possible.
- **Statements, not vacuities.** Each Kirby target above elaborates against the layer it
  is attached to, with the hypotheses unbundled, and is not provable by `rfl` or
  vacuously true (spot-check by negating a hypothesis and confirming the statement
  changes).

## References

- R. Kirby (ed.), *Problems in Low-Dimensional Topology*, in *Geometric Topology*
  (AMS/IP Stud. Adv. Math. 2.2, 1997): the source problem list `[Kir97]`.
- W. B. R. Lickorish, *An Introduction to Knot Theory*, Springer GTM 175 (1997); G. Burde,
  H. Zieschang, *Knots*, de Gruyter (2003): the knot-theory foundations of layer 4
  (presentations, Reidemeister and Markov theorems, Seifert surfaces, the polynomials).
- C. Rourke, B. Sanderson, *Introduction to Piecewise-Linear Topology*, Springer (1972):
  the PL and combinatorial-manifold foundations shared by layers 1 and 11 (PL maps and
  polyhedra in Chapters 1–2, the link condition and regular neighbourhoods in Chapter 3,
  collapse).
- M. Hirsch, *Differential Topology*, Springer GTM 33 (1976): the layer-1 smooth-gluing
  toolkit, with precise statements: collars (§4.6), tubular neighbourhoods (§4.5), and the
  disc theorem behind well-defined connected sum (§8.3, Theorem 8.3.1). J. Lee,
  *Introduction to Smooth Manifolds*, Springer GTM 218, 2nd ed. (2013) is the same material
  at a gentler pace (collars, Theorem 9.25; tubular neighbourhoods, Theorem 6.24).
- R. Palais, *Extending diffeomorphisms*, Proc. Amer. Math. Soc. 11 (1960) 274–277: the
  isotopy uniqueness of ball embeddings, used for connected-sum well-definedness (layer 1).
- J. H. C. Whitehead, *On C¹-complexes*, Ann. of Math. 41 (1940) 809–824, and J. Munkres,
  *Elementary Differential Topology* (Annals of Math. Studies 54, 1966): the smooth-implies-PL
  half of the layer-1 smoothing comparison.
- R. Kirby, L. Siebenmann, *Foundational Essays on Topological Manifolds, Smoothings, and
  Triangulations* (Annals of Math. Studies 88, 1977), Essays IV–V: the Top-to-PL obstruction
  and the failure of the Hauptvermutung, the far-horizon part of the layer-1 comparison.
- G. Perelman, *The entropy formula for the Ricci flow and its geometric applications*,
  [arXiv:math/0211159](https://arxiv.org/abs/math/0211159); *Ricci flow with surgery on
  three-manifolds*, [arXiv:math/0303109](https://arxiv.org/abs/math/0303109);
  *Finite extinction time...*, [arXiv:math/0307245](https://arxiv.org/abs/math/0307245):
  Geometrization (layer 8).
- I. Agol, *The virtual Haken conjecture* (with an appendix by Agol, Groves, Manning),
  Doc. Math. 18 (2013), [arXiv:1204.2810](https://arxiv.org/abs/1204.2810): layer 7.
- D. Gabai, R. Meyerhoff, P. Milley, *Minimum volume cusped hyperbolic three-manifolds*,
  J. Amer. Math. Soc. 22 (2009), and the closed-case companion work: the Weeks manifold as
  the smallest-volume closed orientable hyperbolic 3-manifold (layer 7).
- L. Piccirillo, *The Conway knot is not slice*, Ann. of Math. 191 (2020),
  [arXiv:1808.02923](https://arxiv.org/abs/1808.02923): layer 4 (`[Kir97, 1.41]`).
- M. Freedman, *The topology of four-dimensional manifolds*, J. Differential Geom. 17
  (1982); M. Freedman, F. Quinn, *Topology of 4-Manifolds*, Princeton, 1990:
  topological sliceness and Alexander-polynomial-one knots (layers 4 and 6).
- A. Hatcher, *A proof of the Smale conjecture, `Diff(S³) ≃ O(4)`*, Ann. of Math. 117
  (1983): layer 3 (`[Kir97, 4.34]`).
- T. Watanabe, *Some exotic nontrivial elements of the rational homotopy groups of
  `Diff(S⁴)`*, [arXiv:1812.02448](https://arxiv.org/abs/1812.02448): the disproof of the
  4-dimensional Smale conjecture (layer 3, `[Kir97, 4.126]`).
- C. Manolescu, *Pin(2)-equivariant Seiberg–Witten Floer homology and the triangulation
  conjecture*, J. Amer. Math. Soc. 29 (2016),
  [arXiv:1303.2354](https://arxiv.org/abs/1303.2354): layer 11.
- T. Li, *Rank and genus of 3-manifolds*, J. Amer. Math. Soc. 26 (2013): the disproof of
  Waldhausen's rank-versus-genus conjecture (layer 9).
- F. Quinn, *Ends of maps III: dimensions 4 and 5*, J. Differential Geom. 17 (1982): the
  Annulus Conjecture in dimension 4 (layer 2); Kirby (1969) for dimension `≥ 5`.

The author/title/venue citations above are deliberately conservative; a contributor
expanding a layer should attach the precise reference for each theorem they state (and the
relevant Kirby-list successor entry where one exists), rather than relying on the summary
here.

## How to drive it

Layers 1, 2, and 3 can start immediately and independently against current Mathlib: they
are the high-leverage substrate, and each is reusable library infrastructure on its own.
Layer 1 is the spine almost everything else waits on, so push it first; layers 2 and 3 are
genuinely parallel on-ramps. Layer 4 (knot theory) is a substantial subproject that can
also start immediately and is owned here; layer 5 (Dehn surgery) follows layer 1 and layer
4's knot types, and layer 6 (concordance) follows layer 4. Layers 7 and 8 share a
Riemannian substrate and should be planned together, after the layer-7 volume measure
lands. Layers 9, 10, and 11 are independent of each other and can begin once layer 1's
handlebody and tangent-field API exists. The homological concordance invariants (`τ`, `s`)
are coordinated with the combinatorial Heegaard Floer roadmap, which consumes layer 4's
knot types in return.

## Acknowledgements

This roadmap grew out of walking the Kirby problem list while building the topology
problems in [`leanprover/lean-eval`](https://github.com/leanprover/lean-eval), and out of
the design discussions behind the
[combinatorial Heegaard Floer roadmap](../CombinatorialHeegaardFloer/README.md), whose
knot-theory and concordance lanes it consumes. Thanks to everyone who contributed to those
discussions on the [Lean Zulip](https://leanprover.zulipchat.com/).
