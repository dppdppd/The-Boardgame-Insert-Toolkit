// Test: Inverted lid label — LID_LABELS_INVERT_B
// A solid, full-thickness plaque set into the perforated lid, with the glyphs
// incised into it to LID_SOLID_LABELS_DEPTH. The lattice survives around it.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "inverted lid label" ],
        [ BOX_SIZE_XYZ, [90, 45, 15] ],
        [ BOX_LID,
            [ LID_SOLID_B, f ],
            [ LID_LABELS_INVERT_B, t ],
            [ LID_SOLID_LABELS_DEPTH, 0.5 ],
            [ LABEL,
                [ LBL_TEXT, "Incised" ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [86, 41, 13] ],
        ],
    ],
];
Make(data);
