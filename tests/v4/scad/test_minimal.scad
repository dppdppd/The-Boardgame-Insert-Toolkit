// Test: minimal box with no features and a lid
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ OBJECT_BOX,
        [ NAME, "box 1" ],
        [ BOX_SIZE_XYZ, [100, 100, 50] ],
    ],
];
Make(data);
