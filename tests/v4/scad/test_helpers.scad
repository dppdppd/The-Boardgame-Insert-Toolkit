// Test: All compartment shape variants in a grid
include <boardgame_insert_toolkit_lib.4.scad>;

wall = $g_wall_thickness;
sz = 20;
pitch = sz + wall;

data = [
    [ G_DEFAULT_FONT, "Liberation Sans:style=Regular" ],
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "shape variants" ],
        [ BOX_SIZE_XYZ, [7 * 20 + 8 * wall, 3 * 20 + 4 * wall, sz + 3 * wall] ],
        // square
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [0 * pitch, 0 * pitch] ],
        ],
        // fillet
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [1 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, FILLET ],
            [ FTR_FILLET_RADIUS, 5 ],
        ],
        // fillet rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [1 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, FILLET ],
            [ FTR_FILLET_RADIUS, 5 ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // round
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [2 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, ROUND ],
        ],
        // round rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [2 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // round vertical
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [2 * pitch, 2 * pitch] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ],
        // hex
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [3 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, HEX ],
        ],
        // hex rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [3 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, HEX ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // hex vertical
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [3 * pitch, 2 * pitch] ],
            [ FTR_SHAPE, HEX ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ],
        // hex2
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [4 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, HEX2 ],
        ],
        // hex2 rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [4 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // hex2 vertical
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [4 * pitch, 2 * pitch] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ],
        // oct
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [5 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, OCT ],
        ],
        // oct rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [5 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, OCT ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // oct vertical
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [5 * pitch, 2 * pitch] ],
            [ FTR_SHAPE, OCT ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ],
        // oct2
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [6 * pitch, 0 * pitch] ],
            [ FTR_SHAPE, OCT2 ],
        ],
        // oct2 rotated
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [6 * pitch, 1 * pitch] ],
            [ FTR_SHAPE, OCT2 ],
            [ FTR_SHAPE_ROTATED_B, f ],
        ],
        // oct2 vertical
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [sz, sz, sz] ],
            [ POSITION_XY, [6 * pitch, 2 * pitch] ],
            [ FTR_SHAPE, OCT2 ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ],
    ],
];
Make(data);
