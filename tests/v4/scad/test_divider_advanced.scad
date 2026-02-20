// Test: Dividers — advanced with custom tabs, frames, cycles, columns
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_DIVIDERS,
        [ NAME, "advanced dividers" ],
        [ DIV_TAB_TEXT, ["001", "002", "PASS", "004", "010101"] ],
        [ DIV_TAB_TEXT_SIZE, 6 ],
        [ DIV_TAB_SIZE_XY, [30, 12] ],
        [ DIV_TAB_CYCLE, 5 ],
        [ DIV_TAB_CYCLE_START, 2 ],
        [ DIV_FRAME_NUM_COLUMNS, 2 ],
        [ DIV_FRAME_SIZE_XY, [120, 50] ],
        [ DIV_FRAME_COLUMN, 7 ],
    ],
];
Make(data);
