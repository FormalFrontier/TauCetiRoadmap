# Roadmap: modular forms — Hecke theory, newforms, and L-functions

Mathlib has the *foundations* of modular forms — `SlashInvariantForm`, `ModularForm`,
`CuspForm` and their classes ([`ModularFormClass`](https://leanprover-community.github.io/mathlib4_docs/Mathlib/NumberTheory/ModularForms/Basic.html#ModularFormClass),
`CuspFormClass`, in `Mathlib/NumberTheory/ModularForms/Basic.lean`), the slash action
(`SlashActions.lean`), the congruence subgroups `Γ(N)`, `Γ₀(N)`, `Γ₁(N)`
(`CongruenceSubgroups.lean`), Eisenstein series and `E₄, E₆` (`EisensteinSeries/*`), the
`q`-expansion and [`cuspFunction`](https://leanprover-community.github.io/mathlib4_docs/Mathlib/NumberTheory/ModularForms/QExpansion.html)
(`QExpansion.lean`), the Petersson integrand (`Petersson.lean`), the cusp-form submodule, `Δ`,
`η`, and the level-one dimension formula (`DimensionFormulas/LevelOne.lean`). It has **no Hecke
operators**, no theory of **eigenforms / newforms / oldforms**, no **L-function of a modular
form**, no **valence formula**, and no **general dimension formulas**. We build the classical
arithmetic theory of modular forms on top of Mathlib's analytic foundation: modular forms with
character, the valence formula at general level, the Hecke algebra, the Petersson inner
product, newforms and strong multiplicity one, Atkin–Lehner and Fricke operators, the
L-function with its Euler product and functional equation, and the theorem that the coefficient
field of a newform is a number field — the content of a masters/PhD course on the subject,
resting throughout on complex analysis, Fourier analysis, and the arithmetic of `SL₂(ℤ)`.

The summit is the **dimension formulas** for `M_k(Γ)` and `S_k(Γ)` at general level
(Diamond–Shurman Thm 3.5.1), proved by the **classical analytic route**: the valence formula
together with the elliptic-point and cusp counts of the quotient `Γ\ℍ`. The modular curve here
**is** the analytic quotient `Γ\ℍ`, compactified by adjoining the cusps to a compact Riemann
surface — defined directly, with no functor, no representability, and no algebraic moduli
problem.

Suggested home: `TauCeti/NumberTheory/ModularForms/`.

A large, `sorry`-free body of this theory already exists in the AINTLIB `LeanModularForms`
project (~260 source files). This roadmap specifies the **mathematics**; the file-by-file
migration map is in the secondary *Provenance* section and in `Targets.lean`. Porting it into
`TauCeti/` is the opportunity to restate everything in Mathlib's vocabulary and to **clean up** —
the project's own audits estimate that the newform and eigenform/SMO subtrees alone carry
~30–36% redundancy (parallel `ModularForm`/`CuspForm` chains, dead scaffolding, near-duplicate
`slash` variants) that consolidates on the way in.

## Standing hypotheses and conventions

Spell hypotheses out; **do not** bundle "a modular form with all its invariants" into one class.
Pin these conventions before writing code — implementors make bad, divergent choices otherwise.

- **Levels and characters.** Work with `Γ₁(N) ≤ Γ ≤ Γ₀(N)` and Dirichlet characters
  `χ : DirichletCharacter ℂ N` (`= MulChar (ZMod N) ℂ`, Mathlib's notion — use it, do not
  reinvent). The space with **nebentypus** `χ` is `M_k(N, χ) = M_k(Γ₁(N), χ)`, the `χ`-isotypic
  piece for the diamond operators inside `M_k(Γ₁(N))`. Reserve `M_k(Γ)` for a bare congruence
  subgroup.
- **The weight-`k` slash.** Use Mathlib's `SlashAction`/`ModularForm.slash` and its `k` and
  `GL₂(ℝ)⁺`/`GL₂(ℚ)⁺` conventions throughout; the Hecke double-coset operators are built from it.
  ⚠ Two normalizations of the Hecke action circulate (Shimura's vs Diamond–Shurman's, differing
  by a power of the determinant); **pin Diamond–Shurman's** as primary, and provide the
  Shimura-normalized action as a named bridge (AINTLIB has both via `ShimuraHom`), so any
  half-integral-weight work downstream can use it without a silent reconvention.
- **Normalized eigenforms.** An eigenform is `normalized` when `a₁ = 1`; a **newform** is a
  normalized eigenform in the new subspace. State eigenvalue results for normalized forms, so that
  `Tₙ f = aₙ(f) · f` (Hecke eigenvalue = Fourier coefficient).
- **Coefficient field.** The coefficient field of a newform is `CoefficientField f = ℚ(aₙ : n ≥ 1)
  ⊆ ℂ`, an `IntermediateField ℚ ℂ`. (Name it `CoefficientField`, not after the form: no `K_f`.)
  It is a *number field* — a theorem (Layer 8), not an assumption.
- **`q`-expansions are the computational interface.** State Hecke recurrences, Euler products,
  and eigenform characterizations on the Fourier coefficients `aₙ(f)` via `qExpansion`, not on
  bespoke coefficient types.

## What Mathlib already has (consume)

- **Forms and classes:** `ModularForm Γ k`, `CuspForm Γ k`, `SlashInvariantForm`,
  `ModularFormClass`, `CuspFormClass`, the `ℂ`-module structures, `ModularForm.mul`, `E₄`, `E₆`,
  `Δ`, `η` (`NumberTheory/ModularForms/*`).
- **Congruence subgroups:** `CongruenceSubgroup.Gamma`, `Gamma0`, `Gamma1`, and the maps between
  them (`CongruenceSubgroups.lean`).
- **The upper half-plane and the `SL₂` action:** `UpperHalfPlane`, the Möbius action, the
  fundamental domain and proper discontinuity (`Analysis/Complex/UpperHalfPlane/*`,
  `ModularForms/ProperlyDiscontinuous.lean`).
- **`q`-expansions and cusps:** `qExpansion`, `cuspFunction`, `BoundedAtCusp`, the bounds
  `|aₙ| = O(n^{k})` / `O(n^{k/2})` substrate (`QExpansion.lean`, `Bounds.lean`).
- **Eisenstein series:** `eisensteinSeries`, `gammaSet`, the level-`Γ(N)` series and their
  `q`-expansions (`EisensteinSeries/*`).
- **Petersson integrand:** `petersson k f f' τ`, the pointwise pairing (`Petersson.lean`).
- **Dirichlet characters:** `DirichletCharacter`, conductor, primitivity, `changeLevel`, Gauss
  sums, the Dirichlet L-function with its functional equation
  (`NumberTheory/DirichletCharacter/*`, `LSeries/*`).
- **L-series substrate:** `LSeries`, `LSeriesSummable`, `LSeriesHasSum`, abscissa of convergence,
  and the Euler-product API (`riemannZeta_eulerProduct`, `LSeries/Dirichlet.lean`,
  `EulerProduct/*`).
- **Number fields:** `NumberField`, `IntermediateField`, the Galois theory of `ℚ̄/ℚ` — the target
  of the coefficient-field layer.
- **Adeles and double cosets (for the Hecke algebra):** `DedekindDomain.FiniteAdeleRing`,
  `NumberField.AdeleRing`, `GroupTheory/DoubleCoset`, compact-open subgroups
  (`Topology/Algebra/Group/CompactOpen.lean`), and Haar/measure convolution
  (`MeasureTheory/Group/Convolution.lean`). ⚠ Mathlib has **no Hecke algebra** of any kind, nor the
  smooth adelic convolution algebra `C_c^∞(GL₂(𝔸_f))` or its level corners `C_c^∞(K\GL₂(𝔸_f)/K)`;
  the abstract double-coset ring and the full adelic Hecke algebra are built in Layer 2.

## What is missing (build here)

The valence formula at general level; the Hecke operators `Tₙ`, `Tₚ`, the diamond operators
`⟨n⟩`, and the (commutative) Hecke algebra acting on `M_k(N,χ)`, together with its adelic form
`C_c^∞(GL₂(𝔸_f))`; the Petersson inner product as
an actual inner product and the self-adjointness of `Tₙ` for `(n,N)=1`; the old/new decomposition
and its orthogonality; eigenforms, newforms, oldforms, primitive forms; the Main Lemma, the
conductor theorem, and **strong multiplicity one**; Atkin–Lehner and Fricke operators and their
signs; the L-function of a modular form with its **Euler product**, **completed form**,
**functional equation**, and **analytic continuation**; the **coefficient field** and the proof
that it is a number field; the LMFDB invariants (Satake parameters, Hecke characteristic
polynomials, Galois orbits, labels, …); the **modular curve** `X(Γ)` as the compactified analytic
quotient `Γ\ℍ`, with its cusps, elliptic points, and genus; and the **dimension formulas** for
`M_k(Γ)` and `S_k(Γ)` by the valence-formula route. None of this is upstream.

---

## The build, in layers

The ordering is the dependency order; independent lanes (e.g. L-functions vs. the modular curve)
can proceed in parallel once their inputs exist. As each layer makes the next layer's *types*
expressible in `TauCeti/`, its milestones go into `Targets.lean` (with `sorry`). Embedded Lean
below sketches signatures; it is illustrative, not required to compile.

### Layer 0: modular forms with character (nebentypus)
- **Modular forms with character `M_k(N, χ)` and `S_k(N, χ)`**, defined *intrinsically* by the
  character transformation law — generalizing Mathlib's `ModularForm Γ k`, not carved out as an
  eigenspace after the fact:
  ```lean
  -- f is Γ₁(N)-modular of weight k and transforms by χ under Γ₀(N):
  --   f ∣[k] γ = χ(d_γ) • f   for every γ ∈ Γ₀(N),  d_γ = lower-right entry mod N
  def ModularFormWithChar (N : ℕ) (k : ℤ) (χ : DirichletCharacter ℂ N) : Type  -- and S_k(N, χ)
  ```
  These spaces are the general setting for the entire roadmap; all of the Hecke, Petersson, and
  eigenform theory below lives on them. The **diamond operators `⟨d⟩` are not primitive here** —
  they enter in Layer 2 as elements of the Hecke algebra, and the decomposition of `M_k(Γ₁(N))`
  into nebentypus pieces is then a *theorem*, not the definition.
  ⚠ Define `M_k(N, χ)` by the transformation law; the diamond-eigenspace description is recovered
  once Layer 2 exists. This is where the roadmap deliberately improves on the AINTLIB provenance,
  which defines these spaces as eigenspaces of separately-built `⟨d⟩`.
- **The nebentypus decomposition** of `M_k(Γ₁(N))`. State precisely what we want: the natural map
  is a `ℂ`-linear **isomorphism onto an (internal) direct sum** of the nebentypus subspaces, the
  diamond action being diagonalizable with the `M_k(N,χ)` as its isotypic components,
  ```lean
  -- the diamond decomposition: an internal direct sum over χ : DirichletCharacter ℂ N
  theorem modularForm_gamma1_iSupIndep_char (N : ℕ) (k : ℤ) :
      DirectSum.IsInternal (fun χ : DirichletCharacter ℂ N => M_k(N, χ) /- as submodule -/)
  ```
  ⚠ This is an internal direct sum of subspaces of `M_k(Γ₁(N))`, **not** a naive equality of a
  type with an external `⨁`.
- **Eisenstein series with character** `E_k^{χ,ψ}` (#37): the character-twisted series as named
  modular forms on `Γ₀(N)` with nebentypus, their `q`-expansions in terms of generalized
  Bernoulli numbers and twisted divisor sums, and the Eisenstein subspace.
  ⚠ Match Mathlib's `eisensteinSeries`/`gammaSet` indexing; do not introduce a second Eisenstein
  API.

### Layer 1: the valence formula (general level)
- Consumes the [Contour Integration roadmap](../ContourIntegration/README.md). For a nonzero
  `f ∈ M_k(SL₂(ℤ))`, the **valence formula** (Diamond–Shurman Thm 3.1.1) is a sum over the
  `SL₂(ℤ)`-**orbits** of points of `ℍ` — `ord_P(f)` is constant on an orbit, hence well-defined
  on it — with the two **elliptic orbits** `[i]`, `[ρ]` weighted by the reciprocal `1/e_P` of
  their stabilizer orders (`e_i = 2`, `e_ρ = 3`) and the cusp `∞` contributing `ord_∞`:
  ```text
  ord_∞(f) + ½·ord_i(f) + ⅓·ord_ρ(f) + Σ_{q ∈ (non-elliptic SL₂(ℤ)-orbits of ℍ)} ord_q(f) = k/12
  ```
  equivalently `Σ_{P ∈ SL₂(ℤ)\ℍ*} (1/e_P)·ord_P(f) = k/12` over the orbits of the extended
  upper half-plane `ℍ* = ℍ ∪ {cusps}`. ⚠ The summation index is **orbits in `ℍ`, not points** —
  the precise content of the formula `valence_formula_textbook` already proved, where the sum is
  `∑ᶠ (q : non-elliptic orbits), ord_q(f)`.
- The proof is the contour integral of `f'/f` around the fundamental-domain boundary; `i` and `ρ`
  sit **on** that contour, so their `½` and `⅓` weights are the Hungerbühler–Wasem generalized
  winding numbers of points on a cycle (Contour roadmap) — the precise reason the elliptic weights
  are `1/e_P`.
- **General level:** push to a finite-index `Γ ≤ SL₂(ℤ)` via the degree-`[SL₂(ℤ):±Γ]` covering,
  giving `Σ_{P ∈ Γ\ℍ*} (1/e_P)·ord_P(f) = k·[SL₂(ℤ):±Γ]/12` over the `Γ`-orbits, the input both to
  low-weight vanishing and to the dimension formulas (Layer 10).

### Layer 2: Hecke operators and the Hecke algebra
- **(a) The abstract Hecke ring.** Double cosets `Γ\ΔΓ` for a Hecke pair `(Γ, Δ)`, the convolution
  product, and **commutativity** of the `GL₂` Hecke algebra. Build on Mathlib's
  `GroupTheory/DoubleCoset`; the finiteness that makes the product well-defined is that
  `Γ ∩ gΓg⁻¹` has finite index, so `ΓgΓ = ⊔ᵢ gᵢΓ` is a finite union of right cosets. Keep this
  abstract ring separate from its action, so the structural facts (commutativity, generation by
  `T_p`, `⟨p⟩`) are proved once.
- **(b) The action on forms.** `Tₙ`, `Tₚ` as `ℂ`-linear endomorphisms of `M_k(N,χ)` and
  `S_k(N,χ)`, the ring homomorphism `𝕋 → End_ℂ(M_k(N,χ))`, and the explicit **`q`-expansion
  recurrences**
  ```lean
  -- a_m(T_p f) = a_{mp}(f) + χ(p) p^{k-1} a_{m/p}(f)   (p ∤ N case), etc. (Diamond–Shurman §5.2–5.3)
  def heckeOp (N : ℕ) (k : ℤ) (χ : DirichletCharacter ℂ N) (n : ℕ) : Module.End ℂ (ModularFormWithChar N k χ)
  ```
  with `Tₘ Tₙ = Tₘₙ` for `(m,n)=1` and the prime-power recurrence.
- **The diamond operators `⟨d⟩` are elements of this Hecke algebra** — the operators from the
  double cosets of `Γ₀(N)/Γ₁(N) ≅ (ℤ/N)ˣ`. On `M_k(N, χ)` (defined in Layer 0) they act by the
  scalar `χ(d)`; conversely, decomposing `M_k(Γ₁(N))` into the simultaneous `⟨d⟩`-eigenspaces
  **recovers** Layer 0's nebentypus decomposition. Characters come first; the diamond operators
  live here, as part of the Hecke action — not the other way round.
  ⚠ The action must preserve cuspidality and the nebentypus; prove that, don't assume it.

- **(c) The full smooth adelic Hecke algebra, and the Shimura link.** Reconstruct the Hecke algebra
  the modern way — as the adelic convolution algebra — and identify the abstract double-coset ring
  of (a) as a level-`K` corner of it. State everything for `G_f := GL₂(𝔸_f)`, the finite adeles of
  `ℚ`; the same construction over a general reductive group `𝐆(𝔸_{F,f})` is deferred to the
  [Reductive groups roadmap](../ReductiveGroups/README.md), which this layer will cite for the
  general definition once it provides `𝐆(𝔸_{F,f})`.
  - **The full algebra** `ℋ(G_f) := C_c^∞(G_f)` — the compactly supported, **locally constant**
    `ℂ`-valued functions on `G_f`. ⚠ At the finite places "smooth" means *locally constant*, not
    differentiable: `G_f` is totally disconnected. Fix a Haar measure `dg` on `G_f` and the
    **convolution** product
    ```text
    (f₁ * f₂)(g) = ∫_{G_f} f₁(x) · f₂(x⁻¹ g) dx,
    ```
    making `ℋ(G_f)` an associative `ℂ`-algebra (the left/right convention is a choice — pin one).
  - **The action on smooth representations.** A smooth `G_f`-representation `V` (every vector fixed
    by some compact open) carries `π(f) v = ∫_{G_f} f(g) · π(g) v dg`; so `ℋ(G_f)` acts on every
    level at once, the finite-adelic space of automorphic forms being the motivating `V`.
  - **The level-`K` corner = Shimura's abstract ring (a).** For a compact open `K ⊂ G_f` with
    idempotent `e_K := 𝟙_K / vol(K)`,
    ```text
    ℋ_K := e_K · ℋ(G_f) · e_K = C_c^∞(K \ G_f / K),
    ```
    the `K`-bi-invariant convolution algebra, **is exactly the abstract double-coset Hecke ring of
    (a) at level `K`**: normalising `vol(K) = 1`, the basis element `𝟙_{KgK}` is the double-coset
    operator, and on `K`-fixed vectors `π(𝟙_{KgK}) v = Σᵢ π(gᵢ) v` when `KgK = ⊔ᵢ gᵢ K`. So
    Shimura's formalism is reconciled with the adelic one — it is the level corner — and the
    classical `Tₙ, Tₚ, ⟨d⟩` of (b) are its `K₀(N)` / `K₁(N)`-level elements.
  - **The full algebra as a filtered union of levels** `ℋ(G_f) = ⋃_K ℋ_K` over compact opens:
    shrinking `K` enlarges the corner (`K' ⊂ K ⟹ ℋ_K ⊂ ℋ_{K'}`, since every `K`-bi-invariant
    function is `K'`-bi-invariant).
  - **The restricted tensor product and the unramified (spherical) algebra.**
    `ℋ(GL₂(𝔸_f)) ≅ ⊗'_v ℋ(GL₂(ℚ_v))` over the finite places `v`, the restricted tensor product
    taken with respect to the idempotents `e_{K_v}` of the hyperspecial `K_v = GL₂(ℤ_v)` for almost
    all `v`, with each local factor `ℋ(GL₂(ℚ_v)) = C_c^∞(GL₂(ℚ_v))`. Away from a finite bad set `S`,
    the **unramified Hecke algebra** `ℋ^S := ⊗'_{v∉S} C_c^∞(K_v \ GL₂(ℚ_v) / K_v)` is commutative,
    generated by the `T_p` and the determinant/diamond operators at `p ∉ S` — the natural home for
    the eigenform theory of Layers 3–5.
  - ⚠ **Grounding.** Mathlib has the finite adeles (`DedekindDomain.FiniteAdeleRing`), double
    cosets, compact-open subgroups, and Haar/measure convolution, but not this assembly: the
    locally-constant `C_c^∞` space, its convolution algebra and smooth action, the `e_K` level
    corners, and the restricted tensor product are the milestones of this sub-layer.

### Layer 3: the Petersson inner product, adjoints, oldforms and newforms
- **The Petersson inner product** as a genuine positive-definite Hermitian inner product on
  `S_k(Γ)` (integrate Mathlib's `petersson` integrand over a fundamental domain), and **`Tₙ` is
  self-adjoint** for `(n,N)=1` (`⟨T_n f, g⟩ = ⟨f, T_n g⟩`), so the Hecke algebra away from the
  level is simultaneously diagonalizable.
- **Oldforms and newforms (the spaces):** the old subspace `S_k(N)^{old}` spanned by
  level-raising images `f(τ), f(dτ)` from proper divisors, the **new** subspace `S_k(N)^{new}` as
  its Petersson-orthogonal complement, and their orthogonality and `Tₙ`-stability.

### Layer 4: eigenforms, newforms, primitive forms; the conductor
- **Definitions:**
  ```lean
  structure Eigenform (N : ℕ) (k : ℤ) (χ : DirichletCharacter ℂ N) where
    toCuspForm : CuspForm (Gamma1 N) k
    isEigen    : ∀ n, (n.Coprime N) → ∃ a, heckeOp N k χ n toCuspForm = a • toCuspForm
    -- `normalized`: a₁ = 1;  `Newform`: a normalized eigenform in the new subspace
  ```
  with `Eigenform`, normalized eigenform, `Newform`, `Oldform`, and `primitive form` (= newform),
  and the eigenvalue API `aₙ`/`ringEigenvalue`.
- **The Main Lemma** (the Atkin–Lehner key lemma, Diamond–Shurman Lemma 5.7.1 / Miyake 4.6.x): a
  cusp form whose `q`-expansion is supported on multiples of a prime descends or vanishes.
  **Discharge the two AINTLIB `sorry`s here** — the Atkin–Lehner Main Lemma and the existence of a
  nonzero prime eigenvalue.
- **The conductor theorem** (Miyake 4.6.4 / Diamond–Shurman Prop 5.8.4): every normalized
  eigenform `g ∈ S_k(N,χ)` equals the level-raise of a **newform** of a unique level `M ∣ N`, the
  **conductor** of `g`; the dichotomy on `ℓ·cond(χ) ∣ N`.

### Layer 5: strong multiplicity one and the eigenform characterization
- **Strong multiplicity one** (Diamond–Shurman Thm 5.8.2 / Miyake Thm 4.6.12): two newforms in
  `S_k(Γ₁(N))^{new}` with `aₚ(f) = aₚ(g)` for almost all `p` are equal; each `Tₙ`-eigenspace is
  one-dimensional and the newforms are an orthogonal basis of the new subspace.
- **Diamond–Shurman Proposition 5.8.5** (the coefficient characterization): for `f ∈ M_k(N,χ)`,
  `f` is a normalized eigenform **iff** its Fourier coefficients satisfy
  ```text
  (1)  a₁ = 1
  (2)  a_{p^r} = a_p·a_{p^{r-1}} − χ(p)·p^{k-1}·a_{p^{r-2}}   for all primes p and r ≥ 2
  (3)  a_{mn} = a_m·a_n   whenever (m,n) = 1.
  ```
  This is the bridge to the Euler product (Layer 7): conditions (2)–(3) are exactly
  multiplicativity of the Dirichlet series.

### Layer 6: Atkin–Lehner and Fricke operators
- The Atkin–Lehner involutions `W_Q` for each exact divisor `Q ‖ N` (#18), the **Fricke
  involution** `W_N` (the `Q = N` slash by `[0,-1;N,0]`), their relations with `Tₙ` (commute away
  from `Q`), and on a newform the **signs** `W_Q f = ε_Q(f)·f` with `ε_Q ∈ {±1}` for real
  nebentypus, multiplying to the Fricke sign — the sign of the functional equation.

### Layer 7: L-functions
- **The L-function** `L(s,f) = Σ_{n≥1} aₙ(f)·n^{-s}`, its **convergence** (Diamond–Shurman Prop
  5.9.1: absolute for `Re s > k/2 + 1` on cusp forms, `> k + 1` otherwise), built on Mathlib's
  `LSeries`.
- **The Euler product** for a normalized eigenform (from Prop 5.8.5):
  `L(s,f) = ∏_p (1 − aₚ p^{-s} + χ(p) p^{k-1-2s})^{-1}` (#30).
- **The completed L-function** `Λ(s,f) = N^{s/2}(2π)^{-s}Γ(s)L(s,f)` via the Mellin transform of
  `f`, its **functional equation** `Λ(s,f) = ε·Λ(k−s, f|W_N)` (from Layer 6's Fricke involution and
  Hecke's argument), and **analytic continuation** to all of `ℂ`.
- **Analytic rank and analytic conductor** (#31): the order of vanishing of `L(f,·)` at the central
  point `s = k/2`, and the conductor `N·(…Γ-factor…)`.

### Layer 8: coefficient fields and the integral Hecke algebra
- **The coefficient field** `CoefficientField f = ℚ(aₙ : n) ⊆ ℂ` of a newform (#34), and the
  headline result that **it is a number field**:
  ```lean
  -- the coefficient ring/field of a newform is finite over ℤ/ℚ
  instance (f : Newform N k χ) : NumberField (CoefficientField f)
  theorem finrank_coeffField_eq_dim (f : Newform N k χ) :
      Module.finrank ℚ (CoefficientField f) = newformDim f
  ```
  proved via the **integral Hecke algebra is a finitely generated ℤ-module** (the integral
  `q`-expansion / Eichler–Shimura lattice, Shimura Thm 3.48/3.51/3.52, Miyake Thm 4.5.9/4.5.19).
  ⚠ This is the deepest current gap — the single substantive `sorry` (`heckeAlgℤ_finite`) in the
  AINTLIB body — and the lynchpin for the whole LMFDB layer.

### Layer 9: the LMFDB invariant layer
Each is a named definition with its basic API, mostly short once Layer 8 exists:
- **Hecke characteristic polynomials** (#35): `charpoly(Tₙ | S_k(N,χ)^{new})`, its coefficients as
  traces of Hecke operators, and the factorization into Galois orbits.
- **Satake parameters and angles** (#32): `α_p, β_p` the roots of `X² − aₚX + χ(p)p^{k-1}`,
  `θ_p = arg α_p`. The Ramanujan–Deligne bound `|aₚ| ≤ 2 p^{(k-1)/2}` is used **only to frame the
  definition** (it places `θ_p` on the real line); it is **not a target of this roadmap** — proving
  it needs the Weil conjectures and Deligne's reduction of Ramanujan to them, which are far outside
  the analytic scope here.
- **Galois-conjugate forms and orbits** (#38): `f^σ` (act on coefficients), the orbit `{f^σ}` and
  `#orbit = dim` of the newform; **inner twists** (#42).
- **Dual / self-dual** (#55): `f̄` (conjugate coefficients) and `IsSelfDual f ↔ ∀n, (aₙ).im = 0`.
- **Labels** (#33, #13): the LMFDB label `N.k.a.x` (level, weight, character Galois-orbit, newform
  Galois-orbit), Conrey labels and Galois orbits of Dirichlet characters.
- **Bad primes** (#54): `badPrimes f = N.primeFactors`.

### Layer 10: the modular curve `Γ\ℍ` and the dimension formulas
The modular curve here is the **analytic quotient `Γ\ℍ`**, compactified to a compact Riemann
surface `X(Γ) = Γ\ℍ*` by adjoining the cusps `Γ\ℙ¹(ℚ)` — defined directly, with **no functor, no
representability, no moduli problem**.

- **The analytic theory of cusps and compactification.** Build `X(Γ) = Γ\ℍ*` as a compact Riemann
  surface: the topology and complex charts at ordinary points, at the elliptic points (where the
  chart is `z ↦ z^{e_P}`), and at the cusps (the `q`-disc chart); the **cusp count** `ε∞ = #Γ\ℙ¹(ℚ)`
  and the **elliptic-point counts** `ε₂, ε₃` (periods `2, 3`); and the **genus** `g` of `X(Γ)` as
  the genus of this compact Riemann surface — via the Euler characteristic of the
  `SL₂(ℤ)\ℍ*`-covering (Diamond–Shurman §3.1, §3.9). These
  counts and the genus are the inputs to the dimension formulas; building them is part of this
  layer, not assumed.
- **The dimension formulas** (Diamond–Shurman Thm 3.5.1), by the **valence / counting route**:
  derive the dimension of `M_k(Γ)` and `S_k(Γ)` from the Layer-1 valence formula together with the
  `ε₂, ε₃, ε∞` counts and the genus `g` above, extending Mathlib's level-one
  `ModularForm.dimension_level_one` to general level. For **even `k`**:
  ```text
  dim M_k(Γ) = (k-1)(g-1) + ⌊k/4⌋·ε₂ + ⌊k/3⌋·ε₃ + (k/2)·ε∞          (k ≥ 2)
  dim S_k(Γ) = (k-1)(g-1) + ⌊k/4⌋·ε₂ + ⌊k/3⌋·ε₃ + (k/2 - 1)·ε∞      (k ≥ 4),   dim S_2(Γ) = g
  ```
  (`dim M_0 = 1`, `dim S_0 = 0`, both `0` for `k < 0`); the **odd-`k`** formulas (D–S §3.6) split
  the cusps into regular and irregular and drop the `ε₂` term. `dim S_2(Γ) = g` is the statement
  that weight-two cusp forms are the holomorphic differentials on `X(Γ)`.
- `Targets.lean` seeds this layer with concrete instances at levels `> 1`: `dim S_2(Γ₀(11)) = 1`,
  `dim S_2(Γ₀(23)) = 2`, `dim S_2(Γ₀(2)) = 0`, `dim M_2(Γ₀(11)) = 2`. The general even-weight
  formula above is the layer's headline target; it is stated here in the README (it needs the
  `ε₂, ε₃, ε∞, g` of `X(Γ)` from this same layer, so it is grounded), and is **not** seeded as a
  free-parameter `example` in `Targets.lean`, since with `g, ε₂, ε₃, ε∞` as free variables it is
  false for the wrong data. We keep only the concrete, verifiable instances and pin the general
  statement in prose.

## Worked examples (acceptance criteria, keeping the theory honest)

- **Δ at level one** (`k = 12`, `N = 1`): the unique normalized cusp form; `τ(p)` are its Hecke
  eigenvalues; `aₙ` multiplicative with the `τ(p^r)` recurrence (Prop 5.8.5). The first eigenvalue
  is concrete: **`T₂` acts on `Δ` by `−24`** (`a₂(Δ) = τ(2) = −24`, from the coefficient of `q²`
  in `Δ = q∏(1−qⁿ)²⁴`, equivalently `(E₄³ − E₆²)/1728`) — a fully computable acceptance test of the
  Hecke action (Layer 2).
- **Level 11, weight 2** (`S₂(Γ₀(11))`, dimension 1): a single newform, the elliptic curve `11a`;
  its Fricke sign (Layer 6) and the rank-0 functional equation (Layer 7).
- **Level 37, weight 2** (two newforms with opposite Atkin–Lehner signs): the multiplicity-one /
  sign acceptance test (Layers 5–6).
- **A newform with non-real `aₙ`** (CM coefficient field): `CoefficientField f` a genuine
  imaginary-quadratic field, not totally real — the coefficient-field acceptance test (Layer 8) and
  the not-self-dual test (Layer 9).
- **`η²⁴ = Δ`** as a weight-12 eta quotient (#19): develop `η = q^{1/24}∏(1−qⁿ)` and its `SL₂(ℤ)`
  transformation, and the Ligozat criterion, as an explicit worked example of a modular form rather
  than as general theory.
- **The aspirational coefficient-field summit — a weight-60 level-one eigenform with non-solvable
  coefficient field.** There is a normalized eigenform `f ∈ S₆₀(SL₂(ℤ))` whose coefficient field
  `CoefficientField f` has a Galois closure over `ℚ` that is **not solvable** — the first known
  example, computed by Buzzard in 1992 in answer to a question of Ramakrishnan
  ([*J. Number Theory* **57** (1996)](https://www.sciencedirect.com/science/article/pii/S0022314X96900396)).
  It is a finite, fully grounded computation once Layers 8–9 exist (the coefficient field of a
  level-one eigenform and its Galois group), and is the headline acceptance test for the
  coefficient-field layer.

## Ordering

Layer 0 (nebentypus) and Layer 2 (Hecke operators) are the trunk and come first; the valence
formula (Layer 1) is an independent early lane that only needs the Contour Integration roadmap.
Layers 3–5 (Petersson → newforms → strong multiplicity one) are the core arithmetic and must be
sequential. Layers 6–7 (Atkin–Lehner → L-functions) and Layer 8 (coefficient fields) consume
Layer 5; Layer 9 (LMFDB invariants) consumes Layer 8. Layer 10 (the modular curve `Γ\ℍ` and the
dimension formulas) consumes Layer 1 and is otherwise independent.

## Provenance (migrate and clean from AINTLIB `LeanModularForms`)

Secondary to the mathematics above: the migration map. Headline theorems are `sorry`-free in
AINTLIB unless flagged. Paths are relative to that project's `LeanModularForms/`.

- **Nebentypus / characters (L0):** `Chapters/CharacterSpaces.lean`,
  `HeckeRIngs/GL2/CharacterDecomp.lean`.
- **Valence formula (L1):** `Chapters/ValenceFormula.lean`, `Chapters/WindingElliptic.lean`, and
  the FD-boundary bridge (`ForMathlib/*FDBoundary*`, `*CornerFTC*`, `*CrossingAt*`) on top of the
  Contour Integration engine.
- **Hecke theory (L2):** `HeckeRIngs/AbstractHeckeRing/*` (abstract ring, commutativity),
  `HeckeRIngs/GL2/*` (`HeckeT_n`, `HeckeT_p`, `diamondOp`, `heckeRingHom`, `MultiplicationTable`),
  `Chapters/{HeckeOperators,GL2Operators,RingStructure,Commutativity}.lean`.
- **Petersson / old–new (L3):** `Chapters/{Petersson,AdjointSpectral}.lean`,
  `Modularforms/Petersson*.lean`, `HeckeRIngs/GL2/AdjointTheory*.lean`.
- **Newforms / conductor (L4):** `Chapters/NewformTheory.lean`, `HeckeRIngs/GL2/Newforms/*`
  (`Basic`, `FullEigenform`, `CoeffSeq`, `MainLemma`),
  `HeckeRIngs/GL2/Unified/EigenformFromRing.lean`,
  `Eigenforms/{ConductorTheorem,MainLemma}.lean` ← the two `sorry`s.
- **Strong multiplicity one (L5):** `Chapters/StrongMultiplicityOne.lean`,
  `SMOObligations/StrongMultiplicityOneFull.lean` (the `sorry`-free proof) and its chain; the
  §5.8.5 characterization in `HeckeRIngs/GL2/Newforms/{FullEigenform,CoeffSeq}.lean`.
- **Atkin–Lehner / Fricke (L6):** `Eigenforms/AtkinLehner.lean`, `HeckeRIngs/GL2/Fricke.lean`.
- **L-functions (L7):** `Modularforms/LFunction.lean`, completion/functional-equation pieces in
  `HeckeRIngs/GL2/Newforms/Fricke*.lean`.
- **Coefficient field (L8):** `Labels/HeckeFieldArithmetic.lean` ← the `heckeAlgℤ_finite` `sorry`,
  the lynchpin.
- **LMFDB layer (L9):** `Labels/{Label,Encoding,NewformOrbit,CharacterOrbit}.lean`,
  `Eigenforms/AtkinLehner.lean` (signs), `Chapters/CharacterSpaces.lean`.
- **Dimensions / curve (L10):** `Chapters/{Dimensions,Curves}.lean`,
  `Modularforms/DimensionFormulas.lean` (`dim_gen_cong_levels`, `cuspform_weight_lt_12_zero`) give
  the level-one valence/counting route and the finite-dimensionality; the general-level analytic
  cusp/compactification theory and the general dimension formula are **new** here.

The two structural audits `.mathlib-quality/{newforms,eigenforms-smo}-overview-2026-05-31.md`
catalogue the redundancy to collapse during migration.

## References

- F. Diamond, J. Shurman, *A First Course in Modular Forms* (GTM 228): Ch. 3 (dimension formulas,
  the genus, the analytic theory of `Γ\ℍ*`), Ch. 5 (Hecke operators, newforms, Thm 5.8.2, Props
  5.8.4–5.8.5, §5.9 L-functions).
- T. Miyake, *Modular Forms*: §4.5–4.6 (the integral structure, the conductor theorem, and strong
  multiplicity one Thm 4.6.12) — the numbering the AINTLIB code follows.
- G. Shimura, *Introduction to the Arithmetic Theory of Automorphic Functions*: Ch. 3 (the Hecke
  algebra and its integral structure, Thms 3.48/3.51/3.52).
- B. Edixhoven, *Modular forms, Galois representations and the adelic Hecke algebra* (course notes):
  modular forms as `K`-invariants in an adelic space, with Hecke operators via adelic double cosets —
  the adelic view of Layer 2(c).
- J. R. Getz, H. Hahn, *An Introduction to Automorphic Representations* (Springer, GTM): the smooth
  adelic Hecke algebra `C_c^∞(GL₂(𝔸_f))` with convolution, the `e_K`-corner `C_c^∞(K\G_f/K)`, and the
  restricted tensor product over the finite places — the construction planned in Layer 2(c).
- K. Buzzard, *On the eigenvalues of the Hecke operator T₂*, J. Number Theory **57** (1996) — the
  weight-60 non-solvable coefficient-field example (worked examples).
- N. Hungerbühler, M. Wasem, *Non-integer valued winding numbers and a generalized Residue
  Theorem*, arXiv:1808.00997 — the contour-integration engine behind the valence formula's
  elliptic-point weights (see the [Contour Integration roadmap](../ContourIntegration/README.md)).
- A. Atkin, J. Lehner, *Hecke operators on Γ₀(m)*; W. Stein, *Modular Forms: A Computational
  Approach* (the small-level dimension tables). The **LMFDB** (`https://www.lmfdb.org`) knowls
  fixed by the target definitions.

## Acknowledgements

The body of theory is **migrated and cleaned** from the AINTLIB `LeanModularForms` project
([github.com/CBirkbeck/AINTLIB](https://github.com/CBirkbeck/AINTLIB)), where the headline results
are already `sorry`-free; thanks to its authors. The target definitions discharge a large set of
"def-wanted" specifications from the [LeanBridge](https://github.com/CBirkbeck/LeanBridge)
project: issues #13, #18, #19, #30–#35, #37, #38, #42, #54, #55. The Contour Integration engine the valence
formula depends on is the sibling [Contour Integration roadmap](../ContourIntegration/README.md).
