# Tau Ceti Roadmap

The human-controlled roadmaps for [Tau Ceti](https://github.com/FormalFrontier/TauCeti), an
AIs-welcome Lean 4 library downstream of Mathlib. Humans steer the project from here: each
roadmap is markdown plus Lean target signatures (with `sorry`, which is allowed in this repo
because these are goals, not proofs). The AI-authored mathematics that discharges them lives
in the code repo; review machinery lives in
[TauCetiReview](https://github.com/FormalFrontier/TauCetiReview).

Tau Ceti is being incubated jointly by the [Lean FRO](https://lean-lang.org/fro/) and the
[Mathlib Initiative](https://mathlib-initiative.org/), in partnership with academic and
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

## How changes are made

Anyone can open a pull request against a roadmap. It merges automatically once it has an
approving review from a member of the `@FormalFrontier/roadmap-reviewers` team (the code owners
for roadmap content) and the `build` check passes. Infrastructure files (the workflows, the
Lake config, the toolchain pin) stay with the core `@FormalFrontier/humans` team.

The reviewer pool grows itself: a contributor who lands two merged roadmap PRs is added to
`roadmap-reviewers` automatically, so people who have demonstrably moved a roadmap forward can
start approving others' roadmap work.

## Building

```bash
lake exe cache get
lake build
```
