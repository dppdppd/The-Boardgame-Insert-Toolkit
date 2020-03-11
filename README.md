
# Why
This OpenSCAD library was designed to for quick design and iteration on board game inserts--specifically ones with lids. There are lots of great printable inserts out there, but very few for us vertical storers.

# How
- Download [Openscad](https://www.openscad.org).
- Create a new directory for the board game you're working on. It's best to keep the BIT file with the board game file because future BIT versions may not be backwards compatible and this way you will always be able to recreate the STLs.
- Put _boardgame_insert_toolkit_library.2.scad_ and a copy of _example.2.scad_ in the directory.
- You'll be working intirely in your copy of the example.
- The first line should be __include <boardgame_insert_toolkit_lib.2.scad>;__ and the last should be __MakeAll();__ All of your 'code' goes inbetween.
- Open your new scad file in your favorite text editor and also in Openscad.
- In Openscad, set "Automatic Reload and Preview" _on_ in the Design menu. Now openscad will update the display whenever you save the scad file in the text editor.
- Measure, build, measure again.
- When you're done, in Openscad, _Render_ final geometry, then _Export_ and STL file for your slicer. 
- I also recommend making a little script that will split your STL into separate STLs (one per object) using [Slic3r](https://slic3r.org)'s command line '--split' feature.
- If you post it on Thingiverse, make it a _remix_ of [BIT](https://www.thingiverse.com/thing:3405465) and I'll get notified and eventually add it to the list of game inserts. 

### Pay attention to your dimensions.
- Note that the box dimensions (BOX_DIMENSIONS) are _exterior_ dimensions and are as such to guarantee that the box you're defining fits inside the game's cardboard box.
- Also note that the compartment dimensions are _interior_ dimensions and are as such to guarantee that the game pieces will fit inside them.
- This means that you'll want to make sure that those exterior and interior values don't get too close to each other or your box walls will be thin and/or nonexistant.
- By default you'll want to leave 3mm in depth and length, and 2mm in height, when designing your inserts.
- Note that all dimensions represent mm.

## Key Values
Everything in BIT is defined using key-value pairs, i.e. [ _key_ , _value_ ]. Sometimes the _value_ is an array of other key-value pairs, so it's important to use indentation to keep track of the pairing. That's where a good text editor comes in handy. See the following example.

    [   "example 0: minimal",                                   // our box
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
The first key-value pair is [ "example 0: minimal", _one_big_array_of_keyvalues_ ]. The _one_big_array_of_keyvalues_ is all of the details of the box. Those nested key-values will define properties of the box, including the key-value pair called `BOX_COMPONENTS`, which contains defines a key-value array that holds the parameters of the components. It's key-values all the way down. See https://www.thingiverse.com/thing:3435429 for an example of lots of compartments of lots of components in lots of boxes.


Here is an example of some compartments designed to hold cards, with holes to get our fingers in on the side. Many of these parameters are just the default values and are not necessary, but are included for easy modification:


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
### Box keys
#### `BOX_DIMENSIONS`
value is expected to be an array of 3 numbers, and determines the exterior dimensions
of the box as width, depth, height.  
e.g. `[ BOX_DIMENSIONS, [ 140, 250, 80 ] ]`

#### `BOX_COMPONENTS`
value is expected to be an array of components, each one representing one type of compartment, repeated in 2d.

#### `BOX_VISUALIZATION`
describe me

#### `BOX_LID_NOTCHES`
value is expected to be a bool, "true", "false", "t", or "f", and determines whether the box will have notches that make pulling the lid off easier.  
e.g. `[ BOX_LID_NOTCHES, f ]`

#### `BOX_LID_HEX_RADIUS`
value is expected to be a number, and determines the radius of the hexes in the lid.  
e.g. `[ BOX_LID_HEX_RADIUS, 5 ]`

#### `BOX_LID_FIT_UNDER`
value is expected to be a bool, and determines whether the box bottom is formed to allow the box to sit in the lid when open. Note that this requires a printer that can handle printing 45 degrees outward without supports.

#### `BOX_LID`
value is expected to be a bool, and determines whether a lid is constructed and whether the box has the inset lip to support one.

#### `BOX_THIN_LID`
describe me


### Compartment keys


#### `CMP_NUM_COMPARTMENTS`
value is expected to be an array of 2 numbers, and determines how many compartments this component will have in the width and depth direction.  
e.g. `[ CMP_NUM_COMPARTMENTS, [ 4, 6 ] ]`

#### `CMP_COMPARTMENT_SIZE`
value is expected to be an array of 3 numbers, and determines the interior dimensions of each compartment within the component.  
e.g. `[ CMP_COMPARTMENT_SIZE, [ 10, 20, 5 ] ]`

#### CMP_SHAPE
value is expected to be one of the following:
- `SQUARE`    
default right angled compartment
- `HEX`      
a 6-sided compartment
- `HEX2`     
a 6-sided compartment that is rotated 30 degrees
- `OCT`      
an 8-sided compartment
- `OCT2`     
an 8-sided compartment that is rotated 22.5 degrees
- `ROUND`    
a round compartment
- `FILLET`   
a square compartment with rounded bottoms

e.g. `[ CMP_SHAPE, HEX2 ]`

#### `CMP_SHAPE_ROTATED`
value is expected to be a bool, and determines whether the shape is rotated along the Z axis. That is, whether it goes back and forth or side to side.

#### `CMP_SHAPE_VERTICAL`
value is expected to be a bool, and determines whether the shape is rotated for vertical stacks of pieces.

#### `CMP_PADDING`
value is expected to be an array of 3 numbers, and determines how far apart the compartments in a component are, in the width and depth direction.  
e.g. `[ CMP_PADDING, [ 2.5, 1.3 ] ]`

#### `CMP_PADDING_HEIGHT_ADJUST`
value is expected to be an array of 2 numbers, and determines how much to modify the height of the padding between compartments. These should typically
be negative values.  
e.g. `[ CMP_PADDING_HEIGHT_ADJUST, [ -3, 0 ] ]`

#### `CMP_MARGIN`
value is expected to be an array of 4 bools, and determines whether padding is also added to the outside of the compartment array. The values represent [front, back, left, right ].  
e.g. `[ CMP_MARGIN, [ t, f, t, f ] ]`

#### `CMP_CUTOUT_SIDES`
value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the compartments. The values represent [front, back, left, right ].  
e.g. `[ CMP_CUTOUT_SIDES, [ t, t, f, f ] ]`

#### `CMP_SHEAR`
value is expected to be an array of 2 numbers, and determines the degrees to which the component should be sheared in the direction of width and depth.  
e.g. `[ CMP_SHEAR, [ 45, 0 ] ]`

#### `LABEL`
value is expected to be an array of key-values that define the label. A Label can be defined at the box-level for the label that will appear on the lid, or at the component label for the labels that will appear on the compartments.


### Label keys

#### `LBL_TEXT`
value is expected to either be a string, or an array of strings matching the structure of the compartments. A single string will label every compartment with that string while an array will label each compartment with its respective string.  
e.g. `[ LBL_TEXT, "tokens" ]`  
or

    [ LBL_TEXT,        
        [   
            ["back left", "back right"],        
            ["front left", "front right"],
        ]
    ]

#### `LBL_SIZE`
value is expected to either be `AUTO` or a number. `AUTO` will attempt to scale the label to fit in the space according to _width_. This does not work will with very short words. A number will specify the font size.  
e.g. `[ LBL_SIZE, 12 ]`

#### `LBL_PLACEMENT`
value is expected to be one of the following:  
- `FRONT`
- `BACK`
- `LEFT`
- `RIGHT`
- `FRONT_WALL`
- `BACK_WALL`
- `LEFT_WALL`
- `RIGHT_WALL`
- `CENTER`  

Front, back, left, and right, will place the label on the top surface, while the _wall values will place the label inside, on the compartment wall. Center will place the label on the compartment floor.

#### `LBL_FONT`
value is expected to be a string that determines what font to use for the label. More [here](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles).  
e.g. `[ LBL_FONT, "Times New Roman:style=bold italic" ]`

#### `LBL_DEPTH`
value is expected to be a number, and determines how deep the label should cut.  
e.g. `[ LBL_DEPTH, 0.5 ]`

#### `ROTATION`
value is expected to be a number, and determines the degree to which the component or label is to be rotated.  
e.g. `[ ROTATION, 45 ]`

#### `POSITION`
value is expected to be an array of 2 numbers, although `MAX` is also valid, and determines the position of the label or component. 
- When used on a label, the values are relative to reasonable centers and can be used to adjust the positioning of the text.
- When used on a component, it is always relative to the origin of the box, and almost always needs to be present.
- When used on a component, the value `MAX` essentially aligns that value to opposite end, so 'right' when placed in the x position, and 'back' when placed in the y position.  
e.g. `[ POSITION, [ 20, MAX ] ]`

#### `ENABLED`
value is expected to be a bool, and determines whether the box, component, or label, is used. This allows for easily turning features off temporarily or permanently without needing to delete lots of content.  
e.g. `[ ENABLED, f ]`


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
