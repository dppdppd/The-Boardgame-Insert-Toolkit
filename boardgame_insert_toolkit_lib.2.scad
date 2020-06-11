
// Copyright 2020 MysteryDough https://www.thingiverse.com/MysteryDough/
//
// Released under the Creative Commons - Attribution - Non-Commercial - Share Alike License.
// https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

VERSION = "2.14";
COPYRIGHT_INFO = "\tThe Boardgame Insert Toolkit\n\thttps://github.com/IdoMagal/The-Boardgame-Insert-Toolkit\n\n\tCopyright 2020 Ido Magal\n\tCreative Commons - Attribution - Non-Commercial - Share Alike.\n\thttps://creativecommons.org/licenses/by-nc-sa/4.0/legalcode";

$fn = $preview ? 25 : 100;

// constants
k_key = 0;
k_value = 1;

k_x = 0;
k_y = 1;
k_z = 2;

k_front = 0;
k_back = 1;
k_left = 2;
k_right = 3;

//k_front_left = 0;
//k_back_right = 1;
//k_back_left = 2;
//k_front_right = 3;

t = true;
f = false;

///////////////////////
// PARAMETER KEYWORDS

TYPE = "type";
BOX = "box";
DIVIDERS = "dividers";
SPACER = "spacer";

BOX_LID = "box_lid";

DIV_THICKNESS = "div_thickness";

DIV_TAB_SIZE_XY = "div_tab_size";

DIV_TAB_RADIUS = "div_tab_radius";
DIV_TAB_CYCLE = "div_tab_cycle";

DIV_TAB_TEXT = "div_tab_text";
DIV_TAB_TEXT_SIZE = "DIV_TAB_TEXT_size";
DIV_TAB_TEXT_FONT = "DIV_TAB_TEXT_font";
DIV_TAB_TEXT_SPACING = "DIV_TAB_TEXT_spacing";
DIV_TAB_TEXT_CHAR_THRESHOLD = "DIV_TAB_TEXT_char_threshold";

DIV_FRAME_SIZE_XY = "div_frame_size";

DIV_FRAME_TOP = "div_frame_top";
DIV_FRAME_BOTTOM = "div_frame_bottom";
DIV_FRAME_COLUMN = "div_frame_column";
DIV_FRAME_RADIUS = "div_frame_radius";
DIV_FRAME_NUM_COLUMNS = "div_frame_num_columns";

// BOX PARAMETERS
BOX_SIZE_XYZ = "box_size";
BOX_COMPONENT = "component";
BOX_VISUALIZATION = "visualization";

BOX_NO_LID_B = "no_lid";

LID_NOTCHES_B = "lid_notches";
LID_FIT_UNDER_B = "fit_lid_under";
LID_THIN_B = "thin_lid";
LID_SOLID_B = "box_lid_solid";
LID_HEIGHT = "lid_height";
LID_CUTOUT_SIDES_4B = "lid_cutout_sides";
LID_LABELS_INVERT_B = "lid_label_inverted";
LID_SOLID_LABELS_DEPTH = "lid_label_depth";
LID_LABELS_BG_THICKNESS = "lid_label_bg_thickness";
LID_LABELS_BORDER_THICKNESS = "lid_label_border_thickness";


LID_PATTERN_RADIUS = "lid_hex_radius";
LID_PATTERN_N1 = "lid_pattern_n1";
LID_PATTERN_N2 = "lid_pattern_n2";
LID_PATTERN_ANGLE = "lid_pattern_angle";
LID_PATTERN_ROW_OFFSET = "lid_pattern_row_offset";
LID_PATTERN_COL_OFFSET = "lid_pattern_col_offset";
LID_PATTERN_THICKNESS = "lid_pattern_thickness";

// COMPARTMENT PARAMETERS
CMP_NUM_COMPARTMENTS_XY = "num_compartments";
CMP_COMPARTMENT_SIZE_XYZ = "compartment_size";
CMP_SHAPE = "shape";
CMP_SHAPE_ROTATED_B = "shape_rotated_90";
CMP_SHAPE_VERTICAL_B = "shape_vertical";
CMP_PADDING_XY = "padding";
CMP_PADDING_HEIGHT_ADJUST_XY = "padding_height_adjust";
CMP_MARGIN_4B = "margin";
CMP_CUTOUT_SIDES_4B = "cutout_sides";
//CMP_CUTOUT_CORNERS_4B = "cutout_corners";
CMP_SHEAR = "shear";
CMP_FILLET_RADIUS = "fillet_radius";

// LABEL PARAMETERS
LBL_TEXT = "text";
LBL_SIZE = "size";
LBL_PLACEMENT = "placement";
LBL_FONT = "font";
LBL_DEPTH = "depth";
LBL_SPACING = "spacing";
//LBL_AUTO_CHAR_COUNT = "char_auto";

LABEL = "label";

// LABEL PLACEMENT VALUES
FRONT = "front";
BACK = "back";
LEFT = "left";
RIGHT = "right";
FRONT_WALL = "front-wall";
BACK_WALL = "back-wall";
LEFT_WALL = "left-wall";
RIGHT_WALL = "right-wall";
CENTER = "center";
///

AUTO = "auto";
MAX = "max";

ENABLED_B = "enabled";
ROTATION = "rotation";
POSITION_XY = "position";

// SHAPES
SQUARE = "square";
HEX = "hex";
HEX2 = "hex2";
OCT = "oct";
OCT2 = "oct2";
ROUND = "round";
FILLET = "fillet";

DISTANCE_BETWEEN_PARTS = 2;
////////////////////

// key-values helpers
function __index_of_key( table, key ) = search( [ key ], table )[ k_key ];
function __value( table, key, default = false ) = __index_of_key( table, key ) == [] ? default : table[ __index_of_key( table, key ) ][ k_value ];

///////////////////////
// determines whether lids are output.
g_b_print_lid = t;

// determines whether boxes are output.
g_b_print_box = t; 

// Focus on one box
g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together.
g_b_visualization = f;
g_b_vis_actual = g_b_visualization && $preview;

// Turn off labels during preview. 
g_b_preview_no_labels = f;
g_b_no_labels_actual = g_b_preview_no_labels && $preview;

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = f;            

// default = 1.5
g_wall_thickness = 1.5; 

// default = g_wall_thickness
g_lid_thickness = g_wall_thickness; 

// default = 5.0
g_lid_lip_height = 5.0; 

// give each compartment a different color. Useful for development
g_b_colorize = true;

// tolerance for fittings. This is the gap between fitting pieces,
// such as lids and boxes. Increase to loosen the fit and decrease to
// tighten it.
g_tolerance = 0.1; 


module debug()
{
    #translate( [ -.5, -.5, -50])
        cube( [ 1 , 1, 100 ] );
}

module RotateAndMoveBackToOrigin(a, extents ) 
{
    pos = 
        a == 90 ? [ extents[1], 0, 0] : 
            a == -90 ? [ 0, extents[0], 0 ] : 
                a == -180 ? [ extents[1], extents[0], 0 ] :
                    [0,0,0];

    translate( pos )
        rotate( a=a, v=[0,0,1])
            children();   
}

module RotateAboutPoint(a, v, pt) 
{
    translate(pt)
        rotate(a,v)
            translate(-pt)
                children();   
}

module MirrorAboutPoint( v, pt) 
{
    translate(pt)
        mirror( v )
            translate(-pt)
                children();   
}


function __element( i ) = data[ i ][1];
function __num_elements() = len( data );

function __type( lmnt ) = __value( lmnt, TYPE, default = BOX);

function __is_element_isolated_for_print() = g_isolated_print_box != "" && ( __index_of_key( data, g_isolated_print_box ) != [] ) ;

function __is_element_enabled( lmnt ) = __value( lmnt, ENABLED_B, default = true);

function __element_dimensions( lmnt ) = __type( lmnt ) == DIVIDERS ?
                                    [ __div_frame_size( lmnt )[k_x],  __div_total_height( lmnt ) ] : 
                                    __value( lmnt, BOX_SIZE_XYZ, default = [ 100, 100] );

function __element_position_x( i ) = __element( i - 1 ) == undef ? 0 : __is_element_enabled( __element( i - 1 ) ) ? __element_dimensions( __element( i - 1 ) )[ k_x ] + __element_position_x( i - 1 ) + DISTANCE_BETWEEN_PARTS : __element_position_x( i - 2 );

//vis
function __box_vis_data( box ) = __value( box, BOX_VISUALIZATION, default = "");
function __box_vis_position( box ) = __value( __box_vis_data( box ), POSITION_XY );
function __box_vis_rotation( box ) = __value( __box_vis_data( box ), ROTATION );

function __div_thickness( div ) = __value( div, DIV_THICKNESS, default = 0.5 );
function __div_tab_size( div ) = __value( div, DIV_TAB_SIZE_XY, default = [32, 14] );
function __div_tab_radius( div ) = __value( div, DIV_TAB_RADIUS, default = 4 );
function __div_tab_cycle( div ) = __value( div, DIV_TAB_CYCLE, default = 3 );

function __div_total_height( div ) = __div_tab_size( div )[k_y] + __div_frame_size( div )[k_y];

function __div_tab_text ( div ) = __value( div, DIV_TAB_TEXT, default = ["001","002", "003" ] );
function __div_tab_text_size ( div ) = __value( div, DIV_TAB_TEXT_SIZE, default = 7 );
function __div_tab_text_font ( div ) = __value( div, DIV_TAB_TEXT_FONT, default = "Stencil Std:style=Bold" );
function __div_tab_text_spacing ( div ) = __value( div, DIV_TAB_TEXT_SPACING, default = 1.1 );
function __div_tab_text_char_threshold ( div ) = __value( div, DIV_TAB_TEXT_CHAR_THRESHOLD, default = 4 );

function __div_tab_size( div ) = __value( div, DIV_TAB_SIZE_XY, default = [32, 14] );

function __div_frame_size( div ) = __value( div, DIV_FRAME_SIZE_XY, default = [80, 80] );
function __div_frame_top( div ) = __value( div, DIV_FRAME_TOP, default = 10 );
function __div_frame_bottom( div ) = __value( div, DIV_FRAME_BOTTOM, default = 10 );
function __div_frame_column( div ) = __value( div, DIV_FRAME_COLUMN, default = 7 );
function __div_frame_radius( div ) = __value( div, DIV_FRAME_RADIUS, default = 15 );
function __div_frame_num_columns( div ) = __value( div, DIV_FRAME_NUM_COLUMNS, default = -1 );

// is the text a string or a list of strings?
function __is_multitext( label ) = !is_string( __value( label, LBL_TEXT ) ) && is_list(__value( label, LBL_TEXT ));

function __label_text( label, r = 0, c = 0 ) = __is_multitext( label ) ?  __value( label, LBL_TEXT, default = "" )[c][r] : __value( label, LBL_TEXT, default = "" );
function __label_size_raw( label ) = __value( label , LBL_SIZE, default = AUTO );
function __label_size_is_auto( label ) = __label_size_raw( label ) == AUTO;
function __label_size( label ) = __label_size_is_auto( label ) ? 10 : __label_size_raw( label);
function __label_rotation_raw( label ) = __value( label, ROTATION, default = 0 ) % 360;
function __label_rotation( label ) = __label_rotation_raw( label ) + 
   ( __label_placement_is_left( label ) ? 90 : __label_placement_is_right( label ) ? -90 : __label_placement_is_front( label ) && __label_placement_is_wall( label ) ? 0 : 0 );
function __label_depth( label ) = __value( label, LBL_DEPTH, default = 0.2 );
function __label_placement_raw( label ) = __value( label, LBL_PLACEMENT, default = CENTER );
function __label_placement_is_center( label ) = __label_placement_raw( label ) == CENTER;
function __label_placement_is_back( label ) = __label_placement_raw( label ) == BACK || __label_placement_raw( label ) == BACK_WALL;
function __label_placement_is_front( label ) = __label_placement_raw( label ) == FRONT || __label_placement_raw( label ) == FRONT_WALL;
function __label_placement_is_left( label ) = __label_placement_raw( label ) == LEFT || __label_placement_raw( label ) == LEFT_WALL;
function __label_placement_is_right( label ) = __label_placement_raw( label ) == RIGHT || __label_placement_raw( label ) == RIGHT_WALL;
function __label_placement_is_wall( label ) = 
    __label_placement_raw( label ) == BACK_WALL ||
    __label_placement_raw( label ) == FRONT_WALL ||
    __label_placement_raw( label ) == LEFT_WALL ||
    __label_placement_raw( label ) == RIGHT_WALL ;

function __label_offset( label ) = __value( label, POSITION_XY, default = [0,0] );
function __label_font( label ) = __value( label, LBL_FONT, default = "Liberation Sans:style=Bold" );
function __label_spacing( label ) = __value( label, LBL_SPACING, default = 1 );
function __label_scale_magic_factor( label ) = 1.2 + (1 * abs(tan( __label_rotation( label ) % 90 )) );
function __label_auto_width( label, x, y) = __label_size_is_auto( label ) ? 
            (  cos( __label_rotation( label ) ) * ( x/__label_scale_magic_factor( label ) )) + 
            ( abs( sin( __label_rotation( label ) ) ) * ( y/__label_scale_magic_factor( label ) )) :
            0;

module Colorize()
{
    if ( g_b_vis_actual )
    {
        color( rands(0,1,3), 0.5 )
            children();
    }
    else
    {
        children();
    }
}

module Shear( x, y)
{
    multmatrix(m =  [
        [ 1, 0, sin(x), 0],
        [ 0, 1, sin(y), 0],
        [ 0, 0, 1, 0]
                ])
              children();
}

module MakeAll()
{
    echo( str( "\n\n\n", COPYRIGHT_INFO, "\n\n\tVersion ", VERSION, "\n\n" ));

    if ( __is_element_isolated_for_print() )
    {
        element = __value( data, g_isolated_print_box );

        if ( __type( element ) == DIVIDERS )
        {
            MakeDividers( element );
        }
        else
        {
            MakeBox( element );
        }          
    }
    else
    {
        for( i = [ 0: __num_elements() - 1 ] )
        {
            element = __element( i );

            element_position = ( g_b_vis_actual && __box_vis_position( element ) != [] ) ? __box_vis_position( element ) : [ __element_position_x( i ), 0, 0 ];
            element_rotation = ( g_b_vis_actual && __box_vis_rotation( element ) != undef ) ? __box_vis_rotation( element ) : 0;
            
            translate( element_position )
                RotateAndMoveBackToOrigin( element_rotation, __element_dimensions( i ) )
                {
                    if ( __is_element_enabled( element ) )
                    {
                        Colorize()
                        {
                           if ( __type( element ) == DIVIDERS )
                            {
                                MakeDividers( element );
                            }
                            else
                            {
                                MakeBox( element );
                            }
                        }
                    }
                }
        }
    }

}

module MakeDividers( div )
{
    height = __div_frame_size( div )[k_y];
    width = __div_frame_size( div )[k_x];
    depth = __div_thickness( div );

    tab_width = __div_tab_size( div )[k_x];
    tab_height = __div_tab_size( div )[k_y];
    tab_radius = __div_tab_radius( div );

    tab_text = __div_tab_text( div );

    font_size = __div_tab_text_size( div );
    font = __div_tab_text_font( div );
    font_spacing = __div_tab_text_spacing( div );
    number_of_letters_before_scale_to_fit = __div_tab_text_char_threshold( div );;

    divider_bottom = __div_frame_bottom( div );
    divider_top = __div_frame_bottom( div );
    divider_column = __div_frame_column( div );
    divider_corner_radius = __div_frame_radius( div );
    num_columns = __div_frame_num_columns( div );

    number_of_tabs_per_row = __div_tab_cycle( div );

    space_between_tabs = (width - tab_width ) / ( number_of_tabs_per_row - 1 );

    for (idx = [ 0 : len( tab_text ) - 1 ] ) 
    {
        tab_idx = idx % number_of_tabs_per_row;
        tab_offset = space_between_tabs * tab_idx;

        y_offset = idx * ( height + tab_height + DISTANCE_BETWEEN_PARTS );


        translate( [ 0, y_offset, 0])
            MakeDivider(title = tab_text[idx], tab_offset = tab_offset );
    }

    module MakeDivider( title, tab_offset  )
    {

        column_height = height - tab_height/2;

        gap_size = ( width - ( ( 2 + num_columns ) * divider_column ) ) / ( num_columns + 1 );

        difference()
        {
            MakeRoundedCube( [ width, height, depth ], 4);

            if ( num_columns != -1 )
            for (c = [ 0 : num_columns ] ) 
            {
                translate( [ divider_column + (divider_column + gap_size) * c, divider_bottom, 0])
                    MakeRoundedCube( [ gap_size, height - divider_bottom - divider_top, depth ], 4);
            }

        }

        // TAB
        difference()
        {
            height_overlap = tab_radius;
            title_pos = [ tab_offset, height - height_overlap, 0];

            // tab shape
            translate( title_pos )
            {
                MakeRoundedCube( [ tab_width, tab_height + height_overlap, depth], 4 ); 
            }

            // words
            text_pos = title_pos + [ tab_width/2, font_size * 2, 0 ];

            text_width = len(title) > number_of_letters_before_scale_to_fit ? tab_width * 0.8 : 0;

            translate( text_pos)
                resize([ text_width,0, 0 ], auto=[ true, true, false])
                    linear_extrude( depth )
                        text(text = title, 
                            font = font, 
                            size = font_size, 
                            valign = "top",
                            halign = "center", 
                            spacing = font_spacing,
                            $fn=1);
        }

        
    }
}

module MakeBox( box )
{
    m_box_size = __element_dimensions( box );

    m_num_components =  len( box );

    m_box_label = __value( box, LABEL, default = "");
    m_lid_has_labels = m_box_label != "";

    m_box_is_spacer = __type( box )  == SPACER;
    m_box_has_lid = !__value( box, BOX_NO_LID_B, default = false );

    m_lid = __value( box, BOX_LID, default = [] );

    function __notch_length( D ) = m_box_size[ D ] / 5.0;
    function __lid_notch_depth() = m_wall_thickness / 2 + g_tolerance;


    function __lid_external_size( D )= D == k_z ? m_lid_thickness + m_lid_height : 
                                                m_box_size[ D ];

    function __lid_internal_size( D )= D == k_z ? __lid_external_size( k_z ) - m_lid_thickness : 
                                                __lid_external_size( D ) - m_wall_thickness + ( g_tolerance * 2);

    function __has_solid_lid() = m_lid_solid || g_b_vis_actual;


    m_box_has_thin_lid = __value( m_lid, LID_THIN_B, default = false );

    m_lid_thickness = ( m_box_has_thin_lid ? 0.6 : g_lid_thickness ) - g_tolerance;

    m_lid_notches = __value( m_lid, LID_NOTCHES_B, default = true );
    m_lid_fit_under = __value( m_lid, LID_FIT_UNDER_B, default = true );
    m_lid_solid = __value( m_lid, LID_SOLID_B, default = false );

    m_lid_height = __value( m_lid, LID_HEIGHT, default = 5.0 );
    m_lid_cutout_sides = __value( m_lid, LID_CUTOUT_SIDES_4B, default = [f,f,f,f]);
    m_lid_is_inverted = __value( m_lid, LID_LABELS_INVERT_B, default = false );
    m_lid_label_depth = __value( m_lid, LID_SOLID_LABELS_DEPTH, default = m_lid_thickness / 2 );

    m_lid_label_bg_thickness = __value( m_lid, LID_LABELS_BG_THICKNESS, default = 2.0 );
    m_lid_label_border_thickness = __value( m_lid, LID_LABELS_BORDER_THICKNESS, default = 0.3 );

    m_lid_pattern_n1 = __value( m_lid, LID_PATTERN_N1, default = 6 );
    m_lid_pattern_n2 = __value( m_lid, LID_PATTERN_N2, default = 6 );
    m_lid_pattern_angle = __value( m_lid, LID_PATTERN_ANGLE, default = 30 );
    m_lid_pattern_row_offset = __value( m_lid, LID_PATTERN_ROW_OFFSET, default = 50 );
    m_lid_pattern_col_offset = __value( m_lid, LID_PATTERN_COL_OFFSET, default = 100 );
    m_lid_pattern_thickness = __value( m_lid, LID_PATTERN_THICKNESS, default = 0.5 );

    m_lid_pattern_radius = __value( m_lid, LID_PATTERN_RADIUS, default = 4.0 );


    // FIXME
    m_box_wall_thickness = __value( box, "wall_thickness", default = g_wall_thickness ); // needs work to change if no lid

    m_wall_thickness = m_box_wall_thickness;


    m_wall_underside_lid_storage_depth = 7;

    m_box_inner_position_min = [ m_wall_thickness, m_wall_thickness, m_wall_thickness ];
    m_box_inner_position_max = m_box_size - m_box_inner_position_min;

    if ( m_box_is_spacer )
    {
        MakeLayer( layer = "layer_spacer" );
    }  
    else
    {
        if( g_b_print_lid  && m_box_has_lid )    
        {
            MakeLayer( layer = "layer_lid");
        }

        if ( g_b_print_box )
        {
            difference()
            {

                // carve out the compartments from the box
                difference()
                {
                    MakeLayer( layer = "outerbox" );


                    // create a negative of the component
                    for( i = [ 0: m_num_components - 1 ] )
                    {
                        if ( box[ i ][ k_key ] == BOX_COMPONENT )
                        {
                            component = box[ i ][ k_value ];
                            union()
                            {
                                difference()
                                {
                                    MakeLayer( component , layer = "component_subtractions");
                                    MakeLayer( component, layer = "component_additions" );     
                                }
                                MakeLayer( component, layer = "final_component_subtractions" );
                            }
                        }
                    }
                }
                // lid carve outs
                MakeLayer( layer = "lid_substractions" );
            }
            
        }
    }

    module MakeLayer( component, layer = "" )
    {
        m_is_outerbox = layer == "outerbox";
        m_is_lid = layer == "layer_lid";
        m_is_spacer = layer == "layer_spacer";
        m_is_lid_subtractions = layer == "lid_substractions";

        // we don't use position for the box or the lid. Only for components.
        m_ignore_position = m_is_outerbox || m_is_lid || m_is_spacer || m_is_lid_subtractions;

        m_is_component_subtractions = layer == "component_subtractions";
        m_is_component_additions = layer == "component_additions";
        m_is_final_component_subtractions = layer == "final_component_subtractions";

        function __compartment_size( D ) = __value( component, CMP_COMPARTMENT_SIZE_XYZ, default = [10.0, 10.0, 10.0] )[ D ];
        function __compartments_num( D ) = __value( component, CMP_NUM_COMPARTMENTS_XY, default = [1,1] )[ D ];

        m_component_label = __value( component, LABEL, default = [] );

        function __component_rotation() = __value( component, ROTATION, default = 0 );
        function __is_component_enabled() = __value( component, ENABLED_B, default = true);

        /////////

        function __c_m_s( side ) = __value( component, CMP_MARGIN_4B, default = [f,f,f,f] )[ side ];
        function __component_has_margin( D ) = D == k_x ?
                [ __c_m_s( k_left ), __c_m_s( k_right ) ] :
                [ __c_m_s( k_front ), __c_m_s( k_back )];

        function __component_margin( D ) = [ __component_has_margin( D )[0] ? __component_padding( D ) : 0,
                                            __component_has_margin( D )[1] ? __component_padding( D ) : 0];

        function __component_cutout_side( side ) = __value( component, CMP_CUTOUT_SIDES_4B, default = [f, f, f, f] )[ side ];
//        function __component_cutout_corner( corner ) = __value( component, CMP_CUTOUT_CORNERS_4B, default = [f, f, f, f] )[ corner ];

        function __component_has_exactly_one_cutout() = 
            (__component_cutout_side( k_front )?1:0) +
            (__component_cutout_side( k_back )?1:0) +
            (__component_cutout_side( k_left )?1:0) +
            (__component_cutout_side( k_right )?1:0) == 1;



        function __component_padding( D ) = __value( component, CMP_PADDING_XY, default = [1.0, 1.0] )[ D ];
        function __component_padding_height_adjust( D ) = __value( component, CMP_PADDING_HEIGHT_ADJUST_XY, default = [0.0, 0.0] )[ D ];
        function __component_shape() = __value( component, CMP_SHAPE, default = SQUARE );
        function __component_shape_rotated_90() = __value( component, CMP_SHAPE_ROTATED_B, default = false );
        function __component_shape_vertical() = __value( component, CMP_SHAPE_VERTICAL_B, default = false );
        function __component_is_hex() = __component_shape() == HEX;
        function __component_is_hex2() = __component_shape() == HEX2;
        function __component_is_oct() = __component_shape() == OCT;
        function __component_is_oct2() = __component_shape() == OCT2;        
        function __component_is_round() = __component_shape() == ROUND;
        function __component_is_square() = __component_shape() == SQUARE;
        function __component_is_fillet() = __component_shape() == FILLET;
        function __component_fillet_radius() = __value( component, CMP_FILLET_RADIUS, default = min( __compartment_size( k_z ), 10) );

        function __component_shear( D ) = __value( component, CMP_SHEAR, default = [0.0, 0.0] )[ D ];

        function __req_label() = m_component_label != "";

// end delete me
        ///////////
    
        function __partition_height_scale( D ) = D == __Y2() ? __req_lower_partitions() ? 0.5 : 1.00 : 1.00;

        // Amount of curvature represented as a percentage of the __wall height.
        m_curve_height_scale = 0.50;

        m_b_corner_notch = true;

        m_notch_height = 3.0;

        // DERIVED VARIABLES

        ///////// __component_position helpers

        function __p_i_c( D) = __c_p_raw()[ D ] == CENTER;
        function __p_i_m( D) = __c_p_raw()[ D ] == MAX;
        function __c_p_c( D ) = ( m_box_size[ D ] - __component_size( D )) / 2;
        function __c_p_max( D ) = m_box_size[ D ] - m_wall_thickness - __component_size( D );

        /////////

        function __c_p_raw() = __value( component, POSITION_XY, default = [ CENTER, CENTER ]);
        function __component_position( D ) = __p_i_c( D ) ? __c_p_c( D ): 
                                                __p_i_m( D ) ? __c_p_max( D ): 
                                                    __c_p_raw()[ D ] + m_wall_thickness;

        function __component_position_max( D ) = __component_position( D ) + __component_size( D );

        function __compartment_smallest_dimension() = ( __compartment_size( k_x ) < __compartment_size( k_y ) ) ? __compartment_size( k_x ) : __compartment_size( k_y );

        function __partitions_num_no_margins( D ) = __compartments_num( D ) - 1;
        function __partitions_num( D )= __partitions_num_no_margins( D ) + ( __component_has_margin( D )[0] ? 1 : 0 ) + ( __component_has_margin( D )[1] ? 1 : 0 );

        // calculated __element local dimensions
        function __component_size( D )= ( D == k_z ) ? __compartment_size( k_z ) : 
                                                ( __compartment_size( D )* __compartments_num( D )) + ( __partitions_num( D )* __component_padding( D ));

        function __partition_height( D ) = __component_size( k_z ) + __component_padding_height_adjust( D );
        function __smallest_partition_height() = min( __partition_height( k_x ), __partition_height( k_y ) );


        module ContainWithinBox()
        {
            b_needs_trimming = false;//m_is_component_additions;

            if ( b_needs_trimming &&
            ( 
                __component_position( k_x ) < m_box_inner_position_min[ k_x ]
                || __component_position( k_y ) < m_box_inner_position_min[ k_y ]
                || __component_position( k_x ) + __component_size( k_x )  > m_box_inner_position_max[ k_x ]
                || __component_position( k_y ) + __component_size( k_y )  > m_box_inner_position_max[ k_y ]
            ))
            {
                echo( "<br><font color='red'>WARNING: Components in RED do not fit in box. If this is not intentional then adjustments are required or pieces won't fit.</font><br>");

                color([1,0,0])
                    children();    
            }
            else
            {
                children();  
            }
        }

/////////////////////////////////////////
/////////////////////////////////////////


    module __ColorComponent()
    {
        r = !g_b_colorize ? 0.7 : pow( sin( pow( __component_position(k_x),5) ), 0.5);
        g = !g_b_colorize ? 0.8 :pow( sin( pow( __component_position(k_y), 5) ), 0.3);
        b = !g_b_colorize ? 0.5 :pow( cos( pow( __component_size(k_z), 5) ), 0.5);


        color( [r, g, b] )
            children();
    }

/////////////////////////////////////////

        if ( __is_component_enabled() )
        {
            if ( m_ignore_position )
            {
                InnerLayer();
            }
            else
            { 
                ContainWithinBox()
                    RotateAboutPoint( __component_rotation(), [0,0,1], [__component_position( k_x ) + __component_size( k_x )/2, __component_position( k_y )+ __component_size( k_y )/2, 0] ) 
                        translate( [ __component_position( k_x ), __component_position( k_y ), m_box_size[ k_z ] - __compartment_size( k_z ) ] )
                            Shear( __component_shear( k_x ), __component_shear( k_y ) )
                                InnerLayer();   
            }
        }

        module MakeLidNotch( height = 0, depth = 0, offset = 0 )
        {
            translate( [ offset, offset, 0 ] )
            {
                cube( [  m_box_size[ k_x ] - ( 2 * offset ),
                        __lid_notch_depth() + depth, 
                        m_lid_height + height ] );   

                cube( [  __lid_notch_depth() + depth,
                        m_box_size[ k_y ] - ( 2 * offset ),
                        m_lid_height + height ] ); 
            }
        }

        module MakeLidNotches( height = 0, depth = 0, offset = 0 )
        {
                MakeLidNotch( height = height, depth = depth, offset = offset );

                center = [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0];

                MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                    MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                        MakeLidNotch( height = height, depth = depth, offset = offset );

        }

        module InnerLayer()
        {
            if ( m_is_spacer )
            {
                difference()
                {
                    cube( [ m_box_size[ k_x ], m_box_size[ k_y ], m_box_size[ k_z ] ] );

                    translate( [ m_wall_thickness, m_wall_thickness, 0 ])
                        cube( [ m_box_size[ k_x ] - ( 2 * m_wall_thickness ), m_box_size[ k_y ] - ( 2 * m_wall_thickness ), m_box_size[ k_z ] ] );
                }
            }
            else if ( m_is_outerbox )
            {
                // 'outerbox' is the insert. It may contain one or more 'components' that each
                // define a repeated compartment type.
                //
                cube([  m_box_size[ k_x ], 
                        m_box_size[ k_y ], 
                        m_box_size[ k_z ]]);
            }
            else if ( m_is_lid )
            {
                MakeLid();
            }
            else if ( m_is_component_subtractions ) 
            {
                // 'carve-outs' are the big shapes of the 'components.' Each is then subdivided
                // by adding partitions.

                __ColorComponent()
                {
                    cube([  __component_size( k_x ), 
                            __component_size( k_y ), 
                            __component_size( k_z )]);
                }
            }
            else if ( m_is_component_additions )
            {
                __ColorComponent()
                {
                    MakePartitions();

                    InEachCompartment()
                    {
                        if ( !__component_is_square() && !__component_is_fillet() )
                        {
                            MakeCompartmentShape( "additive" );
                        }

                        if ( __component_is_fillet())
                        {
                            AddFillets();
                        }
                    }
                }
            }
            else if ( m_is_final_component_subtractions )
            {
                // Some shapes, such as the finger cutouts for card compartments
                // need to be done at the end because they substract from the 
                // entire box.

                // finger cutouts
                
                InEachCompartment( )
                {
                    for ( side = [ k_front:k_right ])
                        if ( __component_cutout_side( side ))
                            MakeFingerCutout( side );

                    if ( !__component_is_square() && !__component_is_fillet() )
                        __ColorComponent()
                            MakeCompartmentShape( "subtractive");
                }

                if ( __req_label() && !g_b_no_labels_actual)
                {
                    color([0,0,1])LabelEachCompartment();
                }
            }
            else if ( m_is_lid_subtractions && m_box_has_lid )
            {

                notch_pos_z =  m_box_size[ k_z ] - m_lid_height ;
                
                translate( [ 0,0, notch_pos_z ] )
                    MakeLidNotches();

                // outer, shorter wall
                if ( m_lid_fit_under )
                {
                    // we need to carve out angles so we won't need supports.
                    difference()
                    {
                        vertical_clearance = 1.0 + g_tolerance;

                        MakeLidNotches( height = vertical_clearance, depth = 0 );

                        hull()
                        {
                            translate( [ 0, 0, m_lid_height + vertical_clearance] )
                                MakeLidNotches();

                            translate( [ 0, 0, m_lid_height - 1 + vertical_clearance] )
                                MakeLidNotches( offset = __lid_notch_depth() );

                        }
                    }

                }

                notch_pos_z_corner = notch_pos_z - m_notch_height ;

                if ( m_lid_notches )
                    translate([ 0, 0, notch_pos_z_corner]) 
                        MakeLidCornerNotches();

                detent_pos_z_corner = m_box_size[ k_z ] - m_lid_height/2;

                translate([ 0, 0, detent_pos_z_corner]) 
                    MakeDetents( type = "box" );
            }
        }



////////PATTERNS

        module Tri( R = 1, t = 0.2 )
        {
            n = 3;
            a = 2 * ( PI / n) * 180 / PI;
 
            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                    ],
                
                    [
                        [0,1,2],[3,4,5]
                    ]
                );     
        };   

        module Quad( R = 1, t = 0.2 )
        {
            n = 4;
            a = 2 * ( PI / n) * 180 / PI;
 
            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],
                        [ R * cos(3 * a), R * sin(3 * a) ],

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                        [ ( R - t ) * cos(3 * a), ( R - t ) * sin(3 * a) ],
                    ],
                
                    [
                        [0,1,2,3],[4,5,6,7]
                    ]
                );     
        };   

        module Pent( R = 1, t = 0.2 )
        {
            n = 5;
            a = 2 * ( PI / n) * 180 / PI;
 
            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],
                        [ R * cos(3 * a), R * sin(3 * a) ],
                        [ R * cos(4 * a), R * sin(4 * a) ],

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                        [ ( R - t ) * cos(3 * a), ( R - t ) * sin(3 * a) ],
                        [ ( R - t ) * cos(4 * a), ( R - t ) * sin(4 * a) ],
                    ],
                
                    [
                        [0,1,2,3,4],[5,6,7,8,9]
                    ]
                );     
        };   

        module Hex( R = 1, t = 0.2 )
        {
            n = 6;
            a = 2 * ( PI / n) * 180 / PI;

            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],
                        [ R * cos(3 * a), R * sin(3 * a) ],
                        [ R * cos(4 * a), R * sin(4 * a) ],
                        [ R * cos(5 * a), R * sin(5 * a) ],

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                        [ ( R - t ) * cos(3 * a), ( R - t ) * sin(3 * a) ],
                        [ ( R - t ) * cos(4 * a), ( R - t ) * sin(4 * a) ],
                        [ ( R - t ) * cos(5 * a), ( R - t ) * sin(5 * a) ]
                    ],
                
                    [
                        [0,1,2,3,4,5],[6,7,8,9,10,11]
                    ]
                );
            
                    
        };     

        module Sept( R = 1, t = 0.2 )
        {
            n = 7;
            a = 2 * ( PI / n) * 180 / PI;
 
            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],
                        [ R * cos(3 * a), R * sin(3 * a) ],
                        [ R * cos(4 * a), R * sin(4 * a) ],
                        [ R * cos(5 * a), R * sin(5 * a) ],
                        [ R * cos(6 * a), R * sin(6 * a) ],  

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                        [ ( R - t ) * cos(3 * a), ( R - t ) * sin(3 * a) ],
                        [ ( R - t ) * cos(4 * a), ( R - t ) * sin(4 * a) ],
                        [ ( R - t ) * cos(5 * a), ( R - t ) * sin(5 * a) ],
                        [ ( R - t ) * cos(6 * a), ( R - t ) * sin(6 * a) ],
                    ],
                
                    [
                        [0,1,2,3,4,5,6],[7,8,9,10,11,12,13]
                    ]
                );   
        };    

        module Oct( R = 1, t = 0.2 )
        {
            n = 8;
            a = 2 * ( PI / n) * 180 / PI;
 
            polygon([
                        [ R * cos(0 * a), R * sin(0 * a) ],
                        [ R * cos(1 * a), R * sin(1 * a) ],
                        [ R * cos(2 * a), R * sin(2 * a) ],
                        [ R * cos(3 * a), R * sin(3 * a) ],
                        [ R * cos(4 * a), R * sin(4 * a) ],
                        [ R * cos(5 * a), R * sin(5 * a) ],
                        [ R * cos(6 * a), R * sin(6 * a) ],  
                        [ R * cos(7 * a), R * sin(7 * a) ],                                                

                        [ ( R - t ) * cos(0 * a), ( R - t ) * sin(0 * a) ],
                        [ ( R - t ) * cos(1 * a), ( R - t ) * sin(1 * a) ],
                        [ ( R - t ) * cos(2 * a), ( R - t ) * sin(2 * a) ],
                        [ ( R - t ) * cos(3 * a), ( R - t ) * sin(3 * a) ],
                        [ ( R - t ) * cos(4 * a), ( R - t ) * sin(4 * a) ],
                        [ ( R - t ) * cos(5 * a), ( R - t ) * sin(5 * a) ],
                        [ ( R - t ) * cos(6 * a), ( R - t ) * sin(6 * a) ],
                        [ ( R - t ) * cos(7 * a), ( R - t ) * sin(7 * a) ],                                                                        
                    ],
                
                    [
                        [0,1,2,3,4,5,6,7],[8,9,10,11,12,13,14,15]
                    ]
                );   
        };    


        function AddPoint( R, t, n, i = 0 ) = i == n ? [] : 
            concat( [[ ( R - t ) * cos( i * 2 * ( PI / n) * 180 / PI ), ( R - t ) * sin( i * 2 * ( PI / n) * 180 / PI ) ]],
                AddPoint( R, t, n, i + 1 ) );

        function AddOrderIndex( b, e, i = 0 ) = i == e ? [] :
            concat ( i, AddOrderIndex( b, e, i + 1) );


        module Make2dShape( R, t, n1, n2 )
        {
 
            if ( n1 == 3 && n2 == 3 )
                Tri( R, t );
            else if ( n1 == 4 && n2 == 4 )
                Quad( R, t );                
            else if ( n1 == 5 && n2 == 5 )
                Pent( R, t );
            else if ( n1 == 6 && n1 == 6 )
                Hex( R, t );
            else if ( n1 == 7 && n2 == 7 )
                Sept( R, t );                
            else if ( n1 == 8 && n2 == 8 )
                Oct( R, t );
            else
            {
                base = AddPoint( R, 0, n1 );
                inset = AddPoint( R, t, n2 );

                combined = concat( base, inset );

                order = concat( [ AddOrderIndex( 0, n1)], [AddOrderIndex( n1, n1 + n2, n1 )] );

                polygon( combined, order );     
            }

        };        

        module Make2DPattern( x = 200, y = 200, R = 1, t = 0.5 )
        {
            r = cos( m_lid_pattern_angle ) * R;

            dx = r * ( 1 + m_lid_pattern_col_offset / 100 ) - t;
            dy = R * ( 1 + ( m_lid_pattern_row_offset / 100 ) ) - t;

            x_count = x / dx;
            y_count = y / dy;

            for( j = [ -1: y_count + 1 ] )
                translate( [ ( j % 2 ) * dx/2 + t, 0, 0 ] )
                    for( i = [ -1: x_count + 1 ] )
                        translate( [ i * dx, j * dy, 0 ] )
                            rotate( a = m_lid_pattern_angle, v=[ 0, 0, 1 ] )
                            {
                                Make2dShape( R, t, m_lid_pattern_n1, m_lid_pattern_n2 );
                            }
        }

        module MakeStripedGrid( x = 200, y = 200, w = 1, dx = 0, dy = 0, depth_ratio = 0.5 )
        {

            thickness = max( 0.6, m_lid_thickness * depth_ratio );

            x_count = x / ( w + dx );
            y_count = y / ( w + dy );

            if ( dx > 0 )
            {
                for( j = [ 0: x_count ] )
                {
                    translate( [ j * ( w + dx ), 0, m_lid_thickness - thickness ] )
                        cube( [ w, y, thickness]);
                }
            }

            if ( dy > 0 )
            {
                for( j = [ 0: y_count ] )
                {
                    translate( [ 0, j * ( w + dy ), m_lid_thickness - thickness  ] )
                        cube( [ x, w, thickness ]);
                }
            }
        }


///////////////////////

        module MakeLid() 
        {
            
            module MoveToLidInterior()
            {
                translate([ ( m_wall_thickness )/2 - g_tolerance, ( m_wall_thickness )/2 - g_tolerance, 0]) 
                    children();
            }

            module MakeAllLidTexts( offset = 0, thickness = m_lid_thickness )
            {
                for( i = [ 0 : len( box ) - 1])
                {
                    if ( box[ i ][ k_key ] == LABEL )
                    {
                        label = box[ i ][ k_value ];

                        MakeLidText( label, offset = offset, thickness = thickness );
                    }
                }
            }

            module Make2dLidText( label, width, offset )
            {
                resize([ width,0,0], auto=true )
                    offset( r = offset )
                        text(text = str( __label_text( label ) ), 
                            font = __label_font( label ),  
                            size = __label_size( label ), 
                            spacing = __label_spacing( label ),
                            valign = CENTER, 
                            halign = CENTER, 
                            $fn=100);
            }

            module MakeLidText( label, offset = 0, thickness = m_lid_thickness )
            {
                xpos = __lid_external_size( k_x )/2 + __label_offset( label )[k_x];
                ypos = __lid_external_size( k_y )/2 + __label_offset( label )[k_y];

                auto_width = __label_auto_width( label, __lid_external_size( k_x ), __lid_external_size( k_y ) );
                width = auto_width != 0 ? min( 100, auto_width ) + offset : 0;

                linear_extrude( thickness )
                    translate( [ xpos, ypos, 0 ] )
                        MirrorAboutPoint( [ 1,0,0],[0,0, thickness / 2])
                            RotateAboutPoint( __label_rotation( label ), [0,0,1], [0,0,0] )
                                Make2dLidText( label, width, offset );
            }


            module MakeAllLidTextFrames( offset = 0, thickness = m_lid_thickness )
            {
                for( i = [ 0 : len( box ) - 1])
                {
                    if ( box[ i ][ k_key ] == LABEL )
                    {
                        label = box[ i ][ k_value ];

                        MakeLidTextFrame( label, offset = offset, thickness = thickness );
                    }
                }
            }

            module MakeLidTextFrame( label, offset = 0, thickness = m_lid_thickness )
            {
                xpos = __lid_external_size( k_x )/2 + __label_offset( label )[k_x];
                ypos = __lid_external_size( k_y )/2 + __label_offset( label )[k_y];

                auto_width = __label_auto_width( label, __lid_external_size( k_x ), __lid_external_size( k_y ) );
                width = auto_width != 0 ? min( 100, auto_width ) + offset : 0;

                linear_extrude( thickness )
                    translate( [ xpos, ypos, 0 ] )
                        MirrorAboutPoint( [ 1,0,0],[0,0, thickness / 2])
                            RotateAboutPoint( __label_rotation( label ), [0,0,1], [0,0,0] )
                                offset( r = offset )
                                    intersection()
                                    {
                                        hull()
                                        {
                                            translate( [ -200,0,0])
                                                Make2dLidText( label, width, offset );

                                            translate( [ 200,0,0])
                                                Make2dLidText( label, width, offset );
                                        }
                                        hull()
                                        {
                                            translate( [ -0,-200,0])
                                                Make2dLidText( label, width, offset );

                                            translate( [ 0,200,0])
                                                Make2dLidText( label, width, offset );
                                        }         
                                    }    
                                 
            }

            lid_print_position = [0, m_box_size[ k_y ] + DISTANCE_BETWEEN_PARTS, 0 ];
            lid_vis_position = [ 0, 0, m_box_size[ k_z ] + m_lid_thickness ];
          
            translate( g_b_vis_actual ? lid_vis_position : lid_print_position ) 
            {
                difference()
                {
                    RotateAboutPoint( g_b_vis_actual ? 180 : 0, [0, 1, 0], [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, 0] )
                    {

                        // clip to lid extents
                        intersection()
                        {
                            cube([  __lid_external_size( k_x ), __lid_external_size( k_y ),  __lid_external_size( k_z )]);

                            //detents
                            detent_pos_z_corner = __lid_internal_size( k_z) / 2 + m_lid_thickness;

                            translate([ 0, 0, detent_pos_z_corner]) 
                                MakeDetents( type = "lid" );
                        }

                        // lid edge
                        difference() 
                        {
                            // main __element
                            cube([__lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )]);
                            
                            MoveToLidInterior()
                                cube([  __lid_internal_size( k_x ), __lid_internal_size( k_y ),  __lid_external_size( k_z )]);
                        }

                        // clip to lid extents
                        intersection()
                        {
                            cube([  __lid_external_size( k_x ), __lid_external_size( k_y ),  __lid_external_size( k_z )]);

                            union()
                            {
                                // honeycomb
                                difference()
                                {

                                    linear_extrude( m_lid_thickness )
                                    {
                                        R = m_lid_pattern_radius;
                                        t = m_lid_pattern_thickness;

                                        if ( !__has_solid_lid() )
                                            Make2DPattern( x = __lid_external_size( k_x ), y = __lid_external_size( k_y ), R = R, t = t );
                                        else
                                            square( [ __lid_external_size( k_x ), __lid_external_size( k_y ) ] );
                                    }

                                    // stencil out the text
                                    if ( m_lid_label_bg_thickness > 0 || m_lid_is_inverted  )
                                        if ( !__has_solid_lid() )
                                        {
                                            MakeAllLidTextFrames( offset = m_lid_label_bg_thickness );
                                        }
                                        else
                                        {
                                            MakeAllLidTexts( thickness = m_lid_label_depth );
                                        }                          
                                }

                                if ( m_lid_has_labels )
                                {
                                    if ( !__has_solid_lid() )
                                    {
                                        // grid
                                        if ( !m_lid_is_inverted )
                                        {
                                            // edge
                                            if ( m_lid_label_bg_thickness > 0 )
                                            difference()
                                            {
                                                MakeAllLidTextFrames( offset = m_lid_label_bg_thickness);
                                                MakeAllLidTextFrames( offset = m_lid_label_bg_thickness - m_lid_label_border_thickness );
                                            }

                                            // pattern
                                            if ( m_lid_label_bg_thickness > 0 )
                                            intersection()
                                            {
                                                theta = 45;

                                                x = __lid_external_size( k_x );
                                                y = __lid_external_size( k_y );

                                                x2 = y*sin(theta) + x*cos(theta);
                                                y2 = y*cos(theta) + x*sin(theta);                                     

                                                translate( [x/2-x2/2, y/2-y2/2,0])
                                                    RotateAboutPoint( theta, [0,0,1], [x2/2,y2/2,0] )
                                                        MakeStripedGrid( x = x2, y = y2, w = 0.5, dx = 1, dy = 0, depth_ratio = 0.5 );

                                                MakeAllLidTextFrames( offset = m_lid_label_bg_thickness );
                                            }

                                            // positive text
                                            MakeAllLidTexts( ); 
                                        }
                                        else
                                        {
                                            // negative text
                                            difference()
                                            {
                                                MakeAllLidTextFrames( offset = m_lid_label_bg_thickness );
                                                MakeAllLidTexts();
                                            }    
                                        } 
                                    }
                                }
                            }
                        }

                    } // end rotateAboutPoint
                    
                    for ( side = [ k_front:k_right ])
                    {
                        if ( m_lid_cutout_sides[ side ])
                            MakeFingerCutout( side );
                    }
                }
            }
        }

        module ForEachPartition( D, include_margins = true )
        {
            start = 0;
            end = ( include_margins ? __partitions_num( D ) : __partitions_num_no_margins( D ) ) - 1;

            if ( end >= start )
            {
                firstpos = ( __component_has_margin(D)[0] && include_margins ) ? 0 : __compartment_size( D );

                for ( a = [ start : end  ] )
                {
                    pos = firstpos + ( __compartment_size( D ) + __component_padding( D )) * a ;

                    translate( [ D == k_x ? pos : 0 ,  D == k_y ? pos : 0 , 0 ] )
                        children();
                }
            }
        }

        module ForEachCompartment( D )
        {
            start = 0;
            end = __compartments_num( D ) - 1;

            {
                for ( a = [ start: end  ] )
                {
                    dim1 = __component_margin( D )[0] + ( __component_padding( D ) + __compartment_size( D )) * a ;

                    translate( [ D == k_x ? dim1 : 0 ,  D == k_y ? dim1 : 0 , 0 ] )
                    children();
                }
            }
        }

        module InEachCompartment()
        {
            n_x = __compartments_num( k_x );
            n_y = __compartments_num( k_y );

            for ( x = [ 0: n_x - 1] )
            {
                x_pos = __component_margin( k_x )[0] + ( __compartment_size( k_x ) + __component_padding( k_x ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = __component_margin( k_y )[0] + ( ( __compartment_size( k_y ) ) + __component_padding( k_y ) ) * y;

                    translate( [ x_pos ,  y_pos , 0 ] )
                        children();
                }
            }            
        }

        module LabelEachCompartment()
        {
            n_x = __compartments_num( k_x );
            n_y = __compartments_num( k_y );

            for ( x = [ 0: n_x - 1] )
            {
                x_pos = __component_margin( k_x )[0] + ( __compartment_size( k_x ) + __component_padding( k_x ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = __component_margin( k_y )[0] + ( ( __compartment_size( k_y ) ) + __component_padding( k_y ) ) * y;

                    translate( [ x_pos ,  y_pos , 0 ] ) // to compartment origin
                        MakeLabel( x, y )
                            Helper_MakeLabel( x, y );
                }
            } 
        }

        module MakeFingerCutout( side )
        {

            function __cutout_z() = ( m_is_lid ? m_lid_height + m_lid_thickness : m_box_size[ k_z ] );
            function __padding( D ) = m_is_lid ? 0 : __component_padding( D );
            function __size( D ) = m_is_lid ? __lid_internal_size( D ) : __compartment_size( D );
            function __finger_cutouts_bottom() = m_is_lid ?__lid_external_size( k_z ) - __cutout_z() : __compartment_size( k_z ) - __cutout_z();

            inset_into_compartment_fraction = 1/3;

            // main and perpendicular dimensions
            main_d = ( side == k_back || side == k_front ) ? k_y : k_x; 
            perp_d = ( side == k_back || side == k_front ) ? k_x : k_y;

            // main and perpendicular size of hole
            //  main dimension intrudes into the compartment by some fraction ( e.g. 1/5 )
            main_size = __padding( main_d )/2  + __size( main_d ) * inset_into_compartment_fraction;

            //  perp dimension is a third of the width but no less than 1cm and no more than 3cm
            perp_size = max( 10, min( 30, __size( perp_d )/3 )); // 10mm <= y <= 30mm

            max_radius = 3;
            radius = min( main_size/2, perp_size/2, max_radius);

            pos = [
                // front
                [  
                    __size( k_x )/2  - perp_size/2,       
                    - __padding( k_y )/2 - g_wall_thickness,               
                    __finger_cutouts_bottom() 
                ], 
                // back
                [  
                    __size( k_x )/2  - perp_size/2,                     
                    __size( k_y ) * (1 - inset_into_compartment_fraction) + g_wall_thickness, 
                    __finger_cutouts_bottom() 
                ],
                // left
                [   
                    - __padding( k_x )/2 - g_wall_thickness, 
                    __size( k_y )/2  - perp_size/2, 
                    __finger_cutouts_bottom() 
                ],
                // right
                [   
                    __size( k_x ) * (1 - inset_into_compartment_fraction) + g_wall_thickness, 
                    __size( k_y )/2  - perp_size/2, 
                    __finger_cutouts_bottom()
                ], 
            ];

            size = [

                [ perp_size, main_size, __cutout_z() ], // front
                [ perp_size, main_size, __cutout_z() ], // back
                [ main_size , perp_size, __cutout_z() ], // left 
                [ main_size , perp_size, __cutout_z() ] // right
            ];

            shape = [
                //front
                [ !__component_cutout_side( k_back ),!__component_cutout_side( k_back ),t,t ],

                //back
                [ t,t,!__component_cutout_side( k_front ),!__component_cutout_side( k_front )],

                //left
                [ !__component_cutout_side( k_right ),t,!__component_cutout_side( k_right ),t ],

                //right
                [ t,!__component_cutout_side( k_left ),t,!__component_cutout_side( k_left )],
            ];

            translate( pos[ side ] )
                MakeRoundedCube( size[ side ], radius, shape[ side ]);

        }

        // this rounds out the bottoms regardless of the size of the compartment
        // and doesn't attempt to fit a specific shape.
       module AddFillets()
        {
            r = __component_fillet_radius();

            module _MakeFillet()
            {
                difference()
                {
                    cube_rotated = __component_shape_rotated_90() ? [ __compartment_size( k_x ), r, r ] : [ r, __compartment_size( k_y ), r ];                   
                    cube ( cube_rotated );

 
                    cylinder_translated = __component_shape_rotated_90() ? [ 0, r, r ] : [ r, __compartment_size( k_y ), r ];                    
                    translate( cylinder_translated )
                    {
                        cylinder_rotation = __component_shape_rotated_90() ? [ 0, 1, 0, ] : [ 1, 0, 0 ];

                        rotate( v=cylinder_rotation, a=90 )
                        {
                            h = __component_shape_rotated_90() ? __compartment_size( k_x ) : __compartment_size( k_y );
                            cylinder(h = h, r1 = r, r2 = r);  
                        } 
                    }
                }

            }

             _MakeFillet();

             mirrorv = __component_shape_rotated_90() ? [ 0,1,0] : [1,0,0];
             mirrorpt = __component_shape_rotated_90() ? [ 0, __compartment_size( k_y ) / 2, 0 ] : [ __compartment_size( k_x ) / 2, 0, 0 ];
            
            MirrorAboutPoint(mirrorv, mirrorpt)
            {
                _MakeFillet();   
            }        
        }

        module MakeVerticalShape( h, r, r1, r2, z_offset )
        {
            compartment_z_min = m_wall_thickness;
            compartment_internal_z = __compartment_size( k_z ) - compartment_z_min;

            cylinder_translation = [ r , __compartment_size(k_y)/2 , m_wall_thickness ];

            translate( cylinder_translation )
            {
                angle = __component_is_hex() ? 30 : __component_is_oct() ? 22.5 : 0;

                rotate( a=angle, v=[0, 0, 1] )
                    translate( [ 0,0, z_offset ])
                        cylinder(h, r1, r2, center = false );                      
            }
                
        }

        module MakeCompartmentShape( pass )
        {
            $fn = __component_is_hex() || __component_is_hex2() ? 6 : __component_is_oct() || __component_is_oct2() ? 8 : 100;

            if ( __component_shape_vertical() )
            {
                r = __compartment_smallest_dimension()/2;

                if ( pass == "additive" )
                {
                    difference()
                    {
                         cube ( [ __compartment_size( k_x ), __compartment_size( k_y ), __smallest_partition_height() ] );
                         MakeVerticalShape(h = __compartment_size( k_z ), r = r, r1 = r, r2 = r, z_offset = 0 );
                    }
                }
                else if ( __component_has_exactly_one_cutout() )
                {
                    underbase = m_box_size[ k_z ] - __compartment_size( k_z ) + m_wall_thickness;
                    
                    MakeVerticalShape(h = underbase, r = r, r1 = r/1.3, r2 = r/1.3, z_offset = -underbase );

                }
            }
            else if ( pass == "additive" ) 
            {

                difference()
                { 
                
                    cube ( [ __compartment_size( k_x ), __compartment_size( k_y ), __smallest_partition_height() ] );

                    dim1 = __component_shape_rotated_90() ? k_y : k_x;
                    dim2 = __component_shape_rotated_90() ? k_x : k_y;

                    r = __compartment_size( dim1 ) / 2 / cos( 30 / $fn );

                    union()
                    {
                        cylinder_translation = __component_shape_rotated_90() ?
                                                    [ 0, __compartment_size( k_y )/2 , r ] :
                                                    [ __compartment_size( dim1 )/2, __compartment_size( dim2 ) , r ];


                        translate( cylinder_translation )
                        {
                            RotateAboutPoint( a= __component_shape_rotated_90() ? 90 : 0, 
                            v=[0,0,1], 
                            pt=[ 0,0, 0] )
                            {
                                {
                                    // lay the hex down
                                    rotate( a= 90, v=[ 1,0,0])
                                    {
                                        // do we want hex point down?
                                        rotate( a=__component_is_hex2() ? 
                                                30 : __component_is_oct() ? 
                                                    22.5 : 0, 
                                                v=[ 0, 0, 1])
                                        {
                                            cylinder(h = __compartment_size( dim2 ), r1 = r, r2 = r );  
                                        }
                                    } 
                                }
                            }
                        }

                        // from midpoint--up. clear the rest of the compartment
                        translate( [ 0,0, r ])
                            cube ( [ __compartment_size( k_x ), __compartment_size( k_y ), m_box_size[ k_z ]] );
                    }

                }
            }
        }

        module Helper_MakeLabel( x = 0, y = 0 )
        {
            label_on_y = __label_placement_is_left( m_component_label ) || __label_placement_is_right( m_component_label );
            label_on_x = __label_placement_is_back( m_component_label ) || __label_placement_is_front( m_component_label );            
            label_is_center = __label_placement_is_center( m_component_label );

            label_on_side = __label_placement_is_wall( m_component_label );

            width = __label_auto_width( m_component_label, __compartment_size( k_x ), __compartment_size( k_y ) );

            // since we build from the bottom--up, we need to reverse the order in which we read the text rows
            text_y_reverse = __is_multitext( m_component_label ) ? len(__value( m_component_label, LBL_TEXT)) - y - 1: 0;

            // max_height = label_on_y ? __component_padding( k_x ) : 
            //             label_on_x ? __component_padding( k_y ) : 0;

            // max_width = label_on_y ? __component_padding( k_y ) : 
            //             label_on_x ? __component_padding( k_x ) : 0;

                rotate_vector = label_on_side ? [ 0,1,0] : [0,0,1];
                label_needs_to_be_180ed = __label_placement_is_front( m_component_label) && __label_placement_is_wall( m_component_label);

                RotateAboutPoint( label_needs_to_be_180ed ? 180 : 0, [0,0,1], [0,0,0] )
                    RotateAboutPoint( __label_rotation( m_component_label ), rotate_vector, [0,0,0] )
                        RotateAboutPoint( label_on_side ? 90:0, [1,0,0], [0,0,0] )
                            translate( [ __label_offset( m_component_label )[k_x], __label_offset( m_component_label )[k_y], 0])
                                resize( [ width, 0, 0], auto=true)
                                    translate([0,0,-__label_depth( m_component_label )]) 
                                        linear_extrude( height =  2 * __label_depth( m_component_label ) )
                                            text(text = str( __label_text( m_component_label, x, text_y_reverse) ), 
                                                font = __label_font( m_component_label ), 
                                                size = __label_size( m_component_label ), 
                                                spacing = __label_spacing( m_component_label ),
                                                valign = CENTER, 
                                                halign = CENTER, 
                                                $fn=1);
            }

        module MakeLabel( x = 0, y = 0 )
        {
            z_pos = 0;
            z_pos_vertical = __partition_height( k_y )- __label_size( m_component_label );

            if ( __label_placement_is_center( m_component_label) )
            {
                translate( [ __compartment_size(k_x)/2, __compartment_size(k_y)/2, z_pos] )
                    children();
            }
            else if ( __label_placement_is_front( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(k_x)/2, 0, z_pos_vertical ] )
                        children();
                else                
                    translate( [ __compartment_size(k_x)/2, -__component_padding( k_y )/4, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_back( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(k_x)/2, __compartment_size(k_y), z_pos_vertical ] )
                        children();
                else
                    translate( [ __compartment_size(k_x)/2, __compartment_size(k_y) + __component_padding( k_y )/4, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_left( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ 0, __compartment_size(k_y)/2, z_pos_vertical ] )
                        children();
                else
                    translate( [ - __component_padding(k_x)/4, __compartment_size(k_y)/2, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_right( m_component_label) )
            {            
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(k_x), __compartment_size(k_y)/2, z_pos_vertical ] )
                        children();
                else
                    translate( [ __compartment_size(k_x) + __component_padding(k_x)/4, __compartment_size(k_y)/2, __partition_height( k_y ) + z_pos] )
                        children();
            }
        }

        module MakePartitions()
        {
            ForEachPartition( k_x )   
            {
                MakePartition( axis = k_x );  
            }

            ForEachPartition( k_y )  
            {
                MakePartition( axis = k_y );  
            }
        }

        module MakePartition( axis )
        {
            if ( axis == k_x )
            {
                cube ( [ __component_padding( k_x ), __component_size( k_y ), __partition_height( k_x )  ] );
            }
            else if ( axis == k_y )
            {
                cube ( [ __component_size( k_x ), __component_padding( k_y ) , __partition_height( k_y ) ] );     
            }
        }

        module MakeLidCornerNotch()
        {
            {
                cube([ __notch_length( k_x ), __lid_notch_depth(), m_notch_height ]);
                cube([__lid_notch_depth(), __notch_length( k_y ), m_notch_height]);
            }
        }

        module MakeLidCornerNotches()
        {
            MakeLidCornerNotch();

            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeLidCornerNotch();
            }

            MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeLidCornerNotch();
            }

            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                {
                    MakeLidCornerNotch();    
                }
            }
        }

        module MakeDetents( type /*"lid" | "box"*/ )
        {
            module MakeDetent( type )
            {
                detent_radius = 1/3 * m_wall_thickness + ( type == "box" ? g_tolerance/2 : 0 ) ;

                sphere( r = detent_radius, $fn = 10 );           
            }

            module MakeOneSet( type )
            {
                translate( [m_box_size[ k_x ]/4, m_wall_thickness/2 - ( type == "lid" ? g_tolerance : 0), 0] )
                    MakeDetent( type );

                translate( [m_wall_thickness/2 - ( type == "lid" ? g_tolerance : 0), m_box_size[ k_y ]/4, 0] )
                    MakeDetent( type );
            }

            MakeOneSet( type );

            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeOneSet( type );
            }

            MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeOneSet( type );
            }

            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                {
                    MakeOneSet( type );    
                }
            }
        }
    }

}

module MakeRoundedCube( vec3, radius, vecRounded = [ t, t, t, t ] ){
 
    radii = 
    [
        vecRounded[ 0 ] ? radius : .001,
        vecRounded[ 1 ] ? radius : .001,
        vecRounded[ 2 ] ? radius : .001,
        vecRounded[ 3 ] ? radius : .001,
    ];

    pos = 
    [
        [ radii[0], radii[0], 0 ],
        [ vec3[k_x] - radii[1], radii[1], 0 ],
        [ radii[2], vec3[k_y] - radii[2], 0 ],
        [ vec3[k_x] - radii[3], vec3[k_y] - radii[3], 0 ]
    ] ;
 
    hull()
    {
        h = vec3[k_z];

        for ( idx = [ 0 : 3] ) 
        {
            // collapse the cylinder if we're approximating a point
            fn = radii[ idx ] >= 1 ? $fn: 4;

            translate( pos[ idx ])
                cylinder(r=radii[ idx ], h=h, $fn = fn); 
        }
    }
} 













