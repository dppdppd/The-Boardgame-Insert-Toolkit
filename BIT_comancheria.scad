
include <boardgame_insert_toolkit_lib.scad>;

// determines whether lids are output.
g_b_print_lid = 0;

// determines whether boxes are output.
g_b_print_box = 1; 

// Focus on one box
g_isolated_print_box = "chits_in_play"; 

// Used to visualize how all of the boxes fit together. 
// Turn off for printing.
g_b_visualization = 0;          

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = 0;            


// creates the indentation on the bottom of the box 
//that allows the lid to be put under when in play.
g_b_fit_lid_underneath = 1; 

// this is the outer wall thickness. 
//Default = 1.5
g_wall_thickness = 1.5;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1.0;

// this is the lid thickness.
// Default = g_wall_thickness
g_lid_thickness = 1.5;

// the depth of the lid
g_lid_lip_height = 6.0; // default = 5.0

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 13; 


// 285 x 285 x 50
data =
[
    [   "cards",
        [
            [ "box_dimensions", [225, 200, 20] ],                       // float f -- default:[ 100, 100, 100 ]

            
            [   "components",
                [
                    [   "cards",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 67, 93, 16] ],      // [float, float, float]
                            ["num_compartments",                [3, 2] ],                   // [int, int]
                            ["partition_size_adjustment",       [5, -4 ]],                     // [float,float]
                            ["position",                        ["center", "center" ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],
                ]
            ]
        ]
    ],

   [   "chits_in_play",
        [
            [ "box_dimensions", [203, 104, 20] ],                       // float f -- default:[ 100, 100, 100 ]

            
            [   "components",
                [
                    [   "gray_settl",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 33, 20] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [0, -5 ] ],                // [float, float, float]                          
                        ]
                    ],                      
                    [   "yellow_settl",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 10, 20] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [0, 43 ] ],                // [float, float, float]                           
                        ]
                    ],
                    [   "blue_settl",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 17, 20] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [0, 58 ] ],                // [float, float, float]
                        ]
                    ],         
                    [   "green_settl",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 17, 20] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [0, 80 ] ],                // [float, float, float]
                        ]
                    ], 



                    [   "gray_war",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 6+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [21, -5 ] ],                // [float, float, float]
                        ]
                    ],    
                    [   "blue_war",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 15+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [21, 14 ] ],                // [float, float, float]                         
                            ["label",               
                                [
                                    [ "text",   "WAR"],
                                    [ "rotation",  90],
                                    [ "size",   4 ]
                                ]
                            ]
                        ]
                    ],  
                    [   "green_war",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 15+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [21, 39 ] ],                // [float, float, float]                                                   
                            ["label",               
                                [
                                    [ "text",   "WAR"],
                                    [ "rotation",  90],
                                    [ "size",   4 ]
                                ]
                            ],  
                        ]
                    ],  
                    [   "yello_war",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 23+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [21, 64 ] ],                // [float, float, float]                          
                            ["label",               
                                [
                                    [ "text",   "WAR"],
                                    [ "rotation",  90],
                                    [ "size",   4 ]
                                ]
                            ],                              
                        ]
                    ], 


                    [   "3-4",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 6+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [39, -5 ] ],                // [float, float, float]
                        ]
                    ],                   
                    [   "2-5",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 9+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [39, 13 ] ],                // [float, float, float]
                        ]
                    ],                     
                    [   "1-6",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 15+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [39, 34 ] ],                // [float, float, float]                         
                            ["label",               
                                [
                                    [ "text",   "BANDS"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                              
                        ]
                    ],      
                    [   "ravaged",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 18, 19+3, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -5 ]],                     // [float,float]
                            ["position",                        [75, 67 ] ],                // [float, float, float]
                        ]
                    ],    



                    [   "?",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 43, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [57, -2 ] ],                // [float, float, float]                          
                            ["label",               
                                [
                                    [ "text",   "?"],
                                    [ "rotation",  90],
                                    [ "size",   4 ]
                                ]
                            ],                            
                        ]
                    ],  
                    [   "ai",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 51, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [57, 46 ] ],                // [float, float, float]                            
                            ["label",               
                                [
                                    [ "text",   "INSTRUCTIONS"],
                                    [ "rotation",  90],
                                    [ "size",   4 ]
                                ]
                            ],                               
                        ]
                    ],  



                    [   "enemy",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 20, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [75, -2 ] ],                // [float, float, float]                           
                            ["label",               
                                [
                                    [ "text",   "ENEMY"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],
                    [   "markers",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 18, 13, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [75, 47 ] ],                // [float, float, float]                            
                            ["label",               
                                [
                                    [ "text",   ""],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],     

                    [   "medicine",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 32, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [39, 64 ] ],                // [float, float, float]                           
                            ["label",               
                                [
                                    [ "text",   "MEDICINE"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],     
                    [   "out of play successes",
                        [
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 50, 8] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -8 ]],                     // [float,float]
                            ["position",                        [94, 47 ] ],                // [float, float, float]
                            ["rotation",                        180],                           
                            ["label",               
                                [
                                    [ "text",   "SUCCESS"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],   



                    [   "bison",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 37, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -7 ]],                     // [float,float]
                            ["position",                        [75+18, -3 ] ],                // [float, float, float]                           
                            ["label",               
                                [
                                    [ "text",   "RESOURCE"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],  
                    [   "horses",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 37, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -7 ]],                     // [float,float]
                            ["position",                        [75+18*2, -3 ] ],                // [float, float, float                            
                            ["label",               
                                [
                                    [ "text",   "RESOURCE"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],
                    [   "trade goods",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -4 ]],                     // [float,float]
                            ["position",                        [75+18*3, -6 ] ],                // [float, float, float]                            
                            ["label",               
                                [
                                    [ "text",   "RES"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ], 
                    [   "captives",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -4 ]],                     // [float,float]
                            ["position",                        [75+18*4, -6 ] ],                // [float, float, float]                            
                            ["label",               
                                [
                                    [ "text",   "RES"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],    
                    [   "food",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -4 ]],                     // [float,float]
                            ["position",                        [75+18*5, -6 ] ],                // [float, float, float]                           
                            ["label",               
                                [
                                    [ "text",   "RES"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ], 
                    [   "guns",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, -4 ]],                     // [float,float]
                            ["position",                        [75+18*6, -6 ] ],                // [float, float, float]                          
                            ["label",               
                                [
                                    [ "text",   "RES"],
                                    [ "rotation",  90],
                                    [ "size",   3 ]
                                ]
                            ],                               
                        ]
                    ],    
                    [   "tray",
                        [
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 106, 50, 5] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["position",                        ["max", 47 ] ],                // [float, float, float]       
                                             
                        ]
                    ],
                    [   "cards",
                        [
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 106, 5, 15] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["position",                        ["max", "max" ] ],                // [float, float, float]                                                      
                        ]
                    ],                       
                    [   "dice",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 50, 17, 18] ],      // [float, float, float]
                            ["partition_size_adjustment",       [-3, 0 ]],                     // [float,float]
                            ["position",                        [129, 27 ] ],                // [float, float, float]  
                            ["rotation",                        90],                                                  
                        ]
                    ], 


                ]
            ]
        ]        
    ]

 
    
];
// ? 42
// Instr 50

// enemy 18
// rnd markers 11
// rancherias 9
// medicine 29

// guns 8
// horses 30
// goods 10
// food 10
// captives 10
// bison 34

MakeAll();
