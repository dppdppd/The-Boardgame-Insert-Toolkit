// This function simplifies creating a square component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// lbl:          Optional parameter - Text to include on the bottom - defaults to blank
// font:         Optional parameter - OpensSCAD font specifier - defaults to g_default_font
// size:         Optional parameter - Size of label - defaults to AUTO
function ftr_parms( dx, dy, dz, llx=0, lly=0, lbl="", font=g_default_font, size=AUTO ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [LABEL, 
    [
        [LBL_TEXT, lbl],
        [LBL_FONT, font ],
        [LBL_SIZE, size],
        [LBL_PLACEMENT, CENTER],
        [LBL_DEPTH, 1],
    ],
    ],
];

// This function simplifies creating a fillet component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// radius:       Optional parameter - Radius of the fillet - defaults to 5
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
// lbl:          Optional parameter - Text to include on the bottom - defaults to blank
// font:         Optional parameter - OpensSCAD font specifier - defaults to g_default_font
// size:         Optional parameter - Size of label - defaults to AuTO
function ftr_parms_fillet( dx, dy, dz, llx=0, lly=0, radius=5, rot=t, vert=f, lbl="", font=g_default_font, size=AUTO ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, FILLET],
    [FTR_FILLET_RADIUS, radius],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
    [LABEL, 
    [
        [LBL_TEXT, lbl],
        [LBL_FONT, font ],
        [LBL_SIZE, size],
        [LBL_PLACEMENT, CENTER],
        [LBL_DEPTH, 1],
    ],
    ],
];

// This function simplifies creating a round component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
function ftr_parms_round( dx, dy, dz, llx=0, lly=0, rot=t, vert=f ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, ROUND],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
];

// This function simplifies creating a hex component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
function ftr_parms_hex( dx, dy, dz, llx=0, lly=0, rot=t, vert=f ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, HEX],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
];

// This function simplifies creating a hex2 component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
function ftr_parms_hex2( dx, dy, dz, llx=0, lly=0, rot=t, vert=f ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, HEX2],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
];

// This function simplifies creating a oct component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
function ftr_parms_oct( dx, dy, dz, llx=0, lly=0, rot=t, vert=f ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, OCT],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
];

// This function simplifies creating a oct2 component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// rot:          Optional parameter - Is component rotated around Z axis - defaults to t. Valid values: t, f
// vert:         Optional parameter - Is component for vertical stack of pieces - defaults to f. Valid values: t, f
function ftr_parms_oct2( dx, dy, dz, llx=0, lly=0, rot=t, vert=f ) =
[
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, OCT2],
    [FTR_SHAPE_ROTATED_B, rot],
    [FTR_SHAPE_VERTICAL_B, vert],
];


// This function simplifies creating a vertical round component
// Inputs:
// (dx, dy, dz): Size of the component
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
function ftr_parms_disc( llx=0, lly=0, dx, dy, dz ) =
[
    [FTR_SHAPE_VERTICAL_B, t],
    [FTR_SHAPE, ROUND],
    [FTR_NUM_COMPARTMENTS_XY,   [ 1, 1 ] ],
    [FTR_COMPARTMENT_SIZE_XYZ,  [ dx, dy, dz ] ],
    [POSITION_XY,  [ llx, lly] ],
];

// This function simplifies creating a vertical hexagonal component with a label at the bottom
// Instead of specifying x and y dimensions, the diameter of the hex is used. This is the
// easiest way to make a box for hexagonal tiles.
// Inputs:
// (d, dz):      Size of the component - d is the "diameter" of the tile, and dz is the depth of the stack
// (llx, lly):   Optional parameter - Location of lower left corner - defaults to (0, 0)
// lbl:          Optional parameter - Text to include on the bottom - defaults to blank
// font:         Optional parameter - OpensSCAD font specifier - defaults to g_default_font
// size:         Optional parameter - Size of label - defaults to AuTO
function ftr_parms_hex_tile( llx=0, lly=0, d, dz, lbl="", font=g_default_font, size=AUTO ) =
[
    [FTR_COMPARTMENT_SIZE_XYZ,  [ d, d * sin(60), dz ] ],
    [POSITION_XY,  [ llx, lly ] ],
    [FTR_SHAPE, HEX2],
    [FTR_SHAPE_VERTICAL_B, t],
    [LABEL, 
    [
        [LBL_TEXT, lbl],
        [LBL_FONT, font ],
        [LBL_SIZE, size],
        [LBL_PLACEMENT, CENTER],
        [LBL_DEPTH, 1],
    ],
    ],
];

// This function simplifies creating an inset lid with a hexagonal pattern
// Inputs:
// radius:       Optional parameter - Radius of the hexagons - defaults to 5mm
// thickness:    Optional parameter - Thickness of the hexagonal borders - defaults to 1mm 
// lbl:          Optional parameter - Text to include on the bottom - defaults to blank
// font:         Optional parameter - OpensSCAD font specifier - defaults to g_default_font
// size:         Optional parameter - Size of label - defaults to AuTO
function lid_parms(radius=5, thickness=1, lbl="", font=g_default_font, size=AUTO) =
[
    [ LID_SOLID_B, f],
    [ LID_INSET_B, t],
    [ LID_HEIGHT,  1.5 ],
    [ LID_LABELS_INVERT_B, f],

    [ LID_PATTERN_RADIUS, radius],
    [ LID_PATTERN_THICKNESS, thickness],

    [ LID_LABELS_BORDER_THICKNESS, 0.5 ],
    [ LID_LABELS_BORDER_THICKNESS, 0.5 ],
    [ LABEL,
    [   
        [ LBL_TEXT,     lbl ],
        [ LBL_FONT,     font ],
        [ LBL_SIZE,     size ],
        [ ROTATION,     0 ],
        [ POSITION_XY, [ 0, 0 ]],
    ]
    ],

];

// This function simplifies creating a solid inset lid
function lid_parms_solid() =
[
    [ LID_SOLID_B, t],
    [ LID_INSET_B, t],
    [ LID_HEIGHT,  1.5 ],

];
