// Test: Dividers — basic tab text dividers
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "basic dividers",
        [
            [ TYPE, DIVIDERS ],
            [ DIV_TAB_TEXT, ["A", "B", "C", "D", "E"] ],
        ]
    ],
];

MakeAll();
