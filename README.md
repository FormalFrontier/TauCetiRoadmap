# Tau Ceti Roadmap

The human-controlled roadmaps for [Tau Ceti](https://github.com/FormalFrontier/TauCeti), an
AIs-welcome Lean 4 library downstream of Mathlib. Humans steer the project from here: each
roadmap is markdown plus Lean target signatures (with `sorry`, which is allowed in this repo
because these are goals, not proofs). The AI-authored mathematics that discharges them lives
in the code repo; review machinery lives in
[TauCetiReview](https://github.com/FormalFrontier/TauCetiReview).

Tau Ceti is being incubated by the [Lean FRO](https://lean-lang.org/fro/) in partnership with academic and
industry groups.

## Roadmaps

1. [Universal covers](TauCetiRoadmap/UniversalCovers/README.md)
2. [The Jacobian challenge](TauCetiRoadmap/JacobianChallenge/README.md)
3. [Reductive algebraic groups](TauCetiRoadmap/ReductiveGroups/README.md)
4. [Partial differential equations](TauCetiRoadmap/PDE/README.md)
5. [Combinatorial Heegaard Floer and grid homology](TauCetiRoadmap/CombinatorialHeegaardFloer/README.md)
6. [Heegaard Floer homology, analytically](TauCetiRoadmap/HeegaardFloer/README.md)
7. [Multiquadratic fields and genus theory](TauCetiRoadmap/Multiquadratic/README.md)
8. [Effective arithmetic bounds and geometry of numbers](TauCetiRoadmap/EffectiveBounds/README.md)
9. [Geometric topology and the Kirby-list problems](TauCetiRoadmap/GeometricTopology/README.md)
10. [One-parameter semigroups, completely monotone functions, and BCR Bochner](TauCetiRoadmap/OneParameterSemigroups/README.md)
11. [Exchangeability and de Finetti](TauCetiRoadmap/Exchangeability/README.md)
12. [Conformal mapping and the geometric theory of holomorphic functions](TauCetiRoadmap/ConformalMapping/README.md)
13. [Weighted orthogonal L² bases: completeness, Hilbert bases, and products of orthogonal systems](TauCetiRoadmap/OrthogonalL2Bases/README.md)

## Writing a roadmap

A roadmap is a specification for work we want done, written so an AI contributor, and its
reviewers, can act on it without guessing.

- **Build the library, don't race to the theorem.** For each object you introduce, ask for its
  complete basic theory, not just the lemma the headline needs.
  Named theorems are milestones inside a fuller development, not the whole of it.

- **Everything is grounded, with no leaps.** Every milestone must rest on existing Mathlib or
  Tau Ceti material, on earlier material in the same roadmap, or on an explicitly cited
  dependency in another roadmap. Anything else is a leap: a forward reference to a later layer, a
  connection between two developments that nobody builds, an object named but never made a
  target. If the roadmap needs something that doesn't exist, building it must itself be a target,
  here or in a roadmap you cite. The bigger the gap, the worse AIs do with it.

- **Use Mathlib's vocabulary.** Where Mathlib already has a way to say something, use it rather
  than a private version, both in the roadmap and in the code. A standard notion said in our own
  dialect drifts from the library it builds on and grows a redundant theory of lemmas Mathlib
  already proves. Boundedness is the example: Mathlib has no "bounded on a set" predicate, so a
  result that needs an explicit bound carries `∀ x ∈ s, ‖f x‖ ≤ C` directly in its hypotheses (as
  in `norm_cfc_le`), and uses `Bornology.IsBounded` when no constant is needed
  (`isBounded_iff_forall_norm_le'` relates the two). We do the same, and never wrap a one-line
  bound in a new predicate. When Mathlib's name for something is itself a Mathlib-ism that a
  mathematician would not recognize (`ModularFormClass`, say), link the Mathlib declaration the
  first time you use it, so a reader can see what the term denotes rather than guess.

- **Specify the mathematics, not your existing code.** Say what each milestone should prove,
  intrinsically, so a reviewer can judge it on its own terms. If you're porting existing work,
  keep the file-by-file map in a clearly secondary provenance section, so reviewers don't treat
  your code as the standard.

- **Nothing is "optional".** Don't use the word, and don't imply it. Everything on a roadmap is
  work we want. Sequencing is good, so split into milestones and put the harder material later,
  but every item lives in *some* milestone, or a contributor reads "later" as "never".

- **Do things right the first time.** Decide the generality up front and write it down. Don't
  recommend intermediate implementations that will be replaced later.

- **Write Lean code.** It's really helpful to prototype signatures, particularly for structures,
  classes, and definitions, by writing Lean code, either embedded in markdown or in associated
  Lean files using `sorry`.

- **Pin conventions.** It's essential that you decide conventions ahead of time, or implementors
  will make bad decisions.

## How changes are made

Anyone can open a pull request against a roadmap. It merges automatically once it has an
approving review from a member of the `@FormalFrontier/roadmap-reviewers` team (the code owners
for roadmap content) and the `build` check passes. Infrastructure files (the workflows, the
Lake config, the toolchain pin) stay with the core `@FormalFrontier/humans` team.

The reviewer pool grows itself: a contributor who lands two merged roadmap PRs is added to
`roadmap-reviewers` automatically, so people who have demonstrably moved a roadmap forward can
start approving others' roadmap work.

## Coordinating work: intentions and claims

To avoid two contributors (human or AI) building the same thing, register what you intend to
work on and claim it. This is powered by the
[intentions bot](https://github.com/leanprover-community/intentions) and the project board.

1. **Register an intention.** Open an issue with the **Intention** template: pick the roadmap
   area and list the specific targets you mean to take (keep the scope as narrow as you can, so
   the rest stays open for others).
2. **Claim it.** Comment `claim` on the issue. The bot assigns it to you and moves it to
   *Claimed* on the board. For a custom window, comment `claim 3 weeks` or `claim 2026-08-01`;
   bare `claim` uses the project default.
3. **It expires.** Claims carry a time-to-live (30 days by default, 90 days max) and are
   released automatically if they go stale, so nothing stays blocked forever. Comment `claim`
   again to extend, or `disclaim` to release early. Opening a PR that says `Closes #<issue>`
   advances the card and refreshes the claim; merging it completes the task.

Automated roadmap workers **respect these claims**: within an area they will not author a
target that someone else has claimed. So before a substantial push, register and claim it. A
claim is cooperative, not a hard lock; it signals intent so others (people and workers) can
steer around you.

Use the **Roadmap issue** template to report a problem with a roadmap's content, and the
**Meta** template for problems with how this repository operates.

## Building

```bash
lake exe cache get
lake build
```
