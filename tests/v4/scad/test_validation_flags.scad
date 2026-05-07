// Test: Key/type and physical validation flags can be mixed independently
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

key_on_physical_off_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_VALIDATE_PHYSICAL_B, false ],
    [ OBJECT_BOX,
        [ NAME, "flag key on physical off" ],
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

key_off_physical_on_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_VALIDATE_KEYS_B, false ],
    [ G_VALIDATE_PHYSICAL_B, true ],
    [ OBJECT_BOX,
        [ NAME, "flag key off physical on" ],
        [ BOX_SIZE_XYZ, [30, 24, 8] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 6] ],
        ],
    ],
];

both_off_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_VALIDATE_KEYS_B, false ],
    [ G_VALIDATE_PHYSICAL_B, false ],
    [ OBJECT_BOX,
        [ NAME, "flag both off" ],
        [ BOX_SIZE_XYZ, [30, 24, 8] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ "boz_size", [30, 24, 8] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 6] ],
        ],
    ],
];

legacy_key_off_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_VALIDATE_KEYS_B, false ],
    [ OBJECT_BOX,
        [ NAME, "flag legacy key off" ],
        [ BOX_SIZE_XYZ, [30, 24, 8] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ "boz_size", [30, 24, 8] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 6] ],
        ],
    ],
];

Make(key_on_physical_off_data);
translate([40, 0, 0]) Make(key_off_physical_on_data);
translate([80, 0, 0]) Make(both_off_data);
translate([120, 0, 0]) Make(legacy_key_off_data);
