// Test: Helper functions — lid_parms() and lid_parms_solid()
include <boardgame_insert_toolkit_lib.4.scad>;
include <bit_functions_lib.4.scad>;

data = [
    [ G_DEFAULT_FONT, "Liberation Sans:style=Regular" ],
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "lid_parms helper" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        ftr_parms(dx =46, dy =46, dz =18),
        lid_parms(radius =8, lbl ="PATTERN", font ="Arial:style=Bold", size =10),
    ],
    [ OBJECT_BOX,
        [ NAME, "lid_parms_solid helper" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        ftr_parms(dx =46, dy =46, dz =18),
        lid_parms_solid(),
    ],
];
Make(data);
