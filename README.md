<!--ts-->
<!--te-->

Get started by pasting this prompt into Claude Code, Codex, or your favorite AI chat:

```text
Use dppdppd BIT to create and test the following insert: a sliding-lid box that holds two decks of poker cards and one dealer button.
```

# What

This:

![Dune 1](images/IMG_3294.jpeg)
![Mice n Mystics 2](images/IMG_1453.jpeg)

# Why
This OpenSCAD library was designed for quick design and iteration on board game inserts--specifically ones with lids. There are lots of great printable inserts out there, but very few for us vertical storers.

# Version 4

**v4** is a streamlined release focused on maintainability:
- **Smaller codebase** (3,454 lines, down from 4,456 in v3)
- **Key validation**: typos and unrecognized keys in your data produce structured `BGSD_WARNING:` messages in the console (set `g_validate_keys_b = false;` to suppress)
- Removed hexagonal box type (`HEXBOX`) — hex-shaped *compartments* (`FTR_SHAPE` = `HEX`/`HEX2`) still work in regular boxes
- Bug fixes: asymmetric cutouts with `FTR_CUTOUT_HEIGHT_PCT` (#65), label clipping with shear (#69)
- 14 magic numbers replaced with named constants
- Code documentation: TOC, section headers, module docs

**Migrating from v3**: Change your includes from `boardgame_insert_toolkit_lib.3.scad` to the latest full-version v4 library file in `release/lib/`, for example `boardgame_insert_toolkit_lib.4.0.8.scad`. If you use `HEXBOX` type boxes, keep using v3 — the v3 files are archived in `tests/v3-baseline/`.

# Visual Editor

**[BGSD — Board Game Storage Designer](https://github.com/dppdppd/BGSD)** is a desktop app for visually editing BIT `.scad` files — no OpenSCAD coding required.

![BGSD](images/bgsd_overview.png)

- Schema-driven controls for all v4 keys (checkboxes, dropdowns, XYZ inputs, enums)
- Round-trip editing — opens existing `.scad` files, preserves comments and formatting
- Live SCAD preview pane — see the generated code as you edit
- Automatically downloads BIT library files from GitHub on save
- Opens legacy v2/v3 files and converts them to v4

Download portable binaries from the [BGSD Releases](https://github.com/dppdppd/BGSD/releases) page.

# AI-Assisted Design

Supporting files for AI assistants:

- [`llms.txt`](llms.txt) - curated map for LLMs.
- [`docs/llm/BIT-DESIGN-GENERATION.md`](docs/llm/BIT-DESIGN-GENERATION.md) - design workflow.
- [`docs/llm/BIT-MEASUREMENT-CHECKLIST.md`](docs/llm/BIT-MEASUREMENT-CHECKLIST.md) - what to measure before printing.
- [`docs/llm/BIT-EXAMPLES-CATALOG.md`](docs/llm/BIT-EXAMPLES-CATALOG.md) - task-to-example map for common tray patterns.
- [`docs/llm/examples/two-decks-button-sliding.scad`](docs/llm/examples/two-decks-button-sliding.scad) - assumption-labeled sliding-lid example for two decks of cards and a dealer button.
- [`scripts/validate-design.sh`](scripts/validate-design.sh) - compile check and optional renders for generated user designs.

# How (Text Editor)
- Download [Openscad](https://www.openscad.org).
- Create a new directory for the board game you're working on. It's best to keep the BIT file with the board game file because future BIT versions may not be backwards compatible and this way you will always be able to recreate the STLs.
- In `release/lib/`, find the most recent full-version library file, such as `boardgame_insert_toolkit_lib.4.0.8.scad`. Use the highest version number available.
- Copy that full-version library file and `release/my_designs/starter.scad` into the directory. Feel free to rename _starter.scad_ to something more descriptive.
- You'll be working entirely in your copy of the starter file.
- The first line of your `.scad` file should include that most recent full-version library filename, for example __include <boardgame_insert_toolkit_lib.4.0.8.scad>;__ Do not include the development file `boardgame_insert_toolkit_lib.4.scad` in your own designs. The last line should be __Make(data);__ All of your 'code' goes in-between.
- Open your new scad file in your favorite text editor and also in Openscad.
- In Openscad, set "Automatic Reload and Preview" _on_ in the Design menu. Now openscad will update the display whenever you save the scad file in the text editor.
- Measure, build, measure again.
- When you're done, in Openscad, _Render_ final geometry, then _Export_ an STL file for your slicer. 
- I also recommend making a little script that will split your STL into separate STLs (one per object) using [Slic3r](https://slic3r.org)'s command line '--split' feature.
- If you post it on Thingiverse, make it a _remix_ of [BIT](https://www.thingiverse.com/thing:3405465) and I'll get notified and eventually add it to the list of game inserts.

## Pay attention to your dimensions.
- Note that the box dimensions (BOX_SIZE_XYZ) are _exterior_ dimensions and are as such to guarantee that the box you're defining fits inside the game's cardboard box. __IMPORTANT:__ boxes with inset lids are taller by 2 * g_wall_thickness than defined.
- Also note that the compartment dimensions are _interior_ dimensions and are as such to guarantee that the game pieces will fit inside them.
- This means that you'll want to make sure that those exterior and interior values don't get too close to each other or your box walls will be thin and/or nonexistant.
- By default you'll want to leave 3mm in depth and length, and 2mm in height, when designing your inserts.
- Note that all dimensions represent mm.

## Key Values
Everything in BIT is defined using key-value pairs, i.e. [ _key_ , _value_ ]. Sometimes the _value_ is an array of other key-value pairs, so it's important to use indentation to keep track of the pairing. That's where a good text editor comes in handy. See the following example.

    [ OBJECT_BOX,
        [ NAME, "example 1: minimal" ],                    // box name, for code organization
        [ BOX_SIZE_XYZ, [46.5, 46.5, 15.0] ],              // exterior dimensions
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [4, 4] ],           // a grid of 4 x 4
            [ FTR_COMPARTMENT_SIZE_XYZ, [10, 10, 13.0] ],  // each compartment 10mm x 10mm x 13mm
        ],
    ],

That made this:

![example1](images/example1.png)

### Some Explanation
Each box is defined as `[ OBJECT_BOX, [NAME, "..."], ... ]` with key-value pairs for its properties. `BOX_FEATURE` defines a compartment type within the box. It's key-values all the way down. See https://www.thingiverse.com/thing:3435429 for an example of lots of compartments of lots of components in lots of boxes.


Here is an example of some compartments designed to hold cards, with holes to get our fingers in on the side. Many of these parameters are just the default values and are not necessary, but are included for easy modification:

    [ OBJECT_BOX,
        [ NAME, "example 2" ],
        [ BOX_SIZE_XYZ, [110.0, 180.0, 22.0] ],
        [ ENABLED_B, t ],
        [ BOX_LID,
            [ LID_SOLID_B, f ],
            [ LID_FIT_UNDER_B, f ],
            [ LID_PATTERN_RADIUS, 8 ],
            [ LID_HEIGHT, 10 ],
            [ LABEL,
                [ LBL_TEXT, "Skull     and" ],
                [ LBL_SIZE, AUTO ],
                [ ROTATION, 45 ],
                [ POSITION_XY, [2, -2] ],
            ],
            [ LABEL,
                [ LBL_TEXT, "Crossbones" ],
                [ LBL_SIZE, AUTO ],
                [ ROTATION, 315 ],
                [ POSITION_XY, [-4, -0] ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 60.0, 20.0] ],
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_SHAPE, SQUARE ],
            [ FTR_SHAPE_ROTATED_B, f ],
            [ FTR_SHAPE_VERTICAL_B, f ],
            [ FTR_PADDING_XY, [10, 12] ],
            [ FTR_PADDING_HEIGHT_ADJUST_XY, [-5, 0] ],
            [ FTR_MARGIN_FBLR, [0, 0, 0, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [f, f, f, t] ],
            [ ROTATION, 5 ],
            [ POSITION_XY, [CENTER, CENTER] ],
            [ LABEL,
                [ LBL_TEXT, [
                    ["backleft", "backright"],
                    ["frontleft", "frontright"],
                ] ],
                [ LBL_PLACEMENT, FRONT ],
                [ ROTATION, 5 ],
                [ LBL_SIZE, AUTO ],
                [ POSITION_XY, [-4, -2] ],
                [ LBL_FONT, "Times New Roman:style=bold italic" ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [1, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [60.0, 10.0, 5.0] ],
            [ POSITION_XY, [CENTER, 165] ],
        ],
    ],


And this is the result:

![example2](images/example2.png)

### Hexagonal Compartments
For hex-shaped compartments inside a regular box, use `FTR_SHAPE = HEX` (or `HEX2`) together with `FTR_SHAPE_VERTICAL_B = true` on a `BOX_FEATURE`. The full hexagonal *box type* (`TYPE = HEXBOX`) was removed in v4 — keep using v3 (archived in `tests/v3-baseline/`) if you specifically need that.

### Dividers
As of v2.04, there is also the ability to create card dividers in addition to boxes. A dividers definition looks like this:

    [ OBJECT_DIVIDERS,
        [ NAME, "divider example 1" ],
        [ DIV_TAB_TEXT, ["001","002","003"] ],
        [ DIV_FRAME_NUM_COLUMNS, 2 ],
    ],

And produces something like this:

![dividers](images/dividers1.png)

### Customizable Lid Patterns
As of v2.10, one can now tweak the lid pattern parameters. The default is still a honeycomb, but here are some alternatives:


    [ OBJECT_BOX,
        [ NAME, "lid pattern 1" ],
        [ BOX_SIZE_XYZ, [50.0, 50.0, 20.0] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [47, 47, 18.0] ],
        ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 10 ],
            [ LID_PATTERN_N1, 3 ],
            [ LID_PATTERN_N2, 3 ],
            [ LID_PATTERN_ANGLE, 0 ],
            [ LID_PATTERN_ROW_OFFSET, 10 ],
            [ LID_PATTERN_COL_OFFSET, 140 ],
            [ LID_PATTERN_THICKNESS, 1 ],
        ],
    ]
    ],   

![lid pattern 1](images/pattern1.png)

    [ OBJECT_BOX,
        [ NAME, "lid pattern 2" ],
        [ BOX_SIZE_XYZ, [50.0, 50.0, 20.0] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [47, 47, 18.0] ],
        ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 10 ],
            [ LID_PATTERN_N1, 8 ],
            [ LID_PATTERN_N2, 8 ],
            [ LID_PATTERN_ANGLE, 22.5 ],
            [ LID_PATTERN_ROW_OFFSET, 10 ],
            [ LID_PATTERN_COL_OFFSET, 130 ],
            [ LID_PATTERN_THICKNESS, 0.6 ],
        ],
    ],

![lid pattern 2](images/pattern2.png)

    [ OBJECT_BOX,
        [ NAME, "lid pattern 3" ],
        [ BOX_SIZE_XYZ, [50.0, 50.0, 20.0] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [47, 47, 18.0] ],
        ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 10 ],
            [ LID_PATTERN_N1, 6 ],
            [ LID_PATTERN_N2, 3 ],
            [ LID_PATTERN_ANGLE, 60 ],
            [ LID_PATTERN_ROW_OFFSET, 10 ],
            [ LID_PATTERN_COL_OFFSET, 140 ],
            [ LID_PATTERN_THICKNESS, 0.6 ],
        ],
    ],    

![lid pattern 3](images/pattern3.png)


# Keys

#### `TYPE`
Value is expected to be one of the following:
- `BOX` (default) a box.
- `DIVIDERS` a set of dividers.
- `HEXBOX` a hexagonal box (v3 only — removed in v4).

## Box keys

#### `BOX_SIZE_XYZ`
Value is expected to be an array of 3 numbers, and determines the exterior dimensions of the box as width, depth, height.  
e.g. `[ BOX_SIZE_XYZ, [ 140, 250, 80 ] ]`

#### `HEXBOX_SIZE_DZ` (v3 only)
Value is expected to be an array of 2 numbers, and determines the __interior__ dimension of the box as diameter, and the __exterior__ dimension as height. Removed in v4.  
e.g., `[ HEXBOX_SIZE_DZ,    [ 100, 40 ] ],`

#### `BOX_FEATURE`
Value is expected to be an array of components key-value pairs. Box can have as many of these as desired.

#### `BOX_LID`
Value is expected to be an array of lid key-value pairs.

#### `BOX_NO_LID_B`
Value is expected to be a bool, and determines whether a lid is ommitted. If ommitted, the box will not form an inset lip to support a lid.

#### `BOX_STACKABLE_B`
Value is expected to be a bool and determines whether the base of the box is cut to fit on top of an identically sized box. Note that this requires a printer that can print a 45 degree overhang without supports.

#### `CHAMFER_N`
Value is expected to be a number (in mm), and determines the size of the 45-degree chamfer applied to the exterior edges of the box and lid. Can be specified at the box level or overridden per-component inside `BOX_FEATURE`. Default is 0.4.  
e.g. `[ CHAMFER_N, 2 ]`

#### `BOX_VISUALIZATION`
To be documented later

## Lid keys
As of v2.09, all lid parameters are specified in a BOX_LID container. This makes it easy to reuse box lid parameters across multiple boxes.

#### `LID_TYPE`
Value is expected to be one of `LID_CAP`, `LID_INSET`, or `LID_SLIDING`. If omitted, BIT preserves the legacy behavior: cap lids by default, or inset lids when `LID_INSET_B` or `BOX_STACKABLE_B` is true.

`LID_SLIDING` creates a sliding panel and adds side rails plus a stop to the box. The rails use a printable groove with a horizontal bottom and 45-degree top, and the lid edge has the matching bevel. The groove extends halfway into the wall so the lid rests on a wall shelf under the wedge. The slide opening has a top-open lead-in rather than a covered slot. Patterned sliding lids include a perimeter frame for rigidity, clipped to the same wedge edges and chamfered corners as solid sliding lids. Sliding lids also include a right-triangle locking detent on the top of the opening-side wall with a matching groove in the underside of the lid. The detent stays on the flat rail shelf after the chamfer, spans that flat width minus `G_TOLERANCE` on both sides, uses `G_DETENT_THICKNESS` for protrusion height, and orients the vertical face to resist the lid sliding back out. Detached sliding lids are rotated 180 degrees for printing so the wedge edges and detent groove face upward. `G_LID_THICKNESS` controls sliding panel and rail height; when omitted, it follows the box wall thickness. The sliding lid can still use the normal solid, pattern, and label parameters.
e.g. `[ LID_TYPE, LID_SLIDING ]`

#### `LID_SLIDE_SIDE`
Value is expected to be one of `FRONT`, `BACK`, `LEFT`, or `RIGHT`, and determines which side the sliding lid opens from. Defaults to `FRONT`.
e.g. `[ LID_SLIDE_SIDE, LEFT ]`

#### `LID_FRAME_WIDTH`
Value is expected to be a number, and determines the perimeter frame width on patterned sliding lids. Defaults to the box wall thickness. Use 0 to omit the extra frame.
e.g. `[ LID_FRAME_WIDTH, 4 ]`

#### `LID_INSET_B`
Legacy value expected to be a bool and determines whether the box will have an inset lid or a cap lid when `LID_TYPE` is omitted.
Considerations:
- Inset lids are required if the boxes are intended to snap fit as a stack ( BOX_STACKABLE_B true ).
- Cap lid is preferred for printers that are sloppier, since the cap lid is more forgiving.
- Cap lid is preferred if the cap will be used to hold pieces during play, since the inset lid does not have walls.

#### `LID_TABS_4B`
Value is expected to be an array of 4 bools, and determines on what sides the lid will have tabs when the lid is inset. The default is [ t,t,t,t ].

#### `LID_PATTERN_RADIUS`
Value is expected to be a number, and determines the radius of the hexes in the lid.  
e.g. `[ LID_PATTERN_RADIUS, 5 ]`

#### `LID_PATTERN_N1`
Value is expected to be a number, and determines the number of sides that the pattern outer shape has.  

#### `LID_PATTERN_N2`
Value is expected to be a number, and determines the number of sides that the pattern inner shape has. 

#### `LID_PATTERN_ANGLE`
Value is expected to be a number, and determines the angle of the pattern shape. 

#### `LID_PATTERN_ROW_OFFSET`
Value is expected to be a number, and determines the percent of height that each row will offset from each other. 

#### `LID_PATTERN_COL_OFFSET`
Value is expected to be a number, and determines the percent of width that each column will offset from each other. 

#### `LID_PATTERN_THICKNESS`
Value is expected to be a number, and determines the thickness of the shape, i.e. the difference between the inner and outer shapes` radius. 

#### `LID_FIT_UNDER_B`
Value is expected to be a bool, and determines whether the box bottom is formed to allow the box to sit in the lid when open. Note that this requires a printer that can print a 45 degree overhang without supports. Ignored for sliding lids.

#### `LID_SOLID_B`
Value is expected to be a bool, and determines whether the lid is a hex mesh or solid.

#### `LID_SOLID_LABELS_DEPTH`
Value is expected to be a number, and if the lid is solid, determines how deep the label cut is.

#### `LID_LABELS_INVERT_B`
Value is expected to be a bool, and determines whether the lid label is a positive or negative shape.

#### `LID_LABELS_BG_THICKNESS`
Value is expected to be a number, and determines the thickness of the lid label background.

#### `LID_LABELS_BORDER_THICKNESS`
Value is expected to be a number, and determines the thickness of the lid label border.  Default is 0.3 mm

#### `LID_STRIPE_WIDTH`
Value is expected to be a number, and determines the thickness of the lines in the striped grid behind the label.  Default is 0.5 mm

#### `LID_STRIPE_SPACE`
Value is expected to be a number, and determines the spacing of the lines in the striped grid behind the label.  Default is 1.0 mm

#### `LID_HEIGHT`
Value is expected to be a number, and determines how deep cap and inset lid walls are. Defaults are 2mm for inset lids and 4mm for cap lids. Ignored for sliding lids; sliding panel and groove height are controlled by `G_LID_THICKNESS`, with the top of the 45-degree wall forming the top of the groove.

#### `LID_CUTOUT_SIDES_4B`
Value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the lid. This allows the lid to be used as a card tray during play. The values represent [front, back, left, right ].  
e.g. `[ LID_CUTOUT_SIDES_4B, [ t, t, f, f ] ]`

## Compartment keys

#### `FTR_NUM_COMPARTMENTS_XY`
Value is expected to be an array of 2 numbers, and determines how many compartments this component will have in the width and depth direction.  
e.g. `[ FTR_NUM_COMPARTMENTS_XY, [ 4, 6 ] ]`

#### `FTR_COMPARTMENT_SIZE_XYZ`
Value is expected to be an array of 3 numbers, and determines the interior dimensions of each compartment within the component.  
e.g. `[ FTR_COMPARTMENT_SIZE_XYZ, [ 10, 20, 5 ] ]`

#### `FTR_SHAPE`
Value is expected to be one of the following:
- `SQUARE`   default right angled compartment
- `FILLET`   a square compartment with rounded bottom corners on opposite edges
- `ROUND`    a round compartment
- `HEX`      a 6-sided compartment (flat side down)
- `HEX2`     a 6-sided compartment that is rotated 30 degrees (corner down)
- `OCT`      an 8-sided compartment (flat side down)
- `OCT2`     an 8-sided compartment that is rotated 22.5 degrees (corner down)

e.g. `[ FTR_SHAPE, HEX2 ]`. The following box shows all the different components. The front row has the components in the order listed above. The second row shows the same, but rotated (`[FTR_SHAPE_ROTATED_B]` below). The third row has the same order for vertical stacks of pieces (`[FTR_SHAPE_VERTICAL_B]` below).

![All component types](images/components.png)

#### `FTR_SHAPE_ROTATED_B`
Value is expected to be a bool, and determines whether the shape is rotated along the Z axis. That is, whether it goes back and forth or side to side.

#### `FTR_SHAPE_VERTICAL_B`
Value is expected to be a bool, and determines whether the shape is rotated for vertical stacks of pieces.

#### `FTR_FILLET_RADIUS`
Value is expected to be a number, and determines the radius of the fillet, if shape is fillet.

#### `FTR_PEDESTAL_BASE_B`
Value is expected to be a bool, and determines whether the base of the compartment is a pedestal. This allows for cards or tiles to be extracted by pushing down on one of the sides. Ideal for short stacks and for compartments that are interior and where finger cutouts aren't possible or ideal. 

#### `FTR_PADDING_XY`
Value is expected to be an array of 2 numbers, and determines how far apart the compartments in a component array are, in the width and depth direction.  
e.g. `[ FTR_PADDING_XY, [ 2.5, 1.3 ] ]`

#### `FTR_PADDING_HEIGHT_ADJUST_XY`
Value is expected to be an array of 2 numbers, and determines how much to modify the height of the x and y padding between compartments. These should typically be negative values.  
e.g. `[ FTR_PADDING_HEIGHT_ADJUST_XY, [ -3, 0 ] ]`

#### `FTR_MARGIN_FBLR`
Value is expected to be an array of 4 floats, and determines the front, back, left, and right margins, respectively.  
e.g. `[ FTR_MARGIN_FBLR, [ 1, 10, 0, 20 ] ]`

#### `FTR_CUTOUT_SIDES_4B`
Value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the compartments on the sides. The values represent [front, back, left, right ].  
e.g. `[ FTR_CUTOUT_SIDES_4B, [ t, t, f, f ] ]`

#### `FTR_CUTOUT_HEIGHT_PCT`
Value is expected to be an float between 0 and 100, and determines what percent of the box height is removed for finger cutouts, starting from the top.  At 100, side finger cutouts pass through the floor instead of leaving a bottom skin.  The default is 100.
e.g. `[ FTR_CUTOUT_HEIGHT_PCT, 100 ]`

#### `FTR_CUTOUT_DEPTH_PCT`
Value is expected to be an float between 0 and 100, and determines what percent of the box depth is removed for finger cutouts, when the cutout goes into the base of the box.  The default is 25. 
e.g. `[ FTR_CUTOUT_DEPTH_PCT, 25 ]`

#### `FTR_CUTOUT_WIDTH_PCT`
Value is expected to be an float between 0 and 100, and determines what percent of the box width is removed for finger cutouts.  The default is 50. 
e.g. `[ FTR_CUTOUT_WIDTH_PCT, 25 ]`

#### `FTR_CUTOUT_TYPE`
Value is expected to be one of the following keywords: BOTH, INTERIOR, or EXTERIOR, and determines whether where on the component the cutouts are applied.
e.g. `[ FTR_CUTOUT_TYPE, INTERIOR ]`

#### `FTR_CUTOUT_BOTTOM_B`
Value is expected to be a bool and determines whether the bottom of the compartment is cut out. Note that this is ignored if FTR_PEDESTAL_BASE_B is true or if FTR_SHAPE is set to FILLET.
e.g. `[ FTR_CUTOUT_BOTTOM, true ]`

#### `FTR_CUTOUT_BOTTOM_PCT` 
Value is expected to be an float between 0 and 100, and determines what percent of the box bottom is removed for bottom cutouts.  The default is 80. 
e.g. `[ FTR_CUTOUT_BOTTOM_PCT, 90 ]`

#### `FTR_CUTOUT_CORNERS_4B`
Value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the compartments on the corners. The values represent [front-left, back-right, back-left, front-right ].  
e.g. `[ FTR_CUTOUT_CORNERS_4B, [ t, t, f, f ] ]`

#### `FTR_SHEAR`
Value is expected to be an array of 2 numbers, and determines the degrees to which the component should be sheared in the direction of width and depth. The shearing pivots around the center of the component. 
e.g. `[ FTR_SHEAR, [ 45, 0 ] ]`

#### `CHAMFER_N`
When used inside a `BOX_FEATURE`, overrides the box-level chamfer for that component's compartment edges. See the box-level `CHAMFER_N` entry above for details.

## Label keys
Key-pairs that are expected in a LABEL container.

#### `LABEL`
Value is expected to be an array of key-values that define a label. Labels can be defined at the box level for box labels, inside BOX_LID arrays for labels that will appear on the lid, and inside BOX_FEATURE arrays for labels that will appear on the compartments. Each supports as many labels as desired.

#### `LBL_TEXT`
Value is expected to either be a string, or an array of strings matching the structure of the compartments. A single string will label every compartment with that string while an array will label each compartment with its respective string.  
e.g. `[ LBL_TEXT, "tokens" ]`  
or

    [ LBL_TEXT,        
        [   
            ["back left", "back right"],        
            ["front left", "front right"],
        ]
    ]

#### `LBL_IMAGE`
Value is expected to be a string specifying an SVG filename. `LBL_TEXT` takes priority over `LBL_IMAGE`, so if both are provided, only the string will be used. **Warning:** this option will slow things down considerably.
e.g. `[ LBL_IMAGE, "image.svg" ]`

#### `LBL_SIZE`
Value is expected to either be `AUTO` or a number. `AUTO` will attempt to scale the label to fit in the space according to _width_. This does not work will with very short words. A number will specify the font size (if `LBL_TEXT`) or the image width (if `LBL_IMAGE`).
e.g. `[ LBL_SIZE, 12 ]`

#### `LBL_SPACING`
Value is expected to be a number, and determines the letter spacing. 
e.g. `[ LBL_SPACING, 1.1 ]`


#### `LBL_PLACEMENT`
Value is expected to be one of the following:  
- `FRONT`
- `BACK`
- `LEFT`
- `RIGHT`
- `FRONT_WALL`
- `BACK_WALL`
- `LEFT_WALL`
- `RIGHT_WALL`
- `CENTER`
- `BOTTOM`  

Front, back, left, and right, will place the label on the top surface, while the _wall values will place the label inside, on the compartment wall. Center will place the label on the compartment floor. Bottom is for labeling the bottom of the box.

#### `LBL_FONT`
Value is expected to be a string that determines what font to use for the label. More [here](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles).  
e.g. `[ LBL_FONT, "Times New Roman:style=bold italic" ]`

#### `LBL_DEPTH`
Value is expected to be a number, and determines how deep the label should cut.  
e.g. `[ LBL_DEPTH, 0.5 ]`

#### `ROTATION`
Value is expected to be a number, and determines the degree to which the component or label is to be rotated.  
e.g. `[ ROTATION, 45 ]`

#### `POSITION_XY`
Value is expected to be an array of 2 numbers, although `MAX` is also valid, and determines the position of the label or component. 
- When used on a label, the values are relative to reasonable centers and can be used to adjust the positioning of the text.
- When used on a component, it is always relative to the origin of the box, and almost always needs to be present.
- When used on a component, the value `MAX` essentially aligns that value to opposite end, so 'right' when placed in the x position, and 'back' when placed in the y position.  
e.g. `[ POSITION_XY, [ 20, MAX ] ]`

#### `ENABLED_B`
Value is expected to be a bool, and determines whether the box, component, or label, is used. This allows for easily turning features off temporarily or permanently without needing to delete lots of content.  
e.g. `[ ENABLED_B, f ]`

## Dividers keys
As of v2.04, in addition to boxes, one can also create card dividers.

#### `DIV_THICKNESS`
Value is expected to be a number, and determines the thickness of each divider.

#### `DIV_FRAME_SIZE_XY`
Value is expected to be an array of 2 numbers, and determines the width and height of each divider (without the tab).

#### `DIV_FRAME_TOP`
Value is expected to be a number, and determines the height of the top bar of the divider.

#### `DIV_FRAME_BOTTOM`
Value is expected to be a number, and determines the height of the bottom bar of the divider.

#### `DIV_FRAME_COLUMN`
Value is expected to be a number, and determines the width of the vertical bars of the divider.

#### `DIV_FRAME_RADIUS`
Value is expected to be a number, and determines the radius of the frame corners of the divider.

#### `DIV_FRAME_NUM_COLUMNS`
Value is expected to be a number, and determines the number of columns in the middle of the frame of the divider. 0 makes for a frame that has no middle columns. -1 makes for a solid divider with no holes.

#### `DIV_TAB_SIZE_XY`
Value is expected to be an array of 2 numbers, and determines the width and height of each divider's tab.

#### `DIV_TAB_RADIUS`
Value is expected to be a number, and determines the radius of the corner of the tab on the divider.

#### `DIV_TAB_CYCLE`
Value is expected to be a number, and determines over how many dividers should the tab drift from left to right.

#### `DIV_TAB_CYCLE_START`
Value is expected to be a number, and determines the starting position of the first divider.  Default is 1.

#### `DIV_TAB_TEXT`
Value is expected to be an array of strings, and determines what dividers get created.
e.g. `[ DIV_TAB_TEXT, [ "Tab-1", "Tab-2", "Tab-3", "Tab-4" ] ]`

#### `DIV_TAB_TEXT_SIZE`
Value is expected to be a number, and determines the font size of the tab text.

#### `DIV_TAB_TEXT_FONT`
Value is expected to be a string, and determines the font of the tab text. More [here](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles).  
e.g. `[ LBL_FONT, "Times New Roman:style=bold italic" ]`

#### `DIV_TAB_TEXT_SPACING`
Value is expected to be a number, and determines the letter spacing of the tab text.

#### `DIV_TAB_TEXT_CHAR_THRESHOLD`
Value is expected to be a number, and determines the number of characters above which the size of the font should be determined automatically.

# Contributing

## Repository structure

- Default branch: `master`
- Development library file: `release/lib/boardgame_insert_toolkit_lib.4.scad`
- Shipped version-locked library files: `release/lib/boardgame_insert_toolkit_lib.<version>.scad`
- Design files are organized by publisher: `release/<publisher>/<game>.scad`
- Shipped design files should include a full-version library filename, for example `include <../lib/boardgame_insert_toolkit_lib.4.0.8.scad>;`
- Use `release/my_designs/starter.scad` as a template for new designs
- Tests live in `tests/`

## Submitting a design

To contribute a design, fork this repo, add your `.scad` file to the appropriate publisher folder under `release/` (for example, the `release/my_designs/` folder), and open a pull request against the `master` branch. If your publisher doesn't have a folder yet, create one.

## Working on the library itself

After cloning, run `./scripts/install-hooks.sh` once to enable the version-stamping pre-commit hook. The hook increments the patch version by default when the development library has changed since the current full-version file. For user-facing feature releases, commit with `BIT_VERSION_BUMP=minor` so the minor version increments instead.

Version policy:
- Use a patch release for bug fixes and internal changes with no user-facing impact.
- Use a minor release for user-facing features.
- Keep `release/lib/boardgame_insert_toolkit_lib.4.scad` as the moving development file.
- Ship immutable full-version files beside it, such as `release/lib/boardgame_insert_toolkit_lib.4.0.8.scad`.

Before shipping a release, run `./scripts/package-release.sh` with `--patch` for a patch release or with `--minor` for a minor release. The script stamps the development library, writes the full-version copy beside it in `release/lib/`, updates shipped starter/example includes to that immutable filename, and smoke-compiles the shipped entry files against the versioned library. Re-running the script is idempotent when the current library already matches its full-version file.

The test suite should continue to include `release/lib/boardgame_insert_toolkit_lib.4.scad`, not a full-version copy. That keeps regression tests on the current development surface while shipped designs stay locked to the library version they were created against.

## Reporting bugs

Open an issue at https://github.com/dppdppd/The-Boardgame-Insert-Toolkit/issues with a description of the problem and, if possible, the `.scad` file that reproduces it.

# Published inserts:


- [1830]( https://www.thingiverse.com/thing:3499314)
- [18 India](https://www.thingiverse.com/thing:6732380)
- [7th Continent dividers]( https://www.thingiverse.com/thing:4223923)
- [Architects of the West Kingdom](https://www.thingiverse.com/thing:3937497)
- [Argent Consortium](https://www.thingiverse.com/thing:4549937)
- [BattleLore Second Edition](https://www.printables.com/model/60472-battlelore-second-edition-insert)
- [Bios: Megafauna](https://www.thingiverse.com/thing:3493660)
- [Bios:Genesis](https://www.thingiverse.com/thing:3452368)
- [Castle von Loghan](https://www.printables.com/model/233659-insert-for-castle-von-loghan)
- [Comanchería]( https://www.thingiverse.com/thing:4187266)
- [DiceWar Light of Dragons](https://www.thingiverse.com/thing:6527847)
- [Dinosaur Island Deluxe Edition](https://www.thingiverse.com/thing:4015696)
- [Dune]( https://www.thingiverse.com/thing:4403586 )
- [Dune: Imperium ultimate organizer](https://www.thingiverse.com/thing:6918725)
- [Empyreal Spells & Steam]( https://www.thingiverse.com/thing:4554217 )
- [Empyreal Spells % Steam](https://www.thingiverse.com/thing:4554217)
- [Greenland/Neanderthal]( https://www.thingiverse.com/thing:3469793)
- [Hadrian's Wall](https://www.printables.com/model/90472-insert-for-hadrians-wall-board-game)
- [Happy Pigs](https://www.thingiverse.com/thing:4031037)
- [High Frontier (3rd)]( https://www.thingiverse.com/thing:3482341)
- [Indonesia (upgraded goods and ships )]( https://www.thingiverse.com/thing:3454636)
- [Indonesia (upgraded goods)]( https://www.thingiverse.com/thing:3446879)
- [Journeys in Middle-Earth Battle-Map Terrain box](https://www.printables.com/model/60425-journeys-in-middle-earth-battle-map-terrain-stuff)
- [Maqui 2nd edition](https://www.printables.com/model/90469-insert-for-maqui-board-game-2nd-printing)
- [Mansions of Madness 2nd edition persons container](https://www.printables.com/model/60421-mansions-of-madness-2nd-edition-persons-container)
- [Mice and Mystics]( https://www.thingiverse.com/thing:3435429)
- [Noria](https://www.thingiverse.com/thing:6162186)
- [Orleans]( https://www.thingiverse.com/thing:4493482 )
- [Pandemic]( https://www.thingiverse.com/thing:3412724)
- [Pax Emancipation]( https://www.thingiverse.com/thing:3450282)
- [Pax Porfiriana (Collector's Edition)]( https://www.thingiverse.com/thing:3478944)
- [Pax Renaissance]( https://www.thingiverse.com/thing:3479114)
- [Root](https://www.printables.com/model/60470-root-insert-for-custom-miniatures)
- [Space Hulk Death Angel](https://www.thingiverse.com/thing:4592270)
- [Spyrium](https://www.thingiverse.com/thing:4010875)
- [Star Trek: Frontiers](https://www.printables.com/model/60422-star-trek-frontiers)
- [Stuffed Fables]( https://www.thingiverse.com/thing:3535505)
- [Sword & Sorcery plus Expansions](https://www.thingiverse.com/thing:3699454)
- [Sword & Sorcery]( https://www.thingiverse.com/thing:3515523)
- [Sword & Sorcey Cards box and Chit box](https://www.thingiverse.com/thing:3637030)
- [Tainted Grail: Fall of Avalon](https://www.thingiverse.com/thing:4812198) & [Tainted Grail Expansions](https://www.thingiverse.com/thing:4812222)
- [Tapestry](https://www.thingiverse.com/thing:4579132)
- [Tyrants of the Underdark]( https://www.thingiverse.com/thing:4570276 )
- [V Commandos]( https://www.thingiverse.com/thing:4319308 )
