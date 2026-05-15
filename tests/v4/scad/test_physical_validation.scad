// Test: Physical validation messages for fit and printability issues
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

function __test_all_true( values, i = 0 ) =
    i >= len( values ) ? true : values[ i ] && __test_all_true( values, i + 1 );

function __test_close( a, b, eps = 0.000001 ) =
    is_list( a ) ?
        ( is_list( b ) && len( a ) == len( b ) &&
          __test_all_true( [ for ( i = [ 0 : len( a ) - 1 ] ) __test_close( a[ i ], b[ i ], eps ) ] ) ) :
        abs( a - b ) <= eps;

function __test_expected_sliding_detent_aabb(
    slide_side,
    rail_side_clearance,
    detent_width,
    detent_height,
    detent_length,
    opening_side_edge_pos,
    cross_axis_span,
    z_min = 0,
    z_overcut = 0
) =
    let( cross_axis_start = max( 0, ( cross_axis_span - detent_length ) / 2 ) )
    ( slide_side == LEFT || slide_side == RIGHT ) ?
        [
            [ opening_side_edge_pos, rail_side_clearance + cross_axis_start, z_min ],
            [ opening_side_edge_pos + detent_width, rail_side_clearance + cross_axis_start + detent_length, z_min + detent_height + z_overcut ]
        ] :
        [
            [ rail_side_clearance + cross_axis_start, opening_side_edge_pos, z_min ],
            [ rail_side_clearance + cross_axis_start + detent_length, opening_side_edge_pos + detent_width, z_min + detent_height + z_overcut ]
        ];

function __test_expected_sliding_detent_groove_aabb(
    slide_side,
    rail_side_clearance,
    detent_width,
    detent_height,
    detent_length,
    opening_side_edge_pos,
    cross_axis_span,
    lid_panel_thickness,
    lock_relief = 0
) =
    let(
        cross_axis_start = max( 0, ( cross_axis_span - detent_length ) / 2 ),
        opening_min = opening_side_edge_pos + ( ( slide_side == FRONT || slide_side == LEFT ) ? 0 : -lock_relief ),
        opening_max = opening_side_edge_pos + detent_width + ( ( slide_side == FRONT || slide_side == LEFT ) ? lock_relief : 0 ),
        z_min = lid_panel_thickness - detent_height,
        z_max = lid_panel_thickness + HULL_EPSILON
    )
    ( slide_side == LEFT || slide_side == RIGHT ) ?
        [
            [ opening_min, rail_side_clearance + cross_axis_start, z_min ],
            [ opening_max, rail_side_clearance + cross_axis_start + detent_length, z_max ]
        ] :
        [
            [ rail_side_clearance + cross_axis_start, opening_min, z_min ],
            [ rail_side_clearance + cross_axis_start + detent_length, opening_max, z_max ]
        ];

test_detent_rail_side_clearance = 3.2;
test_detent_width = 0.75;
test_detent_height = 0.5;
test_detent_length = 12;
test_detent_cross_axis_span = 44;
test_detent_lid_panel_thickness = 1.7;
test_detent_near_edge_pos = 0.15;
test_detent_far_edge_pos = 52.1;
test_detent_lock_relief = 0.3;

assert(
    __test_close( __sliding_detent_lock_angle_for_validation( [] ), 45 ),
    "default sliding detent lock angle should be 45 degrees"
);

assert(
    __test_close( __sliding_detent_lock_relief_from_values( 0.8, 0.8, 45 ), 0.8 ),
    "45-degree sliding detent lock angle should make relief match detent height"
);

assert(
    __test_close( __sliding_detent_lock_relief_from_values( 0.8, 0.8, 90 ), 0 ),
    "90-degree sliding detent lock angle should keep a vertical lock face"
);

for ( slide_side = [ FRONT, BACK, LEFT, RIGHT ] )
{
    test_detent_opening_side_edge_pos =
        ( slide_side == FRONT || slide_side == LEFT ) ?
            test_detent_near_edge_pos :
            test_detent_far_edge_pos;

    assert(
        __test_close(
            __sliding_detent_box_aabb_from_values(
                slide_side,
                test_detent_rail_side_clearance,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span
            ),
            __test_expected_sliding_detent_aabb(
                slide_side,
                test_detent_rail_side_clearance,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span
            )
        ),
        str( "box sliding detent AABB mismatch for ", slide_side )
    );

    assert(
        __test_close(
            __sliding_detent_lid_groove_aabb_from_values(
                slide_side,
                0,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span,
                test_detent_lid_panel_thickness
            ),
            __test_expected_sliding_detent_groove_aabb(
                slide_side,
                0,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span,
                test_detent_lid_panel_thickness
            )
        ),
        str( "lid sliding detent groove AABB mismatch for ", slide_side )
    );

    assert(
        __test_close(
            __sliding_detent_lid_groove_aabb_from_values(
                slide_side,
                0,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span,
                test_detent_lid_panel_thickness,
                test_detent_lock_relief
            ),
            __test_expected_sliding_detent_groove_aabb(
                slide_side,
                0,
                test_detent_width,
                test_detent_height,
                test_detent_length,
                test_detent_opening_side_edge_pos,
                test_detent_cross_axis_span,
                test_detent_lid_panel_thickness,
                test_detent_lock_relief
            )
        ),
        str( "lid sliding detent angled groove AABB mismatch for ", slide_side )
    );
}

data = [
    [ G_PRINT_TYPES, [ LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "physical validation box" ],
        [ BOX_SIZE_XYZ, [50, 40, 12] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 0.6 ],
        [ BOX_LID,
            [ LID_PATTERN_THICKNESS, 0.2 ],
            [ LID_FRAME_WIDTH, 0.2 ],
        ],
        [ BOX_FEATURE,
            [ NAME, "too tall and overlapping" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 28, 12] ],
            [ POSITION_XY, [0, 0] ],
        ],
        [ BOX_FEATURE,
            [ NAME, "out of bounds and overlapping" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 28, 8] ],
            [ POSITION_XY, [20, 0] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "cutout invalid percentages" ],
        [ BOX_SIZE_XYZ, [35, 35, 12] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "invalid side cutout params" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 30, 8] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 125 ],
            [ FTR_CUTOUT_DEPTH_PCT, -10 ],
            [ FTR_CUTOUT_WIDTH_PCT, 110 ],
            [ FTR_CUTOUT_DEPTH_MAX, -2 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile side cutout" ],
        [ BOX_SIZE_XYZ, [40, 30, 12] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "fragile front cutout" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [36, 26, 9] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 96 ],
            [ FTR_CUTOUT_DEPTH_PCT, 99 ],
            [ FTR_CUTOUT_WIDTH_PCT, 98 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile rounded side cutout" ],
        [ BOX_SIZE_XYZ, [24, 24, 20] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "narrow rounded-bottom finger cutout" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [14, 18, 18] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 20 ],
            [ FTR_CUTOUT_WIDTH_PCT, 30 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile standard rounded cutout" ],
        [ BOX_SIZE_XYZ, [24, 24, 14] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "shallow rounded side cutout" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 10] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 100 ],
            [ FTR_CUTOUT_DEPTH_PCT, 10 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile bottom cutout" ],
        [ BOX_SIZE_XYZ, [32, 32, 10] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_WALL_THICKNESS, 1.5 ],
        [ BOX_FEATURE,
            [ NAME, "thin floor cutout" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [28, 28, 8.2] ],
            [ FTR_CUTOUT_BOTTOM_B, true ],
            [ FTR_CUTOUT_BOTTOM_PCT, 98 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile corner cutout" ],
        [ BOX_SIZE_XYZ, [30, 30, 10] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "overlapping corner cutouts" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [4, 4, 8] ],
            [ FTR_PADDING_XY, [2, 2] ],
            [ FTR_CUTOUT_CORNERS_4B, [true, true, true, true] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "fragile corner bridge" ],
        [ BOX_SIZE_XYZ, [8, 8, 5] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "tiny paired corner cutouts" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [0.6, 0.6, 2] ],
            [ FTR_PADDING_XY, [0, 0] ],
            [ FTR_CUTOUT_CORNERS_4B, [true, false, true, false] ],
        ],
    ],
    [ OBJECT_DIVIDERS,
        [ NAME, "thin divider" ],
        [ DIV_THICKNESS, 0.2 ],
        [ DIV_FRAME_SIZE_XY, [20, 12] ],
        [ DIV_TAB_TEXT, ["A", "B"] ],
    ],
    [ OBJECT_BOX,
        [ NAME, "render target" ],
        [ BOX_SIZE_XYZ, [20, 20, 8] ],
        [ BOX_LID,
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 6] ],
        ],
    ],
];

detent_thin_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_DETENT_THICKNESS, 0.2 ],
    [ G_DETENT_SPACING, 20 ],
    [ G_DETENT_DIST_FROM_CORNER, 0.1 ],
    [ OBJECT_BOX,
        [ NAME, "thin and too-close sliding detent" ],
        [ BOX_SIZE_XYZ, [20, 18, 8] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

detent_collapsed_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_DETENT_THICKNESS, 0.8 ],
    [ G_DETENT_SPACING, 2 ],
    [ G_DETENT_DIST_FROM_CORNER, 9 ],
    [ OBJECT_BOX,
        [ NAME, "collapsed sliding detent" ],
        [ BOX_SIZE_XYZ, [18, 16, 8] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

detent_chamfer_collision_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_DETENT_THICKNESS, 0.5 ],
    [ G_DETENT_SPACING, 10 ],
    [ G_DETENT_DIST_FROM_CORNER, 0.5 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent clipped by chamfer" ],
        [ BOX_SIZE_XYZ, [24, 20, 8] ],
        [ BOX_WALL_THICKNESS, 2.0 ],
        [ CHAMFER_N, 4 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

detent_cutout_collision_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 2.0 ],
    [ G_DETENT_THICKNESS, 0.5 ],
    [ G_DETENT_SPACING, 6 ],
    [ G_DETENT_DIST_FROM_CORNER, 3 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent cut by exterior opening cutout" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front exterior cutout overlaps detent envelope" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 10, 8] ],
            [ POSITION_XY, [9, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent cutout no cross overlap" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front exterior cutout away from detent cross span" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [14, 10, 8] ],
            [ POSITION_XY, [0, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent cutout no opening-depth overlap" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front exterior cutout behind detent depth span" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 10, 8] ],
            [ POSITION_XY, [9, 8] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent interior opening cutout stays quiet" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front interior cutout overlaps detent envelope only inside" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 10, 8] ],
            [ POSITION_XY, [9, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, INTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
];

detent_cutout_stops_below_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 1.2 ],
    [ G_DETENT_THICKNESS, 0.5 ],
    [ G_DETENT_SPACING, 6 ],
    [ G_DETENT_DIST_FROM_CORNER, 3 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent cutout stops below detent" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front exterior cutout reaches only to rail base" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 10, 8] ],
            [ POSITION_XY, [9, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
];

detent_cutout_disabled_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 2.0 ],
    [ G_DETENT_THICKNESS, 0 ],
    [ G_DETENT_SPACING, 6 ],
    [ G_DETENT_DIST_FROM_CORNER, 3 ],
    [ OBJECT_BOX,
        [ NAME, "disabled sliding detent ignores opening cutout" ],
        [ BOX_SIZE_XYZ, [40, 30, 10] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
        [ BOX_FEATURE,
            [ NAME, "front exterior cutout where disabled detent would be" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 10, 8] ],
            [ POSITION_XY, [9, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, false, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 60 ],
        ],
    ],
];

detent_groove_width_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 4.0 ],
    [ G_TOLERANCE, 0.7 ],
    [ G_DETENT_THICKNESS, 2.0 ],
    [ G_DETENT_SPACING, 4 ],
    [ G_DETENT_DIST_FROM_CORNER, 5 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent groove collapsed width" ],
        [ BOX_SIZE_XYZ, [48, 36, 12] ],
        [ BOX_WALL_THICKNESS, 4.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

detent_groove_height_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 1.0 ],
    [ G_TOLERANCE, 0.49 ],
    [ G_DETENT_THICKNESS, 0.5 ],
    [ G_DETENT_SPACING, 4 ],
    [ G_DETENT_DIST_FROM_CORNER, 4 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent groove collapsed height" ],
        [ BOX_SIZE_XYZ, [36, 30, 10] ],
        [ BOX_WALL_THICKNESS, 2.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

detent_custom_lid_thickness_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 3.0 ],
    [ G_TOLERANCE, 0.2 ],
    [ G_DETENT_THICKNESS, 0.6 ],
    [ G_DETENT_SPACING, 4 ],
    [ G_DETENT_DIST_FROM_CORNER, 5 ],
    [ OBJECT_BOX,
        [ NAME, "sliding detent custom lid thickness stays quiet" ],
        [ BOX_SIZE_XYZ, [48, 36, 12] ],
        [ BOX_WALL_THICKNESS, 2.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

cap_lid_fit_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_TOLERANCE, 0.6 ],
    [ OBJECT_BOX,
        [ NAME, "collapsed cap lid fit" ],
        [ BOX_SIZE_XYZ, [20, 18, 1.4] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_CAP ],
            [ LID_HEIGHT, 0.2 ],
            [ LID_FRAME_WIDTH, 9.5 ],
        ],
    ],
];

inset_lid_fit_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_TOLERANCE, 0.1 ],
    [ OBJECT_BOX,
        [ NAME, "collapsed inset lid fit" ],
        [ BOX_SIZE_XYZ, [3.5, 3.4, 5] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_INSET ],
            [ LID_HEIGHT, 0 ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

sliding_lid_fit_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_LID_THICKNESS, 0.8 ],
    [ G_TOLERANCE, 0.5 ],
    [ G_DETENT_THICKNESS, 0 ],
    [ OBJECT_BOX,
        [ NAME, "collapsed sliding lid fit" ],
        [ BOX_SIZE_XYZ, [3, 3, 4] ],
        [ BOX_WALL_THICKNESS, 1.2 ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

legacy_detent_data = [
    [ G_PRINT_TYPES, DIVIDERS ],
    [ G_DETENT_THICKNESS, 0.1 ],
    [ G_DETENT_SPACING, 9 ],
    [ G_DETENT_DIST_FROM_CORNER, 0.1 ],
    [ G_DETENT_MIN_SPACING, -1 ],
    [ G_TOLERANCE, 0.5 ],
    [ OBJECT_BOX,
        [ NAME, "thin legacy cap detent" ],
        [ BOX_SIZE_XYZ, [14, 12, 8] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_CAP ],
            [ LID_SOLID_B, true ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "collapsed legacy inset detent" ],
        [ BOX_SIZE_XYZ, [30, 30, 8] ],
        [ BOX_WALL_THICKNESS, 1.0 ],
        [ BOX_LID,
            [ LID_TYPE, LID_INSET ],
            [ LID_SOLID_B, true ],
        ],
    ],
];

Make(data);
Make(detent_thin_data);
Make(detent_collapsed_data);
Make(detent_chamfer_collision_data);
Make(detent_cutout_collision_data);
Make(detent_cutout_stops_below_data);
Make(detent_cutout_disabled_data);
Make(detent_groove_width_data);
Make(detent_groove_height_data);
Make(detent_custom_lid_thickness_data);
Make(cap_lid_fit_data);
Make(inset_lid_fit_data);
Make(sliding_lid_fit_data);
Make(legacy_detent_data);
