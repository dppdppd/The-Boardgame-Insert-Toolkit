// Test: Label stencil mode — LID_LABELS_INVERT_B, LID_LABELS_BG_THICKNESS, LID_LABELS_BORDER_THICKNESS
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "stencil label",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [47, 47, 18] ],
                ]
            ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 2 ],
                    [ LID_LABELS_INVERT_B, t ],
                    [ LID_LABELS_BG_THICKNESS, 0 ],
                    [ LID_LABELS_BORDER_THICKNESS, 1 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "STENCIL" ],
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
