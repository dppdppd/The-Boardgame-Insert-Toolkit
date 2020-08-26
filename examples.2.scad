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
    [   "simple box",
        [
            [ BOX_SIZE_XYZ,                                     [45, 45, 15.0] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 42, 42, 13.0] ],
                ]
            ],                            
        ]
    ],

    [   "simple stacking box",
        [
            [ BOX_SIZE_XYZ,                                     [45, 45, 15.0] ],
            [ BOX_STACKABLE_B, t],

            [ BOX_LID,
                [
                    [ LID_SOLID_B, t],
                    [ LID_INSET_B, t],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 42, 42, 13.0] ],
                ]
            ],                            
        ]
    ],

    [   "card tray",
        [
            [ BOX_SIZE_XYZ,                                     [45, 45, 15.0] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 42, 42, 8.0] ],
                    [CMP_CUTOUT_SIDES_4B,                   [t,t,f,f]], // all sides

                ]
            ],                            
        ]
    ],

    [   "card tray 2",
        [
            [ BOX_SIZE_XYZ,                                     [45, 45, 15.0] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 42, 42, 7] ],
                    [CMP_PEDESTAL_BASE_B,            t],     
                ]
            ],                            
        ]
    ],    

    [   "compartment labels",
        [
            [ BOX_SIZE_XYZ,                                     [45, 45, 15.0] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,   [2,2]],
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 10, 10, 8.0] ],

                    [LABEL,               
                        [
                            [LBL_TEXT,        [   
                                                ["backleft", "backright"],
                                                ["frontleft", "frontright"],
                                            ]
                            ],
                            [LBL_PLACEMENT,     LEFT_WALL],
                            [ LBL_SIZE,         AUTO],

                        ]
                    ],                                        
                ]
            ],                            
        ]
    ],

    [   "example 0: minimal",
        [
            [ ENABLED_B,                t],

            [ BOX_SIZE_XYZ,                                     [46.5, 46.5, 15.0] ],
            [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,   [4,4]],
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 10, 10, 13.0] ],
                    [CMP_PADDING_HEIGHT_ADJUST_XY,          [0, -5] ],

                ]
            ],                  
        ]
    ],
    [   "hex tiles",
        [
            [ BOX_SIZE_XYZ,                                     [58, 58, 10.0] ],
            [ BOX_LID,
                [            
                    [ LID_SOLID_B, t],
                ],
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,   [2,2]],
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 25, 25, 5.0] ],
                    [CMP_SHAPE,                             HEX],
                    [CMP_SHAPE_VERTICAL_B,                  t],    
                    [CMP_PADDING_XY,                        [5,5]],

//                    [CMP_CUTOUT_SIDES_4B,                   [t,f,f,f]], // one side
//                    [CMP_CUTOUT_SIDES_4B,                   [t,t,f,f]], // opposite sides  
                    [CMP_CUTOUT_SIDES_4B,                   [t,t,t,t]], // all sides
              

                ]
            ],                  
        ]
    ],    
    [   "hex tiles 2",
        [
            [ BOX_SIZE_XYZ,                                     [52, 55, 10.0] ],
            [ BOX_LID,
                [            
                    [ LID_SOLID_B, t],
                ],
            ],
            [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,               [2,2]],
                    [CMP_COMPARTMENT_SIZE_XYZ,              [ 25, 25, 8.0] ],
                    [CMP_SHAPE,                             HEX2],
                    [CMP_SHAPE_VERTICAL_B,                  t],    
                    [CMP_CUTOUT_CORNERS_4B,                 [t,t,t,t]]
              

                ]
            ],                  
        ]
    ],        
    [   "example 1",
        [
            [ ENABLED_B,                t],
            [ BOX_SIZE_XYZ,             [110.0, 180.0, 22.0] ],

            [ BOX_LID,
                [
                    [ LID_FIT_UNDER_B,      f],
                    [ LID_CUTOUT_SIDES_4B, [f,f,t,t]],
                    [ LID_SOLID_B, t],
                    [ LID_HEIGHT, 15 ],
                    [ LID_INSET_B, f],
                ]
            ],

            [ LABEL,
                [
                    [ LBL_TEXT,     "Skull     and"],
                    [ LBL_SIZE,     AUTO ],
                    [ ROTATION,     45 ],
                    [ POSITION_XY, [ 2,-2]],
                ]
            ],

            [ LABEL,
                [
                    [ LBL_TEXT,     "Crossbones"],
                    [ LBL_SIZE,     AUTO ],
                    [ ROTATION,     315 ],
                    [ POSITION_XY, [ -4,-0]],
                ]
            ],        


            [   BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,              [ 22, 60.0, 20.0] ],
                    [CMP_NUM_COMPARTMENTS_XY,               [2,2] ],
                    [CMP_SHAPE,                             SQUARE],
                    [CMP_SHAPE_ROTATED_B,                   f],
                    [CMP_SHAPE_VERTICAL_B,                  f],
                    [CMP_PADDING_XY,                        [15,12]],
                    [CMP_PADDING_HEIGHT_ADJUST_XY,          [-5, 0] ],
                    [CMP_MARGIN_4B,                         [t,f,f,f]],
                    [CMP_CUTOUT_SIDES_4B,                   [f,f,f,t]],
                    [ROTATION,                              5 ],
                    [POSITION_XY,                           [CENTER,CENTER]],
                    [LABEL,               
                        [
                            [LBL_TEXT,        [   
                                                ["backleft", "backright"],
                                                ["frontleft", "frontright"],
                                            ]
                            ],
                            [LBL_PLACEMENT,     FRONT],
                            [ ROTATION,         10],
                            [ LBL_SIZE,         AUTO],
                            [ POSITION_XY,      [ -4,-2]],
                            [ LBL_FONT,         "Times New Roman:style=bold italic"],

                        ]
                    ],  
                ]
            ],
           [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,       [1,1]],
                    [CMP_COMPARTMENT_SIZE_XYZ,      [ 60.0, 10.0, 5.0] ],
                    [POSITION_XY,                   [CENTER,2]],
                ]
            ],                              

        ]
    ],
    [   "example 2: card tray, shear example",
        [
            [ BOX_SIZE_XYZ,                             [50.0, 50.0, 20.0] ],

            [ BOX_LID,
                [
                    [ LID_SOLID_B,       t],
                ]
            ],

            [ BOX_COMPONENT,
                [
                    [CMP_NUM_COMPARTMENTS_XY,       [2,4]],
                    [CMP_COMPARTMENT_SIZE_XYZ,      [ 20, 5.0, 4.0] ],
                    [CMP_SHEAR,                     [0,45]],
                    [LABEL,               
                        [
                            [LBL_TEXT,        [   
                                                [ "1",  "2" ],
                                                [ "3",  "4" ],
                                                [ "4",  "5" ],
                                                [ "6",  "7" ]
                                            ]
                            ],
                            [LBL_PLACEMENT,   BACK_WALL],
                            [LBL_SIZE,        2],
                            
                        ]
                    ],  
                ]
            ],                              
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
            [ TYPE,                     DIVIDERS ],

            [ DIV_TAB_TEXT,             ["001","002","PASS","004","010101"]],

            [ DIV_TAB_TEXT_SIZE,        6],

            [ DIV_TAB_SIZE_XY,          [30, 12]],
            [ DIV_TAB_CYCLE,            5],

            [ DIV_FRAME_NUM_COLUMNS,    2],
            [ DIV_FRAME_SIZE_XY,        [120, 50]],
            [ DIV_FRAME_COLUMN,         7],


        ]
    ],    

    [   "lid pattern 1",
        [
            [ BOX_SIZE_XYZ,             [50.0, 50.0, 20.0] ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 47, 47, 18.0] ],
                ]
            ],  

             [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS,         10],        

                    [ LID_PATTERN_N1,               3 ],
                    [ LID_PATTERN_N2,               3 ],
                    [ LID_PATTERN_ANGLE,            0 ],
                    [ LID_PATTERN_ROW_OFFSET,       10 ],
                    [ LID_PATTERN_COL_OFFSET,       140 ],
                    [ LID_PATTERN_THICKNESS,        1 ]
                ]
            ]
        ]
    ],   

    [   "lid pattern 2",
        [
            [ BOX_SIZE_XYZ,             [50.0, 50.0, 20.0] ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 47, 47, 18.0] ],
                ]
            ],  

             [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS,         10],        
                    [ LID_PATTERN_N1,               8 ],
                    [ LID_PATTERN_N2,               8 ],
                    [ LID_PATTERN_ANGLE,            22.5 ],
                    [ LID_PATTERN_ROW_OFFSET,       10 ],
                    [ LID_PATTERN_COL_OFFSET,       130 ],
                    [ LID_PATTERN_THICKNESS,        0.6 ]
                ]
            ]
        ]
    ],

    [   "lid pattern 3",
        [
            [ BOX_SIZE_XYZ,             [50.0, 50.0, 20.0] ],
            [ BOX_COMPONENT,
                [
                    [CMP_COMPARTMENT_SIZE_XYZ,  [ 47, 47, 18.0] ],
                ]
            ],  

             [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS,         10],        

                    [ LID_PATTERN_N1,               6 ],
                    [ LID_PATTERN_N2,               3 ],
                    [ LID_PATTERN_ANGLE,            60 ],
                    [ LID_PATTERN_ROW_OFFSET,       10 ],
                    [ LID_PATTERN_COL_OFFSET,       140 ],
                    [ LID_PATTERN_THICKNESS,        0.6 ]
                ]
            ]
        ]
    ],    

   


];


MakeAll();