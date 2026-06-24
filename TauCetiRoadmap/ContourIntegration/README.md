# Roadmap: contour integration and the Hungerbühler–Wasem generalized residue theorem

Mathlib has the Cauchy integral formula and the Cauchy–Goursat theory
(`Mathlib/Analysis/Complex/CauchyIntegral.lean`), circle integrals
(`Mathlib/MeasureTheory/Integral/CircleIntegral.lean`), and the local theory of
meromorphic functions (`Mathlib/Analysis/Meromorphic/*`, including `MeromorphicAt.order`
and the principal-part machinery). But the residue calculus it can reach is the **classical**
one, where the singularities lie strictly *off* the contour and the winding number is an
integer.

The ultimate target of this roadmap is the **Hungerbühler–Wasem generalized residue
theorem** (N. Hungerbühler, M. Wasem, *Non-integer valued winding numbers and a generalized
Residue Theorem*, arXiv:1808.00997, 2018): a residue theorem that remains valid when the
singularities lie **on** the contour, with the residues weighted by a **non-integer-valued
winding number** `n_{z₀}(C) = PV (2πi)⁻¹ ∮_C dz/(z − z₀)` that has a genuine geometric
meaning (an angle, divided by `2π`) for points on the curve. Along the way we build its
prerequisites — the generalized winding number and its geometry, the classical residue
theorem, and the global (homological) Cauchy theorem — none of which Mathlib has.

This is ordinary complex analysis and belongs in Mathlib's analysis tree. Its first client is
arithmetic: the **valence formula** (in the separate
[Modular Forms roadmap](../ModularForms/README.md)) integrates `f'/f` around the boundary of
the standard fundamental domain — a contour that *passes through* the elliptic points `i` and
`ρ`. Their fractional contributions to the valence formula (`½` at `i`, `⅓` at `ρ`) are
exactly Hungerbühler–Wasem winding numbers of points on the contour. So the non-integer
theory is not decoration; it is the engine the modular application runs on.

Suggested home: `TauCeti/Analysis/Contour/`.

## Standing conventions

Pin these once; implementors drift badly otherwise.

- **Curves, immersions, cycles.** A piecewise-`C¹` curve is a continuous `γ : [a,b] → ℂ`,
  `C¹` on each piece of a finite partition. A **closed piecewise-`C¹` immersion** additionally
  has `γ' ≠ 0` on each piece and `γ a = γ b` (HW's standing object); a **cycle** is a finite
  formal `ℤ`-combination of closed curves. Reuse Mathlib's `intervalIntegral` and
  `HasDerivAt`; do not introduce a bespoke path type where a function on `[a,b]` suffices.
- **The contour integral is `∫ t in a..b, γ' t • f (γ t)`** (`intervalIntegral`), agreeing
  with `circleIntegral` on a circle. State results about this integral; do not wrap it.
- **The generalized winding number** of a cycle `C` about any `z₀ ∈ ℂ` — including `z₀ ∈ C` —
  is `n_{z₀}(C) := PV (2πi)⁻¹ ∮_C dz/(z − z₀)` (HW Def 2.1), normalized so a single
  counterclockwise circle about an interior point has winding `1`. For `z₀ ∉ C` this is the
  classical integer index; for `z₀ ∈ C` it is in general **non-integer**.
- ⚠ **A principal value is not an ordinary integral.** When `z₀ ∈ C`, both the winding
  integral and `∮_C f` diverge; the Cauchy principal value is the symmetric-excision limit.
  Keep the PV predicate (`HasCauchyPV …`, an existence-and-value statement) separate from
  genuine integrability, and never silently identify them.
- **Residues via the order/`Laurent` API.** The residue at an isolated singularity is the
  order-`(−1)` Laurent coefficient; reuse `MeromorphicAt.order` and the principal-part
  machinery. For a simple pole it is `lim_{z→z₀}(z − z₀) f(z)`. Do not define a parallel
  "order of vanishing".

## What Mathlib already has (consume)

- **Cauchy's theorem and the integral formula:** `Mathlib/Analysis/Complex/CauchyIntegral.lean`
  (`Complex.circleIntegral_sub_center_inv`, the Cauchy integral formula, the disc/annulus
  theory).
- **Circle integrals:** `Mathlib/MeasureTheory/Integral/CircleIntegral.lean` (`circleIntegral`,
  `circleMap`, `∮ z in C(c, R), f z`).
- **Meromorphic functions:** `Mathlib/Analysis/Meromorphic/*` (`MeromorphicAt`,
  `MeromorphicOn`, `MeromorphicAt.order`, principal parts) — the residue is the order-`(−1)`
  Laurent coefficient against this API.
- **Interval integrals and the FTC:** `Mathlib/MeasureTheory/Integral/IntervalIntegral.lean`,
  `…/FundThmCalculus.lean` — the substrate for the arc FTC and the real winding integral.
- **Homotopy of paths and signed curvature:** `Mathlib/Topology/Homotopy/Path.lean`, and the
  differential-geometry curvature API, inputs to homotopy invariance and to HW Prop 2.3.

## What is missing (build here)

The generalized winding number for points on a cycle (HW Def 2.1) and its geometry (the model
sector value `α/2π`, the finite-crossing decomposition HW Prop 2.2, the real bounded-integrand
formula and the `½·curvature` value HW Prop 2.3); the residue against `MeromorphicAt.order`
and the **classical residue theorem** `∮_C f = 2πi · Σ_s n_s(C)·Res_s f` for a cycle avoiding
its poles; the **global (homological) Cauchy theorem** (proved by Dixon's argument); and the
headline **Hungerbühler–Wasem generalized residue theorem** (HW Thm 3.3), valid with
singularities *on* the cycle. None of this is upstream.

---

## The build, in layers

The ordering is the dependency order. As each layer makes the next layer's *types*
expressible in `TauCeti/`, its milestones go into `Targets.lean` (with `sorry`).

### Layer 0: curves, cycles, and the generalized winding number
- **Piecewise-`C¹` curves, closed immersions, and cycles** on `[a,b]`: continuity, piecewise
  derivative, the non-vanishing-derivative condition, closedness; interval-integrability of
  `γ'·(f ∘ γ)` for `f` continuous on the image.
- **The generalized winding number** `n_{z₀}(C) = PV (2πi)⁻¹ ∮_C dz/(z − z₀)` (HW Def 2.1),
  *defined for every* `z₀ ∈ ℂ`, including `z₀ ∈ C`.
- **The classical case** `z₀ ∉ C`: the PV is an ordinary integral, `n_{z₀}(C) ∈ ℤ`
  (integrality via the primitive-of-`exp` argument), homotopy-invariant in `ℂ ∖ C`, and `0`
  on the unbounded component.
  ⚠ Integrality holds **only** off the curve; the whole point of Layer 1 is that on the curve
  the winding number is geometric and non-integer.

### Layer 1: the geometry of the generalized winding number (HW §2)
- **The model sector** (HW (2.4)): for the corner curve made of a segment, an arc of opening
  angle `α`, and a return segment, `n₀(γ) = α/2π`. So a point at a corner of interior angle
  `α` has winding `α/2π`, and a **smooth crossing** (`α = π`) has winding **`½`**.
- **HW Proposition 2.2 (finite crossings and the winding decomposition).** A closed
  piecewise-`C¹` immersion `Λ` meets any `z₀` at most finitely often; writing
  `Λ = Λ̃ + Γ₁ + … + Γₙ` where `Λ̃` avoids `z₀` and each `Γ_ℓ` is a model sector of angle
  `α_ℓ`, `n_{z₀}(Λ) = n_{z₀}(Λ̃) + Σ_ℓ α_ℓ/2π`. (The finiteness is a Rolle's-theorem argument
  on the immersion.)
- **HW Proposition 2.3 (the real, bounded-integrand formula).** For a closed piecewise-`C^{1,1}`
  immersion `Λ = x + iy`, `n₀(Λ) = (1/2π) ∫_a^b (x ẏ − y ẋ)/(x² + y²) dt` with **bounded
  integrand** (no principal value needed in the real form), and at a crossing `t̃` (where
  `Λ(t̃) = 0`) the integrand tends to `½·k_Λ(t̃)·|Λ̇(t̃)|`, half the signed curvature times
  speed. This is the computational workhorse — a genuine integral, not a PV.
  ⚠ The complex form needs the PV; the real form does not. Keep both and relate them.

### Layer 2: residues, the Cauchy primitive, and the classical residue theorem
- **FTC along an arc:** if `F' = f` on a neighbourhood of `image γ`, then
  `∮_γ f = F(γ b) − F(γ a)`, hence `0` for a closed curve; Cauchy's theorem for a contractible
  contour as a corollary (reconciled with Mathlib's disc statements).
- **Residue at an isolated singularity** `Res_{z₀} f` (the order-`(−1)` Laurent coefficient;
  for a simple pole the limit `lim_{z→z₀}(z − z₀)f(z)`); `ℂ`-linearity; the **simple-pole
  decomposition** `f = (holomorphic) + Σ_s (Res_s f)/(z − s)`.
- **The classical residue theorem** `∮_C f = 2πi · Σ_s n_s(C)·Res_s f` for a closed
  piecewise-`C¹` cycle `C` avoiding the finite pole set `S` — the special case of HW Thm 3.3
  with integer winding numbers, recovering the Cauchy integral formula.

### Layer 3: the global (homological) Cauchy theorem
- **The homology form of Cauchy's theorem**: for `f` holomorphic on open `Ω` and a cycle `C`
  in `Ω` that is **null-homologous** (`n_w(C) = 0` for every `w ∉ Ω`), `∮_C f = 0` and
  `f(z)·n_z(C) = (2πi)⁻¹ ∮_C f(w)/(w − z) dw`. Subsumes the null-homotopic case (null-homotopic
  ⟹ null-homologous, not conversely) and is the hypothesis under which HW Thm 3.3 is stated.
  ⚠ This is **not** called "Dixon's theorem" — it is the homology Cauchy theorem; *Dixon's
  argument* [Dixon 1971] is the slick proof (the auxiliary `g(w,z) = (f(w)−f(z))/(w−z)`
  extends holomorphically across the diagonal, so `z ↦ ∮_C g(w,z)dw` extends to a bounded
  entire function, hence `0`). Name the theorem, attribute the proof.

### Layer 4: the Hungerbühler–Wasem generalized residue theorem (HW Theorem 3.3)
- **The headline.** Let `U ⊆ ℂ` be open, `S ⊆ U` finite, `f` holomorphic on `U ∖ S` and
  meromorphic at each point of `S`, and `C` a **null-homologous** piecewise-`C¹` cycle in `U`
  whose singularities may lie **on** `C`. Then
  `PV (2πi)⁻¹ ∮_C f dz = Σ_{s ∈ S} n_s(C)·Res_s f`,
  with the **generalized (non-integer) winding numbers** of Layer 1 as the weights. Subsumes
  the classical residue theorem (Layer 2, poles off `C`, integer weights) and the half-residue
  case (a simple pole on a smooth arc, winding `½`, contributes `πi·Res_s f`).
- **The two regularity conditions** under which the paper-faithful form holds: condition (A′)
  (the cycle approaches each on-cycle singularity transversally / as a finite union of sectors,
  with a prescribed pole order) and condition (B) (the higher-order Laurent parts cancel by the
  sector-cancellation identity). State both explicitly; they are what make the PV exist.
- **Higher-order poles.** The simple-pole case first, then the general meromorphic case via the
  Laurent principal part — HW handle order `> 1` through the sector cancellation under (B).
- **Applications.** The improper integrals (singular integrals, Cauchy principal values along
  the real axis) that the classical residue theorem cannot reach — HW's motivating use — and
  the valence formula's treatment of `i` and `ρ`.

---

## Worked examples (acceptance criteria, keeping the theory honest)

- **Model sector:** a point at a corner of interior angle `α` has winding `α/2π`; a smooth
  crossing (`α = π`) has winding `½` (HW (2.4)).
- `n_c(circle) = 1` for a counterclockwise circle about an interior `c`
  (reconciles with `circleIntegral_sub_center_inv`); `n` is `0` outside.
- **Classical residue theorem** with two simple poles inside a circle returns
  `2πi·(Res₁ + Res₂)`; the one-pole case is the Cauchy integral formula.
- **A simple pole on the contour** contributes the **half-residue** `πi·Res_s f` (winding `½`)
  — the on-cycle acceptance test, and the bridge to the valence formula's `i` and `ρ`.
- **An improper integral** (e.g. a Cauchy principal value along the real axis with a simple
  pole at `0`) evaluated by HW Thm 3.3 where the classical theorem does not apply — HW's
  motivating example.

## Ordering

Layer 0 (the generalized winding number) and Layer 1 (its geometry, HW §2) are the foundation
and come first. Layer 2 (residues + the classical residue theorem) and Layer 3 (the homology
Cauchy theorem, via Dixon's argument) are the classical backbone. Layer 4 (HW Thm 3.3) is the
summit that unifies them and is the layer the valence formula imports; it is also the most
technical, since the principal-value excision estimates and conditions (A′)/(B) live there.

## References

- N. Hungerbühler, M. Wasem, *Non-integer valued winding numbers and a generalized Residue
  Theorem*, arXiv:1808.00997 (2018) — Def 2.1 (the winding number), Prop 2.2 (finite
  crossings), Prop 2.3 (the real formula), Thm 3.3 (the generalized residue theorem).
- P. Henrici, *Applied and Computational Complex Analysis*, Thm 4.8f (the semicircle /
  half-residue precursor).
- S. Lang, *Complex Analysis* (GTM 103), Ch. VI; L. Ahlfors, *Complex Analysis*, Ch. 4 (the
  index of a point, the residue theorem, the homology form).
- J. D. Dixon, *A brief proof of Cauchy's integral theorem*, Proc. AMS 29 (1971), 625–626
  (the Layer-3 argument).

## Acknowledgements

The whole development is **migrated and cleaned** from the AINTLIB `LeanModularForms` project
([github.com/CBirkbeck/AINTLIB](https://github.com/CBirkbeck/AINTLIB)), where the
Hungerbühler–Wasem theorem is formalized `sorry`-free as
`HungerbuhlerWasem.residueTheorem_crossing_paper_faithful_clean` (HW Thm 3.3) on top of the
`GeneralizedResidueTheory` tree (`generalizedResidueTheorem'`, `generalizedResidueTheorem`,
`generalizedResidueTheorem_higher_order`, `HasCauchyPVOn'`, `residueAt`), the winding-number
files, and `HW33`/`HW33Clean`/`HungerbuhlerWasem/{Crossing,MultiCrossingCPV}`. The migration
is the opportunity to state these in Mathlib's vocabulary, drop the fundamental-domain-specific
scaffolding (which stays with the valence formula in the Modular Forms roadmap), and prepare
them for upstreaming. The per-file map is in `Targets.lean`.
