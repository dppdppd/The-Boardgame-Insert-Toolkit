// Test: Helper functions from bit_functions_lib.3.scad — all ftr_parms_* variants
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

wall = g_wall_thickness;
sz = 20;
pitch = sz + wall;

data = [
    [ "helper functions",
        [
            [ BOX_SIZE_XYZ, [7*20 + 8*wall, 3*20 + 4*wall, sz+3*wall] ],
            [ BOX_FEATURE, ftr_parms(llx=0*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_fillet(llx=1*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_fillet(llx=1*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_round(llx=2*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_round(llx=2*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_round(llx=2*pitch, lly=2*pitch, dx=sz, dy=sz, dz=sz, vert=t) ],
            [ BOX_FEATURE, ftr_parms_hex(llx=3*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_hex(llx=3*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_hex(llx=3*pitch, lly=2*pitch, dx=sz, dy=sz, dz=sz, vert=t) ],
            [ BOX_FEATURE, ftr_parms_hex2(llx=4*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_hex2(llx=4*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_hex2(llx=4*pitch, lly=2*pitch, dx=sz, dy=sz, dz=sz, vert=t) ],
            [ BOX_FEATURE, ftr_parms_oct(llx=5*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_oct(llx=5*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_oct(llx=5*pitch, lly=2*pitch, dx=sz, dy=sz, dz=sz, vert=t) ],
            [ BOX_FEATURE, ftr_parms_oct2(llx=6*pitch, lly=0*pitch, dx=sz, dy=sz, dz=sz) ],
            [ BOX_FEATURE, ftr_parms_oct2(llx=6*pitch, lly=1*pitch, dx=sz, dy=sz, dz=sz, rot=f) ],
            [ BOX_FEATURE, ftr_parms_oct2(llx=6*pitch, lly=2*pitch, dx=sz, dy=sz, dz=sz, vert=t) ],
        ]
    ],
];

MakeAll();
