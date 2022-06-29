include <boardgame_insert_toolkit_lib.2.scad>;
use <RINGM___.ttf>
use <anirm___.ttf>

// determines whether lids are output.
g_b_print_lid = f;

// determines whether boxes are output.
g_b_print_box = t;

g_print_mmu_layer = "default";

//g_print_mmu_layer = "default"; // [ "default" | "mmu_box_layer" | "mmu_label_layer" ]

// Focus on one box
g_isolated_print_box = "Cubes"; 

// Used to visualize how all of the boxes fit together. 
g_b_visualization = false;          
        
// this is the outer wall thickness. 
//Default = 1.5mm
g_wall_thickness = 1.5;

// The tolerance value is extra space put between planes of the lid and box that fit together.
// Increase the tolerance to loosen the fit and decrease it to tighten it.
//
// Note that the tolerance is applied exclusively to the lid.
// So if the lid is too tight or too loose, change this value ( up for looser fit, down for tighter fit ) and 
// you only need to reprint the lid.
// 
// The exception is the stackable box, where the bottom of the box is the lid of the box below,
// in which case the tolerance also affects that box bottom.
//
g_tolerance = 0.15;

// This adjusts the position of the lid detents downward. 
// The larger the value, the bigger the gap between the lid and the box.
g_tolerance_detents_pos = 0.1;

data =
[

    [ "Components",
        [
            [ BOX_SIZE_XYZ,                     [194.0, 66.0, 25.0] ],
            [ ENABLED_B, true],

            // BOOK TOKENS
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [30.5, 30.5, 24]],
                [ CMP_NUM_COMPARTMENTS_XY,      [2, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [0,0]],
            ]],
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [30.5, 30.5, 24]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [0,MAX]],
            ]],

            // Group and leader token
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [30.5, 30.5, 4]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [31.5,MAX]],
            ]],

            // Door tokens
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.5, 20.5, 20]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [63,0]],
            ]],

            // Tracker tokens, lightning
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.5, 20.5, 23.5]],
                [ CMP_NUM_COMPARTMENTS_XY,      [2, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [84,0]],
            ]],

            // Fire tokens, crack token
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.5, 20.5, 16]],
                [ CMP_NUM_COMPARTMENTS_XY,      [2, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [127,0]],
            ]],

            // Wizard hat
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.6, 20.6, 12.5]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [170,0]],
            ]],

            // Magnifying
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.5, 20.5, 10]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,f,f,t]],
                [POSITION_XY,                           [MAX,CENTER]],
            ]],

            // Eyes
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.6, 20.6, 8]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [MAX,MAX]],
            ]],

            // Eyes
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.6, 20.6, 8]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [MAX,MAX]],
            ]],

            // Purple, vortex
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.6, 20.6, 6]],
                [ CMP_NUM_COMPARTMENTS_XY,      [2, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [127.5,MAX]],
            ]],

            // Skull
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [20.6, 20.6, 2]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [f,t,f,f]],
                [POSITION_XY,                           [106,MAX]],
            ]],

            // Cubes
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [41.5, 41.5, 24]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     FILLET],
                [ROTATION, 90],
                [POSITION_XY,                   [63,MAX]],
            ]],

            // Cubes
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [79, 20, 24]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     FILLET],
                [POSITION_XY,                   [90,21.5]],
            ]],
          
            [ BOX_LID, [
                [ LID_PATTERN_RADIUS,         5],        
                [ LID_PATTERN_N1,               8 ],
                [ LID_PATTERN_N2,               8 ],
                [ LID_PATTERN_ANGLE,            22.5 ],
                [ LID_PATTERN_ROW_OFFSET,       10 ],
                [ LID_PATTERN_COL_OFFSET,       130 ],
                [ LID_PATTERN_THICKNESS,        0.6 ],
                [LID_SOLID_B,       f],
                [LABEL,               
                        [
                            [LBL_TEXT,      [   
                                                ["Castle von Loghan"]
                                            ]
                            ],
                            [ LBL_PLACEMENT,     CENTER],
                            [ LBL_SIZE,         AUTO],
                            [ POSITION_XY,      [ 0,0]],
                            
                            [ LBL_DEPTH, 1.8 ]

                        ],
                    ], 
            ],
             
              
        ],
        
    ]
    ],

    [ "BigCards",
        [
            [ BOX_SIZE_XYZ,                     [147.0, 95.0, 53.0] ],
            [ ENABLED_B, true],
            [BOX_NO_LID_B,                  true],

            // BOOK TOKENS
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [144, 92, 50]],
                [CMP_NUM_COMPARTMENTS_XY,       [1, 1] ],
                [CMP_PEDESTAL_BASE_B,           true],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [POSITION_XY,                           [0,0]],
            ]],
          
            [ BOX_LID, [
                [BOX_NO_LID_B,                  true]
                
            ],
             
              
        ],
        
    ]
    ],

    [ "Cubes",
        [
            [ BOX_SIZE_XYZ,                     [194.0, 66.0, 23.0] ],
            [ ENABLED_B, true],

            // Cubes
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [98, 63, 22]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     FILLET],
                [POSITION_XY,                           [0,0]],
            ]],

            // Cards
            [ BOX_COMPONENT, [
                [CMP_COMPARTMENT_SIZE_XYZ,      [92, 64, 18]],
                [ CMP_NUM_COMPARTMENTS_XY,      [1, 1] ],
                [CMP_SHAPE,                     SQUARE],
                [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]],
                [CMP_PEDESTAL_BASE_B,           true],
                [POSITION_XY,                           [MAX,-0.5]],
            ]],
           
          
            [ BOX_LID, [
                [ LID_PATTERN_RADIUS,         5],        
                [ LID_PATTERN_N1,               8 ],
                [ LID_PATTERN_N2,               8 ],
                [ LID_PATTERN_ANGLE,            22.5 ],
                [ LID_PATTERN_ROW_OFFSET,       10 ],
                [ LID_PATTERN_COL_OFFSET,       130 ],
                [ LID_PATTERN_THICKNESS,        0.6 ],
                [LID_SOLID_B,       f],
                [LABEL,               
                        [
                            [LBL_TEXT,      [   
                                                ["Castle von Loghan"]
                                            ]
                            ],
                            [ LBL_PLACEMENT,     CENTER],
                            [ LBL_SIZE,         AUTO],
                            [ POSITION_XY,      [ 0,0]],
                            
                            [ LBL_DEPTH, 1.8 ]

                        ],
                    ], 
            ],
             
              
        ],
        
    ]
    ],

];


MakeAll();