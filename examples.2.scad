
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
            [ "box_dimensions",                             [46.5, 46.5, 15.0] ],             // outside dimensions of the box
            [ "components",
                [
                    [   "my chits",
                        [
                            ["num_compartments",                [4,4]],
                            ["compartment_size",                [ 10, 10, 13.0] ],    // size of each compartment in x,y,z
                        ]
                    ],                  
                ]
            ]
        ]
    ],    
    [   "example 1",
        [
            [ "box_dimensions",                             [110.0, 180.0, 22.0] ],             // outside dimensions of the box
            [ "enabled",                                    t],
            [ "lid_notches",                                f],
            [ "lid_hex_radius",                             8.0],
            [ "fit_lid_under",                              f],

            [ "label",
                [
                    [ "text",   "Example title"],
                    [ "width",   "auto" ],
                    [ "rotation", 45 ],
                    [ "offset", [ -4,-2]],
                ]
            ],

            [   "components",
                [
                    [   "my chits",
                        [
                            ["compartment_size",                [ 22, 60.0, 20.0] ],    // size of each compartment in x,y,z
                            ["num_compartments",                [2,2] ],                // number of compartments [vertically, horizontally]
                            ["shape",                           "square"],                // one of several presets: "hex" | "hex2" | "round" | "square" | "oct" | "oct2"
                            ["shape_rotated_90",                f],                     // rotate shape on Z axis
                            ["shape_vertical",                  f],                     // use shape vertically
                            ["padding",                         [15,12]],               // Determines space between compartments (and margins) in mm
                            ["padding_height_adjust",           [-5, 0] ],             // Vertical, Horizontal
                            ["margin",                          [t,f,f,f]],             // front,back,left,right
                            ["cutout_sides",                    [f,f,f,t]],             // front,back,left,right                                                             
                            ["rotation",                        5 ],                    // rotate the whole component.
                            ["position",                        ["center","center"]],   // x,y in mm | "center" | "max"
                            ["label",               
                                [
                                    ["text",        [   
                                                        ["backleft", "backright"],        // simple string or array representing each compartment
                                                        ["frontleft", "frontright"],
                                                    ]
                                    ],
                                    ["placement",   "front"],                           // "center" | "front" | "back" | "left" | "right" |  "front-wall" | "back-wall" | "left-wall" | "right-wall"
                                    [ "rotation",  10],
                                    [ "font_size", "auto"],
                                    [ "offset", [ -4,-2]],
                                    [ "font", "Times New Roman:style=bold italic"],

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
            [ "box_dimensions",                             [50.0, 50.0, 20.0] ],             // outside dimensions of the box
            [ "components",
                [
                    [   "my chits",
                        [
                            ["num_compartments",                [2,4]],
                            ["compartment_size",                [ 20, 5.0, 5.0] ],    // size of each compartment in x,y,z
                            ["shape_vertical",                  t],
                            ["shear",                           [0,45]],
                            ["label",               
                                [
                                    ["text",        [   
                                                        [ "1",  "2" ],        // simple string or array representing each compartment
                                                        [ "3",  "4" ],
                                                        [ "4",  "5" ],
                                                        [ "6",  "7" ]
                                                    ]
                                    ],
                                    ["placement",   "back-wall"],                           // "center" | "front" | "back" | "left" | "right" |  "front-wall" | "back-wall" | "left-wall" | "right-wall"
                                    ["font_size",        2],
                                    
                                ]
                            ],  
                        ]
                    ],                  
                ]
            ]
        ]
    ],
];


MakeAll();