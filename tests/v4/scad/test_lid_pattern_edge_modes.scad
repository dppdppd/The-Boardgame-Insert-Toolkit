// Regression: pattern edge coverage on small inset and sliding lids.
// These tiny inset/sliding lids expose the 70-degree pattern at the perimeter.
// Box height is 14mm to leave ordinary lid/rail clearance; fit-under is unused.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;
// Render both by default; CLI selection can isolate either clipping path.
// Example: -D 'pattern_edge_mode="inset"' (also "sliding" or "all").
pattern_edge_mode = "all";
assert(pattern_edge_mode == "all" || pattern_edge_mode == LID_INSET || pattern_edge_mode == LID_SLIDING,
       "pattern_edge_mode must be all, inset, or sliding");
Make([
    [ G_PRINT_TYPES, [ LID ] ],
    for (lid_type = [LID_INSET, LID_SLIDING])
    if (pattern_edge_mode == "all" || pattern_edge_mode == lid_type)
    [ OBJECT_BOX,
        [ NAME, str("pattern edge ", lid_type) ],
        [ BOX_SIZE_XYZ, [15, 17, 14] ],
        [ BOX_LID,
            [ LID_TYPE, lid_type ],
            [ LID_FIT_UNDER_B, false ],
            [ LID_FRAME_WIDTH, 0 ],
            [ LID_PATTERN_RADIUS, 4 ],
            [ LID_PATTERN_THICKNESS, 0.5 ],
            [ LID_PATTERN_ANGLE, 70 ],
            [ LID_PATTERN_ROW_OFFSET, 50 ],
            [ LID_PATTERN_COL_OFFSET, 100 ],
        ],
    ],
]);
