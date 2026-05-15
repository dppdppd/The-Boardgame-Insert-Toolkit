// Practical nested validation example:
// A card-and-token tray intentionally includes realistic authoring mistakes:
// a typo in a nested label, a bad nested divider axis, overlapping coin wells,
// an oversized token cup that escapes the parent tray, and malformed child data.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],

    [ OBJECT_BOX,
        [ NAME, "nested tray validation examples" ],
        [ BOX_SIZE_XYZ, [76, 48, 20] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "card and token parent tray" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [66, 38, 16] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "coin pool with label typo" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 10] ],
                [ FTR_SHAPE, ROUND ],
                [ POSITION_XY, [4, 4] ],
                [ LABEL,
                    [ LBL_TEXT, "coin" ],
                    [ LBL_SIZE, 5 ],
                    [ "lbl_fontt", "sans" ],
                ],
                [ FTR_DIVIDERS,
                    [ DIV_AXIS, "z" ],
                ],

                [ BOX_FEATURE,
                    [ NAME, "malformed nested gem pocket" ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, ["bad", 4, 3] ],
                    [ "cmp_shapee", ROUND ],
                    [ POSITION_XY, [CENTER, MAX] ],
                ],
            ],

            [ BOX_FEATURE,
                [ NAME, "overlapping coin pool" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 8] ],
                [ POSITION_XY, [12, 12] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "oversized token cup" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [20, 12, 8] ],
                [ POSITION_XY, [52, 30] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "malformed card slot" ],
                [ FTR_SHAPE, "triangle" ],
                [ POSITION_XY, ["left", CENTER] ],
            ],
        ],
    ],
];

Make(data);
