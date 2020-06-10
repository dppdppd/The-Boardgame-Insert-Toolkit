
include <boardgame_insert_toolkit_lib.2.scad>;

// determines whether lids are output.
g_b_print_lid = true;

// determines whether boxes are output.
g_b_print_box = true; 

// Focus on one box
g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together. 
g_b_visualization = false;          
        
// this is the outer wall thickness. 
//Default = 1.5mm
g_wall_thickness = 1.5;

// tolerance for fittings. This is the gap between fitting pieces,
// such as lids and boxes. Increase to loosen the fit and decrease to
// tighten it.
// Default = 0.1mm
g_tolerance = 0.1; 

 
data =
[
    [   "example 1",
        [
            [ BOX_SIZE_XYZ,             [100.0, 50.0, 50.0] ],
            [ ENABLED_B,                t],

            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS,         10],        

                    [ LID_PATTERN_N1,               4 ],
                    [ LID_PATTERN_N2,               4 ],
                    [ LID_PATTERN_ANGLE,            20 ],
                    [ LID_PATTERN_ROW_OFFSET,       10 ],
                    [ LID_PATTERN_COL_OFFSET,       140 ],
                    [ LID_PATTERN_THICKNESS,        1 ],
                    [ LID_LABELS_INVERT_B, t ],
                    [ LID_LABELS_BG_THICKNESS, 2 ],

                ]
            ],            

            [ LABEL,
                [
                    [ LBL_TEXT,     "SHIFT"],
                    [ LBL_SIZE,     AUTO ],
               //     [ ROTATION,     90 ],
                ]
            ],

            [   BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,              [ 47, 47.0, 48.0] ],
                    [CMP_NUM_COMPARTMENTS_XY,               [2,1] ],
                    [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                ]
            ],
        ]
    ],
];


MakeAll();