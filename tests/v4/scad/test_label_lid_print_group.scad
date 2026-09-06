// Test: Lid label on its own print group — PRINT_GROUP / G_PRINT_GROUPS
// The label is emitted detached so it can be printed in a second filament. Its
// glyph solids must land exactly in the recesses cut into the lid body, and be
// the depth of those recesses rather than the full lid thickness.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "detached lid label" ],
        [ BOX_SIZE_XYZ, [90, 45, 15] ],
        [ BOX_LID,
            [ PRINT_GROUP, "body" ],
            [ LID_SOLID_B, f ],
            [ LID_LABELS_INVERT_B, t ],
            [ LID_SOLID_LABELS_DEPTH, 0.5 ],
            [ LABEL,
                [ PRINT_GROUP, "text" ],
                [ LBL_TEXT, "Two Tone" ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [86, 41, 13] ],
        ],
    ],
];
Make(data);
