# Conformal mapping and the geometric theory of holomorphic functions

The narrative roadmap for the conformal-mapping / geometric-function-theory area of complex
analysis, with the **Riemann mapping theorem** as its summit; `Targets.lean` states the
milestones as `sorry`-goals. Among its applications: the modular-`λ` uniformization
`ℍ/Γ(2) ≅ ℂ∖{0,1}` (hence Picard's little theorem and the elliptic/modular uniformization)
and the boundary regularity of conformal maps — but the area is foundational complex analysis
in its own right.

Mathlib has the **Cauchy foundations** of complex analysis — contour integration and the
Cauchy integral formula, power series / analyticity, the **open mapping theorem**
(`Complex.AnalyticOnNhd.is_constant_or_isOpenMap`), the **maximum modulus principle**
(`Analysis/Complex/AbsMax`), the **Schwarz lemma** (`Analysis/Complex/Schwarz`), the
**Riemann removable-singularity** theorem, the rectangle-integral vanishing lemmas, the unit
disc `Complex.UnitDisc`, `conjCLE`/`starRingEnd ℂ` — but **almost none of the geometric /
boundary superstructure built on them**: no argument principle, no Rouché or Hurwitz, no
Morera as a named theorem, no analytic **normal-families / Montel theorem** (note:
`Analysis/LocallyConvex/Montel.lean` is about Montel *spaces* — locally convex spaces where
closed bounded sets are compact — a different notion from the normal-families theorem L1
targets, and unrelated to its `TendstoLocallyUniformlyOn` formulation), **no complete Riemann
mapping theorem** (only the partial, private results in `Analysis/Complex/RiemannMapping.lean`
— see Prior art), no Schwarz reflection, no Carathéodory boundary correspondence, no
Schwarz–Christoffel, no Schwarz–Pick / hyperbolic metric, no analytic continuation / monodromy
theorem.

The goal is to **build that geometric theory as a reusable library**, with the **Riemann
mapping theorem** (RMT) as the summit. "Done" means a researcher in conformal geometry,
several-complex-variables, modular forms, or PDE finds the objects — conformal
isomorphisms, normal families, the reflected continuation, the boundary correspondence — at
their natural generality with full basic API, so RMT and its boundary regularity are
*consequences of a developed theory*, not isolated endpoints.

Suggested home: `TauCeti/Analysis/Complex/Conformal/` (with
`…/Conformal/ArgumentPrinciple.lean`, `…/NormalFamilies.lean`, `…/RiemannMapping.lean`,
`…/Reflection.lean`, `…/BoundaryCorrespondence.lean`).

**RMT is being formalized upstream — we coordinate.** A complete Riemann mapping theorem is
already in progress at Mathlib ([mathlib4#33505](https://github.com/leanprover-community/mathlib4/pull/33505)),
being merged as a series of human-curated PRs. Tau Ceti may proceed with RMT in the meantime,
but any duplicating L3 statement is a temporary shim: we cite the upstream work, delete the
shim once the Mathlib theorem lands, and refactor downstream consumers to it — see
*[Coordination with upstream Mathlib](#coordination-with-upstream-mathlib-rmt-is-being-formalized-at-mathlib)* below.

## Prior art

- **Mathlib:** none of the layer summits below (reflection, Rouché, the normal-families
  Montel theorem, Carathéodory, …) are present; only the foundations listed above.
  (`Analysis/Complex/Schwarz.lean` is the Schwarz *lemma*, not the reflection *principle*.)
- **Mathlib RMT, in progress (must coordinate).** `Analysis/Complex/RiemannMapping.lean`
  (Kudryashov) holds *partial* results toward RMT; its docstring points to
  [mathlib4#33505](https://github.com/leanprover-community/mathlib4/pull/33505), a complete
  draft proof being brought to Mathlib standards and merged as a series of smaller PRs (its
  current lemmas are private and strictly weaker than the theorem). The square-root/log trick
  L3 relies on is **already in Mathlib**: `Analysis/Complex/BranchLogRoot.lean` has
  `exists_continuousOn_eqOn_exp_comp` (a continuous branch of `log` on a simply connected open
  set — holomorphic when the input is) and `exists_continuousOn_pow_eq` (continuous n-th roots,
  likewise) — **consume these, do not rebuild them.** Beyond
  those, `#33505` itself proves the **L0–L2 prerequisites** — an argument principle, Hurwitz, and
  the Montel/normal-families equicontinuity — internally, as private lemmas rather than
  reusable API. So the overlap with this roadmap is **L0–L3, not just L3**; see *Coordination with
  upstream Mathlib* below for the (correspondingly broadened) shim-deletion commitment.
- **Isabelle/HOL:** the **Riemann mapping theorem is formalized** (Paulson, `Riemann_Mapping`
  in `HOL-Complex_Analysis`), so RMT is *achievable* — Lean simply lacks it. The reflection
  principle and Schwarz–Christoffel appear unformalized in Lean and were not found in a
  search of other provers. So this area ports/re-proves RMT into Lean and adds genuinely new
  material on top.

## Generality bar (decide up front; do not silently specialize)

- **Scalar `ℂ` throughout the conformal layers (L0–L6).** RMT, the reflection principle, and
  the boundary theory are `ℂ`-specific; state them for `f : ℂ → ℂ`. In particular **Schwarz
  reflection (L4) is scalar**: its real-boundary condition `(f z).im = 0` has no Banach-`E`
  analogue without introducing a real form/subspace, which this entry does not do. The
  maximum-principle, open-mapping, and Morera *inputs* are **consumed** from Mathlib at
  whatever generality (often `E`-valued) Mathlib already provides — we do not restate them. But
  every theorem this entry *adds*, from L0 (Rouché / Hurwitz / Morera-as-named) through L6, is
  scalar `ℂ`.
- **Domains: open + connected, simple-connectivity via Mathlib.** Use `IsOpen`,
  `IsConnected`/`IsPreconnected`, and `SimplyConnectedSpace ↥Ω` (Mathlib's class) — never an
  ad hoc "no holes". RMT's hypotheses are: `Ω` open, simply connected, `Ω ≠ univ`, nonempty.
- **Conformal isomorphism = holomorphic bijection.** A biholomorphism `Ω ≃ Ω'` is a
  `DifferentiableOn ℂ` bijection with `DifferentiableOn ℂ` inverse; since holomorphic +
  injective ⇒ open with holomorphic inverse (open mapping), state RMT's conclusion as
  `∃ f, DifferentiableOn ℂ f Ω ∧ Set.InjOn f Ω ∧ f '' Ω = Metric.ball 0 1` and derive the
  packaged `≃` / `ConformalAt` API as companions. Relate to Mathlib's `ConformalAt`.
- **Target disc: `Complex.UnitDisc` / `Metric.ball (0:ℂ) 1`.** Reuse the existing disc and
  its automorphism/`Schwarz` API; do not re-encode the disc.
- **Convergence of holomorphic families: `TendstoLocallyUniformlyOn`** (compact-open), the
  topology under which "holomorphic" is closed and Montel lives. Local boundedness =
  "bounded on each compact `K ⊆ Ω`".
- **Reflection: real-axis first; conjugation is `starRingEnd ℂ`; explicit witness.** See L4.

## Layers (each a discharge-gated milestone; the `sorry` goal in `Targets.lean` is stated for the core layers L0–L4, with L5–L6 deferred)

- **L0 — the local-mapping engine** (consumes the sibling **ContourIntegration** roadmap,
  PR #35). The *argument principle*, residues, winding numbers, and the *global/homological
  Cauchy theorem* are #35's deliverables (`TauCeti/Analysis/Contour/`) — **consume them, do
  not re-derive**. This layer adds the *conformal-geometric* consequences on top: *Rouché*,
  *Hurwitz* (locally-uniform limits of zero-free maps are zero-free or `≡ 0`), the
  open-mapping degree, and *Morera* as a named theorem. The open mapping theorem and `AbsMax`
  are consumed from Mathlib.
- **L1 — normal families / Montel (the analytic theorem, not `MontelSpace`).** Locally bounded
  ⇒ precompact for `TendstoLocallyUniformlyOn` (every sequence has a locally-uniformly-convergent
  subsequence with holomorphic limit); Vitali. This is independent of Mathlib's
  `Analysis/LocallyConvex/Montel.lean` (`MontelSpace`): we do not route through that API. The
  compactness engine RMT runs on.
- **L2 — Schwarz lemma extensions.** *Schwarz–Pick* (holomorphic disc self-maps contract the
  pseudo-hyperbolic metric), the **hyperbolic / Poincaré metric** on `𝔻`, and the disc
  automorphism group `Aut(𝔻) = {e^{iθ}(z−a)/(1−āz)}`. Built on Mathlib's Schwarz lemma.
- **L3 — the Riemann mapping theorem (summit).** Every simply connected proper open
  `Ω ⊊ ℂ` (nonempty) is biholomorphic to `𝔻`. Standard route: the family of injective
  holomorphic `Ω → 𝔻` fixing a point is nonempty (square-root trick on simple-connectivity)
  and normal (L1); maximize `|f′(z₀)|`; the maximizer is onto (else compose with a disc
  automorphism + square root to beat it — L2). Uniqueness up to `Aut(𝔻)`. The square-root /
  holomorphic-log step **consumes Mathlib's `BranchLogRoot` API** (`exists_continuousOn_pow_eq`,
  `exists_continuousOn_eqOn_exp_comp`) rather than rebuilding it; coordinate with the in-progress
  Mathlib RMT (#33505) per *Coordination with upstream Mathlib*.
- **L4 — analytic continuation & the reflection principle.** Morera-based **Schwarz
  reflection** across `ℝ` (witness `F z = if 0 ≤ z.im then f z else conj (f (conj z))`),
  then across an analytic arc / circle by Möbius reduction; **Painlevé removability** across
  an arc; the **monodromy theorem** (continuations along homotopic paths agree). Reflection's
  reflected branch needs the antiholomorphic-composition lemma (L4.0). *This is the layer the
  SW modular-`λ` covering consumes.*
- **L5 — Carathéodory boundary correspondence.** The concrete L5 milestone is the
  **Jordan-domain case**: the RMT map of a Jordan domain extends to a homeomorphism of
  closures. Uses L4 (reflection) for analytic boundary arcs. The general **prime-ends**
  correspondence (Mathlib has no prime-ends definition) is materially heavier and is *not* part
  of the L5 milestone; if pursued it is scoped as its own follow-on target rather than folded
  into L5.
- **L6 — Schwarz–Christoffel.** Explicit conformal maps onto polygons, built on L4 + L5
  (sequenced last, after the boundary theory it needs).

## Relation to sibling roadmaps (this entry is the connective layer)

This area sits **between two of Chris Birkbeck's roadmaps** and feeds two more, so it is
deliberately scoped to the conformal-mapping spine that none of them build:

- **Below — `ContourIntegration` (PR #35).** Provides residues, winding numbers, the
  argument principle, and the global Cauchy theorem (Dixon). **L0 consumes it.**
- **Above — `ModularForms` (PR #47).** A 13-layer entry targeting the complex modular curves
  `Y(Γ)(ℂ) ≅ Γ\ℍ` (the complex-analytic versions, not the moduli-space framing). The
  **modular & elliptic uniformization** — including the
  `ℍ/Γ(2) ≅ ℂ∖{0,1}` `λ`-covering, the
  `j`-invariant, and Picard's theorem — belongs there; it **consumes our L4 (reflection) +
  L5 (boundary correspondence)** together with `UniversalCovers` (deck group). We do **not**
  claim the modular layer here; we supply the conformal inputs it needs.
- **Consumers — `HeegaardFloer` (merged)** uses **L4 Schwarz reflection** for its
  Cauchy–Riemann boundary conditions; **`UniversalCovers` (merged)** supplies the deck-group
  Galois correspondence the `λ`-covering pairs with L4/L5.

So the unique content of this entry — **Montel/normal families, the Riemann mapping theorem,
Schwarz–Pick, reflection, Carathéodory** — is exactly the conformal spine missing between the
residue engine (#35) and the modular/geometric consumers (#47, HeegaardFloer, UniversalCovers).

## Coordination with upstream Mathlib (RMT is being formalized at Mathlib)

A complete RMT proof exists upstream as [mathlib4#33505](https://github.com/leanprover-community/mathlib4/pull/33505)
(at the time of writing a **stalled draft** — last updated 2026-05, merge-conflicted), slated to
land in `Analysis/Complex/RiemannMapping.lean` as a series of smaller, human-curated PRs. The key
fact for scoping: **`#33505` does not reach RMT by magic — it proves the L0–L2 prerequisites
internally**, as private lemmas: an argument principle
(`circleIntegral_logDeriv_eq_finsum_analyticOrderNatAdd`), Hurwitz
(`eqOn_zero_or_forall_ne_zero_of_tendstoLocallyUniformlyOn`,
`eqOn_const_or_injOn_of_tendstoLocallyUniformlyOn`), Montel/normal-families equicontinuity
(`uniformEquicontinuousOn_…`), and holomorphic log / n-th-root (`exists_branch_log`,
`exists_branch_nthRoot`). So the overlap with this roadmap is **L0–L3, not just L3** — while
**L4–L6 (reflection, Carathéodory, Schwarz–Christoffel) are absent from `#33505` entirely** and
unformalized elsewhere. Tau Ceti may proceed with L0–L3 in the meantime, under explicit conditions:

1. **Cite the upstream work.** Every Tau Ceti L0–L3 file and PR cites #33505 and the Mathlib
   `RiemannMapping.lean` / `BranchLogRoot.lean` work as the preceding human-curated effort, and
   reuses Mathlib API (`BranchLogRoot`, and `#33505`'s lemmas once they land) wherever it already
   exists rather than re-deriving it.
2. **Declare the shims temporary — across L0–L3, not only L3.** Any Tau Ceti statement that
   duplicates content destined for Mathlib — the RMT itself *and* the argument-principle /
   Hurwitz / Montel-equicontinuity / branch-log-root prerequisites `#33505` proves internally —
   is a **temporary shim**: we delete it once the human-curated Mathlib version lands and
   refactor every downstream consumer (L4/L5, the SW modular-`λ` covering, `HeegaardFloer`) to it.
3. **Our distinctive L0–L2 value is API, not first proof.** Because `#33505` already contains this
   mathematics (buried and unnamed), what Tau Ceti adds at L0–L2 is to expose it as the **named,
   discoverable library API** (`argument_principle`, `Hurwitz`, `Montel`, …); once `#33505` lands,
   those names should be backed by Mathlib's lemmas rather than independent re-proofs.
4. **Follow through.** PRs introducing these shims state that intent in their description, and the
   AIs carry out the deletion + downstream refactor promptly once the Mathlib lemmas are
   available. (The reflection / Carathéodory / Schwarz–Christoffel layers **L4–L6 are genuinely
   new** and not subject to this shim-deletion clause.)

## Other downstream

Several complex variables, PDE (conformal/quasiconformal mappings), and special-function
theory all consume the conformal-mapping and boundary layers.

## References

Ahlfors, *Complex Analysis* (Ch. 4–6) and *Conformal Invariants*; Conway, *Functions of One
Complex Variable I* (VII–IX); Rudin, *Real and Complex Analysis* (Ch. 14); Stein–Shakarchi,
*Complex Analysis* (Ch. 2, 8); Remmert, *Classical Topics in Complex Function Theory*. RMT:
cf. Paulson's Isabelle/HOL `Riemann_Mapping`. New Lean formalization; credit none — original.
