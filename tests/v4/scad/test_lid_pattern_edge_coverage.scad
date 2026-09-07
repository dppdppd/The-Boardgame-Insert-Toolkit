// Regression: small 70-degree patterned lid. Its short horizontal grid pitch
// requires cells beyond a fixed two-column extension to complete edge struts.
// A zero extra frame makes the edge coverage visible; dimensions are in mm.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;
Make([
    [ G_PRINT_TYPES, [ LID ] ],
    [ OBJECT_BOX,
        [ NAME, "pattern edge coverage" ],
        [ BOX_SIZE_XYZ, [15, 17, 6] ],
        [ BOX_LID,
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
