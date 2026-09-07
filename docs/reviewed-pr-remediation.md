# Reviewed pull-request remediation

This work reviews eight open BIT pull requests against master `5d669389a1de56774450c13073a31cd422912f0f`. GitHub checks also found no open BGSD or Counter Tray Designer pull requests. The original PR heads remained unchanged when rechecked during implementation. The user authorized implementing the review decisions; this follow-up does not merge the original PRs.

| PR | Should it be addressed? | Optimal as submitted? | Implemented determination |
|---|---|---|---|
| [#102](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/102) | Yes; enclosed letter centers detach. | Almost; per-label depth is missing. | Retain the shallow recess and share global/per-label depth precedence. |
| [#103](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/103) | Yes; solid labels engrave the wrong face. | Yes for the production fix. | Use the exterior face and add measured face/depth coverage. |
| [#104](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/104) | Yes; detached text fails to align. | No; sliding and assembled placement remain incomplete. | Share the complete host/text transform and actual surface thickness; test real print-group selection. |
| [#95](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/95) | Yes; patterns omit supported edge geometry. | No; fixed padding still fails at 70 degrees. | Calculate complete lattice bounds while preserving centering, stagger, and polygon shapes. |
| [#91](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/91) | Yes as an optional feature. | Requires a v4 port. | Add native triangle/pentagon constants, validation, cavity/chamfer geometry, documentation, and matching BGSD options. |
| [#92](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/92) | Yes; useful published design. | Yes. | Include the verified Nature organizer link. |
| [#89](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/89) | Yes; useful published design. | Yes after destination verification. | Include the wormhole box link; normal browser access verified identity, files, and BIT credit. |
| [#86](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/pull/86) | Yes for verified contributions. | Partially ready. | Include verified Nemesis; keep Mezo, Pagan, and Puerto Rico pending ordinary destination verification. |

The three unresolved destinations presented access challenges. No broken-link finding or access bypass is implied. The original PR95 padding works for ordinary cases; its failure at a supported angle is the reason for replacing the fixed bound. PR91's original v3 geometry was not found defective; the shared chamfer work is required by the current v4 architecture.

## Verification

Measured label checks cover cap/inset/sliding lids, four sliding directions, printing and assembled preview, requested depth, actual panel thickness, and separated print groups. The complete 65-check result uses a fresh closed/connected inverted-label STL; the O counter remains joined. Native 2D pattern comparisons cover 12 cases, the known fixed-padding negative control, and four invalid-spacing diagnostics. Native polygon checks cover 32 geometry combinations and four expected unsupported-chamfer diagnostics.

All seven affected or new fixture scenes have accepted STL and seven-view evidence. Meshes retained from earlier checkpoints were checked for geometry equivalence before reuse. The corrected mixed-chamfer fixture completed in 876 seconds with zero warnings after its earlier 600-second attempt timed out; the retry used the existing explicit 1800-second limit and included the reviewed pattern correction. Its source and fixture stayed frozen throughout the successful render. The complete compile sweep passes 99 fixtures with zero failures; 28 fixtures intentionally exercise or retain diagnostics. The old chamfer overlap warning is removed by correcting the demonstration layout.

The normal precommit gate compares every existing fixture. Exact intentional transitions pin the baseline commit, both normalized CSG hashes, and passing direct invariants. Imported SVGs compare content hashes instead of checkout-dependent timestamps. Exporter failures, missing outputs, stale files, and concurrent temporary-file cleanup can no longer produce false success in the render runner. Interrupted outer-process checks were rerun and accepted only after both actual child and outer exits were zero.

Full per-agent review notes, before/after artifacts, and implementation logs are retained locally at `/home/coder/projects/3d_Printing/BIT/docs/code-review/2026-09-07-0950-open-prs/`. Recovery transcript: `/home/coder/.codex/sessions/2026/09/07/rollout-2026-09-07T09-11-33-01a07ca3-9b67-7671-896e-a5d91725379a.jsonl`; find the eight-PR verdicts followed by “proceed”. The decisive outcomes are reproduced here so the report remains useful without the local artifacts. These checks verify software geometry, not physical print qualification.

The final native checkpoint is `88950715c3ad184bf1d1c034fd49aef945b888bb` (BIT 4.13.0). Its real hook passed 97 unchanged fixtures and the one exact reviewed fixture correction, with zero failures. The accompanying versioned library file is a source snapshot for review and BGSD Windows validation; no GitHub release is created by this work. Packaging removes inherited trailing whitespace identically from the active library and its versioned copy so the complete staged diff passes whitespace validation; the source tokens and geometry remain unchanged.

## Reproduce the direct geometry checks

```bash
python3 -B tests/check_lid_label_geometry.py --phase all --retention-stl tests/v4/stl/test_label_lid_inverted.stl
python3 tests/pattern_coverage_regression.py
python3 tests/check_native_polygon_geometry.py
./tests/run_tests.sh --csg-only
./tests/csg_regression.sh
```

Generate the required inverted STL with `./tests/run_tests.sh test_label_lid_inverted` before the complete label check. See `docs/guidance/RENDERING.md` for every fixture's STL/seven-view workflow and `docs/guidance/CSG-EXPECTED-CHANGES.md` for the exact transition assertions.
