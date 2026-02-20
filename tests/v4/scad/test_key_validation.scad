// Test: Key validation catches typos, malformed entries, and wrong value types
// Expected: renders successfully with BIT: messages in console
// NOTE: type errors here use values that still render (no OpenSCAD WARNINGs)
//       but are caught by our validation as semantically wrong.
include <boardgame_insert_toolkit_lib.4.scad>;
include <bit_functions_lib.4.scad>;

data = [
    [ G_DEFAULT_FONT, "Liberation Sans:style=Regular" ],
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "key_typos_box" ],
        [ BOX_SIZE_XYZ, [60, 40, 20] ],
        // --- Key name typos (5 total) ---
        [ "boz_size", [
            60,
            40,
            20,
        ]],
        // typo: boz_size
        [ "compnent", [
        ]],
        // typo: compnent (should be component)
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [25, 35, 18] ],
            [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
            // Intentional component-level typo
            [ "cmp_shapee", "square" ],
            // typo: cmp_shapee
        ],
        [ BOX_LID,
            [ LID_SOLID_B, true ],
            // Intentional lid-level typo
            [ "lid_hight", 3 ],
            // typo: lid_hight
            [ LABEL,
                [ LBL_TEXT, "test" ],
                [ LBL_SIZE, 8 ],
                // Intentional label-level typo
                [ "lbl_fontt", "sans" ],
                // typo: lbl_fontt
            ],
        ],
    ],
    // --- Type validation box: wrong types that still render cleanly ---
    // These use valid box structure but with type errors caught by validation
    [ OBJECT_BOX,
        [ NAME, "type_check_box" ],
        [ BOX_SIZE_XYZ, [60, 40, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 36, 18] ],
            // Wrong type: string where enum expected (caught as invalid shape)
            [ FTR_SHAPE, "triangle" ],
            // not a valid shape enum
            // Wrong type: string where bool expected
            [ FTR_PEDESTAL_BASE_B, "yes" ],
            // should be bool
        ],
        // Wrong type: string where bool expected
        [ BOX_NO_LID_B, "false" ],
        // should be bool, not string
    ],
    // --- #3: Missing FTR_COMPARTMENT_SIZE_XYZ ---
    [ OBJECT_BOX,
        [ NAME, "missing_cmp_size" ],
        [ BOX_SIZE_XYZ, [40, 40, 15] ],
        [ BOX_FEATURE,
            // no FTR_COMPARTMENT_SIZE_XYZ — should warn about 10x10x10 default
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
        ],
    ],
    // --- #4: Lid clearance — lid won't fit under box ---
    [ OBJECT_BOX,
        [ NAME, "lid_too_tall" ],
        [ BOX_SIZE_XYZ, [40, 40, 6] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [36, 36, 4] ],
        ],
        [ BOX_LID,
            [ LID_FIT_UNDER_B, true ],
            // default cap lid: 4mm wall + 1.5mm thickness = 5.5mm > 4.5mm interior
        ],
    ],
];
Make(data);
