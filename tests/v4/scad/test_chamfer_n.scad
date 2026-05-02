// Test: CHAMFER_N parameter — exterior edge chamfering + cavity floor/opening chamfers
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
        [ CHAMFER_N, 0.5 ],
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
                   [ CHAMFER_N, 0.5 ],
        ],
    ],

    // Box with chamfer + inset lid + stackable, mixed compartments
    [ OBJECT_BOX,
        [ NAME, "chamfer inset stackable" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_STACKABLE_B, true ],
        [ CHAMFER_N, 0.5 ],
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

    // Box with no explicit CHAMFER_N — exercises the default (0.5 surface mm)
    [ OBJECT_BOX,
        [ NAME, "default chamfer" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 22, 23] ],
        ],
    ],

    // Box with non-square (vertical) cavities + chamfer — exercises the
    // shape-aware code paths in AddCompartmentChamfers (bottom: tapered ring
    // matching the cavity wall, sloped 45° perpendicular to each face) and
    // AddCompartmentTopChamfers (opening flares outward by c).
    // Use a generous chamfer (2.0 mm surface) so the slope is unambiguous.
    [ OBJECT_BOX,
        [ NAME, "chamfer non-square vertical" ],
        [ BOX_SIZE_XYZ, [80, 30, 25] ],
        [ BOX_NO_LID_B, true ],
        [ CHAMFER_N, 2.0 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [1, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 23] ],
            [ FTR_SHAPE, HEX ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ POSITION_XY, [2, 2] ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [1, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 23] ],
            [ FTR_SHAPE, OCT ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ POSITION_XY, [27, 2] ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [1, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 23] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ POSITION_XY, [52, 2] ],
        ],
    ],

    // CHAMFER_N = 0 — explicit zero, exercises the gate that skips both
    // bottom and top chamfer modules. Compartment edges should be sharp.
    [ OBJECT_BOX,
        [ NAME, "chamfer 0" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_NO_LID_B, true ],
        [ CHAMFER_N, 0 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 22, 23] ],
        ],
    ],

    // CHAMFER_N = 1.0 — visible chamfer, 2× the default (0.5).
    [ OBJECT_BOX,
        [ NAME, "chamfer 1.0" ],
        [ BOX_SIZE_XYZ, [70, 50, 25] ],
        [ BOX_NO_LID_B, true ],
        [ CHAMFER_N, 1.0 ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 22, 23] ],
        ],
    ],
];
Make(data);
