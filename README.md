This OpenSCAD library was created to make it easy to create board game inserts with lids for either horizontal or vertical storage, without any programming required.

Create a settings file, in which you specify the box dimensions and any number of compartments, their sizes, what kind of pieces it holds, etc, and the script will do the rest.

The file is built of keyvalue pairs. Here is an example:

    [   "example 0: minimal",
        [
            [ BOX_DIMENSIONS, [46.5, 46.5, 15.0] ],
            [ BOX_COMPONENTS,
                [[   "my chits",
                        [
                            [CMP_NUM_COMPARTMENTS, [4,4]],
                            [CMP_COMPARTMENT_SIZE, [ 10, 10, 13.0] ],
                        ]
                    ]]]]]

The outer keyvalue is [ "box", array_of_keyvalues ]. The array_of_keyvalues is a bunch of stuff we need to define the box. One of those is "components," which contains the different kinds of compartments our box will have.

Result: ![example1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example1.png)



Here is another example:

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



* Published inserts:

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
