<!--ts-->
<!--te-->

# What

This:

![Dune 1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/IMG_3294.jpeg)
![Mice n Mystics 2](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/IMG_1453.jpeg)

# Why
This OpenSCAD library was designed to for quick design and iteration on board game inserts--specifically ones with lids. There are lots of great printable inserts out there, but very few for us vertical storers.

# How
- Download [Openscad](https://www.openscad.org).
- Create a new directory for the board game you're working on. It's best to keep the BIT file with the board game file because future BIT versions may not be backwards compatible and this way you will always be able to recreate the STLs.
- Put _boardgame_insert_toolkit_library.2.scad_ and a copy of _example.2.scad_ in the directory.
- You'll be working entirely in your copy of the example.
- The first line should be __include <boardgame_insert_toolkit_lib.2.scad>;__ and the last should be __MakeAll();__ All of your 'code' goes in-between.
- Open your new scad file in your favorite text editor and also in Openscad.
- In Openscad, set "Automatic Reload and Preview" _on_ in the Design menu. Now openscad will update the display whenever you save the scad file in the text editor.
- Measure, build, measure again.
- When you're done, in Openscad, _Render_ final geometry, then _Export_ and STL file for your slicer. 
- I also recommend making a little script that will split your STL into separate STLs (one per object) using [Slic3r](https://slic3r.org)'s command line '--split' feature.
- If you post it on Thingiverse, make it a _remix_ of [BIT](https://www.thingiverse.com/thing:3405465) and I'll get notified and eventually add it to the list of game inserts. 

### Pay attention to your dimensions.
- Note that the box dimensions (BOX_SIZE_XYZ) are _exterior_ dimensions and are as such to guarantee that the box you're defining fits inside the game's cardboard box.
- Also note that the compartment dimensions are _interior_ dimensions and are as such to guarantee that the game pieces will fit inside them.
- This means that you'll want to make sure that those exterior and interior values don't get too close to each other or your box walls will be thin and/or nonexistant.
- By default you'll want to leave 3mm in depth and length, and 2mm in height, when designing your inserts.
- Note that all dimensions represent mm.

## Key Values
Everything in BIT is defined using key-value pairs, i.e. [ _key_ , _value_ ]. Sometimes the _value_ is an array of other key-value pairs, so it's important to use indentation to keep track of the pairing. That's where a good text editor comes in handy. See the following example.

    [   "example 0: minimal",                            // our box. name is just for code organization.
        [
            [ BOX_SIZE_XYZ, [46.5, 46.5, 15.0] ],        // one kv pair specifying the x, y, and z of our box exterior.
            [ BOX_COMPONENT,                             // our first component.
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [4, 4] ],               // it's a grid of 4 x 4
                    [ CMP_COMPARTMENT_SIZE_XYZ, [ 10, 10, 13.0] ],   // each compartment is 10mm x 10mm x 13mm
                ]
            ]
        ]
    ]

That made this:

![example1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example1.png)

### Some Explanation
The first key-value pair is [ "example 0: minimal", _one_big_array_of_keyvalues_ ], and its value is an array of all of the details of the box. One of those key-pairs is `BOX_COMPONENT` which defines the one type of compartment we want. It's key-values all the way down. See https://www.thingiverse.com/thing:3435429 for an example of lots of compartments of lots of components in lots of boxes.


Here is an example of some compartments designed to hold cards, with holes to get our fingers in on the side. Many of these parameters are just the default values and are not necessary, but are included for easy modification:


    [   "example 1",
        [
            [ BOX_SIZE_XYZ,             [110.0, 180.0, 22.0] ],
            [ ENABLED_B,                t],

             [ BOX_LID,
                [
                    [ LID_NOTCHES_B,        f],
                    [ LID_FIT_UNDER_B,      f],
                    [ LID_CUTOUT_SIDES_4B, [f,f,t,t]],
                    [ LID_SOLID_B, f],
                    [ LID_HEIGHT, 15 ],
                ]
             ]

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
    ]

And this is the result:
![example2](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example2.png)


### Dividers
As of v2.04, there is also the ability to create card dividers in addition to boxes. A dividers definition looks like this:

    [ "divider example 1",
        [
            [ TYPE,                     DIVIDERS ],
            [ DIV_TAB_TEXT,             ["001","002","003"]],
            [ DIV_FRAME_NUM_COLUMNS,    2 ]
        ]
    ]

And produces something like this:
![dividers](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/dividers1.png)

### Customizable Lid Patterns
As of v2.10, one can now tweak the lid pattern parameters. The default is still a honeycomb, but here are some alternatives:


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

![lid pattern 1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/pattern1.png)

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

![lid pattern 2](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/pattern2.png)

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

![lid pattern 3](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/pattern3.png)


# Keys

#### `TYPE`
value is expected to be one of the following:
- `BOX` (default)
a box.
- `DIVIDERS`
a set of dividers.

### Box keys

#### `BOX_SIZE_XYZ`
value is expected to be an array of 3 numbers, and determines the exterior dimensions
of the box as width, depth, height.  
e.g. `[ BOX_SIZE_XYZ, [ 140, 250, 80 ] ]`

#### `BOX_COMPONENT`
value is expected to be an array of components key-value pairs. Box can have as many of these as desired.

#### `BOX_VISUALIZATION`
describe me

### Lid keys
as of v2.09, all lid parameters are specified in a BOX_LID container. This makes it easy to reuse box lid parameters across multiple boxes.

#### `BOX_LID`
value is expected to be an array of lid key-value pairs.

#### `LID_NOTCHES_B`
value is expected to be a bool, "true", "false", "t", or "f", and determines whether the box will have notches that make pulling the lid off easier.  
e.g. `[ LID_NOTCHES_B, f ]`

#### `LID_PATTERN_RADIUS`
value is expected to be a number, and determines the radius of the hexes in the lid.  
e.g. `[ LID_PATTERN_RADIUS, 5 ]`

#### `LID_PATTERN_N1`
value is expected to be a number, and determines the number of sides that the pattern outer shape has.  

#### `LID_PATTERN_N2`
value is expected to be a number, and determines the number of sides that the pattern inner shape has. 

#### `LID_PATTERN_ANGLE`
value is expected to be a number, and determines the angle of the pattern shape. 

#### `LID_PATTERN_ROW_OFFSET`
value is expected to be a number, and determines the percent of height that each row will offset from each other. 

#### `LID_PATTERN_COL_OFFSET`
value is expected to be a number, and determines the percent of width that each column will offset from each other. 

#### `LID_PATTERN_THICKNESS`
value is expected to be a number, and determines the thickness of the shape, i.e. the difference between the inner and outer shapes` radius. 

#### `LID_FIT_UNDER_B`
value is expected to be a bool, and determines whether the box bottom is formed to allow the box to sit in the lid when open. Note that this requires a printer that can handle printing 45 degrees outward without supports.

#### `BOX_NO_LID_B`
value is expected to be a bool, and determines whether a lid is ommitted. If ommitted, the box will not form an inset lip to support a lid.

#### `LID_THIN_B`
describe me

#### `LID_SOLID_B`
value is expected to be a bool, and determines whether the lid is a hex mesh or solid.

#### `LID_SOLID_LABELS_DEPTH`
value is expected to be a number, and if the lid is solid, determines how deep the label cut is.

#### `LID_LABELS_INVERT_B`
value is expected to be a bool, and determines whether the lid label is a positive or negative shape.

#### `LID_LABELS_BG_THICKNESS`
value is expected to be a number, and determines the thickness of the lid label background.

#### `LID_HEIGHT`
value is expected to be a number, and determines whether how deep the lid is.

#### `LID_CUTOUT_SIDES_4B`
value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the lid. This allows the lid to be used as a card tray during play. The values represent [front, back, left, right ].  
e.g. `[ LID_CUTOUT_SIDES_4B, [ t, t, f, f ] ]`

### Dividers keys
as of v2.04, in addition to boxes, one can also create card dividers.

#### `DIV_THICKNESS`
value is expected to be a number, and determines the thickness of each divider.

#### `DIV_FRAME_SIZE_XY`
value is expected to be an array of 2 numbers, and determines the width and height of each divider (without the tab).

#### `DIV_FRAME_TOP`
value is expected to be a number, and determines the height of the top bar of the divider.

#### `DIV_FRAME_BOTTOM`
value is expected to be a number, and determines the height of the bottom bar of the divider.

#### `DIV_FRAME_COLUMN`
value is expected to be a number, and determines the width of the vertical bars of the divider.

#### `DIV_FRAME_RADIUS`
value is expected to be a number, and determines the radius of the frame corners of the divider.

#### `DIV_FRAME_NUM_COLUMNS`
value is expected to be a number, and determines the number of columns in the middle of the frame of the divider. 0 makes for a frame that has no middle columns. -1 makes for a solid divider with no holes.

#### `DIV_TAB_SIZE_XY`
value is expected to be an array of 2 numbers, and determines the width and height of each divider's tab.

#### `DIV_TAB_RADIUS`
value is expected to be a number, and determines the radius of the corner of the tab on the divider.

#### `DIV_TAB_CYCLE`
value is expected to be a number, and determines over how many dividers should the tab drift from left to right.

#### `DIV_TAB_TEXT`
value is expected to be an array of strings, and determines what dividers get created.
e.g. `[ DIV_TAB_TEXT, [ "Tab-1", "Tab-2", "Tab-3", "Tab-4" ] ]`

#### `DIV_TAB_TEXT_SIZE`
value is expected to be a number, and determines the font size of the tab text.

#### `DIV_TAB_TEXT_FONT`
value is expected to be a string, and determines the font of the tab text. More [here](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles).  
e.g. `[ LBL_FONT, "Times New Roman:style=bold italic" ]`

#### `DIV_TAB_TEXT_SPACING`
value is expected to be a number, and determines the letter spacing of the tab text.

#### `DIV_TAB_TEXT_CHAR_THRESHOLD`
value is expected to be a number, and determines the number of characters above which the size of the font should be determined automatically.

### Compartment keys
#### `CMP_NUM_COMPARTMENTS_XY`
value is expected to be an array of 2 numbers, and determines how many compartments this component will have in the width and depth direction.  
e.g. `[ CMP_NUM_COMPARTMENTS_XY, [ 4, 6 ] ]`

#### `CMP_COMPARTMENT_SIZE_XYZ`
value is expected to be an array of 3 numbers, and determines the interior dimensions of each compartment within the component.  
e.g. `[ CMP_COMPARTMENT_SIZE_XYZ, [ 10, 20, 5 ] ]`

#### `CMP_SHAPE`
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

#### `CMP_SHAPE_ROTATED_B`
value is expected to be a bool, and determines whether the shape is rotated along the Z axis. That is, whether it goes back and forth or side to side.

#### `CMP_SHAPE_VERTICAL_B`
value is expected to be a bool, and determines whether the shape is rotated for vertical stacks of pieces.

#### `CMP_FILLET_RADIUS`
value is expected to be a number, and determines the radius of the fillet, if shape is fillet.

#### `CMP_PADDING_XY`
value is expected to be an array of 3 numbers, and determines how far apart the compartments in a component are, in the width and depth direction.  
e.g. `[ CMP_PADDING_XY, [ 2.5, 1.3 ] ]`

#### `CMP_PADDING_HEIGHT_ADJUST_XY`
value is expected to be an array of 2 numbers, and determines how much to modify the height of the x and y padding between compartments. These should typically be negative values.  
e.g. `[ CMP_PADDING_HEIGHT_ADJUST_XY, [ -3, 0 ] ]`

#### `CMP_MARGIN_4B`
value is expected to be an array of 4 bools, and determines whether padding is also added to the outside of the compartment array. The values represent [front, back, left, right ].  
e.g. `[ CMP_MARGIN_4B, [ t, f, t, f ] ]`

#### `CMP_CUTOUT_SIDES_4B`
value is expected to be an array of 4 bools, and determines whether finger cutouts are to be added to the compartments. The values represent [front, back, left, right ].  
e.g. `[ CMP_CUTOUT_SIDES_4B, [ t, t, f, f ] ]`

#### `CMP_SHEAR`
value is expected to be an array of 2 numbers, and determines the degrees to which the component should be sheared in the direction of width and depth.  
e.g. `[ CMP_SHEAR, [ 45, 0 ] ]`

#### `LABEL`
value is expected to be an array of key-values that define a label. Labels can be defined at the box-level for labels that will appear on the lid, or at the component label for the labels that will appear on the compartments. Components can have one label. Boxes can have as many as desired.

### Label keys
Key-pairs that are expected in a LABEL container.

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

#### `LBL_SPACING`
value is expected to be a number, and determines the letter spacing. 
e.g. `[ LBL_SPACING, 1.1 ]`


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

#### `POSITION_XY`
value is expected to be an array of 2 numbers, although `MAX` is also valid, and determines the position of the label or component. 
- When used on a label, the values are relative to reasonable centers and can be used to adjust the positioning of the text.
- When used on a component, it is always relative to the origin of the box, and almost always needs to be present.
- When used on a component, the value `MAX` essentially aligns that value to opposite end, so 'right' when placed in the x position, and 'back' when placed in the y position.  
e.g. `[ POSITION_XY, [ 20, MAX ] ]`

#### `ENABLED_B`
value is expected to be a bool, and determines whether the box, component, or label, is used. This allows for easily turning features off temporarily or permanently without needing to delete lots of content.  
e.g. `[ ENABLED_B, f ]`


# Published inserts:


- [Pandemic]( https://www.thingiverse.com/thing:3412724)
- [Mice and Mystics]( https://www.thingiverse.com/thing:3435429)
- [Indonesia (upgraded goods)]( https://www.thingiverse.com/thing:3446879)
- [Indonesia (upgraded goods and ships )]( https://www.thingiverse.com/thing:3454636)
- [Pax Emancipation]( https://www.thingiverse.com/thing:3450282)
- [Bios:Genesis](https://www.thingiverse.com/thing:3452368)
- [Greenland/Neanderthal]( https://www.thingiverse.com/thing:3469793)
- [Pax Porfiriana (Collector's Edition)]( https://www.thingiverse.com/thing:3478944)
- [Pax Renaissance]( https://www.thingiverse.com/thing:3479114)
- [High Frontier (3rd)]( https://www.thingiverse.com/thing:3482341)
- [Bios: Megafauna](https://www.thingiverse.com/thing:3493660)
- [1830]( https://www.thingiverse.com/thing:3499314)
- [Sword & Sorcery]( https://www.thingiverse.com/thing:3515523)
- [Mansions of Madness 2nd edition persons container]( https://www.thingiverse.com/thing:3527361)
- [Stuffed Fables]( https://www.thingiverse.com/thing:3535505)
- [Star Trek" Frontiers]( https://www.thingiverse.com/thing:3538652)
- [Comanchería]( https://www.thingiverse.com/thing:4187266)
- [7th Continent dividers]( https://www.thingiverse.com/thing:4223923)
- [V Commandos]( https://www.thingiverse.com/thing:4319308 )