# Two Decks Plus Button Sliding-Lid Draft Assumptions

This example is a workflow and SCAD-shape reference for a generic card box with a sliding lid. It is designed for two poker-size card decks and one round dealer button.

## Assumptions In `two-decks-button-sliding.scad`

- Cards are standard poker size.
- Each card well stores one deck.
- Card wells have extra space for a boxed or sleeved deck.
- The dealer button is round and stored in a vertical round cavity.
- The lid opens from the front.
- Dimensions are demonstration defaults and should be replaced with measured values before printing.

## Measurements To Replace

- `deck_x`, `deck_y`, `deck_z`
- `button_diameter`, `button_z`
- `clearance_xy`, `clearance_z`
- `wall`

## Suggested Prompt For Refinement

After measuring your cards and button, ask:

```text
Using docs/llm/BIT-DESIGN-GENERATION.md, update docs/llm/examples/two-decks-button-sliding.scad for my measured card decks and dealer button:
- deck dimensions: ...
- dealer button diameter and thickness: ...
- preferred wall thickness and clearance: ...
Validate the design and report remaining assumptions.
```
