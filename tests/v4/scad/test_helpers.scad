// Test: Helper functions from bit_functions_lib.3.scad — all ftr_parms_* variants
include <boardgame_insert_toolkit_lib.4.scad>;
include <bit_functions_lib.4.scad>;

wall = $g_wall_thickness;
sz = 20;
pitch = sz + wall;

data = [
    [ G_DEFAULT_FONT, "Liberation Sans:style=Regular" ],
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "helper functions" ],
        [ BOX_SIZE_XYZ, [7 * 20 + 8 * wall, 3 * 20 + 4 * wall, sz + 3 * wall] ],
        ftr_parms(llx =0 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_fillet(llx =1 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_fillet(llx =1 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_round(llx =2 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_round(llx =2 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_round(llx =2 * pitch, lly =2 * pitch, dx =sz, dy =sz, dz =sz, vert =t),
        ftr_parms_hex(llx =3 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_hex(llx =3 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_hex(llx =3 * pitch, lly =2 * pitch, dx =sz, dy =sz, dz =sz, vert =t),
        ftr_parms_hex2(llx =4 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_hex2(llx =4 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_hex2(llx =4 * pitch, lly =2 * pitch, dx =sz, dy =sz, dz =sz, vert =t),
        ftr_parms_oct(llx =5 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_oct(llx =5 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_oct(llx =5 * pitch, lly =2 * pitch, dx =sz, dy =sz, dz =sz, vert =t),
        ftr_parms_oct2(llx =6 * pitch, lly =0 * pitch, dx =sz, dy =sz, dz =sz),
        ftr_parms_oct2(llx =6 * pitch, lly =1 * pitch, dx =sz, dy =sz, dz =sz, rot =f),
        ftr_parms_oct2(llx =6 * pitch, lly =2 * pitch, dx =sz, dy =sz, dz =sz, vert =t),
    ],
];
Make(data);
