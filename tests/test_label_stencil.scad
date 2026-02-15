// Test: Label stencil mode — LID_LABELS_INVERT_B, LID_LABELS_BG_THICKNESS, LID_LABELS_BORDER_THICKNESS
// NOTE: This test is slow (~3-5 min STL export) due to inverted label CSG complexity.
// Reduced box size and larger pattern radius to keep render time manageable.
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "stencil label",
        [
            [ BOX_SIZE_XYZ, [40, 40, 15] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [37, 37, 13] ],
                ]
            ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 4 ],
                    [ LID_LABELS_INVERT_B, t ],
                    [ LID_LABELS_BG_THICKNESS, 0 ],
                    [ LID_LABELS_BORDER_THICKNESS, 1 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "INV" ],
                            [ LBL_FONT, "Liberation Sans:style=Bold" ],
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
