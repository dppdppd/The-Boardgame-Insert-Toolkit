
// Copyright 2020 MysteryDough https://www.thingiverse.com/MysteryDough/
//
// Released under the Creative Commons - Attribution - Non-Commercial - Share Alike License.
// https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

VERSION = "2.01";
COPYRIGHT_INFO = "\tThe Boardgame Insert Toolkit\n\thttps://www.thingiverse.com/thing:3405465\n\n\tCopyright 2020 MysteryDough\n\tCreative Commons - Attribution - Non-Commercial - Share Alike.\n\thttps://creativecommons.org/licenses/by-nc-sa/4.0/legalcode";

$fn=100;

// constants
KEY = 0;
VALUE = 1;

X = 0;
Y = 1;
Z = 2;

FRONT = 0;
BACK = 1;
LEFT = 2;
RIGHT = 3;

t = true;
f = false;


DISTANCE_BETWEEN_PARTS = 2;
////////////////////

// key-values helpers
function __index_of_key( table, key ) = search( [ key ], table )[ KEY ];
function __value( table, key, default = false ) = __index_of_key( table, key ) == [] ? default : table[ __index_of_key( table, key ) ][ VALUE ];

///////////////////////

// determines whether lids are output.
g_b_print_lid = 1;

// determines whether boxes are output.
g_b_print_box = 1; 

// Focus on one box
g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together. 
// Turn off for printing.
g_b_visualization = 0;

g_b_vis_actual = g_b_visualization && $preview;

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = 0;            

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

function __box( i ) = data[ i ][1];
function __num_boxes() = len( data );

function __is_box_isolated_for_print() = __index_of_key( data, g_isolated_print_box ) != [];
function __is_box_enabled( box ) = __value( box, "enabled", default = true);

function __box_dimensions( box ) = __value( box, "box_dimensions", default = undef );

function __box_position_x( i ) = __box( i - 1 ) == undef ? 0 : __is_box_enabled( __box( i - 1 ) ) ? __box_dimensions( __box( i - 1 ) )[ X ] + __box_position_x( i - 1 ) + DISTANCE_BETWEEN_PARTS : __box_position_x( i - 2 );

//vis
function __box_vis_data( box ) = __value( box, "visualization", default = "");
function __box_vis_position( box ) = __value( __box_vis_data( box ), "position" );
function __box_vis_rotation( box ) = __value( __box_vis_data( box ), "rotation" );

// is the text a string or a list of strings?
function __is_multitext( label ) = !is_string( __value( label, "text" ) ) && is_list(__value( label, "text" ));

function __label_text( label, r = 0, c = 0 ) = __is_multitext( label ) ?  __value( label, "text", default = "" )[c][r] : __value( label, "text", default = "" );
function __label_size_raw( label ) = __value( label , "font_size", default = "auto" );
function __label_size_is_auto( label ) = __label_size_raw( label ) == "auto";
function __label_size( label ) = __label_size_is_auto( label ) ? 10 : __label_size_raw( label);
function __label_rotation_raw( label ) = __value( label, "rotation", default = 0 ) % 360;
function __label_rotation( label ) = __label_rotation_raw( label ) + 
   ( __label_placement_is_left( label ) ? 90 : __label_placement_is_right( label ) ? -90 : __label_placement_is_front( label ) && __label_placement_is_wall( label ) ? 0 : 0 );
function __label_depth( label ) = __value( label, "depth", default = 0.2 );
function __label_placement_raw( label ) = __value( label, "placement", default = "center" );
function __label_placement_is_center( label ) = __label_placement_raw( label ) == "center";
function __label_placement_is_back( label ) = __label_placement_raw( label ) == "back" || __label_placement_raw( label ) == "back-wall";
function __label_placement_is_front( label ) = __label_placement_raw( label ) == "front" || __label_placement_raw( label ) == "front-wall";
function __label_placement_is_left( label ) = __label_placement_raw( label ) == "left" || __label_placement_raw( label ) == "left-wall";
function __label_placement_is_right( label ) = __label_placement_raw( label ) == "right" || __label_placement_raw( label ) == "right-wall";
function __label_placement_is_wall( label ) = 
    __label_placement_raw( label ) == "back-wall" ||
    __label_placement_raw( label ) == "front-wall" ||
    __label_placement_raw( label ) == "left-wall" ||
    __label_placement_raw( label ) == "right-wall" ;

function __label_offset( label ) = __value( label, "offset", default = [0,0] );
function __label_font( label ) = __value( label, "font", default = "Liberation Sans:style=Bold" );
function __label_scale_magic_factor( label ) = 1.2 + (1 * abs(tan( __label_rotation( label ) % 90 )) );
function __label_auto_width( label, x, y) = __label_size_is_auto( label ) ? 
            ( cos( __label_rotation( label ) ) * ( x/__label_scale_magic_factor( label ) )) + 
            ( sin( __label_rotation( label ) ) * ( y/__label_scale_magic_factor( label ) )) :
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

    if ( __is_box_isolated_for_print() )
    {
        MakeBox( __value( data, g_isolated_print_box ) );
    }
    else
    {
        for( i = [ 0: __num_boxes() - 1 ] )
        {
            box = __box( i );

            box_position = ( g_b_vis_actual && __box_vis_position( box ) != [] ) ? __box_vis_position( box ) : [ __box_position_x( i ), 0, 0 ];
            box_rotation = ( g_b_vis_actual && __box_vis_rotation( box ) != undef ) ? __box_vis_rotation( box ) : 0;
            
            translate( box_position )
                RotateAndMoveBackToOrigin( box_rotation, __box_dimensions( i ) )
                {
                    if ( __is_box_enabled( box ) )
                    {
                        Colorize()
                            MakeBox( box );
                    }
                }
        }
    }

}

module MakeBox( box )
{
    m_box_dimensions = __box_dimensions( box );

    m_components =  __value( box, "components" );

    m_num_components =  len( m_components );

    function __component( c ) = m_components[ c ][1];
    function __component_name( c ) = m_components[ c ][0];

    m_box_label = __value( box, "label", default = "");

    m_box_is_spacer = __value( box, "type") == "spacer";

    m_box_has_thin_lid = __value( box, "thin_lid", default = false );
    m_box_has_lid = __value( box, "lid", default = true );
    m_box_has_lid_notches = __value( box, "lid_notches", default = true );
    m_box_fit_lid_under = __value( box, "fit_lid_under", default = true );

    m_box_wall_thickness = __value( box, "wall_thickness", default = g_wall_thickness ); // needs work to change if no lid

    m_wall_thickness = m_box_wall_thickness;

    m_lid_hex_radius = __value( box, "lid_hex_radius", default = 4.0 );

    // this is the depth of the lid
    m_wall_lip_height = g_lid_lip_height;

    m_wall_underside_lid_storage_depth = 7;

    m_box_inner_position_min = [ m_wall_thickness, m_wall_thickness, m_wall_thickness ];
    m_box_inner_position_max = m_box_dimensions - m_box_inner_position_min;

    if ( m_box_is_spacer )
    {
        MakeLayer( layer = "spacer" );
    }  
    else
    {
        if( g_b_print_lid  && m_box_has_lid )    
        {
            MakeLayer( layer = "lid");
        }

        if ( g_b_print_box )
        {
            difference()
            {
                union()
                {
                    // first pass of carving out elements
                    difference()
                    {
                        MakeLayer( layer = "outerbox" );

                        for( i = [ 0: m_num_components - 1 ] )
                        {
                            MakeLayer( __component( i ) , layer = "component_subtractions");
                        }
                    }
                    // now add the positive elements
                    for( i = [ 0: m_num_components - 1 ] )
                    {
                        MakeLayer( __component( i ), layer = "component_additions" );     
                    }
                }

                // 2nd pass carving for components
                for( i = [ 0: m_num_components - 1 ] )
                {
                    MakeLayer( __component( i ), layer = "final_component_subtractions" );
                }

                // lid carve outs
                MakeLayer( layer = "lid_substractions" );
                
            }
            
        }
    }

    module MakeLayer( component, layer = "" )
    {
        m_is_outerbox = layer == "outerbox";
        m_is_lid = layer == "lid";
        m_is_spacer = layer == "spacer";
        m_is_lid_subtractions = layer == "lid_substractions";

        // we don't use position for the box or the lid. Only for components.
        m_ignore_position = m_is_outerbox || m_is_lid || m_is_spacer || m_is_lid_subtractions;

        m_is_component_subtractions = layer == "component_subtractions";
        m_is_component_additions = layer == "component_additions";
        m_is_final_component_subtractions = layer == "final_component_subtractions";

        function __compartment_size( D ) = __value( component, "compartment_size", default = [10.0, 10.0, 10.0] )[ D ];
        function __compartments_num( D ) = __value( component, "num_compartments", default = [1,1] )[ D ];

        m_component_label = __value( component, "label", default = [] );

        function __component_rotation() = __value( component, "rotation", default = 0 );
        function __is_component_enabled() = __value( component, "enabled", default = true);

        /////////

        function __c_m_s( side ) = __value( component, "margin", default = [f,f,f,f] )[ side ];
        function __component_has_margin( D ) = D == X ?
                [ __c_m_s( LEFT ), __c_m_s( RIGHT ) ] :
                [ __c_m_s( FRONT ), __c_m_s( BACK )];

        function __component_margin( D ) = [ __component_has_margin( D )[0] ? __component_padding( D ) : 0,
                                            __component_has_margin( D )[1] ? __component_padding( D ) : 0];

        function __component_cutout_sides() = __value( component, "cutout_sides", default = [0,0,0,0] );
        function __component_cutout_side( side ) = __component_cutout_sides()[ side ];
        function __component_has_cutout() = __component_cutout_sides() != [0,0,0,0];

        function __component_padding( D ) = __value( component, "padding", default = [1.0, 1.0] )[ D ];
        function __component_padding_height_adjust( D ) = __value( component, "padding_height_adjust", default = [0.0, 0.0] )[ D ];
        function __component_shape() = __value( component, "shape", default = "square" );
        function __component_shape_rotated_90() = __value( component, "shape_rotated_90", default = false );
        function __component_shape_vertical() = __value( component, "shape_vertical", default = false );
        function __component_is_hex() = __component_shape() == "hex";
        function __component_is_hex2() = __component_shape() == "hex2";
        function __component_is_oct() = __component_shape() == "oct";
        function __component_is_oct2() = __component_shape() == "oct2";        
        function __component_is_round() = __component_shape() == "round";
        function __component_is_square() = __component_shape() == "square";
        function __component_is_fillet() = __component_shape() == "fillet";

        function __component_shear( D ) = __value( component, "shear", default = [0.0, 0.0] )[ D ];

        function __req_label() = m_component_label != "";

        // the bottom of the finger cutout
        function __finger_cutouts_bottom() = __compartment_size( Z ) - m_box_dimensions[ Z ];
// end delete me
        ///////////
    
        function __partition_height_scale( D ) = D == __Y2() ? __req_lower_partitions() ? 0.5 : 1.00 : 1.00;

        // Amount of curvature represented as a percentage of the __wall height.
        m_curve_height_scale = 0.50;

        m_b_corner_notch = true;

        m_notch_height = 3.0;

        // DERIVED VARIABLES

        ///////// __component_position helpers

        function __p_i_c( D) = __c_p_raw()[ D ] == "center";
        function __p_i_m( D) = __c_p_raw()[ D ] == "max";
        function __c_p_c( D ) = ( m_box_dimensions[ D ] - __component_size( D )) / 2;
        function __c_p_max( D ) = m_box_dimensions[ D ] - m_wall_thickness - __component_size( D );

        /////////

        function __c_p_raw() = __value( component, "position", default = [ "center", "center" ]);
        function __component_position( D ) = __p_i_c( D ) ? __c_p_c( D ): 
                                                __p_i_m( D ) ? __c_p_max( D ): 
                                                    __c_p_raw()[ D ] + m_wall_thickness;

        function __component_position_max( D ) = __component_position( D ) + __component_size( D );

        function __compartment_smallest_dimension() = ( __compartment_size( X ) < __compartment_size( Y ) ) ? __compartment_size( X ) : __compartment_size( Y );

        function __partitions_num( D )= __compartments_num( D ) - 1 + ( __component_has_margin( D )[0] ? 1 : 0 ) + ( __component_has_margin( D )[1] ? 1 : 0 );

        // calculated __box local dimensions
        function __component_size( D )= ( D == Z ) ? __compartment_size( Z ) : 
                                                ( __compartment_size( D )* __compartments_num( D )) + ( __partitions_num( D )* __component_padding( D ));

        function __partition_height( D ) = __component_size( Z ) + __component_padding_height_adjust( D );
        function __smallest_partition_height() = min( __partition_height( X ), __partition_height( Y ) );

        function __notch_length( D ) = m_box_dimensions[ D ] / 5.0;
        function __lid_notch_depth() = m_wall_thickness / 2;

        m_lid_thickness = ( m_box_has_thin_lid ? 0.6 : g_lid_thickness ) - g_tolerance;

        function __lid_external_size( D )= D == Z ? m_lid_thickness + m_wall_lip_height : 
                                                    m_box_dimensions[ D ];

        function __lid_internal_size( D )= D == Z ? __lid_external_size( Z ) - m_lid_thickness : 
                                                    __lid_external_size( D ) - m_wall_thickness + ( g_tolerance * 2);

        function __has_simple_lid() = g_b_simple_lids || g_b_vis_actual;

        module ContainWithinBox()
        {
            b_needs_trimming = m_is_component_additions;

            if ( b_needs_trimming &&
            ( 
                __component_position( X ) < m_box_inner_position_min[ X ]
                || __component_position( Y ) < m_box_inner_position_min[ Y ]
                || __component_position( X ) + __component_size( X )  > m_box_inner_position_max[ X ]
                || __component_position( Y ) + __component_size( Y )  > m_box_inner_position_max[ Y ]
            ))
            {
                intersection()
                {
                    echo( "<br><font color='red'>WARNING: Components in RED do not fit in box. If this is not intentional then adjustments are required or pieces won't fit.</font><br>");
                    translate( [0, 0, 0] )
                    {
                        cube([  
                                m_box_dimensions[ X ], 
                                m_box_dimensions[ Y ], 
                                m_box_dimensions[ Z ]
                            ]);
                    }    

                    color([1,0,0])
                        children();    
                }
            }
            else
            {
                if ( b_needs_trimming && 
                 ( __component_size( Z ) + m_wall_thickness > m_box_dimensions[ Z ] )
                )
                {
                    intersection()
                    {
                        translate( [m_wall_thickness / 2, m_wall_thickness / 2, 0] )
                            cube([  m_box_dimensions[ X ], 
                                    m_box_dimensions[ Y ], 
                                    m_box_dimensions[ Z ]]);

                        children();    
                    }
                }
                else
                {
                    children();  
                }
            }
        }

/////////////////////////////////////////
/////////////////////////////////////////


    module __ColorComponent()
    {
        r = !g_b_colorize ? 0.7 : pow( sin( pow( __component_position(X),5) ), 0.5);
        g = !g_b_colorize ? 0.8 :pow( sin( pow( __component_position(Y), 5) ), 0.3);
        b = !g_b_colorize ? 0.5 :pow( cos( pow( __component_size(Z), 5) ), 0.5);


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
                    RotateAboutPoint( __component_rotation(), [0,0,1], [__component_position( X ) + __component_size( X )/2, __component_position( Y )+ __component_size( Y )/2, 0] ) 
                        translate( [ __component_position( X ), __component_position( Y ), m_box_dimensions[ Z ] - __compartment_size( Z ) ] )
                            Shear( __component_shear( X ), __component_shear( Y ) )
                                InnerLayer();   
            }
        }

        module MakeLidNotch( height = 0, depth = 0, offset = 0 )
        {
            translate( [ offset, offset, 0 ] )
            {
                cube( [  m_box_dimensions[ X ] - ( 2 * offset ),
                        __lid_notch_depth() + depth, 
                        m_wall_lip_height + height ] );   

                cube( [  __lid_notch_depth() + depth,
                        m_box_dimensions[ Y ] - ( 2 * offset ),
                        m_wall_lip_height + height ] ); 
            }
        }

        module MakeLidNotches( height = 0, depth = 0, offset = 0 )
        {
                MakeLidNotch( height = height, depth = depth, offset = offset );

                center = [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0];

                MirrorAboutPoint( [1,0,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
                    MirrorAboutPoint( [0,1,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
                        MakeLidNotch( height = height, depth = depth, offset = offset );

        }

        module InnerLayer()
        {
            if ( m_is_spacer )
            {
                difference()
                {
                    cube( [ m_box_dimensions[ X ], m_box_dimensions[ Y ], m_box_dimensions[ Z ] ] );

                    translate( [ m_wall_thickness, m_wall_thickness, 0 ])
                        cube( [ m_box_dimensions[ X ] - ( 2 * m_wall_thickness ), m_box_dimensions[ Y ] - ( 2 * m_wall_thickness ), m_box_dimensions[ Z ] ] );
                }
            }
            else if ( m_is_outerbox )
            {
                // 'outerbox' is the insert. It may contain one or more 'components' that each
                // define a repeated compartment type.
                //
                cube([  m_box_dimensions[ X ], 
                        m_box_dimensions[ Y ], 
                        m_box_dimensions[ Z ]]);
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
                    cube([  __component_size( X ), 
                            __component_size( Y ), 
                            __component_size( Z )]);
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
                    if ( __component_cutout_side( FRONT ))
                        MakeFingerCutout( FRONT );

                    if ( __component_cutout_side( BACK ))
                        MakeFingerCutout( BACK );

                    if ( __component_cutout_side( LEFT ))
                        MakeFingerCutout( LEFT );

                    if ( __component_cutout_side( RIGHT ))
                        MakeFingerCutout( RIGHT );   

                    if ( !__component_is_square() && !__component_is_fillet() )
                    {
                        __ColorComponent()
                            MakeCompartmentShape( "subtractive");
                    }
                }

                if ( __req_label() )
                {
                    color([0,0,1])LabelEachCompartment();
                }
            }
            else if ( m_is_lid_subtractions && m_box_has_lid )
            {

                notch_pos_z =  m_box_dimensions[ Z ] - m_wall_lip_height ;
                
                translate( [ 0,0, notch_pos_z ] )
                    MakeLidNotches();

                // outer, shorter wall
                if ( m_box_fit_lid_under )
                {
                    // we need to carve out angles so we won't need supports.
                    difference()
                    {
                        vertical_clearance = 1.0 + g_tolerance;

                        MakeLidNotches( height = vertical_clearance, depth = g_tolerance );

                        hull()
                        {
                            translate( [ 0, 0, m_wall_lip_height + vertical_clearance] )
                                MakeLidNotches();

                            translate( [ 0, 0, m_wall_lip_height - 1 + vertical_clearance] )
                                MakeLidNotches( offset = __lid_notch_depth() + g_tolerance );

                        }
                    }

                }

                notch_pos_z_corner = notch_pos_z - m_notch_height ;

                if ( m_box_has_lid_notches )
                    translate([ 0, 0, notch_pos_z_corner]) 
                        MakeLidCornerNotches();
                    
                
            }
        }



////////PATTERNS

        module MakeHexGrid( x = 200, y = 200, R = 1, t = 0.2 )
        {
            r = cos(30) * R;

            dx = r * 2 - t;
            dy = R * 1.5 - t;

            x_count = x / dx;
            y_count = y / dy;

            for( j = [ 0: y_count ] )
            {
                translate( [ ( j % 2 ) * (r - t/2), 0, 0 ] )
                {
                    for( i = [ 0: x_count ] )
                    {
                        translate( [ i * dx, j * dy, 0 ] )
                            rotate( a=30, v=[ 0, 0, 1 ] )
                                children();
                    }
                }
            }
            
        }

        module Hex( R = 1, t = 0.2 )
        {
 
            polygon([
                [ R * cos(0 * 2 * ( PI / 6)* 180 / PI), R * sin(0 * 2 * ( PI / 6) * 180 / PI) ],
                [ R * cos(1 * 2 * ( PI / 6)* 180 / PI), R * sin(1 * 2 * ( PI / 6) * 180 / PI) ],
                [ R * cos(2 * 2 * ( PI / 6)* 180 / PI), R * sin(2 * 2 * ( PI / 6) * 180 / PI) ],
                [ R * cos(3 * 2 * ( PI / 6)* 180 / PI), R * sin(3 * 2 * ( PI / 6) * 180 / PI) ],
                [ R * cos(4 * 2 * ( PI / 6)* 180 / PI), R * sin(4 * 2 * ( PI / 6) * 180 / PI) ],
                [ R * cos(5 * 2 * ( PI / 6)* 180 / PI), R * sin(5 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(0 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(0 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(1 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(1 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(2 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(2 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(3 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(3 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(4 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(4 * 2 * ( PI / 6) * 180 / PI) ],
                [ ( R - t ) * cos(5 * 2 * ( PI / 6)* 180 / PI), ( R - t ) * sin(5 * 2 * ( PI / 6) * 180 / PI) ]],
                
                [[0,1,2,3,4,5],[6,7,8,9,10,11]]
                );
            
                    
        };

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

            module MakeLidText( offset = 0, thickness = m_lid_thickness )
            {
                xpos = __lid_external_size( X )/2 + __label_offset( m_box_label)[X];
                ypos = __lid_external_size( Y )/2 + __label_offset( m_box_label)[Y];

                auto_width = __label_auto_width( m_box_label, __lid_external_size( X ), __lid_external_size( Y ) );
                width = auto_width != 0 ? min( 100, auto_width ) + offset : 0;

                linear_extrude( thickness )
                    translate( [ xpos, ypos, 0 ] )
                        MirrorAboutPoint( [ 1,0,0],[0,0, thickness / 2])
                            RotateAboutPoint( __label_rotation( m_box_label ), [0,0,1], [0,0,0] )
                                resize([ width,0,0], auto=true)
                                    offset( r = offset )
                                            text(text = str( __label_text( m_box_label ) ), 
                                                font = __label_font( m_box_label ),  
                                                size = __label_size( m_box_label ), 
                                                valign = "center", 
                                                halign = "center", 
                                                $fn=1);
            }

            lid_print_position = [0, m_box_dimensions[ Y ] + DISTANCE_BETWEEN_PARTS, 0 ];
            lid_vis_position = [ 0, 0, m_box_dimensions[ Z ] + m_lid_thickness ];
          
            translate( g_b_vis_actual ? lid_vis_position : lid_print_position ) 
                RotateAboutPoint( g_b_vis_actual ? 180 : 0, [0, 1, 0], [__lid_external_size( X )/2, __lid_external_size( Y )/2, 0] )
                {
                    // lid edge
                    difference() 
                    {
                        // main __box
                        cube([__lid_external_size( X ), __lid_external_size( Y ), __lid_external_size( Z )]);
                        
                        MoveToLidInterior()
                            cube([  __lid_internal_size( X ), __lid_internal_size( Y ),  __lid_external_size( Z )]);
                    }

                    width = __label_auto_width( m_box_label, __lid_external_size( X ), __lid_external_size( Y ) );
                    text_offset = width != 0 ? width/15 : __label_size( m_box_label ) ;

                    difference()
                    {
                        // honeycomb
                        linear_extrude( m_lid_thickness )
                        {
                            R = m_lid_hex_radius;
                            t = 0.5;

                            intersection()
                            {
                                polygon( [[0,0], 
                                        [0, __lid_external_size( Y )], 
                                        [ __lid_external_size( X ), __lid_external_size( Y )],
                                        [ __lid_external_size( X ), 0] ]);   
                                
                                if ( !__has_simple_lid() )
                                {
                                    MakeHexGrid( x = __lid_external_size( X ), y = __lid_external_size( Y ), R = R, t = t )
                                    {
                                        Hex( R = R, t = t );
                                    }
                                }
                            }
                        }

                        if ( !__has_simple_lid() )
                        {
                            MakeLidText( offset = text_offset );
                        }
                        else if ( !m_box_has_thin_lid )
                        {
                            MakeLidText( offset = 0, thickness = m_lid_thickness / 2 );
                        }
                        
                    }
                    

                    if ( !__has_simple_lid() )
                    {
                        //make the grid background
                        intersection()
                        {
                            x = __lid_external_size( X );
                            y = __lid_external_size( Y );

                            RotateAboutPoint( - __label_rotation( m_box_label ) + 45, [0,0,1], [x/2,y/2,0] )
                                MakeStripedGrid( x = x, y = y, w = 0.5, dx = 1, dy = 0, depth_ratio = 0.5 );

                            MakeLidText( offset = text_offset  );                  
                        }
                    }

                    // make the actual lid label
                    if ( !__has_simple_lid() )
                        MakeLidText();

                    // make the background edge
                    if ( !__has_simple_lid() )
                    {
                        difference()
                        {
                           MakeLidText( offset = text_offset );
                           MakeLidText( offset = text_offset - 1 );
                        }
                    }
                }
        }

        module ForEachPartition( D )
        {
            start = 0;
            end = __partitions_num( D ) - 1;

            if ( end >= start )
            {
                for ( a = [ start : end  ] )
                {
                    pos = ( __component_has_margin(D)[0] ? 0 : __compartment_size( D ) ) +
                    ( __compartment_size( D ) + __component_padding( D )) * a ;

                    translate( [ D == X ? pos : 0 ,  D == Y ? pos : 0 , 0 ] )
                    {
                        children();
                    }
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

                    translate( [ D == X ? dim1 : 0 ,  D == Y ? dim1 : 0 , 0 ] )
                    children();
                }
            }
        }

        module InEachCompartment()
        {
            n_x = __compartments_num( X );
            n_y = __compartments_num( Y );

            for ( x = [ 0: n_x - 1] )
            {
                x_pos = __component_margin( X )[0] + ( __compartment_size( X ) + __component_padding( X ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = __component_margin( Y )[0] + ( ( __compartment_size( Y ) ) + __component_padding( Y ) ) * y;

                    translate( [ x_pos ,  y_pos , 0 ] )
                        children();
                }
            }            
        }

        module LabelEachCompartment()
        {
            n_x = __compartments_num( X );
            n_y = __compartments_num( Y );

            for ( x = [ 0: n_x - 1] )
            {
                x_pos = __component_margin( X )[0] + ( __compartment_size( X ) + __component_padding( X ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = __component_margin( Y )[0] + ( ( __compartment_size( Y ) ) + __component_padding( Y ) ) * y;

                    translate( [ x_pos ,  y_pos , 0 ] ) // to compartment origin
                        MakeLabel( x, y )
                            Helper_MakeLabel( x, y );
                }
            } 
        }

 
    module MakeRoundedCube( vec3, radius){
        hull()
        {
            h = vec3[Z];

            translate( [ radius, radius, 0 ])
                cylinder(r=radius, h=h);

            translate( [ vec3[X] - radius, radius, 0 ])
                cylinder(r=radius, h=h);

            translate( [ radius, vec3[Y] - radius, 0 ])
                cylinder(r=radius, h=h);

            translate( [ vec3[X] - radius, vec3[Y] - radius, 0 ])
                cylinder(r=radius, h=h);                
        }
    }             

        module MakeFingerCutout( side )
        {
            cutout_z = m_box_dimensions[ Z ] + 2.0;
            radius = 3;

            if ( side == BACK || side == FRONT )
            {
                cutout_y = min( __component_padding(Y)*2, __compartment_size(Y)/2 )  + min(10, __compartment_size(Y));
                cutout_x = max( 10, __compartment_size( X )/3 );

                pos_x = __compartment_size( X )/2  - cutout_x/2;
                pos_y = - __component_padding( Y ) - m_wall_thickness - radius;

                if ( side == FRONT )
                {
                    translate( [ pos_x, pos_y, __finger_cutouts_bottom() ] )
                        MakeRoundedCube( [ cutout_x , cutout_y, cutout_z ], radius );
                }
                else if ( side == BACK )
                {
                    pos_y2 =  __compartment_size( Y ) + __component_padding( Y )/2 - cutout_y + m_wall_thickness + radius;

                    translate( [ pos_x, pos_y2, __finger_cutouts_bottom() ] )
                        MakeRoundedCube( [ cutout_x , cutout_y, cutout_z ], radius );
                }                
            }  
            else if ( side == LEFT || side == RIGHT )
            {
                cutout_x = min( __component_padding(X)*2, __compartment_size(X)/2) + min(10, __compartment_size(X));
                cutout_y = max( 10, __compartment_size( Y )/3 );

                pos_x = - __component_padding( X ) - m_wall_thickness -radius;
                pos_y = __compartment_size( Y )/2  - cutout_y/2;

                if ( side == LEFT )
                {
                    translate( [ pos_x, pos_y, __finger_cutouts_bottom() ] )
                        MakeRoundedCube( [ cutout_x , cutout_y, cutout_z ], radius );
                }   
                else if ( side == RIGHT )
                {
                    pos_x2 =  __compartment_size( X ) + __component_padding( X )/2 - cutout_x + m_wall_thickness + radius;

                    translate( [ pos_x2, pos_y, __finger_cutouts_bottom() ] )
                        MakeRoundedCube( [ cutout_x , cutout_y, cutout_z ], radius );
                }                    
            }    
        }

        // this rounds out the bottoms regardless of the size of the compartment
        // and doesn't attempt to fit a specific shape.
       module AddFillets()
        {
            r = __smallest_partition_height();

            module _MakeFillet()
            {
                difference()
                {
                    cube_rotated = __component_shape_rotated_90() ? [ __compartment_size( X ), r, r ] : [ r, __compartment_size( Y ), r ];                   
                    cube ( cube_rotated );

 
                    cylinder_translated = __component_shape_rotated_90() ? [ 0, r, r ] : [ r, __compartment_size( Y ), r ];                    
                    translate( cylinder_translated )
                    {
                        cylinder_rotation = __component_shape_rotated_90() ? [ 0, 1, 0, ] : [ 1, 0, 0 ];

                        rotate( v=cylinder_rotation, a=90 )
                        {
                            h = __component_shape_rotated_90() ? __compartment_size( X ) : __compartment_size( Y );
                            cylinder(h = h, r1 = r, r2 = r);  
                        } 
                    }
                }

            }

             _MakeFillet();

             mirrorv = __component_shape_rotated_90() ? [ 0,1,0] : [1,0,0];
             mirrorpt = __component_shape_rotated_90() ? [ 0, __compartment_size( Y ) / 2, 0 ] : [ __compartment_size( X ) / 2, 0, 0 ];
            
            MirrorAboutPoint(mirrorv, mirrorpt)
            {
                _MakeFillet();   
            }        
        }

        module MakeVerticalShape( h, r, r1, r2, z_offset )
        {
            compartment_z_min = m_wall_thickness;
            compartment_internal_z = __compartment_size( Z ) - compartment_z_min;

            cylinder_translation = [ r , __compartment_size(Y)/2 , m_wall_thickness ];

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
                         cube ( [ __compartment_size( X ), __compartment_size( Y ), __smallest_partition_height() ] );
                         MakeVerticalShape(h = __compartment_size( Z ), r = r, r1 = r, r2 = r, z_offset = 0 );
                    }
                }
                else if ( __component_has_cutout())
                {
                    underbase = m_box_dimensions[ Z ] - __compartment_size( Z ) + m_wall_thickness;
                    
                    MakeVerticalShape(h = underbase, r = r, r1 = r/1.3, r2 = r/1.3, z_offset = -underbase );

                }
            }
            else if ( pass == "additive" ) 
            {

                difference()
                { 
                
                    cube ( [ __compartment_size( X ), __compartment_size( Y ), __smallest_partition_height() ] );

                    dim1 = __component_shape_rotated_90() ? Y : X;
                    dim2 = __component_shape_rotated_90() ? X : Y;

                    r = __compartment_size( dim1 ) / 2 / cos( 30 / $fn );

                    union()
                    {
                        cylinder_translation = __component_shape_rotated_90() ?
                                                    [ 0, __compartment_size( Y )/2 , r ] :
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
                            cube ( [ __compartment_size( X ), __compartment_size( Y ), m_box_dimensions[ Z ]] );
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

            width = __label_auto_width( m_component_label, __compartment_size( X ), __compartment_size( Y ) );

            // since we build from the bottom--up, we need to reverse the order in which we read the text rows
            text_y_reverse = __is_multitext( m_component_label ) ? len(__value( m_component_label, "text")) - y - 1: 0;

            // max_height = label_on_y ? __component_padding( X ) : 
            //             label_on_x ? __component_padding( Y ) : 0;

            // max_width = label_on_y ? __component_padding( Y ) : 
            //             label_on_x ? __component_padding( X ) : 0;

                rotate_vector = label_on_side ? [ 0,1,0] : [0,0,1];
                label_needs_to_be_180ed = __label_placement_is_front( m_component_label) && __label_placement_is_wall( m_component_label);

                RotateAboutPoint( label_needs_to_be_180ed ? 180 : 0, [0,0,1], [0,0,0] )
                    RotateAboutPoint( __label_rotation( m_component_label ), rotate_vector, [0,0,0] )
                        RotateAboutPoint( label_on_side ? 90:0, [1,0,0], [0,0,0] )
                            translate( [ __label_offset( m_component_label )[X], __label_offset( m_component_label )[Y], 0])
                                resize( [ width, 0, 0], auto=true)
                                    translate([0,0,-__label_depth( m_component_label )]) 
                                        linear_extrude( height =  2 * __label_depth( m_component_label ) )
                                            text(text = str( __label_text( m_component_label, x, text_y_reverse) ), 
                                                font = __label_font( m_component_label ), 
                                                size = __label_size( m_component_label ), 
                                                valign = "center", 
                                                halign = "center", 
                                                $fn=1);
            }

        module MakeLabel( x = 0, y = 0 )
        {
            z_pos = 0;
            z_pos_vertical = __partition_height( Y )- __label_size( m_component_label );

            if ( __label_placement_is_center( m_component_label) )
            {
                translate( [ __compartment_size(X)/2, __compartment_size(Y)/2, z_pos] )
                    children();
            }
            else if ( __label_placement_is_front( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(X)/2, 0, z_pos_vertical ] )
                        children();
                else                
                    translate( [ __compartment_size(X)/2, -__component_padding( Y )/4, __partition_height( Y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_back( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(X)/2, __compartment_size(Y), z_pos_vertical ] )
                        children();
                else
                    translate( [ __compartment_size(X)/2, __compartment_size(Y) + __component_padding( Y )/4, __partition_height( Y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_left( m_component_label) )
            {
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ 0, __compartment_size(Y)/2, z_pos_vertical ] )
                        children();
                else
                    translate( [ - __component_padding(X)/4, __compartment_size(Y)/2, __partition_height( Y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_right( m_component_label) )
            {            
                if ( __label_placement_is_wall( m_component_label ) )
                    translate( [ __compartment_size(X), __compartment_size(Y)/2, z_pos_vertical ] )
                        children();
                else
                    translate( [ __compartment_size(X) + __component_padding(X)/4, __compartment_size(Y)/2, __partition_height( Y ) + z_pos] )
                        children();
            }
        }

        module MakePartitions()
        {
            ForEachPartition( X )   
            {
                MakePartition( axis = X );  
            }

            ForEachPartition( Y )  
            {
                MakePartition( axis = Y );  
            }
        }

        module MakePartition( axis )
        {
            if ( axis == X )
            {
                cube ( [ __component_padding( X ), __component_size( Y ), __partition_height( X )  ] );
            }
            else if ( axis == Y )
            {
                cube ( [ __component_size( X ), __component_padding( Y ) , __partition_height( Y ) ] );     
            }
        }

        module MakeLidCornerNotch()
        {
            {
                cube([ __notch_length( X ), __lid_notch_depth(), m_notch_height ]);
                cube([__lid_notch_depth(), __notch_length( Y ), m_notch_height]);
            }
        }

        module MakeLidCornerNotches()
        {
            MakeLidCornerNotch();

            MirrorAboutPoint( [1,0,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MakeLidCornerNotch();
            }

            MirrorAboutPoint( [0,1,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MakeLidCornerNotch();
            }

            MirrorAboutPoint( [1,0,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MirrorAboutPoint( [0,1,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
                {
                    MakeLidCornerNotch();    
                }
            }
        }
    }

}














