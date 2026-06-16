# Roadmap: multiquadratic fields and genus theory

Mathlib has quadratic fields, Kummer theory, quadratic reciprocity, and the class group,
but **nothing on multiquadratic extensions** `ℚ(√d₁, …, √dₙ)`: their degree, their
elementary-abelian Galois group, or the genus theory of quadratic fields that they
encode. Genus theory is the first, explicit, computable slice of class field theory, and
it is entirely absent upstream. We build the multiquadratic theory here, and use it to
reach the genus-field description of the 2-part of the class group.

Suggested home: `TauCeti/NumberTheory/Multiquadratic/`.

The Layer-0 square-class machinery (the descent lemma, the degree computation) already
exists, sorry-free, inside the one-theorem formalization
[kim-em/erdos-unit-distance](https://github.com/kim-em/erdos-unit-distance) (Alpöge's
disproof of the uniform-constant Erdős unit-distance conjecture), where it was specialised
to one CM field. The first targets here **generalise and migrate** that machinery; credit
that source (and Alpöge for the mathematics it was written for) in each ported file.

Migration sources, pinned at commit `140edda5974ec5afb8beefdbb3014d93d92bdc64`:
- `ErdosUnitDistance/MultiquadraticField.lean`: `sqrtTower`, `mem_sup_adjoin_sq`,
  `squareClass_of_sqrt_mem`, `sqrtTower_finrank` (port in that order; the first three are
  the descent engine, the last is the degree computation built on them).
- `ErdosUnitDistance/IdealFamily.lean`: `exists_transversal_family` (the Dedekind-domain
  transversal count, an independent migration).
- `ErdosUnitDistance/ClassNumber.lean`: `units_sq_index_le` and its abstract input
  `index_powMonoidHom_two_le_of_closure` (shared with the effective-bounds roadmap).

## Standing hypotheses

Spell hypotheses out; do not bundle them. Work over a base field `K` and an extension
`L ⊇ K` holding the square roots, with `[CharZero K]` (or at least `[NeZero (2 : K)]`,
since the whole theory is false in characteristic 2). The radicands are a family `d : ι → K`
over a finite index `ι`; their chosen square roots are `r : ι → L` with
`r i ^ 2 = algebraMap K L (d i)`.

The one real hypothesis is **square-class independence**: the classes of the `d i` in
`Kˣ ⧸ (Kˣ)²` are `ZMod 2`-linearly independent. The workable, elaboration-friendly form
of this is

> no nonempty subset product `∏_{i ∈ S} d i` is a square in `K`,

and that is the form the degree theorem assumes. (Singleton subsets already force each
`d i ≠ 0`, since `0` is a square; no separate nonvanishing hypothesis is needed.) An early
intermediate target should connect this `Finset` form to genuine `ZMod 2`-linear
independence in `Kˣ ⧸ (Kˣ)²`, the form the Galois-theoretic arguments
want. ⚠ Do **not** bake `K = ℚ` or a specific
prime sequence into the main statements: prove the field-generic theorem, then derive the
rational and prime-indexed versions (the genus-theory inputs) as corollaries.

## What Mathlib already has (consume)

- **Adjoining roots / Kummer theory:** `Mathlib/FieldTheory/IntermediateField/Adjoin/*`
  (`IntermediateField.adjoin`, `adjoin_simple`, `finrank` of `adjoin` of one element),
  `Mathlib/FieldTheory/KummerExtension.lean` (degree of `K(ⁿ√a)`), and the quadratic
  special cases under `Mathlib/Algebra/QuadraticDiscriminant.lean`.
- **Galois theory:** `Mathlib/FieldTheory/Galois/Basic.lean` (`IsGalois`, the
  `Aut`-fixed-field correspondence), `Mathlib/FieldTheory/Normal/Basic.lean`,
  `Mathlib/FieldTheory/PrimitiveElement.lean`.
- **Reciprocity for the splitting law:** `Mathlib/NumberTheory/LegendreSymbol/*`
  (`legendreSym`, quadratic reciprocity, the supplements), the input to "which primes
  split in `ℚ(√d)`".
- **Class group:** `Mathlib/RingTheory/ClassGroup.lean`,
  `Mathlib/NumberTheory/NumberField/ClassNumber.lean`, and the ramification/inertia API
  `Mathlib/NumberTheory/RamificationInertia/*` and
  `Mathlib/RingTheory/DedekindDomain/*` for the splitting and genus-field layers.
- **CM fields** (the multiquadratic CM fields are examples):
  `Mathlib/NumberTheory/NumberField/CMField.lean`.

## What is missing (build here)

The multiquadratic field `ℚ(√d₁, …, √dₙ)` as a structured object: its **degree** `2ⁿ`
under square-class independence; its **Galois group** `(ℤ/2)ⁿ`; the lattice of
subfields ↔ subspaces of `𝔽₂ⁿ`; the **prime-splitting law** in terms of the quadratic
residue symbols of the `dⱼ`; the **2-torsion of the class group** `Cl/Cl²`; and the
**genus field** with the resulting 2-rank formula. None of this is upstream.

---

## The build, in layers

The ordering below is the dependency order. As each layer makes the next layer's *types*
expressible in `TauCeti/`, state its milestones in `Targets.lean` (with `sorry`).

### Layer 0: the multiquadratic field
- **Square-class descent.** If `√r ∈ K(√d₁, …, √dₙ)` for `r ∈ K`, then `r` is a square
  times a subset product `∏_{j ∈ T} dⱼ`. This is the engine; it is what is migrated from
  erdos-unit-distance (`squareClass_of_sqrt_mem`, `mem_sup_adjoin_sq`, the iterated tower
  `sqrtTower`).
- **Degree.** Under square-class independence, `[K(√d₁,…,√dₙ) : K] = 2ⁿ` (migrated and
  de-specialised from `sqrtTower_finrank`).
- **Galois group.** `K(√d₁,…,√dₙ)/K` is Galois with group `(ℤ/2)ⁿ`, generated by the sign
  changes `√dⱼ ↦ ±√dⱼ`; the intermediate fields correspond to `𝔽₂`-subspaces.
  ⚠ Split the work: the `IsGalois` and exponent-2 / abelian facts are the easy half; the
  explicit `Gal ≅ (ℤ/2)ⁿ` isomorphism needs the sign-change automorphism API and the
  degree theorem first, so it comes after.

### Layer 1: the prime-splitting law
- **First theorem, stated this precisely:** for squarefree integers `d₁, …, dₙ` and an
  odd prime `p ∤ d₁ ⋯ dₙ`, `p` splits completely in `ℚ(√d₁,…,√dₙ)` iff
  `legendreSym p dⱼ = 1` for every `j`; more generally the Frobenius at `p` is the vector
  `((d₁/p), …, (dₙ/p))` under `Gal ≅ (𝔽₂)ⁿ`. Rational radicands reduce to this integral
  squarefree case by square classes. This is one packaging of quadratic reciprocity;
  consume `LegendreSymbol/*`.
- ⚠ **Ramification at 2 is the trap.** The discriminant of `ℚ(√d)` is `d` or `4d`
  according to `d mod 4`; the right generators of the genus field are the **prime
  discriminants** (`−4, ±8, p* = (−1)^((p−1)/2) p`), not the squarefree `dⱼ`. State the
  splitting law away from the ramified primes first.
- **Reusable infrastructure:** the conjugate-ideal transversal count
  (`exists_transversal_family`, a Dedekind-domain lemma) migrates here independently.

### Layer 2: the 2-elementary quotient of the class group
- The squaring map on `Cl(K)` and the quotient `Cl(K)/Cl(K)²`. ⚠ Call it what it is:
  this is the maximal elementary-2 **quotient**, not the 2-torsion subgroup `Cl(K)[2]`;
  they have the same cardinality for a finite abelian group but are different objects,
  keep them distinct in names and statements. Also here: the unit-square-class input
  `[O_K^× : (O_K^×)²]` (migrated as `units_sq_index_le`); the ambiguous-class-number
  formula.

### Layer 3: the genus field and the 2-rank theorem (the summit)
- The **genus field** `K_gen`: the maximal extension of `K = ℚ(√d)` unramified at all
  places (the infinite ones included) and abelian over `ℚ`. Prove it is
  **multiquadratic** (the compositum of the `ℚ(√p*)` for the prime discriminants
  dividing `disc K`, so Layer 0 applies) and prove `Gal(K_gen/K) ≅ Cl(K)/Cl(K)²`. (This
  isomorphism holds for real and imaginary `K` alike: the nontrivial automorphism acts on
  `Cl(K)` by inversion, since `I · σI` is principal, so the commutator subgroup of
  `Gal(H/ℚ)` is exactly `Cl(K)²`.)
- ⚠ **The 2-rank formula `= t − 1`** (with `t` the number of ramified primes) **is a
  theorem about the *narrow* class group.** For imaginary `K` narrow = ordinary, so state
  and prove the formula there first. For real `K` the ordinary 2-rank can drop (`ℚ(√3)`
  has `t = 2` but class number `1`), and the `t − 1` count needs the narrow class group
  and the narrow genus field (unramified at finite places only). Mathlib has neither;
  defining the narrow class group is part of this layer and the prerequisite for the real
  case.

### Long horizon (aspiration, not required for the early extraction)
Explicit Kronecker–Weber for the abelian-over-`ℚ` case (every multiquadratic field embeds
in a cyclotomic field, via Gauss sums); the Hilbert class field, of which the genus field
is the part cut out by `Cl/Cl²`; ring class fields. These set the direction; the roadmap
proper is Layers 0–3.

## Worked examples (acceptance criteria, keeping the definitions honest)

Discharge these alongside the layers; they catch a vacuous degree or a wrong genus field:
- `[ℚ(√2, √3) : ℚ] = 4` (the smallest nontrivial multiquadratic degree).
- `ℚ(√−5)` has class number 2 and genus field `ℚ(√−1, √5)`; its 2-rank is `1 = t − 1`
  with `t = 2` ramified primes (`2`, `5`).
- `ℚ(√−21)` (discriminant `−84`) has class group `(ℤ/2)²` and genus field
  `ℚ(√−1, √−3, √−7)` (the prime discriminants `−4, −3, −7`), of degree 4 over it; its
  2-rank is `2 = t − 1` with `t = 3` ramified primes (`2`, `3`, `7`).
- The erdos CM field `ℚ(i, √q₀, …, √q_{g−1})` recovered as a multiquadratic field of
  degree `2^{g+1}`: the general theory must reproduce what the bespoke proof needed.

## Ordering

Layer 0 first (degree, then Galois), because everything rests on it and most of it is a
migration. Layer 1's splitting law and Layer 2's `Cl/Cl²` are independent lanes that can
proceed in parallel once Layer 0's types exist; Layer 3 needs all three.

## References

- D. A. Cox, *Primes of the Form x² + ny²* (genus theory, ring class fields).
- F. Lemmermeyer, *Reciprocity Laws: from Euler to Eisenstein* (genus theory, the genus
  field).
- H. Cohen, *A Course in Computational Algebraic Number Theory* (class groups, the
  2-rank).
- S. Kuroda, *Über den Dirichletschen Körper* (multiquadratic fields).

## Acknowledgements

The Layer-0 square-class and degree machinery is migrated from
[kim-em/erdos-unit-distance](https://github.com/kim-em/erdos-unit-distance), where it was
written (specialised to one CM field) for the formalization of Alpöge's disproof of the
uniform-constant Erdős unit-distance conjecture. Thanks to its authors.
