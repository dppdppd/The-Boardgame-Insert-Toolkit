// Test: Dividers — basic tab text dividers
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_DIVIDERS,
        [ NAME, "basic dividers" ],
        [ DIV_TAB_TEXT, ["A", "B", "C", "D", "E"] ],
    ],
];
Make(data);
