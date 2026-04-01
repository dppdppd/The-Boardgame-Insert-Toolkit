// Test: CHAMFER_N — single box with cap lid, visualization (closed) mode
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
   // [ G_VISUALIZATION_B, true ],
    [ OBJECT_BOX,
        [ NAME, "chamfer closed" ],
        [ BOX_SIZE_XYZ, [50, 50, 25] ],
        [ CHAMFER_N, 0.4 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 23] ],
        ],
    ],
];
Make(data);
