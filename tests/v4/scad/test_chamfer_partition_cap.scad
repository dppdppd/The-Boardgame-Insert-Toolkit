// Test: square-cavity CHAMFER_N top chamfers cap at internal partition walls
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "square chamfer partition cap" ],
        [ BOX_SIZE_XYZ, [42, 42, 16] ],
        [ BOX_NO_LID_B, true ],
        // Surface width 2.0mm converts to a 1.414mm leg, deliberately larger
        // than half the 1.0mm partition width so the per-side cap is exercised.
        [ CHAMFER_N, 2.0 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 14] ],
            [ FTR_PADDING_XY, [1, 1] ],
        ],
    ],
];

Make(data);
