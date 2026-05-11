// Test: one validation flag controls key/type and physical validation
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

validation_on_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ OBJECT_BOX,
        [ NAME, "flag validation on" ],
        [ BOX_SIZE_XYZ, [30, 24, 8] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ "boz_size", [30, 24, 8] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 6] ],
            [ FTR_PEDESTAL_BASE_B, "yes" ],
        ],
    ],
];

validation_off_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_VALIDATE_KEYS_B, false ],
    [ OBJECT_BOX,
        [ NAME, "flag validation off" ],
        [ BOX_SIZE_XYZ, [30, 24, 8] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ "boz_size", [30, 24, 8] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 6] ],
        ],
    ],
];

Make(validation_on_data);
translate([40, 0, 0]) Make(validation_off_data);
