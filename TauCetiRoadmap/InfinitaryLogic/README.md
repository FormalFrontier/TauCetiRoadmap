# Roadmap: infinitary logic, Scott analysis, and the descriptive set theory of countable models

Infinitary logic is the natural home of the model theory of countable structures, and it is
entirely missing from Mathlib. Mathlib has finitary first-order logic — `FirstOrder.Language`,
`Term`, `BoundedFormula`, `Structure`, satisfaction, the compactness theorem, partial
isomorphisms (`PartialEquiv`, `IsExtensionPair`), and Fraïssé theory — but its formula-level
`iInf`/`iSup` are restricted to `[Finite β]`, so there is no Lω₁ω or L∞ω, no Scott analysis, no
Karp characterization, no model existence for infinitary theories, no admissible-set machinery,
and none of the descriptive set theory of the space of countable structures. Mathlib does supply
the ambient stack this rests on: ordinals and `ω₁` (`Ordinal.omega 1`), cardinals with `ℶ_`
(`Cardinal.beth`), Polish and standard Borel spaces, analytic sets, and the back-and-forth
infrastructure for finitely generated partial isomorphisms.

The first summit is **Scott's isomorphism theorem** for countable relational languages: every
countable structure is pinned, up to isomorphism among countable structures, by a single Lω₁ω
sentence, and its Scott rank is below `ω₁`. Around it this roadmap builds a reusable infinitary
model theory and an invariant-descriptive-set-theory library, with four further named summits —
**Karp's theorem**, **model existence and Barwise compactness**, the **Hanf number for Lω₁ω**
(unconditional Morley–Hanf), and **Morley's counting dichotomy** for countable models — each a
milestone inside a fuller development, never the whole of it.

A completed Lean formalization exists in
[`cameronfreer/infinitary-logic`](https://github.com/cameronfreer/infinitary-logic); it is a
migration source and API-warning map (see [Migration source](#migration-source)), **not** the
specification. The specification here is the mathematics — Scott, Karp, Barwise, Morley, Silver —
and the reusable library needed to state and prove it, with the references below as the standard.

Suggested homes:

```text
TauCeti/ModelTheory/Infinitary/      -- Lω₁ω and L∞ω syntax, semantics, operations
TauCeti/ModelTheory/BackAndForth/    -- EF games, potential isomorphism, Karp
TauCeti/ModelTheory/Scott/           -- Scott rank, canonical formulas, Scott sentences
TauCeti/ModelTheory/ModelExistence/  -- consistency properties, omitting types, Löwenheim–Skolem
TauCeti/ModelTheory/Admissible/      -- admissible fragments, Barwise compactness, Nadel
TauCeti/ModelTheory/EM/              -- templates, indiscernibles, stretching
TauCeti/Combinatorics/Partition/     -- arrow notation, infinite Ramsey, Erdős–Rado
TauCeti/Descriptive/Structures/      -- the standard-Borel space of countable structures
TauCeti/Descriptive/Equivalence/     -- Borel equivalence relations, Silver, G₀, Glimm–Effros
```

## The end goal (v1)

For a countable relational language `L` and a countable structure `M`, prove **Scott's isomorphism
theorem**: `M` has an Lω₁ω sentence true in exactly the countable structures isomorphic to `M`, and
its Scott rank is below `ω₁`.

```lean
-- the shape we are building toward, once the definitions land in TauCeti:
-- theorem scott_isomorphism
--     {L : FirstOrder.Language} [L.IsRelational] [Countable (Σ n, L.Relations n)]
--     (M : Type) [L.Structure M] [Countable M] :
--     ∃ σ : L.Sentenceω,
--       M ⊨ σ ∧
--       ∀ (N : Type) [L.Structure N] [Countable N], (N ⊨ σ ↔ Nonempty (M ≃[L] N))
--
-- theorem scottRank_lt_omega1
--     {L : FirstOrder.Language} [L.IsRelational] [Countable (Σ n, L.Relations n)]
--     (M : Type) [L.Structure M] [Countable M] :
--     scottRank L M < ω₁
```

The relational restriction is the honest v1 generality: the atomic diagram of a tuple is then
determined by equality and relation facts, which is what the back-and-forth analysis needs.
Languages with function and constant symbols reduce to this case by relationalization in Layer 11,
with Scott-sentence transfer; Layer 11 depends only on Layers 0–2, so this is an extension, not a
forward reference. The countability hypotheses are kept as separate, explicit instance arguments
(`[L.IsRelational]`, `[Countable (Σ n, L.Relations n)]`, `[Countable M]`), never bundled into a
single class.

## The library spine

The deliverable is a reusable infinitary model theory and invariant DST library, not a proof
script for one theorem. Scott's theorem is the first summit of this spine, not its only output.
The spine is:

1. infinitary syntax and semantics — Lω₁ω (`BoundedFormulaω`) and L∞ω (`BoundedFormulaInf`), with
   the finitary embedding and the `Encodable` adapters;
2. back-and-forth systems and EF games at finite and ordinal length, and potential isomorphism;
3. Scott rank, canonical Scott formulas, and Scott sentences, with the countable coded-formula
   proxy that makes the counting honest;
4. consistency properties, model existence, omitting types, and downward Löwenheim–Skolem for
   countable fragments;
5. admissible fragments, the Barwise proof system, and Nadel's Scott-height bound;
6. Ehrenfeucht–Mostowski templates, order-indiscernibles, and stretching;
7. partition calculus — arrow notation, infinite Ramsey, and Erdős–Rado;
8. the Polish / standard-Borel space of countable structures, with satisfaction, isomorphism, and
   back-and-forth all coded as definable sets;
9. Borel equivalence relations and the Silver, G₀, and Glimm–Effros dichotomies.

Each item is worth building for its own sake, so that later roadmaps (other infinitary logics,
abstract elementary classes, effective structure theory) can consume it directly. The named
summits — Scott, Karp, Barwise compactness, the Hanf number, Morley counting — live inside this
spine.

## Standing hypotheses

Spell hypotheses out; do not bundle them. Pin the conventions below once, up front, so
implementors do not improvise.

* **Languages.** The core is countable relational languages. Carry `[L.IsRelational]`,
  `[Countable M]`, and `[Countable (Σ n, L.Relations n)]` as separate, explicit instance
  hypotheses on every Scott/Karp/Scott-rank statement — there is no bundled `CountableLanguage`
  class. `[L.IsRelational]` is load-bearing (it makes a tuple's atomic diagram a matter of equality
  and relations) and so must appear in the Lean statements, not only the prose. Function and
  constant symbols enter only in the relationalization layer (Layer 11).
* **`ω₁`.** Use `Ordinal.omega 1`, with the scoped notation `ω₁` from
  `Mathlib/SetTheory/Cardinal/Aleph.lean` (`ω_` is `Ordinal.omega`; `ω₁` is `ω_ 1`, "the first
  uncountable ordinal"). Do not introduce a bespoke `CountableOrdinal := {α // α < ω₁}` subtype;
  carry `α < ω₁` as an explicit hypothesis, the way Mathlib carries explicit bounds rather than a
  `Bounded` predicate.
* **Infinitary syntax — a parallel type, not an extension of `BoundedFormula`.** `BoundedFormulaω`
  (Lω₁ω) and `BoundedFormulaInf` (L∞ω) are new inductives over `FirstOrder.Language`; the finitary
  `BoundedFormula` maps in via `toLω`, with realization-compatibility lemmas. Pin the constructor
  shapes exactly: **`BoundedFormulaω` has ℕ-indexed `iSup`/`iInf`** (`φs : ℕ → BoundedFormulaω L α n`),
  with arbitrary countable families entering through the `Encodable` adapters `esup`/`einf`;
  **`BoundedFormulaInf` is the universe-indexed one** (`φs : ι → BoundedFormulaInf L α n`,
  `ι : Type uι`). Lω₁ω is primary for Scott analysis and counting; L∞ω is primary for Karp.
* **Index universe (Karp).** The `iSup`/`iInf` index universe is a parameter. Karp's *backward*
  direction indexes infinitary conjunctions by the structure's universe, so the headline statement
  is the universe-`w` form (`LInfEquivW`); the `Type 0` index case is a named specialization.
* **Countability via a coded proxy.** Raw infinitary syntax is uncountable (branching is a function
  `ℕ → …` for Lω₁ω, `ι → …` for L∞ω). Route every countability argument through a countable
  coded-formula type with `Countable (FormulaCode L n)`, proven to capture back-and-forth
  equivalence (`BFEquiv ↔ agreement on codes`). This is what makes "countably many refinements /
  Scott formulas" a theorem rather than a leap.
* **Scott rank.** Ship one rank convention (the back-and-forth/Scott rank), and state its relation
  to Scott height once, rather than maintaining two parallel notions.
* **Coding for DST.** Fix the carrier to `ℕ`; pin the standard-Borel coding of the space of
  `L`-structures on `ℕ` once, and state every "satisfaction/isomorphism is Borel" result against it.
* **Clean final statements.** The Hanf number / Morley–Hanf theorem is stated unconditionally; any
  transfer hypothesis is an internal lemma, never the endpoint. Morley counting targets the full
  standard-Borel class, with the bounded-Scott-height dichotomy stated separately rather than as a
  "temporary" restriction.

## What Mathlib already has (consume)

* **First-order logic:** `FirstOrder.Language`, `Structure` (`Mathlib/ModelTheory/Basic.lean`);
  `Term`, `BoundedFormula`, `Formula`, `Sentence`, `Theory` (`Mathlib/ModelTheory/Syntax.lean`);
  satisfaction `BoundedFormula.Realize`, `Sentence.Realize`, `Theory.Model`
  (`Mathlib/ModelTheory/Semantics.lean`); `Substructure` (`Substructures.lean`); elementary maps
  (`ElementaryMaps.lean`); language maps and reducts (`LanguageMap.lean`).
* **Back-and-forth:** `PartialEquiv` (`M ≃ₚ[L] N`), `FGEquiv`, and `IsExtensionPair`
  (`Mathlib/ModelTheory/PartialEquiv.lean`), including `embedding_from_cg` / the construction of an
  equivalence between countably generated structures from an extension pair; `DirectLimit`
  (`DirectLimit.lean`); Fraïssé theory (`Fraisse.lean`).
* **Compactness and Löwenheim–Skolem (finitary):** `Theory.IsSatisfiable`,
  `isSatisfiable_iff_isFinitelySatisfiable`, `exists_elementaryEmbedding_card_eq`
  (`Mathlib/ModelTheory/Satisfiability.lean`).
* **Ordinals and cardinals:** `Ordinal.omega0` (`SetTheory/Ordinal/Basic.lean`),
  `Ordinal.limitRecOn` (`SetTheory/Ordinal/Arithmetic.lean`), `Order.IsSuccLimit`
  (`Order/SuccPred/Limit.lean`); `ω₁ = Ordinal.omega 1`, `Cardinal.aleph` (`ℵ_`),
  `Cardinal.aleph0`, `Cardinal.beth` (`ℶ_`) — `SetTheory/Cardinal/Aleph.lean` and `Defs.lean`.
* **Descriptive set theory:** `PolishSpace` (`Topology/MetricSpace/Polish.lean`);
  `StandardBorelSpace`, `AnalyticSet` (`MeasureTheory/Constructions/Polish/Basic.lean`);
  `MeasurableSpace.CountablyGenerated` (`MeasureTheory/MeasurableSpace/CountablyGenerated.lean`);
  `Perfect` (`Topology/Perfect.lean`); `IsGδ`, `residual` (`Topology/GDelta/Basic.lean`).
* **Combinatorics:** `SimpleGraph` (`Combinatorics/SimpleGraph/Basic.lean`), `SimpleGraph.Coloring`
  (`Combinatorics/SimpleGraph/Coloring/VertexColoring.lean`); `HalesJewett`
  (`Combinatorics/HalesJewett.lean`), `Hindman` (`Combinatorics/Hindman.lean`).

Consume these directly rather than re-proving Mathlib's first-order, ordinal/cardinal, Polish-space,
or partial-isomorphism infrastructure.

## What is missing (build here)

Everything infinitary, and the model theory and DST on top of it:

* Lω₁ω and L∞ω syntax and semantics (Mathlib's formula `iInf`/`iSup` require `[Finite β]`);
* back-and-forth at finite and ordinal length, and Karp's theorem;
* Scott rank, canonical Scott formulas, Scott sentences, and the countable coded-formula proxy;
* model existence for countable Lω₁ω fragments: consistency properties, omitting types, downward
  Löwenheim–Skolem;
* admissible fragments, Barwise compactness, and Nadel's bound (Mathlib has no admissible sets / KP);
* Ehrenfeucht–Mostowski templates, order-indiscernibles, and stretching;
* partition calculus — arrow notation, infinite Ramsey, Erdős–Rado (Mathlib has Hindman and
  Hales–Jewett, but no Ramsey/Erdős–Rado/arrow notation);
* the standard-Borel coding of the space of countable structures, with satisfaction, isomorphism,
  and back-and-forth as definable sets;
* Borel equivalence relations and the Silver, G₀, and Glimm–Effros dichotomies (Mathlib has none);
* Morley counting and the Vaught-conjecture vocabulary.

Every item above is a target in some layer below; nothing is left as a gap to be wished into
existence.

## Migration source

A completed Lean formalization of this theory exists at
[`cameronfreer/infinitary-logic`](https://github.com/cameronfreer/infinitary-logic), pinned at
[`a1932b93387b6586e8f0ef3ebbe5c8c703094f69`](https://github.com/cameronfreer/infinitary-logic/tree/a1932b93387b6586e8f0ef3ebbe5c8c703094f69).
Use it as a source of proof scripts to migrate or adapt, a declaration map for each summit, an
API-warning source (where a local definition was convenient but should be generalized or replaced
with Mathlib vocabulary for Tau Ceti), and an attribution source for ported files. It is **not** the
mathematical specification: the specification is the standalone library above, with the references
below as the standard. The map is "where to look", not "what is correct"; judge each milestone on
its own terms. Source README, blueprint, and note files are background only.

* Layer 0: `InfinitaryLogic/Lomega1omega/` and `InfinitaryLogic/Linf/`.
* Layer 1: `InfinitaryLogic/Karp/` and `InfinitaryLogic/Scott/BackAndForth.lean`.
* Layer 2: `InfinitaryLogic/Scott/` (`Formula.lean`, `Sentence.lean`, `Rank.lean`, `Code.lean`,
  `AtomicDiagram.lean`).
* Layer 3: `InfinitaryLogic/Methods/Henkin/` and `InfinitaryLogic/ModelTheory/LowenheimSkolem.lean`.
* Layer 4: `InfinitaryLogic/Admissible/` (including `Admissible/Barwise/`).
* Layer 5: `InfinitaryLogic/Methods/EM/` and `InfinitaryLogic/Methods/Skolem*`.
* Layer 6: `InfinitaryLogic/Combinatorics/` (`ErdosRado.lean`, `InfiniteRamsey*.lean`).
* Layer 7: `InfinitaryLogic/Conditional/MorleyHanfTransfer.lean` and `InfinitaryLogic/ModelTheory/Hanf.lean`.
* Layer 8: `InfinitaryLogic/Descriptive/` (`StructureSpace.lean`, `Polish.lean`,
  `SatisfactionBorel.lean`, `BFEquivBorel.lean`, `IsomorphismBorel.lean`).
* Layer 9: `InfinitaryLogic/Descriptive/G0Dichotomy.lean`, `G0Fusion.lean`,
  `InfinitaryLogic/Conditional/GandyHarrington.lean`, `SilverBurgess.lean`.
* Layer 10: `InfinitaryLogic/ModelTheory/MorleyCounting.lean` and
  `InfinitaryLogic/Descriptive/CountingDichotomy.lean`.

Credit `cameronfreer/infinitary-logic` in each ported or adapted file, and record when a Tau Ceti
file intentionally diverges from this source API.

Provenance notes, kept here rather than in the intrinsic layer text:

* **Layer 2.** The source isolates the countability of refinement sets as
  `CountableRefinementHypothesis` and discharges it (sorry-free) in `Scott/RefinementCount.lean` by a
  self-stabilization / game-counting argument, so its Scott theorem is unconditional; the alternative
  code-based bridge `agree_codes_implies_BFEquiv` (`Scott/Code.lean`) is the route it flags as having
  a gap. The Layer-2 target here is the same theorem — route the count through the coded proxy or a
  direct game-counting argument — judged on its own terms, not copied.
* **Layer 10.** The source's `counting_coded_models_dichotomy` is the bounded-Scott-height result
  (≤ ℵ₀ or 2^ℵ₀), and `morley_counting` is the full Morley theorem (≤ ℵ₁ or 2^ℵ₀); they are distinct
  theorems and are kept separate here.

---

## The build, in layers

The ordering below is the dependency order: no layer depends on a later one. As each layer makes the
next layer's *types* expressible in `TauCeti/`, state its milestones in `Targets.lean` with `sorry`
(or, for shapes whose machinery is not yet grounded, in fenced code blocks here). Each layer is a
full development — object API, milestone theorems, and acceptance examples — not a single theorem.

### Layer 0: infinitary syntax and semantics

Suggested home:

```text
TauCeti/ModelTheory/Infinitary/Syntax.lean
TauCeti/ModelTheory/Infinitary/Semantics.lean
TauCeti/ModelTheory/Infinitary/Operations.lean
TauCeti/ModelTheory/Infinitary/Code.lean
```

Build the two parallel formula types over Mathlib's `FirstOrder.Language`:

* `BoundedFormulaω L α n` (Lω₁ω) with ℕ-indexed `iSup`/`iInf`, and `Formulaω`, `Sentenceω`;
* `BoundedFormulaInf L α n` (L∞ω) with universe-indexed `iSup`/`iInf`, and `FormulaInf`,
  `SentenceInf`;
* the derived connectives (`not`, `and`, `or`, `ex`, `iff`, `⊤`/`⊥`) by De Morgan, matching
  Mathlib's `BoundedFormula` conventions;
* the `Encodable` adapters `esup`/`einf` extending the ℕ-indexed connectives to arbitrary countable
  index types;
* `Realize` for both types, with simp lemmas for every connective and quantifier;
* the finitary embedding `toLω : L.BoundedFormula α n → BoundedFormulaω L α n` and the L∞ω analogue,
  with realization-compatibility (`realize_toLω`);
* substitution, relabeling, `castLE`, free-variable and support operations, and quantifier rank;
* the formula-size / cardinality predicate via `Cardinal` (no bespoke counter);
* the **countable coded-formula proxy** `FormulaCode L n` with `Countable (FormulaCode L n)` and its
  interpretation back into `BoundedFormulaω`.

Key milestones:

```lean
BoundedFormulaω.Realize
BoundedFormulaInf.Realize
BoundedFormulaω.realize_iSup
BoundedFormulaω.realize_iInf
BoundedFormulaω.realize_einf
BoundedFormulaω.realize_esup
toLω
realize_toLω
FormulaCode
FormulaCode.instCountable
FormulaCode.toFormulaω
```

⚠ **API warning.** Do not model the infinitary connectives by extending Mathlib's finitary
`BoundedFormula`; it is the wrong object (its `iInf`/`iSup` need `[Finite β]`). The natural Lean
object is a parallel inductive, related to the finitary one only by the embedding `toLω`.

⚠ **API warning.** Keep the ℕ-indexed constructors and the `Encodable` adapters distinct:
`iSup`/`iInf` are the kernel-level constructors, `esup`/`einf` are derived. Stating the countable
case directly with a function `ι → _` and `[Encodable ι]` is what downstream Scott and DST code
wants; do not bake an encoding choice into the constructors.

### Layer 1: back-and-forth, potential isomorphism, and Karp's theorem

Suggested home:

```text
TauCeti/ModelTheory/BackAndForth/Game.lean
TauCeti/ModelTheory/BackAndForth/PotentialIso.lean
TauCeti/ModelTheory/BackAndForth/Karp.lean
```

Build on Mathlib's `PartialEquiv` / `FGEquiv` / `IsExtensionPair`:

* `BFEquiv α a b`, the ordinal-indexed back-and-forth equivalence of tuples, by `limitRecOn`
  (atomic type at `0`; forth-and-back at successors; agreement below at limits), with monotonicity
  and symmetry;
* the finite EF game and the ω-round game, and the coherent-strategy object, with the quantifier-
  swap obstruction between `BFEquiv ω` and a coherent ω-strategy stated explicitly;
* potential isomorphism as a Mathlib-vocabulary back-and-forth system: a nonempty `FGEquiv` together
  with `IsExtensionPair L M N` and `IsExtensionPair L N M`;
* `LInfEquiv` / `LInfEquivW`, L∞ω-elementary equivalence at index universe `0` and at the structure
  universe `w`.

Karp's theorem and its corollaries:

```lean
potentialIso_iff_BFEquiv_all
karp_theorem            -- L∞ω-equivalence ↔ potential isomorphism, structure-universe index
karp_theorem_universe0  -- the Type 0 index specialization
BFEquiv_implies_agree_quantifierRank
countable_potentialIso_iff_iso   -- on countable structures, potential iso ↔ isomorphism
```

⚠ **API warning.** State Karp at the universe-`w` index convention: the backward direction builds
`iInf`/`iSup` indexed by the structure's universe, so an index type fixed at `Type 0` is too small
to express the witnessing conjunction. Keep `karp_theorem` (`LInfEquivW`) as the headline and
`karp_theorem_universe0` as the named specialization.

### Layer 2: Scott rank, canonical formulas, and Scott's theorem (v1 summit)

Suggested home:

```text
TauCeti/ModelTheory/Scott/Formula.lean
TauCeti/ModelTheory/Scott/Rank.lean
TauCeti/ModelTheory/Scott/Sentence.lean
TauCeti/ModelTheory/Scott/Refinement.lean
```

Build:

* the canonical Scott formulas `scottFormula α a` by ordinal recursion, with the `< ω₁` guard and the
  atomic / successor / limit cases;
* `scottRank` and `scottHeight`, their interoperability, and stabilization;
* `scottSentence M`, the conjunction characterizing `M` among countable structures;
* the **countable-refinement bridge**: each refinement set is countable, proved via the
  coded-formula proxy (`Countable (FormulaCode L n)`, `BFEquiv ↔ agreement on codes`) or a direct
  game-counting argument. This is the one real gap behind Scott's theorem, and discharging it is an
  explicit milestone — so the summit is unconditional, not parametrized by a counting hypothesis.

Key milestones:

```lean
scottFormula
scottFormula_realize_self
BFEquiv_iff_agree_codes
refinement_countable
scottRank_lt_omega1
scottSentence
scott_isomorphism
```

Acceptance examples (discharge alongside the layer): Scott sentences and ranks for finite
structures, pure-equality sets, the dense linear order without endpoints, equivalence relations with
`k` or countably many classes, and simple graphs.

⚠ **API warning.** Do not run countability through raw `BoundedFormulaω`: it is uncountable. The
coded proxy is mandatory, and the bridge from codes to back-and-forth equivalence is a theorem to
prove, not an assumption to carry.

### Layer 3: model existence for countable fragments

Suggested home:

```text
TauCeti/ModelTheory/ModelExistence/ConsistencyProperty.lean
TauCeti/ModelTheory/ModelExistence/ModelExistence.lean
TauCeti/ModelTheory/ModelExistence/OmittingTypes.lean
TauCeti/ModelTheory/ModelExistence/LowenheimSkolem.lean
```

Build the Henkin / consistency-property method for countable Lω₁ω fragments:

* `ConsistencyProperty` for a countable fragment, with the finite-character closure conditions for
  the infinitary connectives;
* the Henkin construction and `model_existence`: a consistency property has a countable model;
* the omitting-types theorem for a countable family of types;
* downward Löwenheim–Skolem for Lω₁ω: a satisfiable countable fragment has a countable model, and an
  uncountable model has a countable elementary substructure for the fragment.

Key milestones:

```lean
ConsistencyProperty
model_existence
omitting_types
downward_lowenheimSkolem_omega1
```

⚠ **API warning.** Compactness fails for Lω₁ω; the model-existence engine is the consistency-property
construction, not Mathlib's finitary compactness. State it for countable fragments and keep the
countability hypotheses explicit.

### Layer 4: admissible fragments and Barwise compactness (summit)

Suggested home:

```text
TauCeti/ModelTheory/Admissible/Fragment.lean
TauCeti/ModelTheory/Admissible/ProofSystem.lean
TauCeti/ModelTheory/Admissible/Barwise.lean
TauCeti/ModelTheory/Admissible/Nadel.lean
```

Build:

* admissible fragments of Lω₁ω, closed under subformulas, finitary connectives, substitution, and
  the relevant infinitary conjunctions; and the admissible-set interface Barwise compactness needs;
* the Barwise proof system, with soundness and the consistency ↔ satisfiability bridge;
* **Barwise compactness**: a `Σ`-definable theory over a countable admissible set, every
  `A`-finite subset of which is satisfiable, is satisfiable;
* Nadel's bound on Scott height in terms of the admissible ordinal.

Key milestones:

```lean
AdmissibleFragment
AdmissibleFragment.closed_under_subformula
barwise_proofSystem_sound
barwise_compactness
nadel_scottHeight_bound
```

⚠ **API warning.** Separate the practical compactness API from the literature-faithful
admissible-set development. The admissible-set machinery does not exist in Mathlib and must be built
here (or in a cited roadmap); do not present an axiomatic compactness interface as if it were the
formalized admissible-set proof.

### Layer 5: Ehrenfeucht–Mostowski methods

Suggested home:

```text
TauCeti/ModelTheory/EM/Template.lean
TauCeti/ModelTheory/EM/Indiscernible.lean
TauCeti/ModelTheory/EM/Stretch.lean
```

Build:

* order-indiscernible sequences and their restricted (per-fragment) variants;
* EM templates: the theory of a model generated by an indiscernible sequence;
* the stretching theorem: from a template, build models containing indiscernible sequences of any
  prescribed order type;
* sequence restriction / reindexing APIs for fragments.

Key milestones:

```lean
Indiscernible
RestrictedIndiscernible
EMTemplate
em_stretch
em_model_of_template
```

### Layer 6: partition calculus — Ramsey and Erdős–Rado (summit-enabling)

Suggested home:

```text
TauCeti/Combinatorics/Partition/Arrow.lean
TauCeti/Combinatorics/Partition/Ramsey.lean
TauCeti/Combinatorics/Partition/ErdosRado.lean
```

Build the partition calculus intrinsically, as reusable (and upstreamable) combinatorics:

* the arrow notation `κ ⟶ (λ)^n_μ` for colorings of `n`-element subsets;
* the infinite Ramsey theorem for finite colorings of `[ℕ]^n`;
* the **Erdős–Rado theorem**: `ℶ_n(κ)⁺ ⟶ (κ⁺)^{n+1}_κ`, and in particular the pair partition
  relation at `ω₁` needed for the Hanf number;
* generalization from pair colorings to finite arities and countable families.

Key milestones:

```lean
Arrows                       -- κ ⟶ (λ)^n_μ
ramsey_infinite
erdos_rado
erdos_rado_pair_omega1
```

⚠ **API warning.** State the arrow relation as the general partition predicate, not a one-off pair
lemma; the Hanf-number application is one instance of it. This layer should read as partition
calculus a non-model-theorist would reuse.

### Layer 7: the Hanf number for Lω₁ω (unconditional Morley–Hanf) (summit)

Suggested home:

```text
TauCeti/ModelTheory/EM/HanfNumber.lean
TauCeti/ModelTheory/ModelExistence/MorleyHanf.lean
```

Combine EM stretching (Layer 5) with Erdős–Rado (Layer 6):

* convert formula truth values on increasing tuples into colorings, and extract a restricted-
  indiscernible sequence;
* prove the **Hanf number** for Lω₁ω: an Lω₁ω sentence with a model of cardinality at least
  `ℶ_ ω₁` (`Cardinal.beth (Ordinal.omega 1)`) has models of arbitrarily large cardinality.

Key milestones:

```lean
extract_indiscernibles_of_large_model
hasArbitrarilyLargeModels_of_beth_omega1
morley_hanf
```

⚠ **API warning.** State `morley_hanf` unconditionally. Any "transfer/extraction" hypothesis is an
internal lemma on the way to it, never the published theorem; the conditional packaging in the
source is provenance, not the target.

### Layer 8: the descriptive set theory of countable structures

Suggested home:

```text
TauCeti/Descriptive/Structures/Space.lean
TauCeti/Descriptive/Structures/SatisfactionBorel.lean
TauCeti/Descriptive/Structures/IsomorphismBorel.lean
TauCeti/Descriptive/Structures/LopezEscobar.lean
```

Build:

* `ModStructures L`, the Polish / standard-Borel space of `L`-structures on the carrier `ℕ`, coded
  via `PolishSpace` / `StandardBorelSpace`;
* satisfaction is Borel: `{M | M ⊨ φ}` is Borel for each `φ : Sentenceω`, with the level tracked by
  quantifier rank;
* the isomorphism relation is analytic, and Borel on the structures of Scott height `≤ α` (using
  Layer 2);
* back-and-forth equivalence `BFEquiv α` is Borel for each `α < ω₁`;
* the López–Escobar / Vaught transfer: the invariant Borel sets are exactly the Lω₁ω-definable ones.

Isolate the genuinely topological lemmas — perfect-set and Cantor-scheme extraction, the
Kuratowski–Ulam meager-sections direction, Mycielski's theorem — as reusable DST suitable for
upstreaming.

Key milestones:

```lean
ModStructures
satisfaction_borel
bfEquiv_borel
iso_analytic
iso_borel_of_bounded_scottHeight
lopezEscobar_vaught
```

⚠ **API warning.** Pin the coding of `ModStructures` once and state every Borelness result against
it; do not let two incompatible codings of "a countable structure" coexist.

### Layer 9: Borel equivalence relations and the Silver / G₀ / Glimm–Effros dichotomies

Suggested home:

```text
TauCeti/Descriptive/Equivalence/Borel.lean
TauCeti/Descriptive/Equivalence/Silver.lean
TauCeti/Descriptive/Equivalence/G0.lean
TauCeti/Descriptive/Equivalence/GlimmEffros.lean
```

Build the Borel-equivalence-relation library, stated intrinsically as DST:

* Borel and analytic equivalence relations, Borel reducibility `≤_B`, and smoothness;
* the **Silver dichotomy**: a coanalytic (in particular Borel) equivalence relation has either
  countably many classes or a perfect set of pairwise inequivalent points;
* the `G₀` dichotomy and its fusion argument;
* `E₀` and the Glimm–Effros dichotomy: a Borel equivalence relation is either smooth or admits a
  continuous embedding of `E₀`.

Key milestones:

```lean
IsBorelEquivalence
BorelReducible
silver_dichotomy
g0_dichotomy
glimmEffros_dichotomy
```

⚠ **API warning.** "Potentially closed" is not enough for nonsmoothness arguments; state the
dichotomies in the perfect-set / continuous-embedding form the Morley-counting application needs.

### Layer 10: Morley counting and the countable-models dichotomy (summit)

Suggested home:

```text
TauCeti/Descriptive/Structures/CountingDichotomy.lean
TauCeti/ModelTheory/MorleyCounting.lean
TauCeti/ModelTheory/Vaught.lean
```

Combine Layer 8 (isomorphism is analytic, and Borel under bounded Scott height) with Layer 9
(Silver). Two distinct milestones with different bounds:

* **(a) bounded-Scott-height dichotomy.** For a sentence whose countable models all have Scott
  height `≤ α < ω₁`, the isomorphism relation is Borel, so by Silver the number of isomorphism types
  is `≤ ℵ₀` or exactly `2^ℵ₀`.
* **(b) full Morley counting.** For any Lω₁ω sentence, the number of isomorphism types of countable
  models is `≤ ℵ₁` or exactly `2^ℵ₀`, by stratifying over the `ω₁` Scott-height strata (`≤ ℵ₀` per
  stratum).

Also build the Vaught toolkit as definitions and statements only: few models, a perfect set of
nonisomorphic models, Borel completeness, and smooth classification, with the Vaught-conjecture
variants stated but not claimed.

Key milestones:

```lean
counting_dichotomy_of_bounded_scottHeight   -- ≤ ℵ₀ or 2^ℵ₀
morley_counting                             -- ≤ ℵ₁ or 2^ℵ₀
PerfectlyManyModels
BorelComplete
vaughtConjecture                            -- statement only
```

⚠ **API warning.** Do not collapse the two milestones into "≤ ℵ₀ or 2^ℵ₀ for all Lω₁ω": that is
Vaught's conjecture, which is open. The bounded-height result and the full Morley theorem are
different theorems with different bounds; keep them, and their hypotheses, separate.

### Layer 11: functions, constants, and many-sorted structures via relationalization

Suggested home:

```text
TauCeti/ModelTheory/Infinitary/Relationalization.lean
TauCeti/ModelTheory/Scott/Transfer.lean
```

Consume Mathlib's `Functions`/`Constants`, `Term`, `Substructure`, and language maps `LHom`
(`Mathlib/ModelTheory/LanguageMap.lean`). Build:

* the relationalization functor `L ↦ Lʳ`, replacing each `n`-ary function by its graph relation
  plus a functionality axiom, and the reduct/expansion equivalence of structures;
* many-sorted handling, pinned to single-sorted relationalization with unary sort predicates and
  relativized quantifiers (revisit only if a concrete many-sorted Mathlib language API is verified
  to exist at the pin);
* transfer of L∞ω-equivalence, Scott rank, and Scott sentences across relationalization.

Because functions become relations, the transfer carries `[Countable (Σ n, L.Functions n)]`
(constants are `Functions 0`) in addition to `[Countable (Σ n, L.Relations n)]`; the many-sorted
case also assumes a countable sort index.

Key milestones:

```lean
relationalize
modelEquiv_relationalize
scottSentence_transfer
scott_isomorphism_of_functions
```

### Layer 12: other infinitary logics Lκλ

Suggested home:

```text
TauCeti/ModelTheory/Infinitary/Lkappa.lean
```

Consume `Cardinal`, `Cardinal.aleph` / `Ordinal.omega`, and the Layer-0 syntax. Build:

* a cardinal-parametrized formula type allowing `< κ`-ary `iInf`/`iSup` and `< λ`-quantifier blocks;
* the formula-size predicate via `Cardinal` (`formulaSize φ < κ`), not a bespoke counter;
* the Lκλ realization semantics generalizing Layer 0, with Lω₁ω recovered as the `κ = ℵ₁, λ = ℵ₀`
  instance by an explicit bridge to Layer 0;
* the Hanf and Löwenheim numbers for Lκω in terms of `Cardinal.beth`.

Key milestones:

```lean
BoundedFormulaKL
formulaSize
lomega1omega_equiv_lkl       -- Lω₁ω as the (ℵ₁, ℵ₀) instance
hanf_number_lkappaomega
```

### Layer 13: effective and admissible-recursive Scott analysis

Suggested home:

```text
TauCeti/ModelTheory/Scott/Effective.lean
```

Consume Layer 2 (Scott rank), Layer 4 (admissible fragments and the admissible-ordinal interface),
and Mathlib computability (`Mathlib/Computability/*`, `Part`, `Nat.Partrec`). Build:

* the lightface vs boldface distinction for Scott analysis;
* hyperarithmetic / `ω₁^{CK}`-bounded Scott rank for computable structures;
* the effective Scott-sentence construction.

Key milestones:

```lean
computableScottRank
effective_scott_isomorphism   -- hyperarithmetic Scott sentence for computable Scott rank
nadel_bound_effective         -- Scott height ≤ ω₁^{CK,M}
```

## Worked examples

Discharge these alongside the layers; they check that the API describes real structures, not just
the final theorems.

* Finite structures have a Scott sentence of finite rank, and the Scott sentence of a finite
  structure is (equivalent to) a first-order sentence.
* A pure-equality set of size `n`, and a countably infinite pure-equality set, with their Scott
  ranks.
* The dense linear order without endpoints: ℵ₀-categorical, with its Scott sentence and rank.
* Equivalence relations with `k` classes and with countably many classes of prescribed sizes.
* Simple graphs, including the random graph (ℵ₀-categorical) and a rigid example.
* The classic Lω₁ω sentence whose countable models are exactly the well-orders of `ℕ` of a fixed
  order type — a property with no first-order axiomatization.
* A sentence with exactly countably many countable models, and one (e.g. via a perfect set of
  pairwise nonisomorphic models) with `2^ℵ₀`.
* An EM-stretched model: from a template, a model with an indiscernible sequence of order type `ω + ω`.
* First-order elementary equivalence is strictly weaker than `L∞ω`-equivalence: e.g. `(ℤ, <)` and
  `(ℤ + ℤ, <)` (one versus two `ℤ`-blocks) are countable, elementarily equivalent, and
  non-isomorphic — hence, on countable structures, not `L∞ω`-equivalent.
* The countable corollary of Karp: on countable structures, `L∞ω`-equivalence, potential
  isomorphism, and isomorphism all coincide. The strictness lives above `ℵ₀`: two non-isomorphic
  dense linear orders without endpoints of size `ℵ₁` are potentially isomorphic by the order
  back-and-forth — hence `L∞ω`-equivalent — but not isomorphic, since Karp delivers a potential
  isomorphism, which need not be an isomorphism for uncountable structures.

## Ordering

Layer 0 first: every later layer needs the infinitary syntax and semantics. Layer 1 (back-and-forth
and Karp) and Layer 2 (Scott analysis) follow and deliver the v1 summit; the coded-formula proxy is
on the critical path to an unconditional Scott theorem. Layer 3 (model existence) and Layer 4
(admissible fragments and Barwise compactness) build the model-construction toolbox.

Layers 5–7 are the Hanf-number track: EM methods, then partition calculus, then the unconditional
Morley–Hanf theorem; Layer 6 is self-contained combinatorics and can proceed in parallel. Layers
8–10 are the descriptive-set-theory track: the standard-Borel space of structures, then Borel
equivalence relations and the Silver dichotomy, then Morley counting. Layers 11–13 generalize the
core — functions and many-sorted languages, other infinitary logics, and effective Scott analysis —
each depending only on earlier layers.

## References

* Dana Scott, "Logic with denumerably long formulas and finite strings of quantifiers", in *The
  Theory of Models*, 1965.
* Carol Karp, "Finite-quantifier equivalence", in *The Theory of Models*, 1965.
* Jon Barwise, *Admissible Sets and Structures*, Springer, 1975.
* H. Jerome Keisler, *Model Theory for Infinitary Logic*, North-Holland, 1971.
* David Marker, *Lectures on Infinitary Model Theory*, Cambridge University Press, 2016.
* Su Gao, *Invariant Descriptive Set Theory*, CRC Press, 2009.
* Alexander Kechris, *Classical Descriptive Set Theory*, Springer, 1995.
* Michael Morley, "The number of countable models", *Journal of Symbolic Logic*, 1970.
* Jack Silver, "Counting the number of equivalence classes of Borel and coanalytic equivalence
  relations", *Annals of Mathematical Logic*, 1980.
* John Burgess, "Effective enumeration of classes in a Σ¹₁ equivalence relation", *Indiana
  University Mathematics Journal*, 1978.
* Paul Erdős and Richard Rado, "A partition calculus in set theory", *Bulletin of the AMS*, 1956.
* Mark Nadel, "Scott sentences and admissible sets", *Annals of Mathematical Logic*, 1974.
* Robert Vaught, "Denumerable models of complete theories", in *Infinitistic Methods*, 1961;
  "Invariant sets in topology and logic", *Fundamenta Mathematicae*, 1974.
* Wilfrid Hodges, *Model Theory*, Cambridge University Press, 1993.
* Maximiliano Dickmann, *Large Infinitary Languages*, North-Holland, 1975.
* Chris Ash and Julia Knight, *Computable Structures and the Hyperarithmetical Hierarchy*,
  North-Holland, 2000; Antonio Montalbán, *Computable Structure Theory*, 2021–2023.
* `cameronfreer/infinitary-logic`, Lean 4 formalization of infinitary logic and Scott analysis.

## Acknowledgements

This roadmap uses Cameron Freer's `infinitary-logic` formalization as its primary migration source;
its Lean target signatures were prototyped with the `lean4-skills` tooling and `lean-lsp-mcp`. Ported
files should preserve source attribution and document any substantial API changes made during
migration to Tau Ceti.
