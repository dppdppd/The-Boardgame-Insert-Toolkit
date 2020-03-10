
# Why
This OpenSCAD library was designed to allow the quick design and iteration on board game inserts, specifically ones with lids. There are lots of great insert designs out there, but very few for us vertical storers.

# How
- Download the Openscad for your OS. https://www.openscad.org
- Create a new directory for the board game you're working on. This is not required, but good habit. It's best to keep the BIT file with the board game file because future BIT versions may not be backwards compatible and this way you will always have the version that was and be able to recreate the STLs.
- Put the _boardgame_insert_toolkit_library.2.scad_ file in the directory. See above.
- Make a copy of _example.2.scad_. Rename it. This will have the specific details that form your insert.
- The first line should be __include <boardgame_insert_toolkit_lib.2.scad>;__ and the last should be __MakeAll();__ Your design goes inbetween.
- I don't recommend using the Openscad built in editor to edit the scad file. I like emacs and Visual Studio Code.
- Open your new scad file in both your favorite text editor and in Openscad.
- In Openscad, set "Automatic Reload and Preview" _on_ in the Design menu. Now openscad will update the display whenever you save the scad file in the text editor.
- Measure, build, measure again.
- When you're done, in Openscad, _Render_ final geometry, then _Export_ and STL file for your slicer. 
- I also recommend making a little script that will split your STL into separate objects using Slic3r (https://slic3r.org)'s --split feature. This is especially handy when sharing your designs, as it eliminates the tedious manual work and allows you to post individual pieces rather than compound objects.
- If you post it on Thingiverse, make it a _remix_ of BIT (https://www.thingiverse.com/thing:3405465) and I'll get notified and eventually add it to the list of game inserts. 

### Pay attention to your dimensions.
- Note that the box dimensions are _exterior_ dimensions and are such to guarantee that the box you're designing fits inside the game box, as you measured the cavity within.
- Also note that the compartment dimensions are _interior_ dimensions and are such to guarantee that the game pieces will fit inside the compartments.
- This means that you'll want to make sure that those exterior and interior values don't get too close to each other or your box walls will be thin and/or nonexistant.
- If you stick to defaults, then the side walls are 1.5mm thick and the lid is 2mm. So you'll want to leave 3mm in depth and length and 2mm in the height when designing compartments.

## Key Values
The fundamental concept of the insert configuration file is the key-value pair, i.e. [ _key_ , _value_ ]. Often the _value_ is an array of other key-value pairs, so it's important to use tabs to keep track of the alignment. That's where a good text editor comes in handy. See the following example.

    [   "example 0: minimal", // our box
        [
            [ BOX_DIMENSIONS, [46.5, 46.5, 15.0] ],             // one kv pair specifying the x, y, and z of our box exterior.
            [ BOX_COMPONENTS,                                   // this is where our components will go.
                [
                    [   "my chits",                             // our first component.
                        [
                            [CMP_NUM_COMPARTMENTS, [4,4]],
                            [CMP_COMPARTMENT_SIZE, [ 10, 10, 13.0] ],
                        ]
                    ]
                ]
            ]
        ]
    ]

That made this: 
![example1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example1.png)

### Some Explanation
The first key-value pair is [ "example 0: minimal", _one_big_array_of_keyvalues_ ]. The _one_big_array_of_keyvalues_ is all of the details of the box. And we assign it to the key named after our box "example 0: minimal". Those key-values will be properties of the box BOX_, including the key-value pair called BOX_COMPONENTS, which contains all of the various different kinds of game piece component. Each component can have many compartments, albiet they will all be nearly identical are generally used to hold multiples of the same kind of piece. See https://www.thingiverse.com/thing:3435429 for an example of lots of compartments of lots of components in lots of boxes.


Here is an example of some card compartments with holes to get our fingers in to pull them out:


    [   "example 1",
        [
            [ BOX_DIMENSIONS,                             [110.0, 180.0, 22.0] ],             
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
                            [CMP_COMPARTMENT_SIZE,                [ 22, 60.0, 20.0] ],    
                            [CMP_NUM_COMPARTMENTS,                [2,2] ],                
                            [CMP_SHAPE,                           SQUARE],                
                            [CMP_SHAPE_ROTATED,                f],                     
                            [CMP_SHAPE_VERTICAL,                  f],                     
                            [CMP_PADDING,                         [15,12]],               
                            [CMP_PADDING_HEIGHT_ADJUST,           [-5, 0] ],             
                            [CMP_MARGIN,                          [t,f,f,f]],             
                            [CMP_CUTOUT_SIDES,                    [f,f,f,t]],             
                            [ROTATION,                        5 ],                    
                            [POSITION,                        [CENTER,CENTER]],   
                            [LABEL,               
                                [
                                    [LBL_TEXT,        [   
                                                        ["backleft", "backright"],        
                                                        ["frontleft", "frontright"],
                                                    ]
                                    ],
                                    [LBL_PLACEMENT,   FRONT],                           
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

And this is the result:
![example2](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example2.png)


# Keys
The following are the reserved keys and values you can/should use.

    // Box keys
    //
    BOX_DIMENSIONS
    BOX_COMPONENTS
    BOX_VISUALIZATION
    BOX_LID_NOTCHES
    BOX_LID_HEX_RADIUS
    BOX_LID_FIT_UNDER
    BOX_LID
    BOX_THIN_LID

    // Compartment keys
    //
    CMP_NUM_COMPARTMENTS
    CMP_COMPARTMENT_SIZE
    CMP_SHAPE
    CMP_SHAPE_ROTATED
    CMP_SHAPE_VERTICAL
    CMP_PADDING
    CMP_PADDING_HEIGHT_ADJUST
    CMP_MARGIN
    CMP_CUTOUT_SIDES
    CMP_SHEAR

    // Label keys
    //
    LBL_TEXT
    LBL_SIZE
    LBL_PLACEMENT
    LBL_FONT
    LBL_DEPTH

    LABEL

    // Valid values for LBL_PLACEMENT
    FRONT
    BACK
    LEFT
    RIGHT
    FRONT_WALL
    BACK_WALL
    LEFT_WALL
    RIGHT_WALL
    CENTER

    // valid values for CMP_SHAPE
    SQUARE
    HEX
    HEX2
    OCT
    OCT2
    ROUND
    FILLET

    AUTO
    MAX

    ENABLED
    ROTATION
    POSITION




# Published inserts:

- Pandemic: https://www.thingiverse.com/thing:3412724
- Mice and Mystics: https://www.thingiverse.com/thing:3435429
- Indonesia (upgraded goods): https://www.thingiverse.com/thing:3446879
- Indonesia (upgraded goods and ships ): https://www.thingiverse.com/thing:3454636
- Pax Emancipation: https://www.thingiverse.com/thing:3450282
- Bios: Genesis: https://www.thingiverse.com/thing:3452368
- Greenland/Neanderthal: https://www.thingiverse.com/thing:3469793
- Pax Porfiriana (Collector's Edition): https://www.thingiverse.com/thing:3478944
- Pax Renaissance: https://www.thingiverse.com/thing:3479114
- High Frontier (3rd): https://www.thingiverse.com/thing:3482341
- Bios: Megafauna: https://www.thingiverse.com/thing:3493660
- 1830: https://www.thingiverse.com/thing:3499314
- Sword & Sorcery: https://www.thingiverse.com/thing:3515523
- Mansions of Madness 2nd edition persons container: https://www.thingiverse.com/thing:3527361
- Stuffed Fables: https://www.thingiverse.com/thing:3535505
- Star Trek: Frontiers: https://www.thingiverse.com/thing:3538652
