// Shared measured label fixture. A small lid and one letter keep CGAL work bounded.
// The 3 mm horizontal offset and asymmetric F used by the Python gate reveal
// mirrored or misplaced inserts; O in rendered fixtures reveals loose counters.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;
label_kind = "cap";
label_side = "front";
label_solid = false;
label_inverted = true;
label_background = 2;
label_global_depth = 0.5;
label_depth = -1; // Negative means omit the per-label override, testing inheritance.
label_groups = "body";
label_visual = false;
label_text = "O";
label_exploded = false;

label_data = [
    [G_PRINT_TYPES, [LID]],
    [G_VISUALIZATION_B, label_visual],
    [OBJECT_BOX,
        [NAME, "measured lid label"],
        [BOX_SIZE_XYZ, [30, 24, 10]],
        [BOX_WALL_THICKNESS, 2],
        [CHAMFER_N, 0],
        [BOX_LID,
            [PRINT_GROUP, "body"],
            [LID_TYPE, label_kind == "slide" ? LID_SLIDING : label_kind == "inset" ? LID_INSET : LID_CAP],
            [LID_SLIDE_SIDE, label_side == "back" ? BACK : label_side == "left" ? LEFT : label_side == "right" ? RIGHT : FRONT],
            [LID_SOLID_B, label_solid],
            [LID_LABELS_INVERT_B, label_inverted],
            [LID_LABELS_BG_THICKNESS, label_background],
            [LID_SOLID_LABELS_DEPTH, label_global_depth],
            [LID_PATTERN_RADIUS, 4],
            [LABEL,
                [PRINT_GROUP, "text"],
                [LBL_TEXT, label_text],
                [LBL_SIZE, 5],
                [LBL_FONT, "Liberation Sans"],
                [POSITION_XY, [3, 1]],
                if (label_depth >= 0) [LBL_DEPTH, label_depth],
            ],
        ],
    ],
];

Make(label_data, print_groups = label_groups);
if (label_exploded) {
    // Show independently exported host and glyph beside the selected composite.
    translate([36, 0, 0]) Make(label_data, print_groups = "body");
    translate([72, 0, 0]) Make(label_data, print_groups = "text");
}
