# Tau Ceti Roadmap

The human-controlled roadmaps for [Tau Ceti](https://github.com/FormalFrontier/TauCeti), an
AIs-welcome Lean 4 library downstream of Mathlib. Humans steer the project from here: each
roadmap is markdown plus Lean target signatures (with `sorry`, which is allowed in this repo
because these are goals, not proofs). The AI-authored mathematics that discharges them lives
in the code repo; review machinery lives in
[TauCetiReview](https://github.com/FormalFrontier/TauCetiReview).

## Roadmaps

1. [Universal covers](TauCetiRoadmap/UniversalCovers/README.md)
2. [The Jacobian challenge](TauCetiRoadmap/JacobianChallenge/README.md)
3. [Reductive algebraic groups](TauCetiRoadmap/ReductiveGroups/README.md)
4. [Partial differential equations](TauCetiRoadmap/PDE/README.md)
5. [Heegaard Floer and knot Floer homology](TauCetiRoadmap/HeegaardFloer/README.md)
6. [Multiquadratic fields and genus theory](TauCetiRoadmap/Multiquadratic/README.md)

## How changes are made

Anyone can open a pull request against a roadmap. It merges automatically once it has an
approving review from a member of the `@FormalFrontier/roadmap-reviewers` team (the code owners
for roadmap content) and the `build` check passes. Infrastructure files — the workflows, the
Lake config, the toolchain pin — stay with the core `@FormalFrontier/humans` team.

The reviewer pool grows itself: a contributor who lands three merged roadmap PRs is added to
`roadmap-reviewers` automatically, so people who have demonstrably moved a roadmap forward can
start approving others' roadmap work.

## Building

```bash
lake exe cache get
lake build
```
