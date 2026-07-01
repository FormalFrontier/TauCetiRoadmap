import Mathlib

/-!
# Variation of Hodge structure (general): proposed definitions + target signatures

The narrative roadmap (layers, generality bar, the structural-vs-geometric boundary, references,
sibling relations) is in `README.md`. **Mathlib has no Hodge structures**, so the chief
deliverable of this entry is getting the *definitions* right (the `JacobianChallenge`
philosophy); below are proposed core definitions and a milestone `sorry` for each layer with a
self-contained target (L0, L1, L2, L3, L5; L4 is a schematic structure seed — see `README.md`). The
deep geometric/analytic engines (Kähler Hodge decomposition, Gauss-Manin of general families,
Schmid's asymptotics) are **out of scope** -- this is the weight-general *structural* theory;
instances come from elsewhere (the weight-1 / curve case is the worked model).

NOTE: elaborates green against `TauCetiRoadmap`'s pinned Mathlib (leanprover/lean4:v4.31.0-rc1); the
milestone `example`s carry `sorry`, every definition is complete.
-/

namespace TauCetiRoadmap.VHS

open Complex

/-- The complexification of the integral lattice `V`. Mathlib supplies the `ℂ`-module structure
when the scalar algebra is the left tensor factor, so this is the canonical orientation
`ℂ ⊗[ℤ] V`, equivalent to the usual notation `V_ℤ ⊗[ℤ] ℂ` by `TensorProduct.comm`. -/
abbrev Complexification (V : Type*) [AddCommGroup V] [Module ℤ V] : Type _ :=
  TensorProduct ℤ ℂ V

/-- The rational vector space attached to the integral lattice `V`. -/
abbrev Rationalification (V : Type*) [AddCommGroup V] [Module ℤ V] : Type _ :=
  TensorProduct ℤ ℚ V

variable {V : Type*} [AddCommGroup V] [Module ℤ V]

/-- The underlying `ℤ`-linear tensor map for lattice-induced complex conjugation on
`V_ℂ = ℂ ⊗[ℤ] V`, acting by complex conjugation on the scalar tensor factor and by the
identity on the lattice. -/
def latticeConjIntLinear : Complexification V →ₗ[ℤ] Complexification V :=
  TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toIntLinearMap (LinearMap.id : V →ₗ[ℤ] V)

/-- Lattice-induced complex conjugation on `V_ℂ = ℂ ⊗[ℤ] V`. On pure tensors it is
`z ⊗ v ↦ (starRingEnd ℂ z) ⊗ v`; under `TensorProduct.comm` this is the usual
`v ⊗ z ↦ v ⊗ (starRingEnd ℂ z)`. -/
def latticeConj : Complexification V →ₛₗ[starRingEnd ℂ] Complexification V where
  toFun := latticeConjIntLinear
  map_add' := latticeConjIntLinear.map_add
  map_smul' c x := by
    change latticeConjIntLinear (c • x) = (starRingEnd ℂ) c • latticeConjIntLinear x
    refine TensorProduct.induction_on x ?hz ?ht ?ha
    · simp
    · intro z v
      change (TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toIntLinearMap
          (LinearMap.id : V →ₗ[ℤ] V)) (c • (z ⊗ₜ[ℤ] v : Complexification V)) =
        (starRingEnd ℂ) c •
          (TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toIntLinearMap
            (LinearMap.id : V →ₗ[ℤ] V)) (z ⊗ₜ[ℤ] v)
      rw [TensorProduct.smul_tmul']
      rw [TensorProduct.map_tmul]
      rw [TensorProduct.map_tmul]
      simp only [LinearMap.id_coe, id_eq]
      rw [Algebra.smul_def]
      change (starRingEnd ℂ) (c * z) ⊗ₜ[ℤ] v =
        (starRingEnd ℂ) c • ((starRingEnd ℂ) z ⊗ₜ[ℤ] v : Complexification V)
      rw [map_mul]
      rw [TensorProduct.smul_tmul']
      rw [Algebra.smul_def]
      simp
    · intro x y hx hy
      calc
        latticeConjIntLinear (c • (x + y)) = latticeConjIntLinear (c • x + c • y) := by
          rw [smul_add]
        _ = latticeConjIntLinear (c • x) + latticeConjIntLinear (c • y) := by
          rw [map_add]
        _ = (starRingEnd ℂ) c • latticeConjIntLinear x +
            (starRingEnd ℂ) c • latticeConjIntLinear y := by
          rw [hx, hy]
        _ = (starRingEnd ℂ) c • (latticeConjIntLinear x + latticeConjIntLinear y) := by
          rw [smul_add]
        _ = (starRingEnd ℂ) c • latticeConjIntLinear (x + y) := by
          rw [map_add]

@[simp]
theorem latticeConj_tmul (z : ℂ) (v : V) :
    latticeConj (V := V) (z ⊗ₜ[ℤ] v) = (starRingEnd ℂ z) ⊗ₜ[ℤ] v :=
  rfl

theorem latticeConj_involutive : Function.Involutive (latticeConj (V := V)) := by
  intro x
  change latticeConjIntLinear (latticeConjIntLinear x) = x
  refine TensorProduct.induction_on x ?hz ?ht ?ha
  · simp [latticeConjIntLinear]
  · intro z v
    change (TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toIntLinearMap
        (LinearMap.id : V →ₗ[ℤ] V))
        ((TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toIntLinearMap
          (LinearMap.id : V →ₗ[ℤ] V)) (z ⊗ₜ[ℤ] v)) = z ⊗ₜ[ℤ] v
    rw [TensorProduct.map_tmul]
    simp only [LinearMap.id_coe, id_eq]
    rw [TensorProduct.map_tmul]
    simp
  · intro x y hx hy
    calc
      latticeConjIntLinear (latticeConjIntLinear (x + y)) =
          latticeConjIntLinear (latticeConjIntLinear x + latticeConjIntLinear y) := by
        rw [map_add]
      _ = latticeConjIntLinear (latticeConjIntLinear x) +
          latticeConjIntLinear (latticeConjIntLinear y) := by
        rw [map_add]
      _ = x + y := by
        rw [hx, hy]

variable [Module.Free ℤ V] [Module.Finite ℤ V]

/-- **L0 -- pure Hodge structure of weight `n`.** The primary datum is a finitely generated
free integral lattice `V = V_ℤ`; the complex vector space is the complexification
`V_ℂ = ℂ ⊗[ℤ] V`, and its conjugation is the canonical lattice-induced map `latticeConj`,
not a user-supplied field. The remaining datum is an `n`-opposed decreasing Hodge filtration
`F^•` on `V_ℂ`:
`F^p ⊕ conj(F^{n+1-p}) = V_ℂ`. -/
structure HodgeStructure (V : Type*) [AddCommGroup V] [Module ℤ V] [Module.Free ℤ V]
    [Module.Finite ℤ V] (n : ℤ) where
  F : ℤ → Submodule ℂ (Complexification V)
  F_antitone : Antitone F
  /-- The filtration is **bounded** (exhaustive + separated): `F^p = ⊤` for `p ≪ 0`, `⊥` for
  `p ≫ 0`. Without this, `opposed` alone admits degenerate `F` with vanishing `(p,q)`-pieces. -/
  F_top : ∃ p, F p = ⊤
  F_bot : ∃ p, F p = ⊥
  opposed : ∀ p, IsCompl (F p) ((F (n + 1 - p)).map (latticeConj (V := V)))

/-- The `(p,q)`-piece `H^{p,q} = F^p ∩ conj(F^q)` with `q = n - p`. -/
def HodgeStructure.piece {n : ℤ} (hs : HodgeStructure V n) (p : ℤ) :
    Submodule ℂ (Complexification V) :=
  hs.F p ⊓ (hs.F (n - p)).map (latticeConj (V := V))

/-- **L0 milestone -- the Hodge decomposition.** The `(p,q)`-pieces give an **internal direct sum**
`V_ℂ = ⨁_p H^{p,q}` (independence + spanning) -- the structural content of `n`-opposedness + the
bounded filtration. -/
example {n : ℤ} (hs : HodgeStructure V n) : DirectSum.IsInternal hs.piece := sorry

/-- **L1 -- polarization.** The primary datum is an integral bilinear form `Qint` on the
lattice. Its complex-bilinear form on `V_ℂ` is obtained by Mathlib's bilinear-form base
change, so values on pure lattice tensors are forced by the extension-of-scalars API. It
satisfies the Hodge-Riemann relations: orthogonality `Q(F^p, F^{n-p+1}) = 0` and positivity
`i^{p-q} Q(v, conj v) > 0` on `H^{p,q}`. -/
structure Polarization {n : ℤ} (hs : HodgeStructure V n) where
  Qint : LinearMap.BilinForm ℤ V
  symm : ∀ v w, Qint v w = (-1 : ℤ) ^ n.natAbs * Qint w v
  nondegenerate : (Qint.baseChange ℂ).Nondegenerate
  orthogonal : ∀ p, ∀ v ∈ hs.F p, ∀ w ∈ hs.F (n - p + 1),
    (Qint.baseChange ℂ).IsOrtho v w
  /-- Hodge-Riemann positivity: `i^{p-q} Q(v, conj v)` (`p-q = 2p-n`) is **real** and `> 0` on
  nonzero `v ∈ H^{p,q}` -- a positive-definite Hermitian form on each piece. -/
  pos : ∀ p, ∀ v ∈ hs.piece p, v ≠ 0 →
    (Complex.I ^ (2 * p - n) * (Qint.baseChange ℂ) v (latticeConj (V := V) v)).im = 0 ∧
      0 < (Complex.I ^ (2 * p - n) *
        (Qint.baseChange ℂ) v (latticeConj (V := V) v)).re

/-- The complex polarization form obtained from the integral form by extension of scalars. -/
def Polarization.Q {n : ℤ} {hs : HodgeStructure V n} (pol : Polarization hs) :
    LinearMap.BilinForm ℂ (Complexification V) :=
  pol.Qint.baseChange ℂ

@[simp]
theorem Polarization.Q_tmul {n : ℤ} {hs : HodgeStructure V n} (pol : Polarization hs)
    (v w : V) : pol.Q (1 ⊗ₜ[ℤ] v) (1 ⊗ₜ[ℤ] w) = (pol.Qint v w : ℂ) := by
  simp [Polarization.Q]

/-- The canonical tower isomorphism
`ℂ ⊗[ℚ] (ℚ ⊗[ℤ] V) ≃ₗ[ℂ] ℂ ⊗[ℤ] V`, used to view a rational subspace of
`V_ℚ` as a complex subspace of `V_ℂ`. -/
noncomputable def rationalToComplexLinearEquiv :
    TensorProduct ℚ ℂ (Rationalification V) ≃ₗ[ℂ] Complexification V :=
  TensorProduct.AlgebraTensorModule.cancelBaseChange ℤ ℚ ℂ ℂ V

/-- The complexification of a rational subspace of `V_ℚ`, realized inside `V_ℂ` by first
applying `Submodule.baseChange` and then cancelling the middle `ℚ`-base change. -/
noncomputable def rationalToComplexSubmodule (W : Submodule ℚ (Rationalification V)) :
    Submodule ℂ (Complexification V) :=
  (W.baseChange ℂ).map (rationalToComplexLinearEquiv (V := V)).toLinearMap

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Rational vectors embedded in `V_ℂ` are fixed by lattice conjugation. -/
theorem rationalToComplexLinearEquiv_one_tmul_fixed (x : Rationalification V) :
    latticeConj (V := V) (rationalToComplexLinearEquiv (V := V) (1 ⊗ₜ[ℚ] x)) =
      rationalToComplexLinearEquiv (V := V) (1 ⊗ₜ[ℚ] x) := by
  refine TensorProduct.induction_on x ?hz ?ht ?ha
  · simp
  · intro q v
    simp [rationalToComplexLinearEquiv, TensorProduct.AlgebraTensorModule.cancelBaseChange_tmul]
  · intro x y hx hy
    simp [TensorProduct.tmul_add, hx, hy]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Complexification of rational subspaces is monotone. -/
theorem rationalToComplexSubmodule_mono :
    Monotone (rationalToComplexSubmodule (V := V)) := by
  intro W W' hWW'
  exact Submodule.map_mono (Submodule.baseChange_mono ℂ hWW')

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The complexification of a rational subspace is stable under lattice conjugation. -/
theorem rationalToComplexSubmodule_conj (W : Submodule ℚ (Rationalification V)) :
    (rationalToComplexSubmodule W).map (latticeConj (V := V)) = rationalToComplexSubmodule W := by
  let gen : Set (Complexification V) :=
    rationalToComplexLinearEquiv (V := V) ''
      ((fun x : Rationalification V => 1 ⊗ₜ[ℚ] x) '' (W : Set (Rationalification V)))
  have hspan : rationalToComplexSubmodule W = Submodule.span ℂ gen := by
    rw [rationalToComplexSubmodule, Submodule.baseChange_eq_span, Submodule.map_span]
    rfl
  have hgen_fixed : ∀ x ∈ gen, latticeConj (V := V) x = x := by
    intro x hx
    rcases hx with ⟨_y, ⟨w, _hw, rfl⟩, rfl⟩
    exact rationalToComplexLinearEquiv_one_tmul_fixed (V := V) w
  have hclosed : ∀ x ∈ rationalToComplexSubmodule W,
      latticeConj (V := V) x ∈ rationalToComplexSubmodule W := by
    intro x hx
    rw [hspan] at hx ⊢
    exact Submodule.span_induction
      (p := fun x _ => latticeConj (V := V) x ∈ Submodule.span ℂ gen)
      (fun y hy => by simpa [hgen_fixed y hy] using Submodule.subset_span hy)
      (by simp)
      (fun _x _y _hx _hy hx hy => by simpa using Submodule.add_mem _ hx hy)
      (fun a _x _hx hx => by
        simpa using Submodule.smul_mem (Submodule.span ℂ gen) ((starRingEnd ℂ) a) hx)
      hx
  apply le_antisymm
  · intro x hx
    rcases hx with ⟨y, hy, rfl⟩
    exact hclosed y hy
  · intro x hx
    refine ⟨latticeConj (V := V) x, hclosed x hx, ?_⟩
    exact latticeConj_involutive (V := V) x

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Lattice conjugation on `V_ℂ` matches rational conjugation before cancelling the
intermediate `ℚ`-base change. -/
theorem rationalToComplexLinearEquiv_conj_tmul (z : ℂ) (x : Rationalification V) :
    latticeConj (V := V) (rationalToComplexLinearEquiv (V := V) (z ⊗ₜ[ℚ] x)) =
      rationalToComplexLinearEquiv (V := V) ((starRingEnd ℂ z) ⊗ₜ[ℚ] x) := by
  refine TensorProduct.induction_on x ?hz ?ht ?ha
  · simp
  · intro q v
    simp [rationalToComplexLinearEquiv, TensorProduct.AlgebraTensorModule.cancelBaseChange_tmul,
      Algebra.smul_def]
  · intro x y hx hy
    simp [TensorProduct.tmul_add, map_add, hx, hy]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The complexification of a rational linear map, transported from
`ℂ ⊗[ℚ] V_ℚ` to `V_ℂ` by the tower cancellation equivalence. -/
noncomputable def rationalMapToComplex {V' : Type*} [AddCommGroup V'] [Module ℤ V']
    (f : Rationalification V →ₗ[ℚ] Rationalification V') :
    Complexification V →ₗ[ℂ] Complexification V' :=
  (rationalToComplexLinearEquiv (V := V')).toLinearMap ∘ₗ
    f.baseChange ℂ ∘ₗ
      (rationalToComplexLinearEquiv (V := V)).symm.toLinearMap

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- On pure lattice tensors, `rationalMapToComplex` is the scalar extension of the
underlying rational map. -/
@[simp]
theorem rationalMapToComplex_tmul {V' : Type*} [AddCommGroup V'] [Module ℤ V']
    (f : Rationalification V →ₗ[ℚ] Rationalification V') (z : ℂ) (v : V) :
    rationalMapToComplex (V := V) f (z ⊗ₜ[ℤ] v) =
      rationalToComplexLinearEquiv (V := V') (z ⊗ₜ[ℚ] f (1 ⊗ₜ[ℤ] v)) := by
  simp [rationalMapToComplex, rationalToComplexLinearEquiv]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The complexification of a rational map commutes with lattice-induced conjugation. -/
theorem rationalMapToComplex_conj {V' : Type*} [AddCommGroup V'] [Module ℤ V']
    (f : Rationalification V →ₗ[ℚ] Rationalification V') (x : Complexification V) :
    rationalMapToComplex (V := V) f (latticeConj (V := V) x) =
      latticeConj (V := V') (rationalMapToComplex (V := V) f x) := by
  refine TensorProduct.induction_on x ?hz ?ht ?ha
  · simp
  · intro z v
    rw [latticeConj_tmul]
    rw [rationalMapToComplex_tmul, rationalMapToComplex_tmul]
    rw [rationalToComplexLinearEquiv_conj_tmul]
  · intro x y hx hy
    simp [map_add, hx, hy]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- A rational map carrying one rational weight step into another carries the associated
complexified subspace into the associated complexified subspace. -/
theorem rationalMapToComplex_maps_WC {V' : Type*} [AddCommGroup V'] [Module ℤ V']
    (f : Rationalification V →ₗ[ℚ] Rationalification V')
    {W : Submodule ℚ (Rationalification V)}
    {W' : Submodule ℚ (Rationalification V')} (hW : W.map f ≤ W') :
    (rationalToComplexSubmodule (V := V) W).map (rationalMapToComplex (V := V) f) ≤
      rationalToComplexSubmodule (V := V') W' := by
  rintro y ⟨x, hx, rfl⟩
  rcases hx with ⟨t, ht, rfl⟩
  refine ⟨f.baseChange ℂ t, ?_, ?_⟩
  · rw [Submodule.baseChange] at ht ⊢
    rcases ht with ⟨s, rfl⟩
    refine TensorProduct.induction_on s ?hz ?ht ?ha
    · simp
    · intro z w
      rw [LinearMap.baseChange_tmul]
      exact ⟨z ⊗ₜ[ℚ] (⟨f w, hW ⟨w, w.property, rfl⟩⟩ : W'), by simp⟩
    · intro x y hx hy
      simpa [map_add] using Submodule.add_mem _ hx hy
  · simp [rationalMapToComplex]

/-- A rational Hodge substructure of a pure Hodge structure: a `ℚ`-subspace `WQ` of `V_ℚ` whose
complexification is spanned by its Hodge pieces (`hodge_spanning`). Conjugation-stability of the
complexification is automatic — it holds for *any* rational subspace (`rationalToComplexSubmodule_conj`)
— so it is not carried as a field; `hodge_spanning` is the genuine sub-Hodge condition. -/
structure RationalHodgeSubstructure {n : ℤ} (hs : HodgeStructure V n) where
  WQ : Submodule ℚ (Rationalification V)
  hodge_spanning : rationalToComplexSubmodule WQ =
    ⨆ p, rationalToComplexSubmodule WQ ⊓ hs.piece p

/-- The complex subspace associated to a rational Hodge substructure. -/
noncomputable def RationalHodgeSubstructure.WC {n : ℤ} {hs : HodgeStructure V n}
    (W : RationalHodgeSubstructure hs) : Submodule ℂ (Complexification V) :=
  rationalToComplexSubmodule W.WQ

/-- **L1 milestone -- semisimplicity over `ℚ` (the summit of the pure theory).** Every rational
Hodge substructure of a polarized Hodge structure has a rational Hodge-substructure complement,
orthogonal under the polarization. -/
example {n : ℤ} (hs : HodgeStructure V n) (pol : Polarization hs)
    (W : RationalHodgeSubstructure hs) :
    ∃ W' : RationalHodgeSubstructure hs,
      IsCompl W.WQ W'.WQ ∧ IsCompl W.WC W'.WC ∧
        (∀ v ∈ W.WC, ∀ w ∈ W'.WC, pol.Q v w = 0) :=
  sorry

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The complex quotient attached to the `k`th graded piece of a complexified weight
filtration. In the mixed-Hodge-structure definition below this is identified with the
complexification of the rational quotient `W_{ℚ,k}/W_{ℚ,k-1}`; it is retained as the
target of that comparison map. -/
@[reducible]
noncomputable def weightGradedPiece
    (WC : ℤ → Submodule ℂ (Complexification V)) (k : ℤ) : Type _ :=
  (WC k) ⧸ ((WC (k - 1)).submoduleOf (WC k))

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The rational `k`th graded piece `grᵂ_k = W_{ℚ,k}/W_{ℚ,k-1}` of an increasing
rational weight filtration. The lower step is viewed inside `W_{ℚ,k}` using
`Submodule.submoduleOf`; for mixed Hodge structures, monotonicity makes this the usual
quotient by `W_{ℚ,k-1}`. -/
@[reducible]
noncomputable def weightGradedRat
    (WQ : ℤ → Submodule ℚ (Rationalification V)) (k : ℤ) : Type _ :=
  (WQ k) ⧸ ((WQ (k - 1)).submoduleOf (WQ k))

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Monotonicity supplies the inclusion `W_{k-1} ≤ W_k` behind the graded-piece
quotient. -/
theorem weightGraded_lower_le
    {WC : ℤ → Submodule ℂ (Complexification V)} (hWC : Monotone WC) (k : ℤ) :
    WC (k - 1) ≤ WC k := by
  exact hWC (by omega)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The complexification of a rational vector space, in the orientation `ℂ ⊗[ℚ] U`. -/
abbrev ratComplexify (U : Type*) [AddCommGroup U] [Module ℚ U] : Type _ :=
  TensorProduct ℚ ℂ U

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The canonical conjugation on `ℂ ⊗[ℚ] U`, conjugating only the scalar tensor factor. -/
noncomputable def ratConj (U : Type*) [AddCommGroup U] [Module ℚ U] :
    ratComplexify U →ₛₗ[starRingEnd ℂ] ratComplexify U where
  toFun := TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
    (LinearMap.id : U →ₗ[ℚ] U)
  map_add' := by intro x y; simp
  map_smul' c x := by
    change TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
        (LinearMap.id : U →ₗ[ℚ] U) (c • x) =
      (starRingEnd ℂ) c • TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
        (LinearMap.id : U →ₗ[ℚ] U) x
    refine TensorProduct.induction_on x ?hz ?ht ?ha
    · simp
    · intro z u
      rw [TensorProduct.smul_tmul']
      rw [TensorProduct.map_tmul]
      rw [TensorProduct.map_tmul]
      rw [TensorProduct.smul_tmul']
      simp [map_mul]
    · intro x y hx hy
      calc
        TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
            (LinearMap.id : U →ₗ[ℚ] U) (c • (x + y)) =
          TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
            (LinearMap.id : U →ₗ[ℚ] U) (c • x + c • y) := by rw [smul_add]
        _ = TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
              (LinearMap.id : U →ₗ[ℚ] U) (c • x) +
            TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
              (LinearMap.id : U →ₗ[ℚ] U) (c • y) := by rw [map_add]
        _ = (starRingEnd ℂ) c • TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
              (LinearMap.id : U →ₗ[ℚ] U) x +
            (starRingEnd ℂ) c • TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
              (LinearMap.id : U →ₗ[ℚ] U) y := by rw [hx, hy]
        _ = (starRingEnd ℂ) c •
            (TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
                (LinearMap.id : U →ₗ[ℚ] U) x +
              TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
                (LinearMap.id : U →ₗ[ℚ] U) y) := by rw [smul_add]
        _ = (starRingEnd ℂ) c • TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
              (LinearMap.id : U →ₗ[ℚ] U) (x + y) := by rw [map_add]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
@[simp]
theorem ratConj_tmul (U : Type*) [AddCommGroup U] [Module ℚ U] (z : ℂ) (u : U) :
    ratConj U (z ⊗ₜ[ℚ] u) = (starRingEnd ℂ z) ⊗ₜ[ℚ] u :=
  rfl

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
theorem ratConj_involutive (U : Type*) [AddCommGroup U] [Module ℚ U] :
    Function.Involutive (ratConj U) := by
  intro x
  change TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
      (LinearMap.id : U →ₗ[ℚ] U)
      (TensorProduct.map (starRingEnd ℂ).toAddMonoidHom.toRatLinearMap
        (LinearMap.id : U →ₗ[ℚ] U) x) = x
  refine TensorProduct.induction_on x ?hz ?ht ?ha
  · simp
  · intro z u
    rw [TensorProduct.map_tmul]
    rw [TensorProduct.map_tmul]
    simp
  · intro x y hx hy
    rw [map_add, map_add, hx, hy]

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The canonical conjugation on `ℂ ⊗[ℚ] U` as a conjugate-linear equivalence. -/
noncomputable def ratConjEquiv (U : Type*) [AddCommGroup U] [Module ℚ U] :
    ratComplexify U ≃ₛₗ[starRingEnd ℂ] ratComplexify U where
  toLinearMap := ratConj U
  invFun := ratConj U
  left_inv := ratConj_involutive U
  right_inv := ratConj_involutive U

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The rational graded conjugation: canonical conjugation on the complexification of
`grᵂ_k(W_ℚ)`. -/
noncomputable def gradedConj (WQ : ℤ → Submodule ℚ (Rationalification V)) (k : ℤ) :
    ratComplexify (weightGradedRat (V := V) WQ k) ≃ₛₗ[starRingEnd ℂ]
      ratComplexify (weightGradedRat (V := V) WQ k) :=
  ratConjEquiv (weightGradedRat (V := V) WQ k)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
theorem gradedConj_involutive (WQ : ℤ → Submodule ℚ (Rationalification V)) (k : ℤ) :
    Function.Involutive (gradedConj (V := V) WQ k) :=
  ratConj_involutive (weightGradedRat (V := V) WQ k)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The Hodge filtration induced on `grᵂ_k`: image of `F^p ∩ W_k` under the quotient
map `W_k → W_k/W_{k-1}`. -/
noncomputable def complexGradedF
    (WC : ℤ → Submodule ℂ (Complexification V))
    (F : ℤ → Submodule ℂ (Complexification V)) (k p : ℤ) :
    Submodule ℂ (weightGradedPiece (V := V) WC k) :=
  ((F p ⊓ WC k).submoduleOf (WC k)).map
    (((WC (k - 1)).submoduleOf (WC k)).mkQ)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The canonical equivalence from `ℂ ⊗[ℚ] W_ℚ` onto the complex subspace of `V_ℂ`
associated to `W_ℚ`. -/
noncomputable def rationalToComplexSubmoduleEquiv
    (W : Submodule ℚ (Rationalification V)) :
    ratComplexify W ≃ₗ[ℂ] rationalToComplexSubmodule (V := V) W :=
  (Submodule.toBaseChange.toLinearEquiv ℂ W).trans
    ((rationalToComplexLinearEquiv (V := V)).ofSubmodules (W.baseChange ℂ)
      (rationalToComplexSubmodule (V := V) W) rfl)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
theorem rationalToComplexSubmoduleEquiv_range_lTensor
    {A B : Submodule ℚ (Rationalification V)} (hAB : A ≤ B) :
    (LinearMap.range
        (TensorProduct.AlgebraTensorModule.lTensor ℂ ℂ
          (((A.submoduleOf B).subtype).restrictScalars ℚ))).map
          (rationalToComplexSubmoduleEquiv (V := V) B : ratComplexify B →ₗ[ℂ]
            rationalToComplexSubmodule (V := V) B) =
      (rationalToComplexSubmodule (V := V) A).submoduleOf
        (rationalToComplexSubmodule (V := V) B) := by
  ext y
  constructor
  · rintro ⟨x, hx, rfl⟩
    rcases hx with ⟨t, rfl⟩
    change ((rationalToComplexSubmoduleEquiv (V := V) B)
        ((TensorProduct.AlgebraTensorModule.lTensor ℂ ℂ
          (((A.submoduleOf B).subtype).restrictScalars ℚ)) t) :
        Complexification V) ∈ rationalToComplexSubmodule (V := V) A
    refine TensorProduct.induction_on t ?hz ?ht ?ha
    · simp [rationalToComplexSubmoduleEquiv]
    · intro z a
      change ((rationalToComplexLinearEquiv (V := V)).ofSubmodules (B.baseChange ℂ)
          (rationalToComplexSubmodule (V := V) B) rfl
          ((Submodule.toBaseChange.toLinearEquiv ℂ B)
            (z ⊗ₜ[ℚ] (a : B))) : Complexification V) ∈
        rationalToComplexSubmodule (V := V) A
      rw [LinearEquiv.ofSubmodules_apply]
      change rationalToComplexLinearEquiv (V := V)
          (((Submodule.toBaseChange.toLinearEquiv ℂ B) (z ⊗ₜ[ℚ] (a : B)) :
            B.baseChange ℂ) : TensorProduct ℚ ℂ (Rationalification V)) ∈
        rationalToComplexSubmodule (V := V) A
      rw [Submodule.toBaseChange.toLinearEquiv_apply]
      exact ⟨z ⊗ₜ[ℚ] ((a : B) : Rationalification V),
        Submodule.tmul_mem_baseChange_of_mem z a.property, rfl⟩
    · intro x y hx hy
      simpa [map_add] using Submodule.add_mem (rationalToComplexSubmodule (V := V) A) hx hy
  · intro hy
    change (y : Complexification V) ∈ rationalToComplexSubmodule (V := V) A at hy
    rcases hy with ⟨a, ha, hy⟩
    rcases Submodule.toBaseChange_surjective' (A := ℂ) (p := A) ha with ⟨t, ht⟩
    refine ⟨(TensorProduct.AlgebraTensorModule.lTensor ℂ ℂ
        (((A.submoduleOf B).subtype).restrictScalars ℚ))
        ((TensorProduct.AlgebraTensorModule.congr (LinearEquiv.refl ℂ ℂ)
          (Submodule.submoduleOfEquivOfLe hAB).symm) t), ?_, ?_⟩
    · exact ⟨_, rfl⟩
    · apply Subtype.ext
      change ((rationalToComplexSubmoduleEquiv (V := V) B)
          ((TensorProduct.AlgebraTensorModule.lTensor ℂ ℂ
            (((A.submoduleOf B).subtype).restrictScalars ℚ))
            ((TensorProduct.AlgebraTensorModule.congr (LinearEquiv.refl ℂ ℂ)
              (Submodule.submoduleOfEquivOfLe hAB).symm) t)) :
          Complexification V) = y
      rw [← hy]
      rw [← ht]
      refine TensorProduct.induction_on t ?hz₂ ?ht₂ ?ha₂
      · simp [rationalToComplexSubmoduleEquiv]
      · intro z a'
        change ((rationalToComplexLinearEquiv (V := V)).ofSubmodules (B.baseChange ℂ)
            (rationalToComplexSubmodule (V := V) B) rfl
            ((Submodule.toBaseChange.toLinearEquiv ℂ B)
              (z ⊗ₜ[ℚ] (⟨(a' : Rationalification V), hAB a'.property⟩ : B))) :
            Complexification V) =
          rationalToComplexLinearEquiv (V := V)
            (((Submodule.toBaseChange.toLinearEquiv ℂ A) (z ⊗ₜ[ℚ] a') :
              A.baseChange ℂ) : TensorProduct ℚ ℂ (Rationalification V))
        rw [LinearEquiv.ofSubmodules_apply]
        rw [Submodule.toBaseChange.toLinearEquiv_apply]
        rw [Submodule.toBaseChange.toLinearEquiv_apply]
        rw [Submodule.coe_toBaseChange_tmul]
        rw [Submodule.coe_toBaseChange_tmul]
      · intro x y hx hy
        simpa [map_add] using congrArg₂ (fun u v => u + v) hx hy

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Complexification commutes with the rational weight-graded quotient:
`ℂ ⊗[ℚ] (W_{ℚ,k}/W_{ℚ,k-1}) ≃
(W_{ℚ,k})_ℂ/(W_{ℚ,k-1})_ℂ`. -/
noncomputable def gradedComplexEquiv
    (WQ : ℤ → Submodule ℚ (Rationalification V)) (hWQ : Monotone WQ) (k : ℤ) :
    ratComplexify (weightGradedRat (V := V) WQ k) ≃ₗ[ℂ]
      weightGradedPiece (V := V) (fun k => rationalToComplexSubmodule (V := V) (WQ k)) k :=
  let lower_le : WQ (k - 1) ≤ WQ k := hWQ (by omega)
  TensorProduct.AlgebraTensorModule.tensorQuotientEquiv ℂ ℚ ℂ
    ((WQ (k - 1)).submoduleOf (WQ k)) ≪≫ₗ
    Submodule.Quotient.equiv
      (LinearMap.range
        (TensorProduct.AlgebraTensorModule.lTensor ℂ ℂ
          ((((WQ (k - 1)).submoduleOf (WQ k)).subtype).restrictScalars ℚ)))
      ((rationalToComplexSubmodule (V := V) (WQ (k - 1))).submoduleOf
        (rationalToComplexSubmodule (V := V) (WQ k)))
      (rationalToComplexSubmoduleEquiv (V := V) (WQ k))
      (rationalToComplexSubmoduleEquiv_range_lTensor (V := V) lower_le)

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The Hodge filtration induced on the complexification of the rational graded piece,
transported from the complex quotient through `gradedComplexEquiv`. -/
noncomputable def gradedF
    (WQ : ℤ → Submodule ℚ (Rationalification V)) (hWQ : Monotone WQ)
    (F : ℤ → Submodule ℂ (Complexification V)) (k p : ℤ) :
    Submodule ℂ (ratComplexify (weightGradedRat (V := V) WQ k)) :=
  (complexGradedF (V := V) (fun k => rationalToComplexSubmodule (V := V) (WQ k)) F k p).comap
    (gradedComplexEquiv (V := V) WQ hWQ k).toLinearMap

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- The induced-purity condition on a mixed Hodge structure is stated on the
complexification of the rational graded piece `grᵂ_k(W_ℚ)`. The induced filtration is
bounded, decreasing, and `k`-opposed with respect to the canonical rational conjugation. -/
noncomputable def gradedPure
    (WQ : ℤ → Submodule ℚ (Rationalification V)) (hWQ : Monotone WQ)
    (F : ℤ → Submodule ℂ (Complexification V)) (k : ℤ) : Prop :=
  (∃ p, gradedF (V := V) WQ hWQ F k p = ⊤) ∧
    (∃ p, gradedF (V := V) WQ hWQ F k p = ⊥) ∧
      Antitone (fun p => gradedF (V := V) WQ hWQ F k p) ∧
        ∀ p, IsCompl (gradedF (V := V) WQ hWQ F k p)
          ((gradedF (V := V) WQ hWQ F k (k + 1 - p)).map
            (gradedConj (V := V) WQ k).toLinearMap)

/-- **L2 -- mixed Hodge structure (schematic).** The primary lattice is again `V_ℤ`. The weight
filtration is recorded rationally on `V_ℚ`; its complexification on `V_ℂ` is derived using
`Submodule.baseChange` and the tower cancellation equivalence. The Hodge filtration is a decreasing
filtration on `V_ℂ`. -/
structure MixedHodgeStructure (V : Type*) [AddCommGroup V] [Module ℤ V] [Module.Free ℤ V]
    [Module.Finite ℤ V] where
  WQ : ℤ → Submodule ℚ (Rationalification V)
  WQ_monotone : Monotone WQ
  /-- A mixed Hodge structure has a finite weight filtration: `W_k = ⊤` for `k ≫ 0`
  and `W_k = ⊥` for `k ≪ 0`; without this, degenerate instances like `W ≡ ⊥`
  satisfy the structure. This field records the exhaustive/top end. -/
  WQ_top : ∃ k, WQ k = ⊤
  /-- The separated/bottom end of the finite weight filtration: `W_k = ⊥` for `k ≪ 0`. -/
  WQ_bot : ∃ k, WQ k = ⊥
  F : ℤ → Submodule ℂ (Complexification V)
  F_antitone : Antitone F
  /-- The Hodge filtration is exhaustive: `F^p = ⊤` for `p ≪ 0`. -/
  F_top : ∃ p, F p = ⊤
  /-- The Hodge filtration is separated: `F^p = ⊥` for `p ≫ 0`. -/
  F_bot : ∃ p, F p = ⊥
  /-- On each rational graded weight piece `grᵂ_k = W_{ℚ,k}/W_{ℚ,k-1}`, the filtration
  induced by `F` on its complexification is a pure Hodge structure of weight `k`. -/
  graded_pure : ∀ k, gradedPure WQ WQ_monotone F k

/-- The complexified weight filtration of a mixed Hodge structure. -/
noncomputable def MixedHodgeStructure.WC
    (mhs : MixedHodgeStructure V) (k : ℤ) : Submodule ℂ (Complexification V) :=
  rationalToComplexSubmodule (mhs.WQ k)

/-- **L2 milestone -- strictness (Deligne).** A morphism of mixed Hodge structures is a single
rational map whose complexification acts on `V_ℂ`; if it is compatible with the rational weight
filtration and the Hodge filtration, it is **strict** for the weight filtration (stated at both the
rational and complex levels) and the Hodge filtration: `range fQ ⊓ W'_{ℚ,k} = fQ(W_{ℚ,k})`,
`range f_ℂ ⊓ W'_{ℂ,k} = f_ℂ(W_{ℂ,k})`, and `range f_ℂ ⊓ F'^p = f_ℂ(F^p)`. -/
example {V' : Type*} [AddCommGroup V'] [Module ℤ V'] [Module.Free ℤ V'] [Module.Finite ℤ V']
    (mhs : MixedHodgeStructure V) (mhs' : MixedHodgeStructure V')
    (fQ : Rationalification V →ₗ[ℚ] Rationalification V')
    (hWQ : ∀ k, (mhs.WQ k).map fQ ≤ mhs'.WQ k)
    (_hF : ∀ p, (mhs.F p).map (rationalMapToComplex fQ) ≤ mhs'.F p) :
    (∀ k, LinearMap.range fQ ⊓ mhs'.WQ k = (mhs.WQ k).map fQ) ∧
      (∀ k, LinearMap.range (rationalMapToComplex fQ) ⊓ mhs'.WC k =
        (mhs.WC k).map (rationalMapToComplex fQ)) ∧
      (∀ p, LinearMap.range (rationalMapToComplex fQ) ⊓ mhs'.F p =
        (mhs.F p).map (rationalMapToComplex fQ)) := sorry

/-- Fixed Hodge numbers for a period-domain target. -/
structure HodgeType where
  h : ℤ → ℕ
  finite_support : {p | h p ≠ 0}.Finite

/-- **L3 -- period domain.** Following Griffiths, the lattice `V_ℤ`, the integral polarization form
`Qint`, and the Hodge type are **fixed**; a *point* of the period domain is a Hodge filtration making
`(V, Qint)` a polarized Hodge structure of that type. Only the filtration varies — so the symmetry
group `G = Aut(V, Qint)` acts and `D` is the homogeneous space `G_ℝ/V` (open in a flag variety). The
`pol_form` field pins the polarization to the fixed form. -/
structure PeriodDomain (V : Type*) [AddCommGroup V] [Module ℤ V] [Module.Free ℤ V]
    [Module.Finite ℤ V] (n : ℤ) (Qint : LinearMap.BilinForm ℤ V) (htype : HodgeType) where
  hs : HodgeStructure V n
  pol : Polarization hs
  /-- The point's polarization is the fixed form `Qint` -- the domain varies only the filtration. -/
  pol_form : pol.Qint = Qint
  hodge_numbers : ∀ p : ℤ, Module.finrank ℂ (hs.piece p) = htype.h p

/-- **L3 milestone -- Hodge numbers partition the dimension.** For any point of the period domain,
the prescribed Hodge numbers sum to the dimension of `V_ℂ` (the numerical shadow of the Hodge
decomposition; a genuine constraint on `HodgeType`). The deeper target -- openness of the period
domain in its flag variety, and the weight-1 identification with the Siegel domain -- needs
flag-variety topology and is described in the README (out of scope for this seed). -/
example {n : ℤ} (Qint : LinearMap.BilinForm ℤ V) (htype : HodgeType)
    (D : PeriodDomain V n Qint htype) :
    ∑ᶠ p, (htype.h p : ℕ) = Module.finrank ℂ (Complexification V) := sorry

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Complexification of an integral linear equivalence. -/
def complexificationLinearEquiv (e : V ≃ₗ[ℤ] V) :
    Complexification V ≃ₗ[ℂ] Complexification V :=
  TensorProduct.AlgebraTensorModule.congr (LinearEquiv.refl ℂ ℂ) e

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
@[simp]
theorem complexificationLinearEquiv_tmul (e : V ≃ₗ[ℤ] V) (z : ℂ) (v : V) :
    complexificationLinearEquiv (V := V) e (z ⊗ₜ[ℤ] v) = z ⊗ₜ[ℤ] e v :=
  rfl

omit [Module.Free ℤ V] [Module.Finite ℤ V] in
/-- Complexification as a monoid homomorphism from integral automorphisms to complex-linear
automorphisms. -/
def complexificationLinearEquivHom :
    (V ≃ₗ[ℤ] V) →* (Complexification V ≃ₗ[ℂ] Complexification V) where
  toFun := complexificationLinearEquiv (V := V)
  map_one' := by
    apply LinearEquiv.ext
    intro x
    refine TensorProduct.induction_on x (by simp) ?_ ?_
    · intro z v
      simp [complexificationLinearEquiv]
    · intro x y hx hy
      simp [map_add, hx, hy]
  map_mul' e f := by
    apply LinearEquiv.ext
    intro x
    refine TensorProduct.induction_on x (by simp) ?_ ?_
    · intro z v
      simp [complexificationLinearEquiv]
    · intro x y hx hy
      simp [map_add, hx, hy]

/-- **L4 -- the monodromy facet of a VHS.** The *full* L4 target is a variation of Hodge
structure over a base `B`: a local system + a holomorphic Hodge-filtration bundle +
Griffiths transversality (`∇F^p ⊆ F^{p-1}⊗Ω¹`), with monodromy landing in `G(ℤ)` -- see
README. This signature captures only its **monodromy representation** facet (the part the
L5 milestone uses): a representation on the integral lattice preserving the integral
polarization form. Named to be honest that it is *not* the full VHS datum. -/
structure PolarizedMonodromyRepresentation {n : ℤ} (hs : HodgeStructure V n)
    (pol : Polarization hs) (Γ : Type*) [Group Γ] where
  ρ : Γ →* (V ≃ₗ[ℤ] V)
  preserves_integral_form : ∀ (g : Γ) v w, pol.Qint (ρ g v) (ρ g w) = pol.Qint v w

/-- The complexified monodromy representation attached to an integral monodromy representation. -/
def PolarizedMonodromyRepresentation.complexMonodromy {n : ℤ} {hs : HodgeStructure V n}
    {pol : Polarization hs} {Γ : Type*} [Group Γ]
    (M : PolarizedMonodromyRepresentation hs pol Γ) :
    Γ →* (Complexification V ≃ₗ[ℂ] Complexification V) :=
  (complexificationLinearEquivHom (V := V)).comp M.ρ

/-- **L4 -- variation of Hodge structure (schematic full datum).** This seeds the genuine VHS layer:
a local system of integral lattices on a base `B`, a holomorphic Hodge-filtration bundle recorded
schematically as complex subbundles, Griffiths transversality, and polarized monodromy. The analytic
notions are placeholders until the roadmap imports the needed complex-geometry infrastructure. -/
structure VariationOfHodgeStructure (B : Type*) (V : Type*) [AddCommGroup V] [Module ℤ V]
    [Module.Free ℤ V] [Module.Finite ℤ V] (n : ℤ) (Γ : Type*) [Group Γ] where
  fiber : HodgeStructure V n
  polarization : Polarization fiber
  monodromy : PolarizedMonodromyRepresentation fiber polarization Γ
  hodgeBundle : ℤ → B → Submodule ℂ (Complexification V)
  holomorphic : ∀ _ : ℤ, Prop
  griffiths_transversality : Prop

-- L4 has no self-contained provable milestone: period-map horizontality / Griffiths transversality
-- (`∇F^p ⊆ F^{p-1}⊗Ω¹`) is an analytic statement needing the connection/complex-geometry
-- infrastructure that the README declares out of scope. `VariationOfHodgeStructure` above is
-- the schematic structural seed; the provable engine for the L4/L5 rigidity theory is the Schur
-- milestone below.

/-- **L5 milestone -- Schur (the linear-algebraic core).** If the complexified monodromy
representation is irreducible, its commutant is scalar. This is the *engine* under period-map
rigidity and Deligne's theorem of the fixed part / semisimplicity -- but those full theorems need
genuine *polarizable VHS* hypotheses (a real VHS, not just a form-preserving representation); this
milestone is the plain finite-dimensional Schur lemma that they invoke. -/
example {n : ℤ} (hs : HodgeStructure V n) (pol : Polarization hs) {Γ : Type*} [Group Γ]
    (M : PolarizedMonodromyRepresentation hs pol Γ)
    (hirr : ∀ W : Submodule ℂ (Complexification V),
      (∀ g, W.map ((M.complexMonodromy g).toLinearMap) = W) → W = ⊥ ∨ W = ⊤)
    (T : Complexification V →ₗ[ℂ] Complexification V)
    (hT : ∀ g v, T (M.complexMonodromy g v) = M.complexMonodromy g (T v)) :
    ∃ c : ℂ, ∀ v, T v = c • v := sorry

end TauCetiRoadmap.VHS
