// Test: Box-level labels on all sides — FRONT, BACK, LEFT, RIGHT, BOTTOM
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "all side labels",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ LABEL,
                [
                    [ LBL_TEXT, "FRONT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, FRONT ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "BACK" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, BACK ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "LEFT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, LEFT ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "RIGHT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, RIGHT ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "BOTTOM" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, BOTTOM ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
                ]
            ],
        ]
    ],
];

MakeAll();
