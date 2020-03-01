This OpenSCAD library was created to make it easy to create board game inserts with lids for either horizontal or vertical storage, without any programming required.

Create a settings file, in which you specify the box dimensions and any number of compartments, their sizes, what kind of pieces it holds, etc, and the script will do the rest.

The file is built of keyvalue pairs. Here is an example:

    [   "example 0: minimal",
        [
            [ "box_dimensions", [46.5, 46.5, 15.0] ],
            [ "components",
                [[   "my chits",
                        [
                            ["num_compartments", [4,4]],
                            ["compartment_size", [ 10, 10, 13.0] ],
                        ]
                    ]]]]]

The outer keyvalue is [ "box", array_of_keyvalues ]. The array_of_keyvalues is a bunch of stuff we need to define the box. One of those is "components," which contains the different kinds of compartments our box will have.

Result: ![example1](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example1.png)



Here is another example:

    [   "example 1: basic tray with defaults",
        [
            [ "box_dimensions",                             [110.0, 180.0, 22.0] ],             
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
                            ["compartment_size",                [ 22, 60.0, 20.0] ],    
                            ["num_compartments",                [2,2] ],                
                            ["shape",                           "square"],                
                            ["shape_rotated_90",                f],                     
                            ["shape_vertical",                  f],                     
                            ["padding",                         [15,12]],               
                            ["padding_height_adjust",           [-5, 0] ],             
                            ["margin",                          [t,f,f,f]],             
                            ["cutout_sides",                    [f,f,f,t]],             
                            ["rotation",                        5 ],                    
                            ["position",                        ["center","center"]],   
                            ["label",               
                                [
                                    ["text",        [   
                                                        ["backleft", "backright"],        
                                                        ["frontleft", "frontright"],
                                                    ]
                                    ],
                                    ["placement",   "front"],                           
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

And this is the result:

![example2](https://github.com/IdoMagal/The-Boardgame-Insert-Toolkit/blob/master/images/example2.png)



Inserts:

- Pandemic: https:
- Mice and Mystics: https:
- Indonesia (upgraded goods): https:
- Indonesia (upgraded goods and ships ): https:
- Pax Emancipation: https:
- Bios: Genesis: https:
- Greenland/Neanderthal: https:
- Pax Porfiriana (Collector's Edition): https:
- Pax Renaissance: https:
- High Frontier (3rd): https:
- Bios: Megafauna: https:
- 1830: https:
- Sword & Sorcery: https:
- Mansions of Madness 2nd edition persons container: https:
- Stuffed Fables: https:
- Star Trek: Frontiers: https:
Cheers.

## CHANGE NOTES

### v2.00

Version 2.00 is a major rework and is not compatible with previous versions. 
The major changes are
- "type" has been replaced with explicit specification of a-la-carte features.
- Labels have more options.

### Details: 

- g_b_visualization is now purely for previewing and cannot be exported (accidentally or otherwise)
- components are now colorized for easier debugging of overlaps
- labels
    - New field, "placement" (default "center") specifies where to place the text relative to the compartment. 
        Supported values are "center", "below", "back", "left", "right", "back-wall", "front-wall", "right-wall", "left-wall".
         "center" places the text in the FRONT of the compartment while the others place it on one of the adjacent partitions.
         "-wall" placement places the labels on the wall of the compartment.
    - New field, "offset" (default "[0,0]") specifies the amount to adjust the position of the text, in the x and y directions.
    - New field, "font" (default "Liberation Sans:style=bold") specifies a font to use.
    - The field "rotation" now specifies an angle in degrees and supports any angle.
    - The field "size" now supports (and defaults to) "auto," which attempts to fit the text into its region.
    - When using an array of labels, the labels are no longer read in reverse order and should appear as specified in the array.
- boxes
    - New field "lid_notches" (default "true") specifies whether the box has notches or not.
    - New field "fit_lid_under" (default "true") replaces g_b_fit_lid_underneath and allows per-box specification on whether the box should be printed to allow the lid to fit underneath.
    - New field "lid_hex_radius" (default "4.0") specifies the radius of the honeycomb hexes in the lid.
- components
    - The field "rotation" now respects any value and specifies the rotation of the entire component.
    - The field "type" has been deprecated. All of the functionality has been moved into individual component features.
    - The field "partition_size_adjustment" has been deprecated.
    - New field "padding" (default "[1.0, 1.0]") specifies the size of the partitions between compartments, in the x and y directions.
    - The field "partition_height_adjustment" has been renamed "padding_height_adjust."
    - The global "g_partition_thickness" has been deprecated.
    - The global "g_finger_partition_thickness" has been deprecated.
    - New field "margin" (default "[false,false,false,false]") specifies which sides of the component will have a partition. The sides are [FRONT,BACK,LEFT,RIGHT].
    - New field "cutout_sides" (default "[false,false,false,false]") specifies sides of the compartment to place finger cutouts. Sides are [FRONT,BACK,LEFT,RIGHT]. 
    - New field "shape" (default "square") specifies a geometric shape for the compartments. Supported shapes are "hex", "hex2", "oct", "oct2", "round", "square", "fillet".
    - New field "shape_rotated_90" (default "false") specifies whether the shape should be rotated 90 degrees.
    - New field "shape_vertical" (default "false") specifies whether the shape should be rotated vertically.
    - New field "shear" (default "[0,0]) specifies angles by which to shear the component in the x and y directions.
- misc
    - misc bug fixes

### v1.17

- Updated examples with more properties.
- Added examples of partition_size_adjustment and partition_height_adjustment

### v1.16

- Fixed error in rotated hex chit_stack computation
- Added "hex_rotated" shape, which is has point-side-down

### v1.15

- Bug fixes and cleanup

### v1.13

- Vertical chit stacks now rotate correctly.
- Finger cutouts now go through the bottom. This saves material and makes it easier to get pieces out.
- Added shaped holes in the bottom of vertical stacks.

### v1.12

- Better support for compact fits.
- Bug fixes and optimizations.

### v1.11

- Now supports rotation of features.

### v1.10

- Under-box storage of lid without need for supports.
- Misc optimizations and bug fixes
- Moved Mice and Mystics to its own thing (https:

### v1.09

- More work on visualization.
- Added option to print extra thin lids.
- Added option to create insets at box bottom that allow lid to be stowed under during play.
- Added simple solid labeled lid option.
- Misc fixes and optimizations.

### v1.08

- Added ability to visualize the inserts closed and arranged as they will be placed in the
- game box.

### v1.07

- Enlarged lid hexes to shorten Openscad rendering.
- Added lid label offset to help legibility.

### v1.06

- Added native honeycomb lid pattern.
- Added ability to label lids.
- Updated Mice and Mystics insert.

### v1.05

- Added ability to label compartments individually within a component.
- Added Mice and Mystics example.

### v1.04

- Added support for labelling compartments.
- Moved Pandemic to its own thing. (https:

### v1.03

- Added support for negative position values, which position relative to the other side of the box.
- Fixed lid fitting issue.
- Clamped max depth of finger cutouts.

### v1.02

- Added support for round and hex chit stacks using the "shape" property.
- Misc bug fixes.

### v1.01

- Added support for a chit stack compartment.
- Added an example SCAD file that features every compartment type.
- Fixed misc bugs.
