// Test: CHAMFER_N parameter — exterior edge chamfering
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    // Box with chamfer, no lid, 3x2 grid
    [ OBJECT_BOX,
        [ NAME, "chamfer no lid" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_NO_LID_B, true ],
        [ CHAMFER_N, 0.2 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 22, 23] ],
        ],
    ],

    // Box with chamfer + cap lid, 2x2 grid with cutouts
    [ OBJECT_BOX,
        [ NAME, "chamfer cap lid" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 22, 23] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
                   [ CHAMFER_N, 0.2 ],
        ],
    ],

    // Box with chamfer + inset lid + stackable, mixed compartments
    [ OBJECT_BOX,
        [ NAME, "chamfer inset stackable" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_STACKABLE_B, true ],
        [ CHAMFER_N, 0.2 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 46, 23] ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [1, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [10, 20, 15] ],
            [ POSITION_XY, [55, 2] ],
        ],
    ],

    // Box with no chamfer (default) — reference
    [ OBJECT_BOX,
        [ NAME, "no chamfer" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 22, 23] ],
        ],
    ],
];
Make(data);
