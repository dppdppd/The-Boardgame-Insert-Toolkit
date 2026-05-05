// Test: Sliding lid rail clearance cutaway
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

wall = 4;
box_xyz = [70, 52, 24];
interior_xyz = [box_xyz[k_x] - 2*wall, box_xyz[k_y] - 2*wall, box_xyz[k_z] - wall];
tolerance = 0.1;

lid_thickness = wall;
sliding_lid_bevel = max(HULL_EPSILON, min(lid_thickness / 2, wall / 2));
sliding_lid_groove_depth = sliding_lid_bevel;
sliding_lid_rail_width = max(HULL_EPSILON, wall - sliding_lid_groove_depth);
sliding_lid_fit_tolerance = max(0, tolerance);
sliding_lid_rail_side_clearance = sliding_lid_rail_width + 2*sliding_lid_fit_tolerance;
sliding_lid_panel_thickness = max(HULL_EPSILON, lid_thickness - 2*sliding_lid_fit_tolerance);
lid_lift = sliding_lid_fit_tolerance;
cutaway_height = box_xyz[k_z] + lid_lift + sliding_lid_panel_thickness + 2*HULL_EPSILON;
section_depth = 1;
section_y = box_xyz[k_y] / 2 - section_depth / 2;

box_object = [
    OBJECT_BOX,
    [ NAME, "sliding rail clearance" ],
    [ BOX_SIZE_XYZ, box_xyz ],
    [ BOX_WALL_THICKNESS, wall ],
    [ BOX_LID,
        [ LID_TYPE, LID_SLIDING ],
        [ LID_SLIDE_SIDE, FRONT ],
        [ LID_SOLID_B, true ],
    ],
    [ BOX_FEATURE,
        [ FTR_COMPARTMENT_SIZE_XYZ, interior_xyz ],
    ],
];

box_data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ G_TOLERANCE, tolerance ],
    box_object,
];

lid_data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, false ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ G_TOLERANCE, tolerance ],
    box_object,
];

module ClosedSlidingLid()
{
    Make(box_data);

    translate([
        sliding_lid_rail_side_clearance,
        -box_xyz[k_y] - DISTANCE_BETWEEN_PARTS,
        box_xyz[k_z] + lid_lift
    ])
        Make(lid_data);
}

intersection()
{
    ClosedSlidingLid();

    // Full-width front section through the rail channel. Keeping only a thin
    // depth slice removes the back plane and avoids projection overlap.
    translate([-HULL_EPSILON, section_y, -HULL_EPSILON])
        cube([
            box_xyz[k_x] + 2*HULL_EPSILON,
            section_depth,
            cutaway_height
        ]);
}
