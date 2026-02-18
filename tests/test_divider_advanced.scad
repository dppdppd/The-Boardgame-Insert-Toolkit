// Test: Dividers — advanced with custom tabs, frames, cycles, columns
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_DIVIDERS, [
        [ NAME, "advanced dividers" ],
        [ DIV_TAB_TEXT, ["001", "002", "PASS", "004", "010101"] ],
        [ DIV_TAB_TEXT_SIZE, 6 ],
        [ DIV_TAB_SIZE_XY, [30, 12] ],
        [ DIV_TAB_CYCLE, 5 ],
        [ DIV_TAB_CYCLE_START, 2 ],
        [ DIV_FRAME_NUM_COLUMNS, 2 ],
        [ DIV_FRAME_SIZE_XY, [120, 50] ],
        [ DIV_FRAME_COLUMN, 7 ],
    ]],
];
MakeAll();
