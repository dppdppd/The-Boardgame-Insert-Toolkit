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
