
include <boardgame_insert_toolkit_lib.2.scad>;

// determines whether lids are output.
g_b_print_lid = true;

// determines whether boxes are output.
g_b_print_box = true; 

// Focus on one box
g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together. 
g_b_visualization = false;          

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = false;            

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
    [   "example 0: minimal",
        [
            [ BOX_DIMENSIONS,                             [46.5, 46.5, 15.0] ],             // outside dimensions of the box
            [ BOX_COMPONENTS,
                [
                    [   "my chits",
                        [
                            [CMP_NUM_COMPARTMENTS,                [4,4]],
                            [CMP_COMPARTMENT_SIZE,                [ 10, 10, 13.0] ],    // size of each compartment in x,y,z
                        ]
                    ],                  
                ]
            ]
        ]
    ],
    [   "example 1",
        [
            [ BOX_DIMENSIONS,                             [110.0, 180.0, 22.0] ],             // outside dimensions of the box
            [ ENABLED,                                    t],
            [ BOX_LID_NOTCHES,                                f],
            [ BOX_LID_HEX_RADIUS,                             8.0],
            [ BOX_LID_FIT_UNDER,                              f],

            [ LABEL,
                [
                    [ LBL_TEXT,   "Example title"],
                    [ LBL_SIZE,   AUTO ],
                    [ ROTATION, 45 ],
                    [ POSITION, [ -4,-2]],
                ]
            ],

            [   BOX_COMPONENTS,
                [
                    [   "my chits",
                        [
                            [CMP_COMPARTMENT_SIZE,                [ 22, 60.0, 20.0] ],    // size of each compartment in x,y,z
                            [CMP_NUM_COMPARTMENTS,                [2,2] ],                // number of compartments [vertically, horizontally]
                            [CMP_SHAPE,                           SQUARE],                // one of several presets: HEX | HEX2 | ROUND | SQUARE | OCT | OCT2
                            [CMP_SHAPE_ROTATED,                f],                     // rotate shape on Z axis
                            [CMP_SHAPE_VERTICAL,                  f],                     // use shape vertically
                            [CMP_PADDING,                         [15,12]],               // Determines space between compartments (and margins) in mm
                            [CMP_PADDING_HEIGHT_ADJUST,           [-5, 0] ],             // Vertical, Horizontal
                            [CMP_MARGIN,                          [t,f,f,f]],             // front,back,left,right
                            [CMP_CUTOUT_SIDES,                    [f,f,f,t]],             // front,back,left,right                                                             
                            [ROTATION,                        5 ],                    // rotate the whole component.
                            [POSITION,                        [CENTER,CENTER]],   // x,y in mm | CENTER | MAX
                            [LABEL,               
                                [
                                    [LBL_TEXT,        [   
                                                        ["backleft", "backright"],        // simple string or array representing each compartment
                                                        ["frontleft", "frontright"],
                                                    ]
                                    ],
                                    [LBL_PLACEMENT,   FRONT],                           // CENTER | FRONT | BACK | LEFT | RIGHT |  FRONT_WALL | BACK_WALL | LEFT_WALL | RIGHT_WALL
                                    [ ROTATION,  10],
                                    [ LBL_SIZE, AUTO],
                                    [ POSITION, [ -4,-2]],
                                    [ LBL_FONT, "Times New Roman:style=bold italic"],

                                ]
                            ],  
                        ]
                    ],                  
                ]
            ]
        ]
    ],
    [   "example 2: card tray, shear example",
        [
            [ BOX_DIMENSIONS,                             [50.0, 50.0, 20.0] ],             // outside dimensions of the box
            [ BOX_COMPONENTS,
                [
                    [   "my chits",
                        [
                            [CMP_NUM_COMPARTMENTS,                [2,4]],
                            [CMP_COMPARTMENT_SIZE,                [ 20, 5.0, 5.0] ],    // size of each compartment in x,y,z
                            [CMP_SHAPE_VERTICAL,                  t],
                            [CMP_SHEAR,                           [0,45]],
                            [LABEL,               
                                [
                                    [LBL_TEXT,        [   
                                                        [ "1",  "2" ],        // simple string or array representing each compartment
                                                        [ "3",  "4" ],
                                                        [ "4",  "5" ],
                                                        [ "6",  "7" ]
                                                    ]
                                    ],
                                    [LBL_PLACEMENT,   BACK_WALL],                           // CENTER | FRONT | BACK | LEFT | RIGHT |  FRONT_WALL | BACK_WALL | LEFT_WALL | RIGHT_WALL
                                    [LBL_SIZE,        2],
                                    
                                ]
                            ],  
                        ]
                    ],                  
                ]
            ]
        ]
    ],
    [ "divider example 1",
        [
            [ TYPE, DIVIDERS ],
            [ DIV_TAB_TEXT,   ["001","002","003"]],
        ]
    ],
    
    [ "divider example 2",
        [
            [ TYPE, DIVIDERS ],

            [ DIV_TAB_TEXT,   ["001","002","PASS","004","010101"]],

            [ DIV_TAB_TEXT_SIZE, 6],

            [ DIV_TAB_WIDTH, 30],
            [ DIV_TAB_HEIGHT, 12],
            [ DIV_TAB_CYCLE, 5],

            [ DIV_FRAME_NUM_COLUMNS, 2],
            [ DIV_FRAME_WIDTH, 120],
            [ DIV_FRAME_HEIGHT, 50],
            [ DIV_FRAME_COLUMN, 7],


        ]
    ],    
];


MakeAll();