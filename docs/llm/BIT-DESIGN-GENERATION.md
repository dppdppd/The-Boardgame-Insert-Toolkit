# BIT Design Generation Guide For LLMs

Use this guide when a user asks an assistant to create a BIT `.scad` file for a board game or component set, for example "create a sliding-lid BIT box for two decks of cards and a dealer button".

BIT designs are physical objects. Do not turn a game title directly into final printable geometry. First collect measurements, state assumptions, generate a structured plan, then write and validate the SCAD.

## Required Context

Read these files before generating a design:

- `README.md`: user setup, versioned library include rules, and dimension conventions.
- `docs/guidance/BIT-PARAMETERS.md`: exact v4 key names, enums, and gotchas.
- `release/my_designs/starter.scad`: minimal user design shape.
- `docs/llm/BIT-EXAMPLES-CATALOG.md`: task-to-example map.
- `docs/llm/BIT-MEASUREMENT-CHECKLIST.md`: required physical measurements.
- `docs/llm/BIT-GENERATED-DESIGN-VALIDATION.md`: validation commands.

Use `release/lib/boardgame_insert_toolkit_lib.4.scad` only for repo tests and library development. User design files should include the newest full-version release library in `release/lib/`, such as `boardgame_insert_toolkit_lib.4.0.8.scad`.

## Generation Workflow

1. Identify the target game exactly: edition, language, base game vs expansions, and whether cards are sleeved.
2. Ask for or record measurements from `docs/llm/BIT-MEASUREMENT-CHECKLIST.md`.
3. Separate facts, measurements, assumptions, and unresolved questions. Use `docs/llm/BIT-DESIGN-SCHEMA.md` as the planning shape.
4. Propose a tray layout before SCAD: box count, component groups, lids, labels, and what each tray stores.
5. Write SCAD only after measurements are available or the user explicitly accepts assumptions.
6. Keep all game-specific dimensions as named variables near the top of the file.
7. Validate with `scripts/validate-design.sh`. Repair syntax, key, type, and geometry issues before presenting the design.
8. Report the generated file path, validation result, render output if produced, and any assumptions that still need measurement.

## Rules For Correct BIT SCAD

- Use millimeters.
- `BOX_SIZE_XYZ` is an exterior tray size.
- `FTR_COMPARTMENT_SIZE_XYZ` is an interior cavity size.
- Leave clearance around real components. Do not make a compartment exactly equal to a measured component.
- Keep lids in the height budget. Inset lids can add height; check the README notes.
- Prefer simple rectangular trays first. Add labels, patterns, sliding lids, and complex cutouts only when they serve the storage goal.
- Use `G_VALIDATE_KEYS_B` unless the user asks to suppress validation.
- Do not use v3-only `HEXBOX` in v4. For hex-shaped compartments in a rectangular tray, use `FTR_SHAPE` with `HEX` or `HEX2`.
- If a dimension comes from the web, cite it in comments or an assumptions file. If it is not sourced, mark it as a user-measurement placeholder.

## Questions To Ask When Data Is Missing

Ask only the questions that block a useful first design:

- Which edition and language of the game?
- Base game only, or which expansions?
- Sleeved or unsleeved cards?
- What are the interior dimensions of the game box?
- Do you want removable gameplay trays or compact storage trays?
- Will the box be stored vertically?
- What are the measured dimensions of cards, tile stacks, token stacks, and tallest pieces?

If the user wants a rough draft, generate an assumption-labeled design and make the measurement placeholders obvious.

## Output Pattern

For a full response, produce:

1. A short design plan.
2. A `.scad` file with named variables and comments for assumptions.
3. Validation command output summary.
4. A checklist of measurements the user should verify before printing.

## Repair Loop

If validation fails:

- Read the OpenSCAD and `BIT:` messages.
- Fix unknown keys by checking `docs/guidance/BIT-PARAMETERS.md`.
- Fix impossible geometry by increasing `BOX_SIZE_XYZ`, reducing compartment counts, or increasing wall/clearance values.
- Re-run validation.
- Render iso/top views for non-trivial layouts.

Do not present an unvalidated SCAD file as finished.
