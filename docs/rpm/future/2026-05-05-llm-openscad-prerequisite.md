# Add Explicit OpenSCAD Prerequisite To LLM Instructions

## Context

The generated-design workflow relies on `scripts/validate-design.sh`, which in turn requires `openscad` on `PATH`. The script fails clearly when OpenSCAD is missing, but the LLM-facing docs do not yet tell assistants to check or install OpenSCAD before attempting validation.

## Acceptance

- `llms.txt` or `docs/llm/BIT-DESIGN-GENERATION.md` explicitly tells assistants to verify OpenSCAD is available before validation.
- The guidance points users to the existing README/OpenSCAD download path when OpenSCAD is absent.
- A generated-design prompt test still routes assistants through `scripts/validate-design.sh`.
