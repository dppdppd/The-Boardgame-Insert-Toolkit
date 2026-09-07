# Reviewed CSG changes

`tests/csg_regression.sh` normally requires every existing fixture's normalized CSG to match the chosen baseline. An intentional geometry correction can replace that equality expectation with an exact reviewed transition in `tests/csg_expected_changes.json`. This is an assertion of the expected new output, not a skipped fixture: the gate still compiles both versions, compares them, verifies both hashes, and runs the specified geometry checks.

The installed pre-commit hook calls the gate normally and discovers this manifest automatically. No environment bypass is needed. An absent manifest leaves the original equality rule in force. Malformed manifests fail before compilation; an unlisted change, different baseline commit, different old or new normalized output, or failing invariant command remains a gate failure.

## Manifest format

The document has `version: 1` and a `changes` list. Every entry has exactly these fields:

| Field | Meaning |
|---|---|
| `baseline_commit` | Full 40-character commit ID actually used for the baseline export. Branch names and abbreviated hashes are not accepted. |
| `test` | Exact repository-relative path, such as `tests/v4/scad/test_lid_pattern.scad`. |
| `before_sha256` | SHA256 of the baseline normalized CSG file, including its final newline. |
| `after_sha256` | SHA256 of the reviewed current normalized CSG file. It must differ from the old hash. |
| `reason` | A human-readable explanation of the correction, including what invariant replaces the obsolete equality expectation and where its evidence lives. |
| `invariant_commands` | Nonempty list of argument lists. Every command must pass and should verify the actual intended geometry or behavior. |

For example, a pattern correction could name `[["python3", "tests/pattern_coverage_regression.py"]]` as its invariant commands. A fixture affected by independent label and pattern corrections should name both relevant checks. Commands execute from the repository root without shell expansion. Each unique argument list runs once per gate invocation, with a ten-minute timeout; status and complete logs remain in that invocation's output directory. A failure stays failed if another entry uses the same command. Results are never reused across separate gate invocations.

Do not add entries merely because output changed. First inspect the old/new geometry, settle the intended behavior, and pass the direct geometry checks and required renders. Then run the comparison with `--keep-output`, inspect its normalized differences, and obtain the exact values:

```bash
git rev-parse HEAD
sha256sum /tmp/bit_csg_regression.REPLACE/test_lid_pattern.baseline.normalized.csg
sha256sum /tmp/bit_csg_regression.REPLACE/test_lid_pattern.current.normalized.csg
```

Use the actual selected baseline instead of `HEAD` when comparing another ref, and replace the temporary path with the gate's reported output directory. The before/after hashes are assertions backed by that review; do not regenerate them automatically during the gate. Duplicate entries for the same baseline and fixture are rejected. Old entries become inactive when the baseline advances and do not authorize new changes against a different commit.

After writing reviewed entries, rerun the normal gate. Commit only when it passes. A changed invariant implementation, unexpected OpenSCAD output, or unrelated geometry edit must still be investigated; do not replace a red with a broader allowance.

## Mechanism tests

```bash
python3 tests/test_csg_expected_changes.py
```

These lightweight unit tests use synthetic normalized CSG files. They check the exact approved transition, altered before/after output, an unrelated baseline or fixture, an absent or malformed manifest, missing explanations/commands, invariant failure, and per-invocation command caching. They do not replace the geometry checks named by production manifest entries.

## Imported asset normalization

Normalized imports preserve their file path and geometry parameters, but replace OpenSCAD's serialized modification timestamp with the referenced file's SHA256. A fresh Git worktree changes asset timestamps without changing geometry; comparing those timestamps caused three SVG fixtures to fail even when the library and outlines were identical. Comparing bytes resolves that false failure while ensuring a changed SVG at the same path and timestamp still changes normalized CSG.

The normalizer resolves relative paths from each source fixture's directory and hashes only referenced assets. It fails closed when an import path is missing, unreadable, or unresolved. The existing group, preview-color, and identity-transform normalization remains unchanged. Run `python3 tests/test_normalize_csg_assets.py` for timestamp-only changes, byte changes with the same filename and timestamp, missing files, unresolved paths, imports without timestamps, and quoted filenames containing timestamp-like text.
