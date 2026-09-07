// Native odd polygons: TRI, TRI2, PENT, PENT2 run left to right.
// Rows from front to back: vertical default chamfer, vertical sharp edge,
// laid-down X axis, laid-down Y axis. The last two omit unsupported chamfers.
// Each 20 mm footprint has 4 mm of separation so default opening chamfers
// cannot meet a neighboring cavity; the surrounding box leaves a solid floor.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

shapes = [TRI, TRI2, PENT, PENT2];
data = [
    [ G_PRINT_TYPES, [BOX] ],
    [ OBJECT_BOX,
        [ NAME, "triangle and pentagon compartments" ],
        [ BOX_SIZE_XYZ, [108, 108, 24] ],
        [ BOX_NO_LID_B, true ],
        for (row = [0:3], col = [0:3])
            [ BOX_FEATURE,
                [ FTR_SHAPE, shapes[col] ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                [ POSITION_XY, [4 + col * 24, 4 + row * 24] ],
                [ FTR_SHAPE_VERTICAL_B, row < 2 ],
                [ FTR_SHAPE_AXIS, row == 2 ? X : Y ],
                if (row > 0) [ CHAMFER_N, 0 ],
            ],
    ],
];
Make(data);
