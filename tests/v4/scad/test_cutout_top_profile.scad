// Regression: partial-height finger cutouts should have one clean top profile.
//
// The rounded-bottom side cutout uses a vertical profile extruded into the wall.
// A passing build shows one continuous rectangular top footprint per side with
// a rounded lower edge in side views. A regression shows split/pill-like lobes
// or a depth tied to the cutout width.

include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "front-back partial finger" ],
        [ BOX_SIZE_XYZ, [50, 50, 28] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 14] ],
            [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 35 ],
            [ FTR_CUTOUT_DEPTH_PCT, 20 ],
            [ FTR_CUTOUT_WIDTH_PCT, 70 ],
        ],
    ],

    [ OBJECT_BOX,
        [ NAME, "left-right partial finger" ],
        [ BOX_SIZE_XYZ, [50, 50, 28] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 14] ],
            [ FTR_CUTOUT_SIDES_4B, [f, f, t, t] ],
            [ FTR_CUTOUT_HEIGHT_PCT, 35 ],
            [ FTR_CUTOUT_DEPTH_PCT, 20 ],
            [ FTR_CUTOUT_WIDTH_PCT, 70 ],
        ],
    ],
];

Make(data);
