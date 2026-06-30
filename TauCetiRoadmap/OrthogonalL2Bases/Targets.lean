/-
Copyright (c) 2026 The Tau Ceti contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Targets — weighted orthogonal L² bases (`OrthogonalL2Bases`)

Representative `sorry`-milestones for the `OrthogonalL2Bases` roadmap (full narrative and the
complete API in `README.md`). These state the **weight↔measure-isometry enhancement** — the small
addition that gives every family's basis in *both* normalizations — on top of the existing layers:
the new primitive `weightL2Isometry : L²(w·μ) ≃ₗᵢ L²(μ)` and its `HilbertBasis` transport `mapₗᵢ`
(Part 0); the orthogonality relation (A1, Gaussian-measure form); the bridge producing the
weighted-measure basis with the `L²(μ)` √w-envelope basis as its `mapₗᵢ`-image (B2); the named
Gaussian-Hermite instance (A3); and the product / `pi` bases (B3). The Hermite-function object API
(A2), the function-side `hermiteHilbertBasis`, the completeness toolkit (B1), and the Chebyshev
instance (Part C) are stated in full in `README.md`; this file seeds the representative core.

Conventions folded in from review (a roadmap reviewer + Codex/GPT-5.4): `μ : Measure ℝ` (the bridge
evaluates `Polynomial.eval`); `weightL2Isometry` needs only `0 < w` a.e. (no finiteness — the
`ENNReal.ofReal` density is finite); `mapₗᵢ` body `ofRepr (e.symm.trans b.repr)` (Mathlib has no
`≃ₗᵢ`-transport); ℕ-smul Hermite derivative; `ℤ[X]` Hermite mapped to `ℝ[X]` via `hermiteℝ`; every
basis ships a `coe_*` / `*_apply` anti-vacuity pin. Elaborates against the pinned toolchain
(sorry-warnings only).
-/

namespace TauCetiRoadmap.OrthogonalL2Bases

open MeasureTheory ProbabilityTheory Polynomial Real
open scoped NNReal ENNReal

/-! ## Part 0 — weight ↔ measure isometry + basis transport (the unifying primitives) -/

variable {𝕜 : Type*} [RCLike 𝕜]

/-- **Weight ↔ measure isometry.** For an a.e.-positive weight `w` on *any* measurable space,
multiplication by `√w` is a linear isometric equivalence `L²(w·μ) ≃ₗᵢ L²(μ)`
(`w·μ := μ.withDensity (ofReal ∘ w)`); an *equivalence* precisely because `w > 0` a.e. (`hwpos`
load-bearing). Purely measure-theoretic, so stated over an arbitrary `MeasurableSpace` (only the
polynomial bridge below needs `Measure ℝ`); a genuine Mathlib gap and an upstream candidate. The
single primitive converting weight-in-measure ↔ weight-in-function; transports any Hilbert basis
across (`mapₗᵢ`). -/
noncomputable def weightL2Isometry {α : Type*} [MeasurableSpace α] (μ : Measure α) (w : α → ℝ)
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) :
    Lp 𝕜 2 (μ.withDensity (fun x => ENNReal.ofReal (w x))) ≃ₗᵢ[𝕜] Lp 𝕜 2 μ := sorry

/-- Element-level characterization (anti-vacuity): the isometry is multiplication by `√w`. -/
theorem weightL2Isometry_apply {α : Type*} [MeasurableSpace α] (μ : Measure α) (w : α → ℝ)
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ)
    (f : Lp 𝕜 2 (μ.withDensity (fun x => ENNReal.ofReal (w x)))) :
    weightL2Isometry (𝕜 := 𝕜) μ w hwpos hwm f =ᵐ[μ] fun x => Real.sqrt (w x) • f x := sorry

/-- Inverse direction (multiplication by `(√w)⁻¹`), closing the both-normalizations loop. -/
theorem weightL2Isometry_symm_apply {α : Type*} [MeasurableSpace α] (μ : Measure α) (w : α → ℝ)
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (g : Lp 𝕜 2 μ) :
    (weightL2Isometry (𝕜 := 𝕜) μ w hwpos hwm).symm g
      =ᵐ[μ] fun x => (Real.sqrt (w x))⁻¹ • g x := sorry

/-- Transport a Hilbert basis along a linear isometric equivalence. Mathlib has `ofRepr` but no
`≃ₗᵢ`-transport, so this is a needed (one-line) target. -/
noncomputable def _root_.HilbertBasis.mapₗᵢ {ι : Type*} {E F : Type*}
    [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    [NormedAddCommGroup F] [InnerProductSpace 𝕜 F]
    (b : HilbertBasis ι 𝕜 E) (e : E ≃ₗᵢ[𝕜] F) : HilbertBasis ι 𝕜 F :=
  HilbertBasis.ofRepr (e.symm.trans b.repr)

@[simp] theorem _root_.HilbertBasis.mapₗᵢ_apply {ι : Type*} {E F : Type*}
    [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    [NormedAddCommGroup F] [InnerProductSpace 𝕜 F]
    (b : HilbertBasis ι 𝕜 E) (e : E ≃ₗᵢ[𝕜] F) (i : ι) :
    (b.mapₗᵢ e) i = e (b i) := sorry

/-! ## Part A1 — Hermite polynomial API (the analytic input; `hermite n : ℤ[X]`) -/

theorem derivative_hermite_succ (n : ℕ) :
    derivative (hermite (n + 1)) = (n + 1) • hermite n := sorry

theorem integrable_aeval_mul_gaussian (p : ℤ[X]) :
    Integrable (fun x : ℝ => aeval x p * Real.exp (-(x ^ 2 / 2))) := sorry

theorem hermite_generating_function (x t : ℝ) :
    ∑' n : ℕ, aeval x (hermite n) * t ^ n / (n.factorial : ℝ) = Real.exp (x * t - t ^ 2 / 2) := sorry

/-- **The orthogonality relation, Gaussian-measure form** — the analytic fact the Gaussian basis
needs, stated directly against `N(0,1)` (the Lebesgue `∫ Hₘ Hₙ e^{-x²/2} dx = n!√(2π)` form is this
times `√(2π)`). -/
theorem integral_hermite_mul_hermite_gaussianReal (m n : ℕ) :
    (∫ x, aeval x (hermite m) * aeval x (hermite n) ∂(gaussianReal 0 1))
      = if m = n then (n.factorial : ℝ) else 0 := sorry

/-! ## Part B1 — Completeness toolkit (moment determinacy; supplies `hcomplete`) -/

theorem ae_eq_zero_of_forall_moment_eq_zero (g : ℝ → ℝ)
    (hexp : ∀ a : ℝ, 0 ≤ a → Integrable (fun x : ℝ => Real.exp (a * |x|) * g x) volume)
    (hmom : ∀ n : ℕ, ∫ x : ℝ, x ^ n * g x = 0) :
    g =ᵐ[volume] 0 := sorry

/-- **B1, measure level** — the determinacy result the *weighted-measure* bridge actually needs
(`ae_eq_zero_of_forall_moment_eq_zero` above is the `volume`/function instance; `barePolyLp_ortho_eq_bot`
is for an arbitrary `μ`, so it must rest on a measure-level statement). A finite measure `ν` on `ℝ`
with every exponential moment finite is moment-determinate, so a `g ∈ L²(ν)` orthogonal to every
monomial is a.e. `0`. Finiteness is **not** a separate hypothesis: it is the `a = 0` case of `hexp`
(`Integrable (fun _ => 1) ν`, i.e. `IsFiniteMeasure ν`), derived inside the proof — so the caller
`barePolyLp_ortho_eq_bot`, which has only `hexp` for `ν = w·μ`, can apply this directly with no leap. -/
theorem ae_eq_zero_of_forall_moment_eq_zero_of_finite_expMoments
    {ν : Measure ℝ}
    (hexp : ∀ a : ℝ, 0 ≤ a → Integrable (fun x : ℝ => Real.exp (a * |x|)) ν)
    {g : ℝ → 𝕜} (hg : MemLp g 2 ν)
    (hmom : ∀ n : ℕ, ∫ x, (algebraMap ℝ 𝕜 x) ^ n * g x ∂ν = 0) :
    g =ᵐ[ν] 0 := sorry

/-! ## Part B2 — orthogonality relation → Hilbert basis (re-keyed: weight in the MEASURE) -/

section WeightedBridge
variable (p : ℕ → Polynomial ℝ) (w : ℝ → ℝ) (c : ℕ → ℝ)

/-- The bare normalized polynomial `pₙ/√cₙ` as an element of `L²(w·μ; 𝕜)` (scalar-cast). -/
noncomputable def barePolyLp {μ : Measure ℝ}
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x)))) (n : ℕ) :
    Lp 𝕜 2 (μ.withDensity (fun x => ENNReal.ofReal (w x))) :=
  (hmem n).toLp _

/-- **Orthonormality from the orthogonality relation** `∫ pₘ pₙ w ∂μ = cₙ δ`. `hwm` is needed to
rewrite the `∫ … w ∂μ` (Lebesgue-side) relation into the inner product over `μ.withDensity w`. -/
theorem orthonormal_barePolyLp {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (horth : ∀ m n, (∫ x, (p m).eval x * (p n).eval x * w x ∂μ) = if m = n then c n else 0)
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x)))) :
    Orthonormal 𝕜 (barePolyLp (𝕜 := 𝕜) p w c hmem) := sorry

/-- **Completeness target** — grounded in moment determinacy
(`ae_eq_zero_of_forall_moment_eq_zero_of_finite_expMoments`, B1 measure level, applied to `ν = w·μ`):
the load-bearing hypothesis is `hexp`, that the weighted measure `w·μ` has every exponential moment
finite (true for Gaussian decay, automatic for compact support), so polynomials are dense in
`L²(w·μ)`. Degree alone does **not** give completeness for an arbitrary `μ, w` — `hexp` is what makes
it grounded. Note `hdeg` uses `degree` (not `natDegree`): `natDegree 0 = 0` would let `p 0 = 0` slip
through and kill the basis (e.g. `μ = δ₀`), so we require the genuine degree, forcing `p n ≠ 0`.
Produces the `ᗮ = ⊥` input the assembler consumes. -/
theorem barePolyLp_ortho_eq_bot {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (hdeg : ∀ n, (p n).degree = (n : WithBot ℕ))
    (hexp : ∀ a : ℝ, 0 ≤ a →
      Integrable (fun x : ℝ => Real.exp (a * |x|)) (μ.withDensity (fun x => ENNReal.ofReal (w x))))
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x)))) :
    (Submodule.span 𝕜 (Set.range (barePolyLp (𝕜 := 𝕜) p w c hmem)))ᗮ = ⊥ := sorry

/-- **PRIMITIVE (weight in the measure).** The normalized bare polynomials are a Hilbert basis of the
weighted measure `L²(w·μ)` — the textbook statement and the consumer's object. (`hdeg` is *not* a
parameter here: completeness `hcomplete` is the input; degree is used only to produce it, in
`barePolyLp_ortho_eq_bot`.) -/
noncomputable def hilbertBasisOfWeightedMeasure {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (horth : ∀ m n, (∫ x, (p m).eval x * (p n).eval x * w x ∂μ) = if m = n then c n else 0)
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x))))
    (hcomplete : (Submodule.span 𝕜 (Set.range (barePolyLp (𝕜 := 𝕜) p w c hmem)))ᗮ = ⊥) :
    HilbertBasis ℕ 𝕜 (Lp 𝕜 2 (μ.withDensity (fun x => ENNReal.ofReal (w x)))) :=
  HilbertBasis.mkOfOrthogonalEqBot (orthonormal_barePolyLp p w c hwpos hwm hc horth hmem) hcomplete

/-- **DERIVED (weight in the function).** The original Part-A headline — the `pₙ·√w`-type basis of
`L²(μ)` — is now the `weightL2Isometry`-image of the weighted-measure basis. One line, no separate
proof. -/
noncomputable def hilbertBasisOfOrthogonalSystem {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (horth : ∀ m n, (∫ x, (p m).eval x * (p n).eval x * w x ∂μ) = if m = n then c n else 0)
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x))))
    (hcomplete : (Submodule.span 𝕜 (Set.range (barePolyLp (𝕜 := 𝕜) p w c hmem)))ᗮ = ⊥) :
    HilbertBasis ℕ 𝕜 (Lp 𝕜 2 μ) :=
  (hilbertBasisOfWeightedMeasure p w c hwpos hwm hc horth hmem hcomplete).mapₗᵢ
    (weightL2Isometry μ w hwpos hwm)

/-- Element-level pin for the weighted-measure basis (immediate from `coe_mkOfOrthogonalEqBot`). -/
theorem coe_hilbertBasisOfWeightedMeasure {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (horth : ∀ m n, (∫ x, (p m).eval x * (p n).eval x * w x ∂μ) = if m = n then c n else 0)
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x))))
    (hcomplete : (Submodule.span 𝕜 (Set.range (barePolyLp (𝕜 := 𝕜) p w c hmem)))ᗮ = ⊥) :
    ⇑(hilbertBasisOfWeightedMeasure p w c hwpos hwm hc horth hmem hcomplete)
      = barePolyLp (𝕜 := 𝕜) p w c hmem := sorry

/-- Element-level pin for the derived function-side basis: the `weightL2Isometry` image of the
weighted-measure basis (from `mapₗᵢ_apply` + `coe_hilbertBasisOfWeightedMeasure`). -/
theorem coe_hilbertBasisOfOrthogonalSystem {μ : Measure ℝ}
    (hwpos : ∀ᵐ x ∂μ, 0 < w x) (hwm : AEMeasurable w μ) (hc : ∀ n, 0 < c n)
    (horth : ∀ m n, (∫ x, (p m).eval x * (p n).eval x * w x ∂μ) = if m = n then c n else 0)
    (hmem : ∀ n, MemLp (fun x => (algebraMap ℝ 𝕜) ((p n).eval x / Real.sqrt (c n))) 2
      (μ.withDensity (fun x => ENNReal.ofReal (w x))))
    (hcomplete : (Submodule.span 𝕜 (Set.range (barePolyLp (𝕜 := 𝕜) p w c hmem)))ᗮ = ⊥) (n : ℕ) :
    hilbertBasisOfOrthogonalSystem p w c hwpos hwm hc horth hmem hcomplete n
      = weightL2Isometry μ w hwpos hwm (barePolyLp (𝕜 := 𝕜) p w c hmem n) := sorry

end WeightedBridge

/-! ## Part A3 — the Gaussian Hermite basis (the named target the consumer imports) -/

/-- `Hₙ` over `ℝ` (Mathlib's `hermite n` is `ℤ[X]`; map to `ℝ[X]`). -/
noncomputable def hermiteℝ (n : ℕ) : Polynomial ℝ := (hermite n).map (Int.castRingHom ℝ)

/-- **Gaussian Hermite ONB of `L²(N(0,1); 𝕜)`** — the bare normalized probabilists' Hermite
polynomials `Hₙ/√(n!)`, the standard ONB any `L²(N(0,1))` expansion is taken against. The immediate
instance of `hilbertBasisOfWeightedMeasure` (`μ = volume`, `w = gaussianPDFReal 0 1`, `p = hermiteℝ`,
`cₙ = n!`), since `gaussianReal 0 1 = volume.withDensity (gaussianPDF 0 1)`
(`gaussianReal_of_var_ne_zero`). -/
noncomputable def gaussianHermiteHilbertBasis :
    HilbertBasis ℕ 𝕜 (Lp 𝕜 2 (gaussianReal 0 1)) := sorry

/-- The Gaussian Hermite basis is the explicit `Hₙ/√(n!)` family (the anti-vacuity pin downstream
needs to compute chaos coordinates). -/
theorem coe_gaussianHermiteHilbertBasis (n : ℕ) :
    ⇑(gaussianHermiteHilbertBasis (𝕜 := 𝕜) n) =ᵐ[gaussianReal 0 1]
      fun x => (algebraMap ℝ 𝕜) (aeval x (hermite n) / Real.sqrt (n.factorial)) := sorry

/-- Variance-general `L²` membership (scalar-cast), for the Wick variables `Hₙ(W h)`. -/
theorem memLp_hermite_gaussianReal (n : ℕ) (v : ℝ≥0) :
    MemLp (fun x => (algebraMap ℝ 𝕜) (aeval x (hermite n) / Real.sqrt (n.factorial))) 2
      (gaussianReal 0 v) := sorry

/-! ## Part B3 — product / pi bases + the Gaussian multi-d instance -/

section Product
variable {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
  {μ : Measure α} {ν : Measure β} [SigmaFinite μ] [SigmaFinite ν]

/-- **Product basis** — Hilbert basis of `L²(μ ⊗ ν)` from factor bases (real Mathlib gap; the
finite-dim `OrthonormalBasis.tensorProduct` only). -/
noncomputable def prodHilbertBasis {ι₁ ι₂ : Type*}
    (b₁ : HilbertBasis ι₁ 𝕜 (Lp 𝕜 2 μ)) (b₂ : HilbertBasis ι₂ 𝕜 (Lp 𝕜 2 ν)) :
    HilbertBasis (ι₁ × ι₂) 𝕜 (Lp 𝕜 2 (μ.prod ν)) := sorry

/-- **Characterization** (anti-vacuity): the `(i,j)` vector is a.e. the product `b₁ i ⊗ b₂ j`. -/
theorem prodHilbertBasis_apply {ι₁ ι₂ : Type*}
    (b₁ : HilbertBasis ι₁ 𝕜 (Lp 𝕜 2 μ)) (b₂ : HilbertBasis ι₂ 𝕜 (Lp 𝕜 2 ν)) (i : ι₁) (j : ι₂) :
    ⇑(prodHilbertBasis b₁ b₂ (i, j)) =ᵐ[μ.prod ν] fun q => (b₁ i) q.1 * (b₂ j) q.2 := sorry

end Product

noncomputable def piHilbertBasis
    {ι : Type*} [Fintype ι] {α : ι → Type*} [∀ i, MeasurableSpace (α i)]
    {μ : ∀ i, Measure (α i)} [∀ i, SigmaFinite (μ i)] {κ : ι → Type*}
    (b : ∀ i, HilbertBasis (κ i) 𝕜 (Lp 𝕜 2 (μ i))) :
    HilbertBasis (∀ i, κ i) 𝕜 (Lp 𝕜 2 (Measure.pi μ)) := sorry

/-- **Multi-d Gaussian Hermite basis** of `L²(γⁿ)` — `piHilbertBasis` over the 1-D Gaussian basis;
the multi-index Hermite basis `Ψ_α = ∏ᵢ Hₐᵢ`, the standard basis for multivariate Gaussian L² /
chaos expansions. -/
noncomputable def gaussianHermitePiBasis (ι : Type*) [Fintype ι] :
    HilbertBasis (ι → ℕ) 𝕜 (Lp 𝕜 2 (Measure.pi (fun _ : ι => gaussianReal 0 1))) :=
  piHilbertBasis (fun _ => gaussianHermiteHilbertBasis)

/-- Characterization of the multi-d basis (anti-vacuity): `Ψ_α(x) = ∏ᵢ Hₐᵢ(xᵢ)/√(αᵢ!)`. -/
theorem coe_gaussianHermitePiBasis (ι : Type*) [Fintype ι] (a : ι → ℕ) :
    ⇑(gaussianHermitePiBasis (𝕜 := 𝕜) ι a)
      =ᵐ[Measure.pi (fun _ : ι => gaussianReal 0 1)]
        fun x => ∏ i, (algebraMap ℝ 𝕜) (aeval (x i) (hermite (a i)) / Real.sqrt ((a i).factorial)) :=
  sorry

end TauCetiRoadmap.OrthogonalL2Bases
