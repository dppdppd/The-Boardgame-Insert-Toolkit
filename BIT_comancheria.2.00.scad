
include <boardgame_insert_toolkit_lib.2.00.scad>;

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


sha = ["padding_height_adjust",           [-10, -10]];


// 285 x 285 x 50
data =
[
    [   "cards",
        [
            ["box_dimensions", [225, 200, 20] ],                       // float f -- default:[ 100, 100, 100 ]

            
            [   "components",
                [
                    [   "cards",
                        [
                            ["compartment_size",                [ 67, 93, 16] ],      // [float, float, float]
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["num_compartments",                [3, 2] ],                   // [int, int]
                            ["padding",                          [5, 4 ]],                     // [float,float]
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
            ["box_dimensions", [203, 98, 20] ],                       // float f -- default:[ 100, 100, 100 ]

            
            [   "components",
                [
                    [   "gray_settl",
                        [
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 25, 20] ],      // [float, float, float]
                            ["padding",                         [1, 1 ]],                     // [float,float]
                            sha,                      // Vertical, Horizontal
                            ["position",                        [0, 0 ] ],                // [float, float, float]                          
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                        ]
                    ],                      
                    [   "blue_green_settl",
                        [
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 17, 20] ],      // [float, float, float]
                            ["num_compartments",                [1,2]],
                            ["padding",                         [1, 6 ]],                     // [float,float]
                            sha,
                            ["position",                        [0, 25 ] ],                // [float, float, float]                          
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,0,0,0]],                                                             
                        ]
                    ],
                    [   "yellow_settl",
                        [
                            ["shape",                           "hex"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20, 10, 20] ],      // [float, float, float]
                            ["padding",                         [1, 4 ]],                     // [float,float]
                            sha,
                            ["position",                        [0, "max" ] ],                // [float, float, float]                          
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "sttlmnts"],
                                    ["placement",   "below"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,-4]]

                                ]
                            ],                        ]
                    ],
         


                    [   "gray_war",
                        [
                            ["compartment_size",                [ 17, 6+2, 18] ],      // [float, float, float]
                            ["padding",                         [1, 1 ]],                     // [float,float]
                            sha,
                            ["position",                        [21, 0 ] ],                // [float, float, float]                          
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "war"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,2]]
                                ]
                            ],                         
                        ]
                    ],    
                    [   "blue_green_war",
                        [
                            ["compartment_size",                [ 17, 15+2, 18] ],      // [float, float, float]
                            ["num_compartments",                [1,2]],
                            ["padding",                         [1, 8 ]],                     // [float,float]
                            sha,
                            ["position",                        [21, 8 ] ],                // [float, float, float]                          
                            ["margin",                          [1,0,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,0,0,0]],                                                             
                        ]
                    ],  
                    [   "yello_war",
                        [
                            ["compartment_size",                [ 17, 23+2, 18] ],      // [float, float, float]
                            ["padding",                         [1, 6 ]],                     // [float,float]
                            sha,
                            ["position",                        [21, 58 ] ],                // [float, float, float]                          
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                        ]
                    ], 

                    [   "3-4",
                        [
                            ["compartment_size",                [ 17, 6+2, 18] ],
                            sha,    
                            ["padding",                         [1, 1 ]],                     // [float,float]
                            ["position",                        [39, 0 ] ],                // [float, float, float]
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "bands"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,2.5]]
                                ]
                            ],
                        ]
                    ],                   
                    [   "2-5",
                        [
                            ["compartment_size",                [ 17, 9+2, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 6 ]],                     // [float,float]
                            ["position",                        [39, 9 ] ],                // [float, float, float]
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,0,0,0]],                                                             
                        ]
                    ],                     
                    [   "1-6",
                        [
                            ["compartment_size",                [ 17, 15+2, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",       [1,6 ]],                     // [float,float]
                            ["position",                        [39, 28 ] ],                // [float, float, float]                         
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,0,0,0]],                                                             
                        ]
                    ],  
                    [   "medicine",
                        [
                            ["compartment_size",                [ 17, 32+2, 18] ],      // [float, float, float]
                            sha,
                            ["padding",                         [1, 4 ]],                     // [float,float]
                            ["position",                        [39, 53 ] ],                // [float, float, float]                           
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "medicine"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  90],
                                    ["font_size",   3 ],
                                    ["offset", [-2,0]]
                                ]
                            ],
                        ]
                    ],                         



                    [   "?",
                        [
                            ["compartment_size",                [ 17, 43, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 0 ]],                     // [float,float]
                            ["position",                        [56, 0 ] ],                // [float, float, float]                                                     
                            ["margin",                          [1,1,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "success"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  90],
                                    ["font_size",   3 ],
                                    ["offset", [0,0]]
                                ]
                            ],
                        ]
                    ],  
                    [   "ai",
                        [
                            ["compartment_size",                [ 17, 51, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [0, 1 ]],                     // [float,float]
                            ["position",                        [56, 43 ] ],                // [float, float, float]                                                         
                            ["margin",                          [1,0,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "instructions"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  90],
                                    ["font_size",   3 ],
                                    ["offset", [0,0]]
                                ]
                            ],
                        ]
                    ],  



                    [   "enemy",
                        [
                            ["compartment_size",                [ 17, 20, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 27 ]],                     // [float,float]
                            ["position",                        [73, 0 ] ],                // [float, float, float]                           
                            ["margin",                          [1,0,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["label",               
                                [
                                    ["text",        "enemy"],
                                    ["placement",   "below"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,2]]
                                ]
                            ],
                        ]
                    ],
                    [   "markers",
                        [
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 18, 13, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["position",                        [73, 47 ] ],                // [float, float, float]                                                          
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["label",               
                                [
                                    ["text",        "markers"],
                                    ["placement",   "below"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,-1]]
                                ]
                            ],
                        ]
                    ],     
                    [   "ravaged",
                        [
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 18, 19+3, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 6 ]],                     // [float,float]
                            ["position",                        [73, 67 ] ],                // [float, float, float]
                            ["margin",                          [1,0,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "ravaged"],
                                    ["placement",   "below"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,-1]]
                                ]
                            ],
                        ]
                    ],    

                    [   "2nd set of ?",
                        [
                            ["compartment_size",                [ 17, 43, 18] ],      // [float, float, float]
                            sha,    
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["position",                        [93, "max" ] ],                // [float, float, float]                                                     
                            ["margin",                          [1,0,0,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [0,1,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "success"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  90],
                                    ["font_size",   3 ],
                                    ["offset", [0,0]]
                                ]
                            ],
                        ]
                    ],
    

                    [   "bison",
                        [
                            ["compartment_size",                [ 17, 37, 18] ],      // [float, float, float]
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            sha,    
                            ["position",                        [91, 0 ] ],                // [float, float, float]                           
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "bison"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  90],
                                    ["font_size",   3 ],
                                    ["offset", [0,0]]
                                ]
                            ],
                        ]
                    ],  
                    [   "horses",
                        [
                            ["compartment_size",                [ 17, 37, 18] ],      // [float, float, float]
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            sha,    
                            ["position",                        [75+17*2, 0 ] ],                // [float, float, float]                           
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",   "horses"],
                                    ["rotation",  90],
                                    ["font_size",   3 ]
                                ]
                            ],                               
                        ]
                    ],
                    [   "trade goods",
                        [
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["position",                        [75+17*3+1, 0 ] ],                // [float, float, float]                            
                            sha,    
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["label",               
                                [
                                    ["text",        "tr. goods"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,1]]
                                ]
                            ],
                        ]
                    ], 
                    [   "captives",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            sha,    
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["position",                        [75+17*4+2, 0 ] ],                // [float, float, float]                                                           
                            ["label",               
                                [
                                    ["text",        "captives"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,1]]
                                ]
                            ],
                        ]
                    ],    
                    [   "food",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            sha,    
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["position",                        [75+17*5+3, 0 ] ],                // [float, float, float]                                                         
                            ["label",               
                                [
                                    ["text",        "food"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,1]]
                                ]
                            ],
                        ]
                    ], 
                    [   "guns",
                        [
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 17, 10+2, 18] ],      // [float, float, float]
                            sha,    
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["padding",                         [1, 5 ]],                     // [float,float]
                            ["cutout_sides",                    [1,0,0,0]],                                                             
                            ["position",                        [75+17*6+4, 0 ] ],                // [float, float, float]                                                          
                            ["label",               
                                [
                                    ["text",        "guns"],
                                    ["placement",   "above"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   3 ],
                                    ["offset", [0,1]]
                                ]
                            ],
                        ]
                    ],    
                    [   "tray",
                        [
                            ["compartment_size",                [ 106, 48, 10] ],      // [float, float, float]
                            ["padding",                         [0, 0 ]],                     // [float,float]
                            ["position",                        ["max", "max" ] ],                // [float, float, float]       
                            sha,                                             
                        ]
                    ],
                    [   "cards",
                        [
                            ["enabled",                         1],
                            ["compartment_size",                [ 106, 5, 15] ],      // [float, float, float]
                            ["padding",       [0, 0 ]],                     // [float,float]
                            ["position",                        ["max", "max" ] ],                // [float, float, float]                                                      
                        ]
                    ],                       
                    [   "dice",
                        [
                            ["compartment_size",                [ 50, 17, 18] ],      // [float, float, float]
                            sha,    
                            ["margin",                          [1,1,1,1]],                     // BOTTOM,TOP,LEFT,RIGHT
                            ["padding",                         [11, 5 ]],                     // [float,float]
                            ["position",                        [128, 22 ] ],                // [float, float, float]  
                            ["label",               
                                [
                                    ["text",        "dice"],
                                    ["placement",   "center"],          // center | below | above | left | right
                                    ["rotation",  0],
                                    ["font_size",   4 ],
                                    ["offset", [0,0]]
                                ]
                            ],
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
