// Test: FEATURE_COPY validates malformed references and copy transform values.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "feature copy validation examples" ],
        [ BOX_SIZE_XYZ, [70, 42, 20] ],
        [ BOX_NO_LID_B, true ],

        [ BOX_FEATURE,
            [ NAME, "known bay" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 14] ],
            [ POSITION_XY, [10, 10] ],
        ],

        [ FEATURE_COPY,
            [ NAME, "bad reference type" ],
            [ ENABLED_B, false ],
            [ FEATURE_REFERENCE, 17 ],
            [ POSITION_XY, [34, 10] ],
        ],

        [ FEATURE_COPY,
            [ NAME, "missing reference" ],
            [ ENABLED_B, false ],
            [ FEATURE_REFERENCE, "does not exist" ],
            [ POSITION_XY, "left" ],
            [ ROTATION, "tilted" ],
        ],
    ],
];

Make(data);
