// Test: laid-down hex/oct CHAMFER_N emits unsupported cavity chamfer warnings
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "laid-down feature chamfer warning" ],
        [ BOX_SIZE_XYZ, [82, 28, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 14] ],
            [ FTR_SHAPE, HEX ],
            [ CHAMFER_N, 2.0 ],
            [ POSITION_XY, [1, 1] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 14] ],
            [ FTR_SHAPE, OCT ],
            [ CHAMFER_N, 2.0 ],
            [ POSITION_XY, [25, 1] ],
        ],
        // Vertical hex is supported and should not add an unsupported warning.
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 14] ],
            [ FTR_SHAPE, HEX ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ CHAMFER_N, 2.0 ],
            [ POSITION_XY, [49, 1] ],
        ],
    ],

    [ OBJECT_BOX,
        [ NAME, "laid-down box chamfer warning" ],
        [ BOX_SIZE_XYZ, [58, 28, 18] ],
        [ BOX_NO_LID_B, true ],
        [ CHAMFER_N, 1.5 ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 14] ],
            [ FTR_SHAPE, OCT2 ],
            [ POSITION_XY, [3, 1] ],
        ],
        // Explicit zero opts this unsupported cavity out of CHAMFER_N handling.
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 14] ],
            [ FTR_SHAPE, HEX2 ],
            [ CHAMFER_N, 0 ],
            [ POSITION_XY, [31, 1] ],
        ],
    ],
];

Make(data);
