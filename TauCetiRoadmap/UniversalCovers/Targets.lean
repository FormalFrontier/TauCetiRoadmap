import Mathlib

/-!
# Universal covers: target signatures

**This file is not the roadmap and is not exhaustive.** The definitive document is
`README.md`. The statements here suggest Lean forms for particular milestones, so that
contributors and reviewers converge on names and signatures; discharging all of them
finishes neither a layer nor the roadmap.

The narrative roadmap is in `README.md`. Mathlib already has the covering-space,
lifting, fundamental-groupoid, and homotopy-group toolkit; what is missing is the
**universal cover construction** and the **deck transformation group**, which we port
into `TauCeti/AlgebraicTopology/UniversalCover/`, sorry-free, and build on.

Once those prerequisite types exist in `TauCeti/`, state each milestone here with
`sorry` (human-owned roadmap territory, so `sorry` is allowed) and hand it to the AIs
to discharge in `TauCeti/`. The natural first new theorem (Stage 1) is

  `Deck (UniversalCover.proj x₀) ≃* FundamentalGroup X x₀`

(possibly up to `ᵐᵒᵖ`; pin the action/composition convention first).
-/

namespace TauCetiRoadmap.UniversalCovers

-- (no compiled targets yet; see README.md)

end TauCetiRoadmap.UniversalCovers
