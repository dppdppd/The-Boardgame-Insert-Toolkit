# BIT GUI — Design & Implementation Plan

Cross-platform desktop GUI for constructing Boardgame Insert Toolkit design files.
Eliminates the need to memorize parameter keys/types/defaults.

## Dev Loop

This is the most important section. Every code change follows this loop:

```
1. Edit code (Svelte components in src/)
2. Build:   cd bit-gui && npm run build
3. Launch:  xvfb-run -a node bit-gui/harness/run.js
4. Drive:   type intent + interact via REPL (Playwright controls Electron)
5. Inspect: view screenshots in bit-gui/harness/out/
6. Repeat
```

### Harness

The harness runs the real app headless inside this container and gives
the developer (me) hands and eyes on every change.

**Launch**: `xvfb-run -a node bit-gui/harness/run.js`
- Launches Electron via Playwright (virtual display).
- Playwright controls the app natively (no WebDriver needed).
- Opens an interactive REPL on stdin.

**REPL commands** (every command auto-screenshots after execution):
- `shot <label>` — screenshot only
- `click <css>` — click an element
- `type <css> "<text>"` — clear + type into an element
- `toggle <css>` — click a checkbox/toggle
- `wait <css>` — wait until element is visible
- `intent "<text>"` — set the intent pane text (visible in next screenshot)
- `act "<intent text>" <command> <args>` — set intent + execute + screenshot (one-liner shorthand)

**Screenshots**:
- All go to `bit-gui/harness/out/` (never cleared; accumulates).
- Naming: `<NNN>_<label>.png` (monotonic counter per session).

### Intent Pane (in-app, always visible)

The app has a bottom strip that is always rendered and captured in every screenshot:
- **Intent**: large readable text showing what I expect to happen.
- **Step**: current step number.

This makes every screenshot self-describing: the intent text inside the image
says what should be true, and the rest of the image shows what actually happened.

- `data-testid="intent-text"` — the text area where intent is written.
- `data-testid="intent-step"` — step counter display.

### After Each Change (developer protocol)

For every code change:
1. State what I expect (1–3 bullets).
2. Launch harness, set intent text, interact with the GUI.
3. Inspect screenshots in `bit-gui/harness/out/`.
4. Report: expectation + screenshot filenames used to confirm.

No prescripted test scenarios. The developer articulates the expected behavior,
interacts to confirm it, and the screenshots are the evidence.

### App Env Vars (for headless/harness use)

| Var | Purpose |
|-----|---------|
| `BITGUI_TEST_PROJECT_DIR=/path` | Auto-open this project on startup |
| `BITGUI_AUTOSAVE_DEBOUNCE_MS=0` | Instant save (no debounce delay) |
| `BITGUI_DISABLE_PROMPTS=1` | Suppress modal dialogs |
| `BITGUI_WINDOW_WIDTH=1200` | Window width for screenshots |
| `BITGUI_WINDOW_HEIGHT=900` | Window height for screenshots |

### data-testid Convention

Every interactive element gets a `data-testid` attribute so the REPL
can target by intent, not by pixel coordinates:
- `add-element` — top-level "Add Element" button
- `element-N-name` — element name field (N = index)
- `element-N-expand` — expand/collapse toggle
- `element-N-delete` — delete element button
- `element-N-add-param` — "Add Parameter" button
- `kv-KEY-editor` — inline editor for a key (e.g. `kv-BOX_SIZE_XYZ-editor`)
- `kv-KEY-x`, `kv-KEY-y`, `kv-KEY-z` — individual fields for xyz types
- `kv-KEY-delete` — delete a key-value row
- `keypicker-search` — key picker search input
- `keypicker-item-KEY` — key picker result item
- `options-open` — options menu button
- `save-status` — save indicator in status bar
- `intent-text` — harness intent pane text area
- `intent-step` — harness step counter

---

## Goals

1. **Visual key-value constructor** — structured editor for BIT `data[]` arrays.
2. **Autosave on every change** — writes a real `.scad` file so OpenSCAD renders live.
3. **Schema-driven** — keys, types, defaults derived from v4 library; no custom keys.
4. **Cross-platform** — Windows, macOS, Linux (Electron).
5. **Project-centric** — each project is a self-contained folder.

## Architecture

### Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Desktop shell | **Electron** | Cross-OS, Chromium-based (reliable rendering), native file I/O |
| Frontend | **Svelte 4** | Lightweight, reactive, good tree UI ergonomics |
| Schema | `bit.schema.json` | Machine-readable; derived from v4 source |
| Build | Vite + Electron | Vite builds frontend, Electron loads from dist/ |
| Harness | **Playwright** | Controls Electron natively, screenshots, REPL |

> **Note**: Tauri was attempted first but WebKit2GTK had fundamental JS execution
> issues in the container (modules not loading, CSP blocking inline scripts).
> Electron works reliably headless with zero configuration.

### Repo Layout

```
The-Boardgame-Insert-Toolkit/
  bit-gui/
    src/                    # Svelte frontend
      lib/
        components/         # Tree, inline editors, key picker, options menu
        schema/             # Schema loader + helpers
        stores/             # Svelte stores (project state, autosave, settings)
      App.svelte
      main.ts
    main.js                 # Electron main process
    preload.js              # Electron preload (contextBridge)
    schema/
      bit.schema.json       # Authoritative GUI schema
      generate_schema.py    # Script: parse v4 .scad -> regenerate schema
    harness/
      run.js                # Playwright-driven REPL (launch + screenshot + interact)
      out/                  # Screenshot output (accumulates, never cleared)
    dist/                   # Vite build output (loaded by Electron)
    package.json
    vite.config.mjs
```

## Project Model

### Project Folder Structure

Each project lives in its own folder (default root: `~/Documents/BIT Projects/`):

```
MyInsert/
  design.scad             # Generated; OpenSCAD opens this file
  project.bitgui.json     # Authoritative project state; GUI opens this
  lib/
    boardgame_insert_toolkit_lib.4.scad   # Copied from app resources
    bit_functions_lib.4.scad              # Copied from app resources
```

### design.scad (generated output)

```openscad
// Generated by BIT GUI — do not edit manually
// Lib version: 4.00 (sha256: abcd1234...)

include <lib/boardgame_insert_toolkit_lib.4.scad>;
include <lib/bit_functions_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "tray",
        [
            [ TYPE, BOX ],
            [ BOX_SIZE_XYZ, [100, 80, 30] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [40, 70, 25] ],
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 1] ],
                ]
            ],
        ]
    ],
];

MakeAll();
```

Key formatting rules:
- Keys are unquoted constant names (e.g. `BOX_SIZE_XYZ`, not `"box_size"`)
- Booleans: `true` / `false`
- Numbers: bare (no quotes)
- Strings: double-quoted
- Lists: `[a, b, c]`
- Nested tables: indented `[ KEY, VALUE ]` pairs

### project.bitgui.json

```json
{
  "version": 1,
  "lib_checksums": {
    "boardgame_insert_toolkit_lib.4.scad": "sha256:abcd...",
    "bit_functions_lib.4.scad": "sha256:ef01..."
  },
  "globals": {
    "g_b_print_lid": true,
    "g_b_print_box": true,
    "g_isolated_print_box": ""
  },
  "data": [
    {
      "name": "tray",
      "type": "BOX",
      "params": [
        { "key": "BOX_SIZE_XYZ", "value": [100, 80, 30] },
        {
          "key": "BOX_COMPONENT",
          "value": [
            { "key": "CMP_COMPARTMENT_SIZE_XYZ", "value": [40, 70, 25] },
            { "key": "CMP_NUM_COMPARTMENTS_XY", "value": [2, 1] }
          ]
        }
      ]
    }
  ]
}
```

## Schema: `bit.schema.json`

### Purpose

Drives the entire GUI: key pickers, inline editors, validation, defaults.
No custom keys allowed — if it's not in the schema, you can't add it.

### Structure

```json
{
  "version": "4.00",
  "contexts": {
    "element": {
      "description": "Top-level element (BOX or DIVIDERS)",
      "keys": {
        "TYPE": {
          "type": "enum",
          "values": ["BOX", "DIVIDERS", "SPACER"],
          "default": "BOX",
          "help": "Element type"
        },
        "BOX_SIZE_XYZ": {
          "type": "xyz",
          "default": [100, 100, 30],
          "help": "Box outer dimensions [x, y, z]",
          "contexts": ["BOX", "SPACER"]
        },
        "BOX_COMPONENT": {
          "type": "table_list",
          "child_context": "component",
          "help": "List of compartment components",
          "contexts": ["BOX", "SPACER"]
        }
      }
    },
    "component": {
      "description": "Compartment component (inside BOX_COMPONENT)",
      "keys": {
        "CMP_COMPARTMENT_SIZE_XYZ": { "type": "xyz", "default": [10, 10, 10] },
        "CMP_SHAPE": { "type": "enum", "values": ["SQUARE", "HEX", "HEX2", "OCT", "OCT2", "ROUND", "FILLET"] }
      }
    },
    "lid": { "description": "Lid parameters (inside BOX_LID)", "keys": {} },
    "label": { "description": "Label parameters (inside LABEL)", "keys": {} },
    "divider": { "description": "Divider parameters (TYPE=DIVIDERS)", "keys": {} }
  },
  "globals": {
    "g_b_print_lid": { "type": "bool", "default": true },
    "g_b_print_box": { "type": "bool", "default": true },
    "g_isolated_print_box": { "type": "string", "default": "" }
  },
  "types": {
    "bool": "Checkbox (true/false)",
    "number": "Numeric input",
    "string": "Text input",
    "enum": "Dropdown of predefined values",
    "xy": "Two numeric inputs [x, y]",
    "xyz": "Three numeric inputs [x, y, z]",
    "4bool": "Four checkboxes [front, back, left, right]",
    "table": "Nested key-value table (single)",
    "table_list": "List of nested key-value tables",
    "string_list": "List of strings"
  }
}
```

### Schema Generation

`schema/generate_schema.py` parses `boardgame_insert_toolkit_lib.4.scad`:
1. Extract `__VALID_*_KEYS` arrays -> allowed keys per context
2. Extract `__Validate*Types()` checks -> infer types
3. Extract accessor `default=` values -> defaults
4. Manual enrichment file (`schema/overrides.json`) for help text and enum values

## UI Design

### Single-Panel Tree View

Every node shows **all keys with their defaults** — no "Add Parameter" picker.
Users edit values in-place; unchanged values emit as defaults (or are omitted
in the generated SCAD if they match the default).

Optional **sub-nodes** (BOX_COMPONENT, BOX_LID, LABEL) are added/removed
with `[+]` / `[trash]` buttons. These are the only structural add/delete actions.

```
+-----------------------------------------------+
| BIT GUI                             [Options]  |
+-----------------------------------------------+
| [+ Add Element]                                |
|                                                |
| v "tray" (BOX)                          [trash]|
|   TYPE          [BOX       v]                  |
|   BOX_SIZE_XYZ  [100] [80] [30]               |
|   BOX_NO_LID_B  [ ]                           |
|   BOX_STACKABLE_B [ ]                          |
|   BOX_WALL_THICKNESS [1.5]                     |
|   ... (all box-level keys with defaults)       |
|   v BOX_COMPONENT                          [+] |
|     v Component 1                      [trash] |
|       CMP_COMPARTMENT_SIZE_XYZ [10] [10] [10]  |
|       CMP_NUM_COMPARTMENTS_XY  [1] [1]         |
|       CMP_SHAPE  [SQUARE v]                    |
|       ... (all component keys with defaults)   |
|       [+ Label]                                |
|   v BOX_LID                            [trash] |
|     LID_FIT_UNDER_B  [x]                       |
|     LID_SOLID_B  [ ]                           |
|     ... (all lid keys with defaults)           |
|     [+ Label]                                  |
|   [+ Lid] [+ Label]                            |
|                                                |
+-----------------------------------------------+
| design.scad saved | Libs: current              |
+-----------------------------------------------+
| [intent input field]                           |
+-----------------------------------------------+
```

### Inline Editor Widgets (by schema type)

| Schema Type | Widget | Example |
|-------------|--------|---------|
| `bool` | Checkbox | `[x]` / `[ ]` |
| `number` | Numeric input | `[2.5]` |
| `string` | Text input | `["Game Name"]` |
| `enum` | Dropdown | `[SQUARE v]` |
| `xy` | 2 numeric inputs | `[1] [1]` |
| `xyz` | 3 numeric inputs | `[100] [80] [30]` |
| `4bool` | 4 labeled checkboxes | `F[ ] B[ ] L[x] R[x]` |
| `4num` | 4 labeled numeric inputs | `F[0] B[0] L[0] R[0]` |
| `table` | Expandable node (optional, added via [+]) | disclosure triangle |
| `table_list` | Expandable list + [+] to add items | list of expandable nodes |
| `string_list` | Editable list of strings | `["A", "B", "C"] [edit]` |
| `position_xy` | 2 inputs (number/CENTER/MAX) | `[CENTER] [CENTER]` |

### Optional Sub-Nodes

These are the only things users add/remove structurally:

| Sub-node | Where it appears | Add button |
|----------|-----------------|------------|
| BOX_COMPONENT item | Inside BOX_COMPONENT list | `[+]` on BOX_COMPONENT header |
| BOX_LID | Element level | `[+ Lid]` at bottom of element |
| LABEL | Element, component, or lid level | `[+ Label]` at bottom of parent |

When added, a sub-node is populated with all its schema defaults.

### Options Menu

| Setting | Default | Notes |
|---------|---------|-------|
| Projects Root | `~/Documents/BIT Projects/` | Folder browser |
| Autosave Debounce | 300ms | Slider: 100–1000ms |
| Lib Update Policy | Prompt on mismatch | Dropdown |
| Backup on Lib Update | true | Checkbox |
| OpenSCAD Path | (auto-detect) | For "Open in OpenSCAD" button |

Settings stored in Electron app data dir (OS-appropriate).

## Autosave Pipeline

1. **UI edit** (any change: value edit, add/delete node, reorder)
2. **Debounce** (configurable, default 300ms)
3. **Validate** against schema (inline warnings in tree; don't block save)
4. **Generate SCAD** text from JSON tree
5. **Atomic write**:
   - Write `design.scad.tmp` + fsync
   - Rename `design.scad.tmp` -> `design.scad` (on Windows: remove old + rename)
   - Write `project.bitgui.json.tmp` + fsync + rename
6. **Status bar** shows "Saved" timestamp

## Stale-Lib Detection

### On Project Open / App Startup

1. App ships current v4 libs as bundled resources.
2. Compute SHA-256 of each file in `project/lib/`.
3. Compare to bundled resource checksums.
4. If mismatch:
   - Show dialog: "Project libraries are outdated."
   - Actions:
     - **Update** — backup old to `lib/_old/<timestamp>/`, copy new libs
     - **Keep** — dismiss; don't nag again until bundled libs change

### On New Project

- Copy bundled libs to `project/lib/`.
- Record checksums in `project.bitgui.json`.

## SCAD Generator Rules

### Formatting

- 4-space indentation
- Keys: unquoted OpenSCAD constants (e.g. `BOX_SIZE_XYZ`)
- Booleans: `true` / `false`
- Numbers: bare (integer or decimal)
- Strings: `"double-quoted"`
- Vectors: `[a, b, c]` (space after comma)
- Nested tables: each `[KEY, VALUE]` pair on its own line, indented
- Header comment: `// Generated by BIT GUI — do not edit manually`
- Lib version comment: `// Lib version: 4.00 (sha256: ...)`

### Globals

- Only emit globals that differ from their defaults (keep output clean).
- Always emit `g_b_print_lid`, `g_b_print_box`, `g_isolated_print_box` (essential).

### Data Array

- Each element: `[ "name", [ [KEY, VALUE], ... ] ]`
- `BOX_COMPONENT` wraps a list of component tables
- Nested tables (BOX_LID, LABEL) are inline `[KEY, [nested pairs]]`

## Implementation Phases

### Phase 0: Harness + Skeleton
- [x] Scaffold Electron + Svelte 4 project in `bit-gui/`
- [x] Add intent pane (always visible bottom strip with text + step counter)
- [x] Add `data-testid` attributes to all elements from day 1
- [x] Implement harness: Playwright-driven REPL (`harness/run.js`)
- [x] Confirm: app loads headless, intent pane visible, screenshot works

### Phase 1: Schema + Tree View
- [x] Create `bit.schema.json` (from v4 valid keys + validation + accessors)
- [x] Basic tree view (expand/collapse, display key-value pairs from fixture project)
- [x] Nodes show all keys with defaults (populated from schema, muted styling)
- [x] Inline editor widgets (bool, number, string, enum, xy, xyz, 4bool, 4num, string_list, position_xy)

### Phase 2: Editing + Autosave
- [x] All keys shown with defaults, revert button on non-defaults
- [x] Store actions: add/delete elements, rename, update params
- [x] Add/remove optional sub-nodes (BOX_COMPONENT items, BOX_LID, LABEL)
- [x] SCAD text generator (omit keys matching defaults)
- [x] SCAD preview toggle
- [x] Atomic file writer (Electron main process via IPC)
- [x] Autosave pipeline (debounced)
- [x] Open/Save As via Electron dialogs
- [x] SCAD is sole source of truth (no JSON project file)
- [x] Preamble/postamble preserved (user code outside data[] survives)
- [x] BITGUI marker comment; .bak backup on first save of unmarked files
- [x] Expression support (__expr for function calls, arithmetic)
- [x] Expression elements in data[] (e.g. makeFaction()) preserved as read-only
- [x] Open in OpenSCAD button
- [ ] Reorder list items (components)

### Phase 3: Polish + Release
- [ ] Duplicate element/component
- [ ] Cross-platform release builds (electron-builder)
- [ ] Keyboard shortcuts (Ctrl+O, Ctrl+S, Ctrl+Shift+S)

### Backlog
- [ ] Undo/redo
- [ ] Dark/light theme
- [ ] Recent files list
- [ ] Schema generation script (`generate_schema.py`)
