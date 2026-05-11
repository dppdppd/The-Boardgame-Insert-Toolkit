// Test: nested BOX_FEATURE entries are schema- and physical-validated.
// Expected: renders parent geometry and emits BGSD_WARNING messages for nested
// feature limitation, nested key/type validation contexts, parent-local child
// bounds, and sibling child overlap.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested_feature_validation" ],
        [ BOX_SIZE_XYZ, [72, 44, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "parent cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [64, 36, 14] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "schema only child" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 10] ],
                [ FTR_SHAPE, ROUND ],
                [ POSITION_XY, [4, 4] ],
                [ LABEL,
                    [ LBL_TEXT, "child" ],
                    [ LBL_SIZE, 5 ],
                    [ "lbl_fontt", "sans" ],
                ],
                [ FTR_DIVIDERS,
                    [ DIV_AXIS, "z" ],
                ],

                [ BOX_FEATURE,
                    [ NAME, "grandchild validation" ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, ["bad", 4, 3] ],
                    [ "cmp_shapee", ROUND ],
                    [ POSITION_XY, [CENTER, MAX] ],
                ],
            ],

            [ BOX_FEATURE,
                [ NAME, "overlap child" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 8] ],
                [ POSITION_XY, [12, 12] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "out of parent child" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [20, 12, 8] ],
                [ POSITION_XY, [50, 28] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "bad child types" ],
                [ FTR_SHAPE, "triangle" ],
                [ POSITION_XY, ["left", CENTER] ],
            ],
        ],
    ],
];

Make(data);
