# Roadmap: Heegaard Floer homology, analytically

Heegaard Floer homology (Ozsváth–Szabó) and its knot-theoretic sibling knot Floer
homology are among the most consequential inventions of twenty-first-century
low-dimensional topology: they categorify the Alexander polynomial, detect Seifert
genus and fiberedness, bound the slice genus and unknotting number, and power most
modern progress on surgery, concordance, and contact geometry. Nothing remotely near
them exists in any proof assistant; Mathlib has no knots, no 3-manifolds, and no
symplectic geometry. This roadmap is the **analytic half**: the full holomorphic
tower — Morse homology, Fredholm theory, transversality and Sard–Smale, the
Cauchy–Riemann elliptic package, Gromov compactness, gluing, Lagrangian Floer
homology, and `HF̂` via holomorphic disks in `Sym^g(Σ)`. The theories that are
combinatorial all the way down (grid homology, lattice homology, the
Ozsváth–Stipsicz–Szabó stable `HF̂`) are its companion
[Combinatorial Heegaard Floer roadmap](../CombinatorialHeegaardFloer/README.md);
the two meet at precisely-stated reconciliation theorems named in both.

This is **not a linear roadmap**. It is a family of lanes with several independent
on-ramps; nearly every lane is publishable mathematics on its own, and each would be
a first in any prover. Suggested homes: `TauCeti/Analysis/` and
`TauCeti/Geometry/Symplectic/` (the analytic lanes), with `TauCeti/LowDimTopology/`
holding the Heegaard-diagram geometry where the analytic tower lands.

## Why this is less hopeless than folklore says

The analytic track has a reputation as a "major research project" (Patrick Massot),
and it is — but two findings, both verified against the sources, make it materially
less hopeless than the folklore suggests:

- Heegaard Floer needs **no virtual machinery**. Ozsváth–Szabó's transversality
  ([arXiv:math/0101206](https://arxiv.org/abs/math/0101206), Theorem 3.4) is
  classical Sard–Smale over nearly-symmetric almost complex structures, with Oh's
  boundary-injectivity as input, so polyfolds and virtual fundamental cycles are off
  the critical path entirely.
- The **`Sym^g` route is analytically lighter for a formalizer than the cylindrical
  one**: fixed strip domain, genus-zero disk-tree bubbling only, no Riemann mapping
  theorem, no Deligne–Mumford, no SFT compactness. The only index theorem the whole
  tower needs is Riemann–Roch-with-boundary via Robbin–Salamon spectral flow;
  Atiyah–Singer never appears.

Armstrong–Kempe's De Giorgi–Nash–Moser formalization
([arXiv:2604.05984](https://arxiv.org/abs/2604.05984), ~56k lines of Lean 4 built in
weeks from human blueprints) is an existence proof that this kind of analytic
substrate yields quickly to blueprint-driven effort.

## The end goals

- **v3 (the long game, analytic).** Morse homology; Lagrangian Floer homology of
  exact Lagrangians; `HF̂(Y)` over 𝔽₂ via holomorphic disks in `Sym^g(Σ)`.
- **Reconciliations (shared with the combinatorial roadmap).** `HF̂_st` = stabilized
  holomorphic `HF̂` (the appendix of
  [arXiv:0912.0830](https://arxiv.org/abs/0912.0830)); lattice homology = `HF⁻` of
  plumbed manifolds (Zemke [arXiv:2111.14962](https://arxiv.org/abs/2111.14962));
  grid homology = knot Floer homology
  ([arXiv:math/0607691](https://arxiv.org/abs/math/0607691), via the cylindrical
  reformulation of Lane F5). Each is a precise "the two definitions agree" theorem
  where the analytic tower here meets a combinatorial lane there; they are stated in
  both roadmaps.

```lean
-- the shape we are building toward (state in Targets.lean as the types land):
--
-- v3: the analytic invariant for a pointed Heegaard diagram, over 𝔽₂:
-- def HFhat (D : PointedHeegaardDiagram) (hD : D.WeaklyAdmissible) (J : ...) :
--     GradedModule (ZMod 2) := ...   -- Lagrangian-Floer-type homology in Sym^g
-- theorem HFhat_invariant : ...      -- diagram moves + J-independence, naturality-ready
```

## Standing conventions (spell them out; never bake in)

- **𝔽₂ first, ℤ as a separate later stage.** Signs are a genuinely separable layer
  everywhere in this subject: the holomorphic theory has orientation systems (an
  affine torsor of choices, and a historical source of errata). State every 𝔽₂
  theorem so the coefficient ring can be generalized without restating the geometry.
- **State invariance naturality-ready.** In a proof assistant you must decide on
  day one whether "the invariant" is an isomorphism class, a group, or a transitive
  system of groups and isomorphisms (Juhász–Thurston–Zemke
  [arXiv:1210.4996](https://arxiv.org/abs/1210.4996)). Phrase invariance as
  specified isomorphisms attached to elementary moves, with composition laws stated
  as separate (later) targets, even while the first theorems prove only the
  isomorphism class. ⚠ Basepoint-moving maps act nontrivially (Zemke); do not
  quotient them away silently.
- **In the analytic lanes, hypotheses stay unbundled** exactly as in the PDE
  roadmap: totally real vs Lagrangian boundary conditions, tame vs compatible `J`,
  weak vs strong admissibility are separate named hypotheses, never a bundled
  structure.
- **Do every analytic move once, in the cleanest setting first.** Morse homology
  (Lane M) is the full Floer proof architecture at ODE cost; exact Lagrangian Floer
  (Lane F3) is the first genuine Floer homology with bubbling switched off. Each is
  a deliberate rehearsal of the moves the `Sym^g` theory needs, not a detour.

## Inventory: what Mathlib master gives us (consume)

- **Singular homology** (`Mathlib/AlgebraicTopology/SingularHomology/*`, with
  homotopy invariance): the comparison target for Morse homology in Lane M.
- **Homological algebra:** `Mathlib/Algebra/Homology/*`, complexes over any
  `ComplexShape ι`, homology via `ShortComplex`, homotopies and
  `HomotopyEquiv.toHomologyIso`, **mapping cones** (`HomotopyCofiber.lean`,
  `HomotopyCategory/MappingCone.lean`), long exact sequences, Euler characteristics:
  the bookkeeping for every Floer complex and continuation map.
- **Analysis, genuinely ready:** Banach-space calculus with **inverse and implicit
  function theorems in Banach generality**
  (`Mathlib/Analysis/Calculus/InverseFunctionTheorem/*`, `Implicit.lean`);
  **manifolds over arbitrary Banach model spaces by design** (`ModelWithCorners`,
  tangent bundles, smooth vector bundles, manifolds with boundary/corners), with
  integral curves and flows on Banach manifolds; compact operators and the
  **Fredholm alternative** (`Operator/FredholmAlternative.lean`); Arzelà–Ascoli;
  Banach–Alaoglu; Lax–Milgram; strong one-variable complex analysis (Cauchy
  integral, removable singularity, identity theorem, Schwarz lemma); Hofer's lemma
  (`Mathlib/Analysis/Hofer.lean`, whose docstring already names bubbling-off
  analysis for holomorphic curves as its purpose); Bessel-potential Sobolev spaces
  `H^{s,p}(ℝⁿ)` on tempered distributions.
  ⚠ Partitions of unity and smooth approximation require `FiniteDimensional`;
  fine for our purposes, but check before citing them in a Banach context.

## Inventory: what is missing (build here)

Ranked by load-bearing weight: Fredholm operators and index theory (nothing exists);
**Sard's theorem, even finite-dimensional** (an explicit Mathlib TODO), hence
transversality and Sard–Smale; Sobolev spaces in the shape PDE needs them (`W^{k,p}`
on domains, embeddings, multiplication, Rellich: the **shared spine with the PDE
roadmap**, which builds exactly this in its Lane A); elliptic estimates for the
first-order operator ∂̄ (Calderón–Zygmund inequality, boundary regularity for
totally real boundary conditions, bootstrapping); almost complex structures and
symplectic manifolds (*even the definitions*, which can land immediately); Morse
theory, gradient flows, stable manifolds; manifold orientations and degree theory.

The combinatorics of pointed Heegaard diagrams — generators, domains, periodic
domains, admissibility — that Lane F4 puts a holomorphic count on are built in the
[combinatorial roadmap](../CombinatorialHeegaardFloer/README.md)'s Lane H; consume
them rather than rebuild.

---

## The lanes

Each lane consumes the previous; F1 is shared with the PDE roadmap. Canonical
references are named per stage because "follow the canonical text" is the only
sane formalization mode here, and every "standard gluing argument" citation in
the literature is treated as a stub to be re-proved.

### Lane M: Morse homology (Stage 0)

The full Floer proof architecture at ODE cost, and a first in any prover. Do it
twice, deliberately:

1. **Dynamical route** (Audin–Damian, *Morse Theory and Floer Homology*, written
   to be student-checkable): Morse functions, stable/unstable manifolds (the
   stable-manifold theorem is itself new to Mathlib), the λ-lemma, Morse–Smale
   transversality via finite-dimensional **Sard** (also new, and an explicit
   Mathlib TODO blocking Whitney embedding improvements), broken-trajectory
   compactness, gluing, `∂² = 0`, invariance; Morse homology ≅ singular homology
   (consume Mathlib's new singular homology).
2. **Functional-analytic route** (Schwarz, *Morse Homology*): trajectory spaces as
   zero sets of a Fredholm section of a Banach bundle over `W^{1,2}` paths,
   transversality by Sard–Smale, gluing by Newton iteration with quadratic
   estimates. This rehearses *every* Floer move. Wehrheim
   ([arXiv:1205.0713](https://arxiv.org/abs/1205.0713)) is the only complete
   account of corner structures and associativity of gluing; use it.

### Lane F0: the nonlinear-analysis substrate

Finite-dimensional **Sard**; **Fredholm operators** (index, stability under compact
and small perturbations, kernel/cokernel splitting); the Fredholm property of
`d/ds + A(s)` on the strip with invertible asymptotics; **Sard–Smale** (Smale
1965); the "moduli space = zero set of a Fredholm section, generically a manifold
of dimension = index" package (McDuff–Salamon, Appendix A). Banach IFT: consume
from Mathlib. ⚠ No Atiyah–Singer: the only index computation ever needed
downstream is Riemann–Roch-with-boundary via spectral flow (F1.3).

### Lane F1: the Cauchy–Riemann elliptic package (shared with the PDE roadmap)

The PDE roadmap's Lane A/B builds `W^{k,p}(Ω)`, embeddings, Rellich, and
Calderón–Zygmund in general; this lane needs only the **2-dimensional,
first-order-elliptic-system slice** (McDuff–Salamon, Appendix B), and should
consume the shared spine rather than duplicate it:

1. `W^{k,p}` of maps of surfaces/strips, Sobolev multiplication (`kp > 2`), trace.
2. The Calderón–Zygmund inequality `‖u‖_{W^{1,p}} ≤ C‖∂̄u‖_{L^p}` via the Cauchy
   kernel; interior elliptic bootstrapping; **boundary regularity for totally real
   boundary conditions** (Schwarz reflection).
3. Linear Cauchy–Riemann operators on the disk/strip as Fredholm operators between
   Sobolev completions; **Riemann–Roch with boundary**; the **Maslov index** for
   paths of Lagrangians and spectral flow (Robbin–Salamon).

### Lane F2: J-holomorphic curves

McDuff–Salamon (*J-holomorphic Curves and Symplectic Topology*, 2nd ed.) as spine,
with boundary versions from Oh and Floer–Hofer–Salamon:

1. **Definitions land immediately** (almost nothing to wait for): almost complex
   structures, tame/compatible `J`, symplectic manifolds, `J`-holomorphic maps,
   energy. Even Darboux/Moser are self-contained early targets.
2. **Local theory** (MS Chapter 2): unique continuation, critical points,
   somewhere-injectivity; Oh's boundary-injectivity for totally real boundary.
3. **Compactness** (MS Chapter 4): mean-value inequalities, monotonicity, removal
   of singularities, and **Gromov compactness for strips/disks with totally real
   boundary under energy bounds**, bubbling into trees of disks and spheres. ⚠ No
   Deligne–Mumford, no varying-domain stable maps: fixed genus-zero domains only;
   resist the general theory.
4. **Transversality** (MS Chapter 3; Floer–Hofer–Salamon for strips): universal
   moduli spaces over Banach spaces of `J`'s, Sard–Smale via somewhere-injectivity.
5. **Gluing** (Schwarz's model, then MS Chapter 10): pregluing, uniformly bounded
   right inverses, quadratic estimates, Newton iteration, *including* surjectivity
   onto neighborhoods of broken configurations, the historically under-written
   half.

### Lane F3: Lagrangian Floer homology, exact case

Floer's theorem in its cleanest nontrivial generality, and the first genuine Floer
homology in any prover: **exact Lagrangians in an exact symplectic manifold**
(zero section vs its Hamiltonian image in `T*S¹`, then `T*M`); exactness kills
bubbling outright, so F2.3's bubbling analysis is not yet load-bearing.
Generators, the action functional, moduli of strips, `∂² = 0` by gluing +
compactness, continuation maps, Hamiltonian-isotopy invariance, and
`HF(L, φ(L)) ≅ H_*(L)`-type computations in cotangent bundles. ⚠ Skip monotone
Floer theory entirely: Heegaard Floer replaces monotonicity with admissibility, so
the monotone chapter is a detour on this roadmap.

### Lane F4: Heegaard Floer homology, holomorphically

Ozsváth–Szabó ([arXiv:math/0101206](https://arxiv.org/abs/math/0101206)) §§2–4
over 𝔽₂, consuming Lanes F0–F3 and the diagram combinatorics of the combinatorial
roadmap's Lane H.1:

1. **`Sym^g(Σ)` geometry:** smooth complex structure (elementary symmetric
   functions), the totally real tori `T_α`, `T_β`, `π₂ ≅ ℤ` for `g > 2`, the
   basepoint divisor and positivity `n_z(φ) ≥ 0`. ⚠ `T_α` is only ever needed
   *totally real* (with a taming form); do not chase Lagrangian-ness.
2. **Spin^c structures** (Turaev's vector-field model) and `s_z`; domains and the
   combinatorial Maslov index (Lipshitz's formula `e(D) + n_x(D) + n_y(D)`,
   stateable now, against F1.3 later).
3. **Nearly-symmetric `J`** and transversality (OS Theorem 3.4 = Sard–Smale + Oh);
   **admissibility energy bounds** (OS Lemmas 4.12–4.13) replacing monotonicity.
4. **`HF̂` over 𝔽₂:** `∂² = 0` (boundary degenerations have `n_z ≥ 1`, so they are
   absent from the hat differential); `J`-independence and isotopy invariance by
   continuation; **handleslides via Perutz**
   ([arXiv:0801.0564](https://arxiv.org/abs/0801.0564)): the handleslid torus is
   Hamiltonian-isotopic, so invariance reduces to F3's continuation maps instead of
   a new (triangle) moduli problem; stabilization.
5. **Then, staged:** orientation systems and ℤ; `HF^±`, `HF^∞` (boundary
   degenerations now matter: OS Theorem 3.15); holomorphic triangles and cobordism
   maps; surgery exact triangles; `d`-invariants; naturality (JTZ) as the
   capstone. Each is its own milestone; none blocks v3.

### Lane F5: beyond (far horizon, named so nobody mistakes the scope)

Lipshitz's cylindrical reformulation
([arXiv:math/0502404](https://arxiv.org/abs/math/0502404) **with** the erratum
[arXiv:1301.4919](https://arxiv.org/abs/1301.4919)), with varying source curves and
SFT/Bourgeois–Eliashberg–Hofer–Wysocki–Zehnder compactness
([arXiv:math/0308183](https://arxiv.org/abs/math/0308183)), and, through it,
bordered Floer homology ([arXiv:0810.0687](https://arxiv.org/abs/0810.0687)).
Knot Floer homology via doubly-pointed diagrams and the reconciliation **grid
homology = HFK** ([arXiv:math/0607691](https://arxiv.org/abs/math/0607691)) also
live here, joining this roadmap to the combinatorial one's Lane G. ⚠ Polyfolds and
virtual techniques stay off this roadmap: nothing here needs them.

## Acceptance criteria ("checks along the way")

Concrete checks that rule out vacuous or mis-stated definitions:

- **Morse homology:** `S^n` and `T^n` from standard Morse functions; the
  isomorphism with Mathlib's singular homology (Lane M's reconciliation).
- **Exact Floer:** `HF(L₀, φ(L₀))` in `T*S¹` has rank 2 = `rank H_*(S¹)`; the
  Arnold-type intersection bound in the exact case.
- **`HF̂` computes:** `HF̂(L(p,q))` over 𝔽₂ from the genus-1 diagram (every moduli
  count a bigon) gives `𝔽^p`, one generator per spin^c structure.
- **The two definitions meet:** `HF̂(L(p,q))` computed analytically from the genus-1
  diagram agrees with the combinatorial roadmap's Lane H computation: the first
  reconciliation seam crossed end to end.

## References

- P. Ozsváth, Z. Szabó,
  [arXiv:math/0101206](https://arxiv.org/abs/math/0101206) and
  [arXiv:math/0105202](https://arxiv.org/abs/math/0105202) (Ann. of Math. 2004):
  the holomorphic theory; Lane F4's text.
- M. Audin, M. Damian, *Morse Theory and Floer Homology*, Springer Universitext,
  2014; M. Schwarz, *Morse Homology*, Birkhäuser, 1993; K. Wehrheim,
  [arXiv:1205.0713](https://arxiv.org/abs/1205.0713): Lane M.
- D. McDuff, D. Salamon, *J-holomorphic Curves and Symplectic Topology*, 2nd ed.,
  AMS Colloquium Publications 52, 2012: Lanes F0–F2 (Appendices A–C and Chapters
  2–4, 10); Y.-G. Oh, *Symplectic Topology and Floer Homology* I–II, Cambridge,
  2015: the boundary-condition versions and Lane F3.
- J. Robbin, D. Salamon, *The Maslov index for paths*, Topology 32 (1993);
  *The spectral flow and the Maslov index*, Bull. LMS 27 (1995): F1.3.
- T. Perutz, [arXiv:0801.0564](https://arxiv.org/abs/0801.0564): handleslides as
  Hamiltonian isotopies (F4.4).
- R. Lipshitz, [arXiv:math/0502404](https://arxiv.org/abs/math/0502404) with
  erratum [arXiv:1301.4919](https://arxiv.org/abs/1301.4919); Lipshitz–Ozsváth–
  Thurston [arXiv:0810.0687](https://arxiv.org/abs/0810.0687): Lane F5.
- I. Zemke, [arXiv:2111.14962](https://arxiv.org/abs/2111.14962); Manolescu–
  Ozsváth–Sarkar [arXiv:math/0607691](https://arxiv.org/abs/math/0607691): the
  reconciliation targets, shared with the combinatorial roadmap.
- A. Juhász, D. Thurston, I. Zemke,
  [arXiv:1210.4996](https://arxiv.org/abs/1210.4996): naturality, the capstone.
- P. Kronheimer, T. Mrowka, *Monopoles and Three-Manifolds*, Cambridge, 2007: not
  a target, but the gold standard of analytic completeness the analytic lanes
  should hold themselves to.
- S. Armstrong, T. Kempe, [arXiv:2604.05984](https://arxiv.org/abs/2604.05984):
  De Giorgi–Nash–Moser in Lean 4: evidence on formalization speed for the F1
  substrate, and a candidate source to mine.

## How to drive it

Lane M and F0 start as soon as anyone wants the analytic track moving, and so do
the bare symplectic/almost-complex definitions of F2.1; none of them waits for the
[combinatorial roadmap](../CombinatorialHeegaardFloer/README.md). F1 should be
planned jointly with the PDE roadmap rather than alone; F3 is the first analytic
headline and F4 the second. The seams that join the two roadmaps are the
reconciliation theorems, each stated on both sides.

## Acknowledgements

This roadmap builds directly on earlier discussions on the [Lean
Zulip](https://leanprover.zulipchat.com/), and would not have been possible without
them:

- [#maths > Feasibility of formalizing Grid Homology for summer pro...](https://leanprover.zulipchat.com/#narrow/channel/116395-maths/topic/Feasibility.20of.20formalizing.20Grid.20Homology.20for.20summer.20pro.2E.2E.2E)
  (summer 2025): Kevin Buzzard's encouragement ("It would be a shame to miss this
  opportunity to get Heegaard Floer homology into mathlib") and Patrick Massot's
  caution that the holomorphic theory is "a major research project", which this
  roadmap takes seriously rather than dismisses.
- [#general > dreams of big projects](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/dreams.20of.20big.20projects)
  (2025, Siddhartha Gadgil, Patrick Massot): the holomorphic theory as a dream
  target, and the observation that combinatorial computation must "relate the
  result to actual information" — which the reconciliation targets, joining this
  roadmap to its combinatorial companion, are designed to answer.
- [#general > O(1000) definitions for Annals](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/O.281000.29.20definitions.20for.20Annals)
  (2026, Kevin Buzzard and others): Heegaard Floer homology as a recurring missing
  definition in recent Annals papers; also raised in recent FormalFrontier
  target-selection discussions.

Thanks to everyone who contributed to these discussions.
