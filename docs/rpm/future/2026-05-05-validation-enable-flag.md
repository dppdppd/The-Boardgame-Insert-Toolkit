# Decide On A Separate Physical Validation Enable Flag

## Description

Decide whether physical validation should remain under `G_VALIDATE_KEYS_B` or move behind a dedicated global flag.

## Scope

- Evaluate whether key/type validation and physical validation should be independently configurable.
- If separate, add a global such as `G_VALIDATE_PHYSICAL_B` with clear default behavior and backward compatibility.
- Update validation dispatch so key/type checks and physical checks can be enabled independently.
- Document the flag behavior in the parameter guide and examples.
- Add tests that cover enabled, disabled, and mixed validation settings.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_key_validation.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Small to medium. The main decision is API clarity; implementation should be contained once the behavior is chosen.

## 2026-05-06 Status

Moved to `IN-PROGRESS` after transformed-footprint validation closed. The next pass should decide whether physical validation remains coupled to `G_VALIDATE_KEYS_B` or gains a dedicated global such as `G_VALIDATE_PHYSICAL_B`.

## Completion Note

Closed after adding `G_VALIDATE_PHYSICAL_B` and splitting key/type validation from physical validation. Defaults preserve existing behavior: physical validation stays on by default, and designs that only set `G_VALIDATE_KEYS_B=false` continue to suppress physical validation unless `G_VALIDATE_PHYSICAL_B=true` explicitly opts back in.

Verification:
- Direct `openscad -o /tmp/test_validation_flags.csg tests/v4/scad/test_validation_flags.scad` confirmed key-only, physical-only, both-off, and legacy key-off modes.
- `./tests/run_tests.sh --csg-only test_validation_flags test_key_validation test_physical_validation test_cutout_top_profile test_rotated_sheared_physical_validation`
- Full CSG suite covered in chunks: 64 test files passed, 0 failed, 0 warnings.
