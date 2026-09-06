// Test: Solid lid label depth — LID_SOLID_LABELS_DEPTH
// The glyphs are incised to the given depth rather than cut through the lid,
// and on the face the label mirror targets.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "solid lid label depth" ],
        [ BOX_SIZE_XYZ, [90, 45, 15] ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
            [ LID_SOLID_LABELS_DEPTH, 0.5 ],
            [ LABEL,
                [ LBL_TEXT, "Depth" ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [86, 41, 13] ],
        ],
    ],
];
Make(data);
