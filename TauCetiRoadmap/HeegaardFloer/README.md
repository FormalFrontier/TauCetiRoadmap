# Roadmap: Heegaard Floer and knot Floer homology

Heegaard Floer homology (Ozsváth–Szabó) and its knot-theoretic sibling knot Floer
homology are among the most consequential inventions of twenty-first-century
low-dimensional topology: they categorify the Alexander polynomial, detect Seifert
genus and fiberedness, bound the slice genus and unknotting number (reproving the
Milnor conjecture), and power most modern progress on surgery, concordance, and
contact geometry. Nothing remotely near them exists in any proof assistant; Mathlib
has no knots, no 3-manifolds, and no symplectic geometry. **We are deliberately,
wildly ambitious anyway**: this roadmap carries both the combinatorial theories
(formalizable now, with real topological payoffs of their own) *and* the full
analytic tower — Fredholm theory, transversality, Gromov compactness, gluing,
Lagrangian Floer homology — meeting at precisely-stated reconciliation theorems.

This is **not a linear roadmap**. It is two families of lanes with many independent
on-ramps; nearly every lane is publishable mathematics on its own, and several would
be a first in any prover. Suggested homes: `TauCeti/KnotTheory/Grid/`,
`TauCeti/KnotTheory/Diagrams/`, `TauCeti/Algebra/Bigraded/`,
`TauCeti/LowDimTopology/` (lattice homology, Heegaard diagrams),
`TauCeti/Analysis/` and `TauCeti/Geometry/Symplectic/` (the analytic lanes).

## The organizing dichotomy

**Combinatorial computability is not combinatorial definition-with-invariance.**
Most "combinatorial" results in this field — Sarkar–Wang nice diagrams
([arXiv:math/0607777](https://arxiv.org/abs/math/0607777)), the grid-diagram
computability of all flavors (Manolescu–Ozsváth–Thurston
[arXiv:0910.0078](https://arxiv.org/abs/0910.0078), resting on the ~280-page
Manolescu–Ozsváth link surgery formula
[arXiv:1011.1317](https://arxiv.org/abs/1011.1317)), bordered-Floer factoring of
mapping classes ([arXiv:1010.2550](https://arxiv.org/abs/1010.2550)) — are
*algorithms whose correctness certificates are holomorphic*. Exactly two bodies of
theory are combinatorial all the way down (definition, invariance proof, and
applications), plus one combinatorial neighbor:

1. **Grid homology for knots and links** (Manolescu–Ozsváth–Szabó–Thurston
   [arXiv:math/0610559](https://arxiv.org/abs/math/0610559); the book
   Ozsváth–Stipsicz–Szabó, *Grid Homology for Knots and Links*, AMS 2015). The
   book's main line (Chapters 1–15) is deliberately self-contained: invariance
   reduces to Cromwell's theorem (proved in its Appendix B), spectral sequences are
   explicitly avoided, and the holomorphic identification (Chapter 16) is needed for
   **nothing** — not invariance, not τ, not the combinatorial Milnor-conjecture
   proof, not the slice-genus bound, not the Legendrian/transverse invariants, not
   ℤ coefficients. What is lost without holomorphic input is only sharpness and
   detection (genus *detection*, fiberedness, unknot detection).
2. **Stable combinatorial HF̂ of 3-manifolds** (Ozsváth–Stipsicz–Szabó
   [arXiv:0912.0830](https://arxiv.org/abs/0912.0830), ℤ-signs sequel
   [arXiv:1301.0480](https://arxiv.org/abs/1301.0480)) — the *unique* published
   fully-combinatorial definition-plus-invariance of a Heegaard Floer 3-manifold
   invariant: HF̂ up to tracked `(𝔽 ⊕ 𝔽)`-tensor factors, exactly HF̂ for
   `b₁(Y) = 0` via a twisted refinement.
3. **Lattice homology** of plumbed 3-manifolds (Némethi
   [arXiv:0709.0841](https://arxiv.org/abs/0709.0841), after Ozsváth–Szabó
   [arXiv:math/0203265](https://arxiv.org/abs/math/0203265)): pure lattice
   combinatorics, invariance under Neumann moves, and Zemke's theorem
   ([arXiv:2111.14962](https://arxiv.org/abs/2111.14962)) that it computes `HF⁻` of
   all plumbed manifolds.

The analytic track is **on the roadmap, not a non-goal**. Two findings make it less
hopeless than folklore says (both verified against the sources): Heegaard Floer
needs **no virtual machinery** — Ozsváth–Szabó's transversality
([arXiv:math/0101206](https://arxiv.org/abs/math/0101206), Theorem 3.4) is classical
Sard–Smale over nearly-symmetric almost complex structures, with Oh's
boundary-injectivity as input, so polyfolds and virtual fundamental cycles are off
the critical path entirely; and the **Sym^g route is analytically lighter for a
formalizer than the cylindrical one** — fixed strip domain, genus-zero disk-tree
bubbling only, no Riemann mapping theorem, no Deligne–Mumford, no SFT compactness.
The only index theorem the whole tower needs is Riemann–Roch-with-boundary via
Robbin–Salamon spectral flow; Atiyah–Singer never appears.

## The end goals

- **v1 (knots, combinatorial).** Grid homology `GH̃`, `GĤ`, `GH⁻` over 𝔽₂ with full
  invariance, the concordance invariant τ, and the **Milnor conjecture**
  `u(T_{p,q}) = (p−1)(q−1)/2` — a genuinely celebrated theorem (first proved by
  Kronheimer–Mrowka with gauge theory), by pure combinatorics.
- **v2 (3-manifolds, combinatorial).** Ozsváth–Stipsicz–Szabó's stable `HF̂_st(Y)`
  over 𝔽₂, with its purely topological invariance proof.
- **v3 (the long game, analytic).** Morse homology; Lagrangian Floer homology of
  exact Lagrangians; `HF̂(Y)` over 𝔽₂ via holomorphic disks in `Sym^g(Σ)`.
- **Reconciliations.** Grid homology = knot Floer homology
  ([arXiv:math/0607691](https://arxiv.org/abs/math/0607691)); `HF̂_st` = stabilized
  holomorphic `HF̂` (the appendix of 0912.0830); lattice homology = `HF⁻` of plumbed
  manifolds (Zemke). Each is a precise "the two definitions agree" theorem where a
  combinatorial lane meets the analytic one.

```lean
-- the shapes we are building toward (state in Targets.lean as the types land):
--
-- v1 — grid homology is a link invariant, and τ bounds unknotting number:
-- def GH' (G : GridDiagram) : BigradedModule (ZMod 2) := ...   -- simply blocked GĤ
-- theorem GH'_invariant (G G' : GridDiagram) (h : G.MovesTo G') : GH' G ≅ GH' G'
-- theorem tau_le_unknotting (K : GridKnot) : |τ K| ≤ unknottingNumber K
-- theorem milnor_conjecture (p q : ℕ) (h : Nat.Coprime p q) :
--     unknottingNumber (torusKnot p q) = (p - 1) * (q - 1) / 2
--
-- v3 — the analytic invariant for a pointed Heegaard diagram, over 𝔽₂:
-- def HFhat (D : PointedHeegaardDiagram) (hD : D.WeaklyAdmissible) (J : ...) :
--     GradedModule (ZMod 2) := ...   -- Lagrangian-Floer-type homology in Sym^g
-- theorem HFhat_invariant : ...      -- diagram moves + J-independence, naturality-ready
```

## Standing conventions (spell them out; never bake in)

- **𝔽₂ first, ℤ as a separate later stage.** Signs are a genuinely separable layer
  everywhere in this subject: grid homology has sign assignments
  (MOST; Gallais [arXiv:0706.0089](https://arxiv.org/abs/0706.0089)), the
  holomorphic theory has orientation systems (an affine torsor of choices, and a
  historical source of errata). State every 𝔽₂ theorem so the coefficient ring can
  be generalized without restating the topology.
- **A link *is* (at first) a grid diagram modulo grid moves.** Knot theory needs no
  privileged representation: the grid theory is self-contained with this
  definition, and the identification with embeddings `S¹ ↪ S³` (via Cromwell's
  theorem and Reidemeister calculus) is its own lane (K), not a prerequisite.
  Reconciliation theorems connect representations later; nothing in Lane G waits
  for topology.
- **State invariance naturality-ready.** In a proof assistant you must decide on
  day one whether "the invariant" is an isomorphism class, a group, or a transitive
  system of groups and isomorphisms (Juhász–Thurston–Zemke
  [arXiv:1210.4996](https://arxiv.org/abs/1210.4996)). Phrase invariance as
  specified isomorphisms attached to elementary moves, with composition laws stated
  as separate (later) targets — even while the first theorems prove only the
  isomorphism class. ⚠ Basepoint-moving maps act nontrivially (Zemke); do not
  quotient them away silently.
- **Track stabilization factors explicitly.** The fully blocked grid homology
  `GH̃(G)` depends on grid size: `GH̃(G) ≅ GĤ(L) ⊗ W^{⊗(n−1)}` with
  `W = 𝔽 ⊕ 𝔽` in bigradings (0,0), (−1,−1); OSS's 3-manifold invariant is *stable*
  in the same sense. Build the "graded vector space up to `⊗W`-stabilization"
  quotient as API, not ad hoc.
- **Mind the bigrading bookkeeping.** Maslov gradings via the `J`-function
  (`M_O(x) = J(x−O, x−O) + 1`), Alexander via
  `A = ½(M_O − M_X) − (n−1)/2`: integer-valuedness is a lemma, not a definition.
  Fix once whether differentials drop Maslov by 1 and preserve Alexander
  (unblocked) and write the `(M, A)`-conventions table before stating anything.
- **Keep "computes" as a requirement, not an afterthought.** The acceptance
  criteria below evaluate the invariants on explicit small grids (`n ≤ 5` has at
  most `120` generators). Definitions whose differentials cannot be evaluated by
  `decide`/`Decidable` instances (or fast enough kernel reduction) on those
  examples should be revised. (Lesson from Coq/Agda homology efforts: making
  formal homology compute is the recurring pain point.)
- **In the analytic lanes, hypotheses stay unbundled** exactly as in the PDE
  roadmap: totally real vs Lagrangian boundary conditions, tame vs compatible `J`,
  weak vs strong admissibility are separate named hypotheses, never a bundled
  structure.

## Inventory: what Mathlib master gives us (consume)

- **Homological algebra, the strong point:** `Mathlib/Algebra/Homology/*` —
  complexes over any `ComplexShape ι` (so ℤ×ℤ-bigraded complexes are immediate),
  homology via `ShortComplex`, homotopies and `HomotopyEquiv.toHomologyIso`
  (`Homotopy.lean`), **mapping cones** (`HomotopyCofiber.lean`,
  `HomotopyCategory/MappingCone.lean`), snake lemma and the long exact sequence
  (`ShortComplex/ShortExact.lean`, `HomologySequence.lean`), bicomplexes/total
  complexes, Euler characteristics (`EulerCharacteristic.lean`). All of it applies
  over `ModuleCat (MvPolynomial (Fin n) (ZMod 2))` directly.
- **Grid combinatorics:** `Mathlib/GroupTheory/Perm/*` (including `Sign`),
  permutation matrices, `Finset`/`Fintype`, `ZMod n` for toroidal indexing.
- **Graded objects:** `Mathlib/CategoryTheory/GradedObject.lean` (+ monoidal
  structure), `DirectSum`, `MvPolynomial`.
- **Presented monoids** (`Mathlib/Algebra/PresentedMonoid/Basic.lean`, from Hannah
  Fechtner's braid program) — the seed for Lane K's braid groups.
- **Singular homology** (`Mathlib/AlgebraicTopology/SingularHomology/*`, with
  homotopy invariance) — the comparison target for Morse homology in Lane M.
- **Analysis, genuinely ready:** Banach-space calculus with **inverse and implicit
  function theorems in Banach generality**
  (`Mathlib/Analysis/Calculus/InverseFunctionTheorem/*`, `Implicit.lean`);
  **manifolds over arbitrary Banach model spaces by design** (`ModelWithCorners`,
  tangent bundles, smooth vector bundles, manifolds with boundary/corners), with
  integral curves and flows on Banach manifolds; compact operators and the
  **Fredholm alternative** (`Compact/FredholmAlternative.lean`); Arzelà–Ascoli;
  Banach–Alaoglu; Lax–Milgram; strong one-variable complex analysis (Cauchy
  integral, removable singularity, identity theorem, Schwarz lemma); Hofer's lemma
  (`Mathlib/Analysis/Hofer.lean` — whose docstring already names bubbling-off
  analysis for holomorphic curves as its purpose); Bessel-potential Sobolev spaces
  `H^{s,p}(ℝⁿ)` on tempered distributions.
  ⚠ Partitions of unity and smooth approximation require `FiniteDimensional`;
  fine for our purposes, but check before citing them in a Banach context.

## Inventory: what is missing (build here)

**Combinatorial side:** everything knot-theoretic (the only knot-adjacent file in
Mathlib is `Algebra/Quandle.lean`); grid diagrams and grid moves; bigraded modules
over `𝔽₂[V₁,…,Vₙ]` as a working API; the structure theorem for finitely generated
bigraded `𝔽[U]`-modules (τ's home); filtered complexes and filtered homotopy type
(Mathlib's spectral-sequence machinery is young and has no filtered-complex
constructor — and the grid main line deliberately avoids spectral sequences, so
only the filtered-complex API is needed); pointed Heegaard diagram combinatorics
and the nice-move calculus.

**Analytic side (ranked by load-bearing weight):** Fredholm operators and index
theory (nothing exists); **Sard's theorem — even finite-dimensional** (an explicit
Mathlib TODO) — hence transversality and Sard–Smale; Sobolev spaces in the shape
PDE needs them (`W^{k,p}` on domains, embeddings, multiplication, Rellich — the
**shared spine with the PDE roadmap**, which builds exactly this in its Lane A);
elliptic estimates for the first-order operator ∂̄ (Calderón–Zygmund inequality,
boundary regularity for totally real boundary conditions, bootstrapping); almost
complex structures and symplectic manifolds (*even the definitions* — these can
land immediately); Morse theory, gradient flows, stable manifolds; manifold
orientations and degree theory. Note Armstrong–Kempe's De Giorgi–Nash–Moser
formalization ([arXiv:2604.05984](https://arxiv.org/abs/2604.05984), ~56k lines of
Lean 4 built in weeks from human blueprints) as an existence proof that this kind
of substrate yields quickly to blueprint-driven AI effort.

---

## Part I: the combinatorial lanes

### Lane G: grid homology (the spine)

Follow Ozsváth–Stipsicz–Szabó's book, whose chapters are nearly a blueprint
already. Milestone order:

1. **Grid diagrams and grid states.** Toroidal `n × n` grids with `O`/`X`-markings
   (one per row and column); grid states as bijections columns → rows; rectangles,
   and **empty** rectangles `Rect°(x, y)`. ⚠ Encoding choice (plain
   `Equiv.Perm (Fin n)` vs functions on `ZMod n` vs a `2n × 2n` double cover; cf.
   Kyle Miller's "pointed cyclic orders" suggestion) deserves a short experiment
   before committing — the 2025 summer project (acknowledgements) tried all three.
2. **Gradings.** The `J`-function, `M_O`, `M_X`, `A`; integer-valuedness of `A`;
   grading-change formulas across a rectangle.
3. **The complexes and `∂² = 0`.** Fully blocked `GC̃` over 𝔽₂ (rectangles avoiding
   all markings): `∂² = 0` by the juxtaposition case analysis (disjoint /
   overlapping / annular pairs of empty rectangles) — finite combinatorics, the
   ideal first nontrivial theorem. Then unblocked `GC⁻` over `𝔽₂[V₁,…,Vₙ]` and
   simply blocked `GĤ`.
4. **Euler characteristic = Alexander polynomial**, via the grid determinant
   formula (book, Chapter 3.3) — an early, decidable, self-validating milestone.
5. **Invariance over 𝔽₂.** Grid moves = commutation + (de)stabilization.
   Commutation: pentagon-counting chain maps with hexagon-counting homotopies.
   Stabilization: identify `GC⁻(G')` with the mapping cone of
   `V₁ − V₂ : GC⁻(G)[V₁] → GC⁻(G)[V₁]` (consume Mathlib's cones). ⚠ The homologies
   of the *blocked* theories depend on grid size through `⊗W` factors; only the
   stabilization-quotient (or `GĤ`, `GH⁻`) is the link invariant.
6. **All `V_i` act identically on homology**; `GH⁻` as `𝔽[U]`-module; the structure
   theorem for finitely generated bigraded `𝔽[U]`-modules; **τ**.
7. **`|τ(K)| ≤ u(K)`** via crossing-change maps; `τ(T_{p,q})` via the canonical
   cycle; **the Milnor conjecture** (book Chapter 6, after Sarkar
   [arXiv:1011.5265](https://arxiv.org/abs/1011.5265)).
8. **Symmetries and the genus bound** `g(K) ≥ max{s : GĤ(K, s) ≠ 0}`. ⚠ The book is
   explicit that the combinatorial treatment "falls short of showing these bounds
   are sharp" — sharpness is holomorphic (Lane F4's far future); state the bound,
   not detection.
9. **Skein exact sequence; alternating knots are thin; links** (multivariable
   Alexander polynomial as Euler characteristic; grid polytope vs Thurston norm,
   again bound only).
10. **Slice genus:** `|τ(K)| ≤ g_s(K)` via saddle/birth/death maps and normal forms
    of knot cobordisms (book Appendix B.5) — the most topologically substantial
    step of the combinatorial line; gives the combinatorial Kronheimer–Mrowka
    theorem.
11. **Legendrian and transverse GRID invariants** `λ^±`; reprove Chekanov's
    Legendrian non-simplicity of `m(5₂)` combinatorially.
12. **ℤ coefficients** via sign assignments (existence and uniqueness up to gauge;
    MOST §15.2, or Gallais's spin-extension construction).
13. **The filtered theory** (book Chapters 13–14): the Alexander filtration on the
    grid complex over `𝔽[V]`; invariant = filtered quasi-isomorphism type — the
    combinatorial stand-in for `CFK^∞`, and the door to Υ-type concordance
    invariants. Needs Lane ALG's filtered-complex API.

### Lane ALG: bigraded and filtered homological algebra

Mostly assembling Mathlib pieces into a working API, plus genuinely new material:
bigraded modules over `𝔽₂[V₁,…,Vₙ]` with grading-shift conventions; mapping-cone
API at the bigraded level; the **structure theorem for finitely generated bigraded
`𝔽[U]`-modules** (the algebraic home of τ and of "tower plus torsion"
decompositions); **filtered chain complexes** and filtered chain homotopy
equivalence — new to Mathlib, needed only from G.13 onward, and reusable far beyond
this roadmap. ⚠ No spectral sequences are needed anywhere on the main line; resist
building them here.

### Lane K: knot-theory reconciliation

The "no privileged representation" lane: planar diagrams / oriented PD codes,
Reidemeister moves, braid groups and Markov/Alexander theorems (coordinate with
Hannah Fechtner's braid-group program rather than duplicating it), the Alexander
polynomial by other routes (Kauffman states, Burau) reconciled with G.4's grid
determinant, and the **adequacy theorems**: Cromwell's theorem (grid moves generate
grid equivalence of links; book Appendix B.4 — elementary but fiddly diagrammatic
combinatorics) and Reidemeister's theorem, ultimately connecting grid diagrams to
embeddings `S¹ ↪ S³` (or `ℝ³`). ⚠ Prior art (Isabelle/AFP knot theory; the Lean
`leanknot` experiment) shows diagram-calculus *adequacy* is where such projects
stall — which is exactly why Lane G does not wait for this lane.

### Lane L: lattice homology

Plumbing trees/graphs and their lattices; Némethi's lattice (co)homology
`ℍ⁻`/`ℍ⁰` as a `ℤ[U]`-module from lattice points and weight functions; invariance
under **Neumann moves**; computations for Seifert-fibered examples; `d`-invariant
analogues. Entirely finite combinatorics plus bilinear forms; a self-contained
on-ramp to the *3-manifold* side with no Heegaard diagrams at all, and the cheapest
lane to start in parallel. Far-future reconciliation: Zemke's `ℍ⁻ ≅ HF⁻`.

### Lane H: combinatorial HF̂ of 3-manifolds

The Ozsváth–Stipsicz–Szabó stable invariant
([arXiv:0912.0830](https://arxiv.org/abs/0912.0830)):

1. Pointed multi-pointed Heegaard diagram *combinatorics* (the diagram as data:
   surface genus, attaching-curve combinatorics, basepoints — no smooth topology
   yet); generators, domains, periodic domains, weak/strong **admissibility**.
2. The nice-move calculus and "convenient" diagrams from pair-of-pants
   decompositions; the chain complex (every count is a bigon or square).
3. `HF̂_st(Y)` over 𝔽₂: well-definedness and the purely topological invariance
   proof; lens spaces and `S¹ × S²` as the first computations.
4. ℤ coefficients via sign assignments
   ([arXiv:1301.0480](https://arxiv.org/abs/1301.0480)); the twisted refinement
   recovering `HF̂(Y)` on the nose for `b₁(Y) = 0`.

⚠ The serious topological input is **Reidemeister–Singer with basepoints** (any two
pointed Heegaard diagrams of `Y` are connected by moves) — Morse/Cerf theory that
does not exist in Mathlib. Treat it the way Lane G treats Cromwell: make "diagrams
modulo moves" the *definition* of the input equivalence class, state the invariance
theorem against it, and put the identification with smooth 3-manifolds in a
separable reconciliation target (which Lane M's Morse theory will eventually feed).
⚠ This package has no absolute gradings and no `U`-flavors; do not promise them
here.

## Part II: the analytic lanes

Each lane consumes the previous; F1 is shared with the PDE roadmap. Canonical
references are named per stage because "follow the canonical text" is the only
sane formalization mode here — and every "standard gluing argument" citation in
the literature is treated as a stub to be re-proved.

### Lane M: Morse homology (Stage 0)

The full Floer proof architecture at ODE cost, and a first in any prover. Do it
twice, deliberately:

1. **Dynamical route** (Audin–Damian, *Morse Theory and Floer Homology* — written
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
   account of corner structures and associativity of gluing — use it.

### Lane F0: the nonlinear-analysis substrate

Finite-dimensional **Sard**; **Fredholm operators** (index, stability under compact
and small perturbations, kernel/cokernel splitting); the Fredholm property of
`d/ds + A(s)` on the strip with invertible asymptotics; **Sard–Smale** (Smale
1965); the "moduli space = zero set of a Fredholm section, generically a manifold
of dimension = index" package (McDuff–Salamon, Appendix A). Banach IFT: consume
from Mathlib. ⚠ No Atiyah–Singer — the only index computation ever needed
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
   Deligne–Mumford, no varying-domain stable maps — fixed genus-zero domains only;
   resist the general theory.
4. **Transversality** (MS Chapter 3; Floer–Hofer–Salamon for strips): universal
   moduli spaces over Banach spaces of `J`'s, Sard–Smale via somewhere-injectivity.
5. **Gluing** (Schwarz's model, then MS Chapter 10): pregluing, uniformly bounded
   right inverses, quadratic estimates, Newton iteration — *including* surjectivity
   onto neighborhoods of broken configurations, the historically under-written
   half.

### Lane F3: Lagrangian Floer homology, exact case

Floer's theorem in its cleanest nontrivial generality, and the first genuine Floer
homology in any prover: **exact Lagrangians in an exact symplectic manifold**
(zero section vs its Hamiltonian image in `T*S¹`, then `T*M`) — exactness kills
bubbling outright, so F2.3's bubbling analysis is not yet load-bearing.
Generators, the action functional, moduli of strips, `∂² = 0` by gluing +
compactness, continuation maps, Hamiltonian-isotopy invariance, and
`HF(L, φ(L)) ≅ H_*(L)`-type computations in cotangent bundles. ⚠ Skip monotone
Floer theory entirely: Heegaard Floer replaces monotonicity with admissibility, so
the monotone chapter is a detour on this roadmap.

### Lane F4: Heegaard Floer homology, holomorphically

Ozsváth–Szabó ([arXiv:math/0101206](https://arxiv.org/abs/math/0101206)) §§2–4
over 𝔽₂, consuming Lanes F0–F3 and the diagram combinatorics of Lane H.1:

1. **`Sym^g(Σ)` geometry:** smooth complex structure (elementary symmetric
   functions), the totally real tori `T_α`, `T_β`, `π₂ ≅ ℤ` for `g > 2`, the
   basepoint divisor and positivity `n_z(φ) ≥ 0`. ⚠ `T_α` is only ever needed
   *totally real* (with a taming form); do not chase Lagrangian-ness.
2. **Spin^c structures** (Turaev's vector-field model) and `s_z`; domains and the
   combinatorial Maslov index (Lipshitz's formula `e(D) + n_x(D) + n_y(D)` —
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
[arXiv:1301.4919](https://arxiv.org/abs/1301.4919)) — varying source curves and
SFT/Bourgeois–Eliashberg–Hofer–Wysocki–Zehnder compactness
([arXiv:math/0308183](https://arxiv.org/abs/math/0308183)) — and, through it,
bordered Floer homology ([arXiv:0810.0687](https://arxiv.org/abs/0810.0687)).
Knot Floer homology via doubly-pointed diagrams and the reconciliation **grid
homology = HFK** ([arXiv:math/0607691](https://arxiv.org/abs/math/0607691)) also
live here. ⚠ Polyfolds and virtual techniques stay off this roadmap: nothing here
needs them.

## Acceptance criteria ("checks along the way")

Concrete checks that rule out vacuous or mis-stated definitions:

- **Grid homology computes:** `GĤ` of the unknot (2×2 grid) and the trefoil
  (5×5), with their bigradings, by `decide`-style evaluation; `GH̃` of an `n × n`
  unknot grid exhibits the `W^{⊗(n−1)}` factor (the grid-size dependence is real,
  ruling out a vacuous stabilization quotient).
- **Euler characteristic:** `χ(GĤ(K)) = Δ_K(t)` on the trefoil and figure-eight,
  and in general (G.4), matching the grid determinant.
- **τ bites:** `τ(T_{3,4}) = 3`; the Milnor conjecture for `T_{2,3}` and `T_{3,4}`
  as instances of G.7; an alternating knot is thin (G.9).
- **Oracle agreement:** spot-check `GĤ` ranks against published tables
  (HFKcalc/Knot Atlas data) for a handful of ≤ 8-crossing knots.
- **Lattice homology:** `ℍ` of a concrete negative-definite plumbing (e.g. the
  `E₈`-plumbing / Poincaré sphere) matches the literature.
- **`HF̂_st` computes:** lens spaces give `𝔽^p` (one generator per spin^c
  structure); `S¹ × S²` exercises weak admissibility.
- **Morse homology:** `S^n` and `T^n` from standard Morse functions; the
  isomorphism with Mathlib's singular homology (Lane M's reconciliation).
- **Exact Floer:** `HF(L₀, φ(L₀))` in `T*S¹` has rank 2 = `rank H_*(S¹)`; the
  Arnold-type intersection bound in the exact case.
- **The two definitions meet:** `HF̂(L(p,q))` computed analytically from the
  genus-1 diagram (every moduli count a bigon) agrees with Lane H's combinatorial
  computation — the first reconciliation seam crossed end to end.

## References

- P. Ozsváth, A. Stipsicz, Z. Szabó, *Grid Homology for Knots and Links*, AMS
  Mathematical Surveys and Monographs 208, 2015: **the spine of Lane G**, nearly a
  blueprint; Appendix A is Lane ALG's contents, Appendix B is Lane K's.
- C. Manolescu, P. Ozsváth, S. Sarkar,
  [arXiv:math/0607691](https://arxiv.org/abs/math/0607691); Manolescu–Ozsváth–
  Szabó–Thurston [arXiv:math/0610559](https://arxiv.org/abs/math/0610559): grid
  homology's origins; the latter is the self-contained one.
- P. Ozsváth, A. Stipsicz, Z. Szabó,
  [arXiv:0912.0830](https://arxiv.org/abs/0912.0830) and
  [arXiv:1301.0480](https://arxiv.org/abs/1301.0480): Lane H.
- A. Némethi, [arXiv:0709.0841](https://arxiv.org/abs/0709.0841); I. Zemke,
  [arXiv:2111.14962](https://arxiv.org/abs/2111.14962): Lane L and its
  reconciliation.
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
- A. Juhász, D. Thurston, I. Zemke,
  [arXiv:1210.4996](https://arxiv.org/abs/1210.4996): naturality, the capstone.
- P. Kronheimer, T. Mrowka, *Monopoles and Three-Manifolds*, Cambridge, 2007: not
  a target, but the gold standard of analytic completeness the analytic lanes
  should hold themselves to.
- S. Armstrong, T. Kempe, [arXiv:2604.05984](https://arxiv.org/abs/2604.05984):
  De Giorgi–Nash–Moser in Lean 4 — evidence on formalization speed for the F1
  substrate, and a candidate source to mine.

## How to drive it

Large by design, expanded **iteratively**, and deliberately non-linear. Lanes G.1–3
(with ALG), L, K, and F2.1 (bare symplectic/almost-complex definitions) can all
start immediately and independently; Lane M and F0 start as soon as anyone wants
the analytic track moving, and nothing in Part I waits for them. The spine to push
hardest is **G**: it reaches a famous theorem (Milnor conjecture) entirely within
reach of current technology. Lane H follows G once the nice-move idiom is
established; F1 should be planned jointly with the PDE roadmap rather than alone;
F3 is the first analytic headline and F4 the second. As each lane makes the next
milestone's *types* expressible in `TauCeti/`, state those milestones in
`Targets.lean` (with `sorry`) and hand them to the AIs to discharge. Nothing here
blocks on upstream Mathlib.

## Acknowledgements

This roadmap builds directly on earlier discussions on the [Lean
Zulip](https://leanprover.zulipchat.com/), and would not have been possible without
them:

- [#maths > Feasibility of formalizing Grid Homology for summer pro...](https://leanprover.zulipchat.com/#narrow/channel/116395-maths/topic/Feasibility.20of.20formalizing.20Grid.20Homology.20for.20summer.20pro.2E.2E.2E)
  (summer 2025): an undergraduate team's grid-homology project — the first attempt
  at this material in Lean — with Kevin Buzzard's encouragement ("It would be a
  shame to miss this opportunity to get Heegaard Floer homology into mathlib"),
  Patrick Massot's caution that the holomorphic theory is "a major research
  project" (which Part II takes seriously rather than dismisses), and Kyle
  Miller's observation that grid-diagram combinatorics stands alone — the design
  position Lane G adopts.
- [#new members > knot theory](https://leanprover.zulipchat.com/#narrow/channel/113489-new%20members/topic/knot.20theory)
  (2022–2024, Monica Omar, Kyle Miller, Kim Morrison, Junyan Xu, and others): the
  richest design discussion of knot representations in Lean — oriented PD codes,
  quandle invariants, and the "no privileged representation" philosophy this
  roadmap follows; Junyan Xu raised grid diagrams and Heegaard Floer homology
  there years before this roadmap.
- [#general > dreams of big projects](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/dreams.20of.20big.20projects)
  (2025, Siddhartha Gadgil, Patrick Massot): exotic ℝ⁴'s via combinatorial
  Heegaard Floer theory and the Milnor conjecture as dream targets, and the
  objection — combinatorial computation must "relate the result to actual
  information" — that this roadmap's reconciliation targets are designed to
  answer.
- [#general > O(1000) definitions for Annals](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/O.281000.29.20definitions.20for.20Annals)
  (2026, Kevin Buzzard and others): Heegaard Floer homology and basic knot theory
  as recurring missing definitions in recent Annals papers; also raised in recent
  FormalFrontier target-selection discussions.
- Hannah Fechtner's braid-group program
  ([Lean Together 2025 talk](https://www.youtube.com/watch?v=qVzuTWycPaw)), whose
  presented-monoid infrastructure is already in Mathlib and which Lane K should
  build on rather than duplicate.

Thanks to everyone who contributed to these discussions.
