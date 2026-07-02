import Mathlib

/-!
# Conformal mapping and geometric function theory: target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is
`README.md`. The statements here suggest Lean forms for particular milestones, so that
contributors and reviewers converge on names and signatures; discharging all of them
finishes neither a layer nor the roadmap.

The narrative roadmap (layers, proof routes, generality bar, references, downstream uses)
is in `README.md`. Mathlib has the Cauchy foundations — open mapping
(`Complex.AnalyticOnNhd.is_constant_or_isOpenMap`), maximum modulus (`Analysis/Complex/AbsMax`),
the Schwarz lemma (`Analysis/Complex/Schwarz`), Riemann removable singularities, the
rectangle-integral vanishing lemmas, `Complex.UnitDisc`, `conjCLE`/`starRingEnd ℂ`,
`TendstoLocallyUniformlyOn` — but not the geometric superstructure. We build it in
`TauCeti/Analysis/Complex/Conformal/`, with the Riemann mapping theorem as the summit.

A representative milestone from each of the core layers **L0–L4** is stated below with `sorry`
(allowed in this human-owned roadmap library); what lands in `TauCeti/` must be proved with only
the three kernel axioms. The boundary layers **L5 (Carathéodory, Jordan-domain case)** and **L6
(Schwarz–Christoffel)** are described narratively in `README.md` and do not yet carry
representative target signatures here (no Jordan-domain / prime-ends or polygon-map vocabulary in
the pinned Mathlib to state them cleanly against); they will be added as the boundary API takes
shape. The residue/winding/global-Cauchy and argument-principle layer is the sibling
`ContourIntegration` roadmap (PR #35, `TauCeti/Analysis/Contour/`) — **consumed**, not
re-derived here; L0 below adds only the conformal-geometric consequences (Rouché, Hurwitz,
Morera-as-named). The modular/elliptic uniformization that L4/L5 feed lives in the
`ModularForms` roadmap (PR #36), not here.

Conventions (pinned in `README.md`): scalar `ℂ`; domains open + `SimplyConnectedSpace`;
disc `Metric.ball (0:ℂ) 1`; convergence `TendstoLocallyUniformlyOn`; conjugation
`starRingEnd ℂ`; the reflection extension is the explicit witness
`F z = if 0 ≤ z.im then f z else conj (f (conj z))`.
-/

namespace TauCetiRoadmap.ConformalMapping

open Complex Filter Topology

/-- **L0 — Hurwitz.** A locally-uniform limit of nowhere-zero holomorphic functions on a
connected open set is either nowhere zero or identically zero. (Built on the argument
principle / residue theory from the sibling `ContourIntegration` roadmap, PR #35; the
perturbation backbone for RMT injectivity in the limit.) -/
example {Ω : Set ℂ} (hΩ : IsOpen Ω) (hconn : IsConnected Ω) {f : ℕ → ℂ → ℂ} {g : ℂ → ℂ}
    (hf : ∀ n, DifferentiableOn ℂ (f n) Ω) (hg : DifferentiableOn ℂ g Ω)
    (hconv : TendstoLocallyUniformlyOn f g atTop Ω)
    (hne : ∀ n, ∀ z ∈ Ω, f n z ≠ 0) :
    (∀ z ∈ Ω, g z ≠ 0) ∨ (∀ z ∈ Ω, g z = 0) :=
  sorry

/-- **L1 — Montel / normal families.** A sequence of holomorphic functions, uniformly
bounded on every compact subset of an open set, has a subsequence converging locally
uniformly to a holomorphic limit. The compactness engine of RMT. -/
example {Ω : Set ℂ} (hΩ : IsOpen Ω) {f : ℕ → ℂ → ℂ}
    (hf : ∀ n, DifferentiableOn ℂ (f n) Ω)
    (hb : ∀ K ⊆ Ω, IsCompact K → ∃ C, ∀ n, ∀ z ∈ K, ‖f n z‖ ≤ C) :
    ∃ (φ : ℕ → ℕ) (g : ℂ → ℂ), StrictMono φ ∧ DifferentiableOn ℂ g Ω ∧
      TendstoLocallyUniformlyOn (fun n => f (φ n)) g atTop Ω :=
  sorry

/-- **L2 — Schwarz–Pick.** A holomorphic self-map of the unit disc does not increase the
pseudo-hyperbolic distance `|(z−w)/(1−w̄z)|`. (Mathlib's Schwarz lemma is the `w = 0` case.) -/
example {f : ℂ → ℂ} (hf : DifferentiableOn ℂ f (Metric.ball 0 1))
    (hmaps : Set.MapsTo f (Metric.ball 0 1) (Metric.ball 0 1))
    {z w : ℂ} (hz : z ∈ Metric.ball (0 : ℂ) 1) (hw : w ∈ Metric.ball (0 : ℂ) 1) :
    ‖(f z - f w) / (1 - (starRingEnd ℂ) (f w) * f z)‖
      ≤ ‖(z - w) / (1 - (starRingEnd ℂ) w * z)‖ :=
  sorry

/-- **L3 — the Riemann mapping theorem (summit).** Every nonempty, simply connected, open
proper subset of `ℂ` is biholomorphic to the unit disc: there is a holomorphic injection
onto `Metric.ball 0 1` (its inverse is then holomorphic by the open mapping theorem). -/
example {Ω : Set ℂ} (hopen : IsOpen Ω) (hconn : IsConnected Ω)
    (hsc : SimplyConnectedSpace Ω) (hne_univ : Ω ≠ Set.univ) :
    ∃ f : ℂ → ℂ, DifferentiableOn ℂ f Ω ∧ Set.InjOn f Ω ∧ f '' Ω = Metric.ball 0 1 :=
  sorry

/-- **L4.0 — antiholomorphic composition** (reflection prerequisite). If `f` is
`ℂ`-differentiable on `S`, then `z ↦ conj (f (conj z))` is `ℂ`-differentiable on `conj '' S`. -/
example {f : ℂ → ℂ} {S : Set ℂ} (hf : DifferentiableOn ℂ f S) :
    DifferentiableOn ℂ (fun z => (starRingEnd ℂ) (f ((starRingEnd ℂ) z)))
      ((starRingEnd ℂ) '' S) :=
  sorry

/-- **L4 — the Schwarz reflection principle (real axis).** On a conjugation-symmetric open
`Ω`, a function continuous on the closed upper part, holomorphic on the open upper part, and
real on `Ω ∩ ℝ`, extends holomorphically to all of `Ω` (via the witness
`F z = if 0 ≤ z.im then f z else conj (f (conj z))`) with the reflection symmetry. The layer
the SW modular-`λ` covering consumes. -/
example {Ω : Set ℂ} (hΩ : IsOpen Ω) (hsymm : ∀ z, z ∈ Ω ↔ (starRingEnd ℂ) z ∈ Ω)
    {f : ℂ → ℂ}
    (hcont : ContinuousOn f (Ω ∩ {z | 0 ≤ z.im}))
    (hholo : DifferentiableOn ℂ f (Ω ∩ {z | 0 < z.im}))
    (hreal : ∀ z ∈ Ω, z.im = 0 → (f z).im = 0) :
    ∃ F : ℂ → ℂ,
      DifferentiableOn ℂ F Ω ∧
      Set.EqOn F f (Ω ∩ {z | 0 ≤ z.im}) ∧
      ∀ z ∈ Ω, F ((starRingEnd ℂ) z) = (starRingEnd ℂ) (F z) :=
  sorry

end TauCetiRoadmap.ConformalMapping
