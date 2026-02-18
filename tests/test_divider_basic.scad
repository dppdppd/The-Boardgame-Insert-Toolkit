// Test: Dividers — basic tab text dividers
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_DIVIDERS, [
        [ NAME, "basic dividers" ],
        [ DIV_TAB_TEXT, ["A", "B", "C", "D", "E"] ],
    ]],
];
MakeAll();
