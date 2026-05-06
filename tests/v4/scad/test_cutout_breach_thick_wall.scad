// Regression: finger cutout must breach the outer wall when BOX_WALL_THICKNESS
// is set per-box (overriding the global default $g_wall_thickness=2.0).
//
// Bug history: MakeSideCutouts used $g_wall_thickness for the margin-side
// slot, so a wall of e.g. 3mm left a sliver of material at the outer surface
// — the "finger cutout" was sealed on the outside.
//
// In a passing build, EVERY box below shows an unobstructed slot through the
// front wall to the compartment cavity (visible as a clear opening from the
// front view, and as a slot poking past the box outline in the top view).
// If the bug regresses, the wall in the front view will appear continuous /
// the slot will not poke past the box outline in the top view.

include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    // Box 1 — round vertical compartment, EXTERIOR cutout (the user's
    // Mini-Chips case). Wall 3mm. Pre-fix: 0.5mm sliver at outer surface.
    [ OBJECT_BOX,
        [ NAME, "round-vert-w3" ],
        [ BOX_SIZE_XYZ, [32, 32, 30] ],
        [ BOX_WALL_THICKNESS, 3 ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [26, 26, 26] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ FTR_CUTOUT_SIDES_4B, [t, f, f, f] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_DEPTH_PCT, 50 ],
            [ FTR_PADDING_XY, [2, 2] ],
        ],
    ],

    // Box 2 — extra-thick wall (5mm). Stresses the m_wall_thickness path.
    [ OBJECT_BOX,
        [ NAME, "thick-w5" ],
        [ BOX_SIZE_XYZ, [40, 40, 20] ],
        [ BOX_WALL_THICKNESS, 5 ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [28, 28, 16] ],
            [ FTR_CUTOUT_SIDES_4B, [t, f, f, f] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
        ],
    ],

    // Box 3 — default wall (2.0mm). Common case must still breach (no
    // regression on the path that already worked).
    [ OBJECT_BOX,
        [ NAME, "default-w" ],
        [ BOX_SIZE_XYZ, [40, 40, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [36, 36, 16] ],
            [ FTR_CUTOUT_SIDES_4B, [t, f, f, f] ],
        ],
    ],
];

Make(data);
