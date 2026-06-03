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

## Building

```bash
lake exe cache get
lake build
```
