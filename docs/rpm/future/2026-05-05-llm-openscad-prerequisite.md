# Add Explicit OpenSCAD Prerequisite To LLM Instructions

## Context

The generated-design workflow relies on `scripts/validate-design.sh`, which in turn requires `openscad` on `PATH`. The script fails clearly when OpenSCAD is missing, but the LLM-facing docs do not yet tell assistants to check or install OpenSCAD before attempting validation.

## Acceptance

- `llms.txt` or `docs/llm/BIT-DESIGN-GENERATION.md` explicitly tells assistants to verify OpenSCAD is available before validation.
- The guidance points users to the existing README/OpenSCAD download path when OpenSCAD is absent.
- A generated-design prompt test still routes assistants through `scripts/validate-design.sh`.

## Worker Result

### Summary

Added explicit OpenSCAD availability guidance to the LLM design workflow and generated-design validation instructions. Assistants are now told to run `command -v openscad` before validation, point users to `README.md#how-text-editor` when OpenSCAD is absent, and continue routing generated-design checks through `scripts/validate-design.sh`.

### Files changed

- `docs/llm/BIT-DESIGN-GENERATION.md`
- `docs/llm/BIT-GENERATED-DESIGN-VALIDATION.md`
- `docs/rpm/future/2026-05-05-llm-openscad-prerequisite.md`

### Verification run

- `rg -n "command -v openscad|README.md#how-text-editor|scripts/validate-design.sh" docs/llm/BIT-DESIGN-GENERATION.md docs/llm/BIT-GENERATED-DESIGN-VALIDATION.md docs/llm/BIT-DESIGN-SCHEMA.md llms.txt`

### Remaining risks or follow-ups

No separate generated-design prompt-test file appears to exist in the repository; verification used the durable LLM guide/schema artifacts and confirmed they still route generated-design validation through `scripts/validate-design.sh`.
