# BIT Design Plan Schema

This is the structured plan an assistant should create before writing BIT SCAD. It is a planning contract, not a required runtime input to OpenSCAD.

Use the JSON Schema in `docs/llm/BIT-DESIGN-SCHEMA.json` when a tool supports schema-constrained output.

## Required Sections

- `game`: title, edition, language, expansions, and storage goals.
- `sources`: public sources used for game facts or dimensions.
- `measurements`: user-provided physical measurements.
- `component_groups`: things to store, with counts, dimensions, and clearance.
- `assumptions`: every unsourced or unmeasured decision.
- `bit_design`: planned BIT boxes, features, lids, and labels.
- `validation`: commands to run and results to report.

## Planning Requirements

- Facts from sources, user measurements, and assumptions must be separate.
- Every `component_groups[].storage_dimensions_mm` value must be either user-measured, source-backed, or listed in `assumptions`.
- `bit_design.boxes[].box_size_xyz_mm` must be exterior dimensions.
- `bit_design.boxes[].features[].compartment_size_xyz_mm` must be interior dimensions.
- The plan must include unresolved measurements before generating final SCAD.

## Minimal Example

```json
{
  "game": {
    "title": "Example Game",
    "edition": "unknown",
    "language": "unknown",
    "expansions": [],
    "storage_goals": ["vertical storage", "removable trays"]
  },
  "sources": [],
  "measurements": [
    {
      "name": "box interior",
      "value_mm": [280, 280, 70],
      "provided_by": "user"
    }
  ],
  "component_groups": [
    {
      "name": "cards",
      "count": 120,
      "component_dimensions_mm": [54, 80, 0.35],
      "storage_dimensions_mm": [58, 84, 45],
      "clearance_mm": [2, 2, 2],
      "measurement_status": "assumed"
    }
  ],
  "assumptions": [
    {
      "name": "sleeved card envelope",
      "value": "58 x 84 mm cavity",
      "risk": "May be too small for thick sleeves",
      "verify_by": "Measure sleeved card stack"
    }
  ],
  "bit_design": {
    "library_include": "boardgame_insert_toolkit_lib.4.0.8.scad",
    "boxes": [
      {
        "name": "cards",
        "box_size_xyz_mm": [180, 90, 50],
        "features": [
          {
            "kind": "card wells",
            "num_compartments_xy": [3, 1],
            "compartment_size_xyz_mm": [58, 84, 45]
          }
        ],
        "lid": {
          "type": "LID_CAP",
          "solid": true
        }
      }
    ]
  },
  "validation": {
    "command": "scripts/validate-design.sh --render path/to/design.scad",
    "status": "not_run",
    "notes": []
  }
}
```
