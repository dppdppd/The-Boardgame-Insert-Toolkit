
// Copyright 2019 MysteryDough https://www.thingiverse.com/MysteryDough/
//
// Released under the Creative Commons - Attribution - Non-Commercial - Share Alike License.
// https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

VERSION = "1.10";
COPYRIGHT_INFO = "\tThe Boardgame Insert Toolkit\n\thttps://www.thingiverse.com/thing:3405465\n\n\tCopyright 2019 MysteryDough\n\tCreative Commons - Attribution - Non-Commercial - Share Alike.\n\thttps://creativecommons.org/licenses/by-nc-sa/4.0/legalcode";

$fn=100;

// constants
KEY = 0;
VALUE = 1;

X = 0;
Y = 1;
Z = 2;

DISTANCE_BETWEEN_PARTS = 2;
PARTITION_FINGERS = 13;
////////////////////

// key-values helpers
function __index_of_key( table, key ) = search( [ key ], table )[ KEY ];
function __value( table, key, default = false ) = __index_of_key( table, key ) == [] ? default : table[ __index_of_key( table, key ) ][ VALUE ];

///////////////////////


module RotateAndMoveBackToOrigin(a, extents ) 
{
    pos = a == 90 ? 
        [ extents[1], 0, 0] : 
        a == -90 ? 
            [ 0, extents[0], 0 ] : 
            a == -180 ? 
                [ extents[1], extents[0], 0 ] :
                0;

    translate( pos )
    {
        rotate(a, [0,0,1])
        {
            children();   
        }
    }
}

module RotateAboutPoint(a, v, pt) 
{
    translate(pt)
    {
        rotate(a,v)
        {
            translate(-pt)
            {
                children();   
            }
        }
    }
}

module MirrorAboutPoint( v, pt) 
{
    translate(pt)
    {
        mirror( v )
        {
            translate(-pt)
            {
                children();   
            }
        }
    }
}



function __box( b ) = data[ b ][1];
function __num_boxes() = len( data );

function __is_box_isolated_for_print() = __index_of_key( data, g_isolated_print_box ) != [];
function __is_box_enabled( box ) = __value( box, "enabled", default = true);

function __box_dimensions( b ) = __value( __box( b ), "box_dimensions" );
function __box_position_x( b ) = __box( b - 1 ) == undef ? 0 : __is_box_enabled( b - 1 ) ? __box_dimensions( b - 1)[ X ] + __box_position_x( b - 1 ) + DISTANCE_BETWEEN_PARTS : __box_position_x( b - 2 );

//vis
function __box_vis_data( box ) = __value( box, "visualization", default = "");
function __box_vis_position( box ) = __value( __box_vis_data( box ), "position" );
function __box_vis_rotation( box ) = __value( __box_vis_data( box ), "rotation" );

function __is_string( s ) = len( str( s,s )) == len( s ) * 2;

function __is_multitext( label ) = !__is_string( __value( label, "text" ) ) && len( __value( label, "text" )) != undef;
function __label_text( label, r = 0, c = 0 ) = __is_multitext( label ) ?  __value( label, "text", default = "" )[c][r] : __value( label, "text", default = "" );
function __label_size( label ) = __value( label , "size", default = 4 );
function __label_rotation( label ) = __value( label, "rotation", default = 0 );
function __label_depth( label ) = __value( label, "depth", default = 0.3 );

module Colorize()
{
    if ( g_b_visualization )
    {
        color( rands(0,1,3), g_b_visualization ? 0.5 : 1 )
        {
            children();
        }
    }
    else
    {
        children();
    }

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
        for( b = [ 0: __num_boxes() - 1 ] )
        {
            box = __box( b );

            box_position = ( g_b_visualization && __box_vis_position( box ) != [] ) ? __box_vis_position( box ) : [ __box_position_x( b ), 0, 0 ];
            box_rotation = ( g_b_visualization && __box_vis_rotation( box ) != undef ) ? __box_vis_rotation( box ) : 0;
            
            translate( box_position )
            {
                RotateAndMoveBackToOrigin( box_rotation, __box_dimensions( b ) )
                {
                    if ( __is_box_enabled( box ) )
                    {
                        Colorize()
                        {
                            MakeBox( box );
                        }
                    }
                }
            }
        }
    }

}


module MakeBox( box )
{
    m_box_dimensions = __value( box, "box_dimensions", default = [ 100.0, 100.0, 100.0 ] );

    m_components =  __value( box, "components" );

    m_num_components =  len( m_components );

    function __component( c ) = m_components[ c ][1];

    m_box_label = __value( box, "label", default = "");

    m_box_is_spacer = __value( box, "type") == "spacer";

    m_box_has_thin_lid = __value( box, "thin_lid", default = false ) == true;

            // tolerance for fittings
        m_tolerance = 0.05; 

        // __wall_local determins the lid-less (part) __wall width.
        // Wall exterior is added on and creates the sturdier exterior that also holds the lid.
        m_wall_thickness = 2.0;

        // this is the depth of the lid
        m_wall_lip_height = 5.0;

        m_wall_underside_lid_storage_depth = 7.0;

        m_box_inner_position_min = [ m_wall_thickness, m_wall_thickness, m_wall_thickness ];
        m_box_inner_position_max = m_box_dimensions - m_box_inner_position_min;


    if ( m_box_is_spacer )
    {
        MakeLayer( layer = "spacer" );
    }  
    else
    {
        if( g_b_print_lid )    
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
                            MakeLayer( __component( i ) , layer = "carve_outs");
                        }
                    }


                    // now add the positive elements
                    for( i = [ 0: m_num_components - 1 ] )
                    {
                        MakeLayer( __component( i ), layer = "additive_components" );     
                    }
                }

                // final carving from everything
                for( i = [ 0: m_num_components - 1 ] )
                {
                    MakeLayer( __component( i ), layer = "final_carve_outs" );
                }
                
            }
            
        }
    }


    


    module MakeLayer( component, layer = "" )
    {
        m_is_outerbox = layer == "outerbox";
        m_is_lid = layer == "lid";
        m_is_spacer = layer == "spacer";

        // we don't use position for the box or the lid. Only for components.
        m_ignore_position = m_is_outerbox || m_is_lid || m_is_spacer;

        m_is_carve_outs = layer == "carve_outs";
        m_is_additive_components = layer == "additive_components";
        m_is_final_carve_outs = layer == "final_carve_outs";

        function __compartment_size( D ) = __value( component, "compartment_size", default = [10.0, 10.0, 10.0] )[ D ];
        function __compartments_num( D ) = __value( component, "num_compartments", default = [1,1] )[ D ];

        m_component_label = __value( component, "label", default = [] );

        function __comp_rot_raw() = __value( component, "rotation", default = 0 );
        function __comp_rot_valid() = __comp_rot_raw() == 90 ? 90 : __comp_rot_raw() == -90 ? -90 : __comp_rot_raw() == 180 ? 180 : 0;
        function __component_rotation() = __comp_rot_valid();
        function __component_rotated_90() = abs( __component_rotation() ) == 90;
        function __component_rotated_180() = abs( __component_rotation() ) == 180;
        function __X2() = __component_rotated_90() ? Y : X;
        function __Y2() = __component_rotated_90() ? X : Y;
        function __RotatedResult( _0 = 0, _90 = 0, _180 = 0, _n90 = 0 ) = ( __component_rotation() == 90 ) ? _90 : ( __component_rotation() == 180 ) ? _180 : ( __component_rotation() == -90 ) ? _n90 : _0 ;
        function __component_shape() = __value( component, "shape", default = "square" );
        function __component_type() = __value( component, "type", default = "generic" );
        function __component_extra_spacing( D ) = __value( component, "extra_spacing", default = [0.0, 0.0] )[ D ];
        function __is_component_enabled() = __value( component, "enabled", default = true);

        /////////

        function __is_plain() = __component_type() == "generic";
        function __is_cards() = __component_type() == "cards";
        function __is_tokens() = __component_type() == "tokens";
        function __is_chit_stack() = __component_type() == "chit_stack";
        function __is_chit_stack_vertical() = __component_type() == "chit_stack_vertical";

        function __req_thick_partitions() = __is_cards() || __is_chit_stack() || __is_chit_stack_vertical();
        function __req_lower_partitions() = __is_chit_stack();
        function __req_bottoms() = __is_tokens() || ( __is_chit_stack() && __component_shape() != "square" );
        function __req_single_end_partition() = ( __is_cards() && __compartments_num( __Y2() ) == 1 ) || __is_chit_stack_vertical();
        function __req_double_end_partition() = __is_chit_stack();
        function __req_label() = m_component_label != "";

                // Determines whether finger cutouts are made. (For cards)
        function __req_finger_cutouts() = __is_cards() || __is_chit_stack_vertical();

        // the bottom of the finger cutout
        function __finger_cutouts_bottom() = max( -10, __compartment_size( Z ) - m_box_dimensions[ Z ] + 2.0 );

        ///////////
    
        function __partition_height_scale( D ) = D == __Y2() ? __req_lower_partitions() ? min( 0.5, (__compartment_size( X ) / __compartment_size( Z )) /2) : 1.00 : 1.00;

        // Amount of curvature represented as a percentage of the __wall height.
        m_bottom_curve_height_scale = 0.50;

        m_b_corner_notch = true;

        m_notch_height = 3.0;

        // DERIVED VARIABLES

        ///////// __component_position helpers

        function __p_i_c( D) = __c_p_raw()[ D ] == "center";
        function __p_i_m( D) = __c_p_raw()[ D ] == "max";
        function __c_p_c( D ) = ( m_box_dimensions[ D ] - __component_size( D )) / 2;
        function __c_p_max( D ) = m_box_dimensions[ D ] - m_wall_thickness -  __component_size( D );

        /////////

        function __c_p_raw() = __value( component, "position", default = [ "center", "center" ]);
        function __component_position( D ) = __p_i_c( D )? 
                                            __c_p_c( D ): 
                                            __p_i_m( D )? 
                                                __c_p_max( D ): 
                                           //     __c_p_raw()[D] < 0 ? 
                                           //         __c_p_max( D ) + __c_p_raw()[D] : 
                                                    __c_p_raw()[D] + m_wall_thickness;

        function __component_position_max( D ) = __component_position( D ) + __component_size( D );

        // The thickness of the __compartment __partitions.
        function __partition_thickness( D ) = ( D == __Y2() ) && __req_thick_partitions() ? PARTITION_FINGERS + __component_extra_spacing( D ): 1 + __component_extra_spacing( D );

        // whether to add __partitions on the __box edges.
        function __partition_num_modifier( D ) = ( D == __Y2() ) ? 
                                            ( __req_single_end_partition() ? 
                                            0 : 
                                            __req_double_end_partition() ? 
                                                1 : 
                                                -1 ) : 
                                            -1 ;

        // for rounded bottoms, use the lowest __wall
        function __height_for_rounded_bottom() = 
            ( min( __partition_height( Y ), min( m_bottom_curve_height_scale * __compartment_size( Z ), __partition_height( X ) )));

        function __compartment_smallest_dimension() = ( __compartment_size( X ) < __compartment_size( Y ) ) ? __compartment_size( X ) : __compartment_size( Y );

        function __partitions_num( D )= __compartments_num( D ) + __partition_num_modifier( D );

        // calculated __box local dimensions
        function __component_size( D )= ( D == Z ) ? __compartment_size( Z ) : ( __compartment_size( D )* __compartments_num( D )) + ( __partitions_num( D )* __partition_thickness( D ));

        // clamp __partition heights
        function __partition_height( D ) = __compartment_size( Z ) * __partition_height_scale( D );

        function __notch_length( D ) = m_box_dimensions[ D ] / 5.0;
        function __notch_depth() = m_wall_thickness;

        m_lid_thickness = ( m_box_has_thin_lid ? 0.2 : m_wall_thickness ) - m_tolerance;

        function __lid_external_size( D )= D == Z ?     
                                        m_lid_thickness + m_wall_lip_height : 
                                        m_box_dimensions[ D ];

        function __lid_internal_size( D )= D == Z ? 
                                        __lid_external_size( Z ) - m_lid_thickness : 
                                        __lid_external_size( D ) - m_wall_thickness + m_tolerance;

        function __has_simple_lid() = g_b_simple_lids || g_b_visualization;

        module TranslateWithRotation( normal, rotated )
        {
            if ( abs( __component_rotation() ) == 90 )
            {
                translate( rotated )
                {
                    children();
                }
            }
            else
            {
                translate( normal )
                {
                    children();
                }
            }
        }

        module ContainWithinBox()
        {
            b_needs_trimming = m_is_carve_outs || m_is_additive_components;

            if ( b_needs_trimming &&
            ( __component_position( X ) < m_box_inner_position_min[ X ] ||
            __component_position( Y ) < m_box_inner_position_min[ Y ] ||
            __component_position( Z ) < m_box_inner_position_min[ Z ] ||
            __component_position( X ) + __component_size( X ) > m_box_inner_position_max[ X ] ||
            __component_position( Y ) + __component_size( Y ) > m_box_inner_position_max[ Y ] ||
            __component_position( Z ) + __component_size( Z ) > m_box_inner_position_max[ Z ]))
            {
                intersection()
                {
                    echo( "<br><font color='red'>WARNING: Components in RED do not fit in box. If this is not intentional then adjustments are required or pieces won't fit.</font><br>");
                    translate( [m_wall_thickness, m_wall_thickness, 0] )
                    {
                        cube([  m_box_dimensions[ X ] - (2 * m_wall_thickness ), 
                                m_box_dimensions[ Y ] - ( 2 * m_wall_thickness ), 
                                m_box_dimensions[ Z ]]);
                    }    

                    color([1,0,0])
                    { 
                        children();    
                    }
                }
            }
            else
            {
                children();
            }
        }

/////////////////////////////////////////
/////////////////////////////////////////
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
                {
                    translate( [ __component_position( X ), __component_position( Y ), m_box_dimensions[ Z ] - __compartment_size( Z ) ] )
                    {
                        InnerLayer();
                    }
                }
            }
        }

        module InnerLayer()
        {
            if ( m_is_spacer )
            {
                difference()
                {
                    cube( [ m_box_dimensions[ X ], m_box_dimensions[ Y ], m_box_dimensions[ Z ] ] );

                    translate( [ m_wall_thickness, m_wall_thickness, 0 ])
                    {
                        cube( [ m_box_dimensions[ X ] - ( 2 * m_wall_thickness ), m_box_dimensions[ Y ] - ( 2 * m_wall_thickness ), m_box_dimensions[ Z ] ] );
                    }
                }
            }
            else if ( m_is_outerbox )
            {
                // 'outerbox' is the insert. It may contain one or more 'components' that each
                // define a repeated compartment type.
                //

                difference()
                {
                    // outer, shorter wall
                    if ( g_b_fit_lid_underneath )
                    {
                        hull()
                        {
                            translate( [0,0,m_wall_underside_lid_storage_depth])
                            {
                                cube([  m_box_dimensions[ X ], 
                                        m_box_dimensions[ Y ], 
                                        m_box_dimensions[ Z ] - ( m_wall_lip_height + m_wall_underside_lid_storage_depth ) ] );
                            }

                            translate( [m_wall_thickness/2, m_wall_thickness/2, m_wall_underside_lid_storage_depth - 2] )
                            {
                                cube([  m_box_dimensions[ X ] - m_wall_thickness - (4 * m_tolerance), 
                                        m_box_dimensions[ Y ] - m_wall_thickness - (4  * m_tolerance), 
                                        2 ]);
                            } 
                        }
                    }
                    else
                    {
                        cube([  m_box_dimensions[ X ], 
                            m_box_dimensions[ Y ], 
                            m_box_dimensions[ Z ] - ( 1 * m_wall_lip_height) ] );     
                    }


                    notch_pos_z =  m_box_dimensions[ Z ] - m_wall_lip_height - m_notch_height;

                    translate([ 0, 0, notch_pos_z]) 
                        MakeLidNotches();

                    // if ( g_b_fit_lid_underneath )
                    // {
                    //     translate([ 0, 0, m_wall_lip_height]) 
                    //     {
                    //         MakeLidNotches();  
                    //     }
                    // }
                     
                                     
                }

                // inner, taller wall

                top_height = max( m_wall_lip_height, m_box_dimensions[ Z ] / 2  );

                // top half is a tighter fit
                translate( [m_wall_thickness/2, m_wall_thickness/2, max( 0, m_box_dimensions[ Z ] - top_height) ] )
                {
                    cube([  m_box_dimensions[ X ] - m_wall_thickness, 
                            m_box_dimensions[ Y ] - m_wall_thickness, 
                            top_height]);
                }       
                // lower half is a looser fit. If there's no lid storage in the base than this gets covered
                translate( [m_wall_thickness/2, m_wall_thickness/2, 0] )
                {
                    cube([  m_box_dimensions[ X ] - m_wall_thickness - (4 * m_tolerance), 
                            m_box_dimensions[ Y ] - m_wall_thickness - (4  * m_tolerance), 
                            m_box_dimensions[ Z ] / 2]);
                }        
                
            }
            else if ( m_is_lid )
            {
                MakeLid();
            }
            else if ( m_is_carve_outs ) 
            {
                // 'carve-outs' are the big shapes of the 'components.' Each is then subdivided
                // by adding partitions.
                cube([  __component_size( X ), 
                        __component_size( Y ), 
                        __component_size( Z )]);
            }
            else if ( m_is_additive_components )
            {
                MakePartitions();
            }
            else if ( m_is_final_carve_outs )
            {

                // Some shapes, such as the finger cutouts for card compartments
                // need to be done at the end becaause they substract from the 
                // entire box.

                // finger cutouts
                if ( __req_finger_cutouts() )
                {
                    InEachCompartment( y_modify = 0, only_y = false, only_x = true  )
                    {
                        MakeFingerCutout();
                    }
                }

                                // labels
                if ( __req_label() )
                {
                    LabelEachCompartment();
                }
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
                        {
                            rotate( 30, [ 0, 0, 1 ] )
                            {
                                children();
                            }
                        }
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

        module MakeStripedGrid( x = 200, y = 200, w = 1, dx = 0, dy = 0, ratio = 0.5 )
        {
            x2 = abs( __label_rotation( m_box_label ) ) == 90 ? y : x; 
            y2 = abs( __label_rotation( m_box_label ) ) == 90 ? x : y;

            dx2 = abs( __label_rotation( m_box_label ) ) == 90 ? dy : dx;
            dy2 = abs( __label_rotation( m_box_label ) ) == 90 ? dx : dy;

            x_count = x / ( w + dx2 );
            y_count = y / ( w + dy2 );

            if ( dx2 > 0 )
            {
                for( j = [ 0: x_count ] )
                {
                    translate( [ j * ( w + dx2 ), 0, ( 1 - ratio ) * m_lid_thickness ] )
                    {
                        cube( [ w, y, m_lid_thickness * ratio ]);
                    }
                }
            }

            if ( dy2 > 0 )
            {
                for( j = [ 0: y_count ] )
                {
                    translate( [ 0, j * ( w + dy2 ), ( 1 - ratio ) * m_lid_thickness ] )
                    {
                        cube( [ x, w, m_lid_thickness * ratio ]);
                    }
                }
            }
        }



///////////////////////

        module MakeLid() 
        {
            module MoveToLidInterior()
            {
                translate([ ( m_wall_thickness - m_tolerance )/2 , ( m_wall_thickness - m_tolerance )/2, 0]) 
                {
                    children();
                }
            }

            module MakeLidText( offset = 0, thickness = m_lid_thickness )
            {
                linear_extrude( thickness )
                {
                    translate( [ __lid_external_size( X )/2, __lid_external_size( Y )/2, 0 ] )
                    {
                        MirrorAboutPoint( [ 1,0,0],[0,0, thickness / 2])
                        {
                            RotateAboutPoint( __label_rotation( m_box_label ), [0,0,1], [0,0,0] )
                            {
                                offset( offset )
                                {
                                    text(text = str( __label_text( m_box_label ) ), 
                                        font="Liberation Sans:style=Bold", 
                                        size = __label_size( m_box_label), 
                                        valign = "center", 
                                        halign = "center", 
                                        $fn=1);
                                }
                            }
                        }
                    }
                }

            }

            lid_print_position = [0, m_box_dimensions[ Y ] + DISTANCE_BETWEEN_PARTS, 0 ];
            lid_vis_position = [ 0, 0, m_box_dimensions[ Z ] + m_lid_thickness ];
          
            translate( g_b_visualization ? lid_vis_position : lid_print_position ) 
            RotateAboutPoint( g_b_visualization ? 180 : 0, [0, 1, 0], [__lid_external_size( X )/2, __lid_external_size( Y )/2, 0] )
            {
                // lid edge only
                difference() 
                {
                    // main __box
                    cube([__lid_external_size( X ), __lid_external_size( Y ), __lid_external_size( Z )]);
                    
                    MoveToLidInterior()
                    {
                        cube([  __lid_internal_size( X ), __lid_internal_size( Y ),  __lid_external_size( Z )]);
                    }
                }

                difference()
                {
                    linear_extrude( m_lid_thickness )
                    {
                        R = 4.0;
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
                        MakeLidText( 4 );
                    }
                    else if ( !m_box_has_thin_lid )
                    {
                        MakeLidText( 0, thickness = m_lid_thickness / 2 );
                    }
                    
                }
                

                if ( !__has_simple_lid() )
                {
                    intersection()
                    {
                        MakeStripedGrid( x = __lid_external_size( X ), y = __lid_external_size( Y ), w = 0.5, dx = 0, dy = 1, ratio = 0.5 );

                        MakeLidText( offset = 4 );                  
                    }
                }

                if ( !__has_simple_lid() )
                    MakeLidText();

                if ( !__has_simple_lid() )
                {
                    difference()
                    {
                        MakeLidText( 4 );
                        MakeLidText( 3 );
                    }
                }
            }
        }


        module InEachCompartment( x_modify = 0, y_modify = 0 , only_x = false, only_y = false )
        {
            only_x2 = __RotatedResult( _0 = only_x, _90 = only_y, _180 = only_x, _n90 = only_y  );
            only_y2 = __RotatedResult( _0 = only_y, _90 = only_x, _180 = only_y, _n90 = only_x  );

            x2_modify = __RotatedResult( _0 = x_modify, _90 = y_modify, _180 = x_modify, _n90 = y_modify );
            y2_modify = __RotatedResult( _0 = y_modify, _90 = x_modify, _180 = y_modify, _n90 = x_modify );

            n_x = only_y2 ? 1  : __compartments_num( X ) + x2_modify;
            n_y = only_x2 ? 1 : __compartments_num( Y ) + y2_modify;

            b_continue = only_x2 ? n_x > 0 : only_y2 ? n_y > 0 : true;  
            
            if ( b_continue )
            {
                for ( x = [ 0: n_x - 1] )
                {
                    x_pos = ( __compartment_size( X ) + __partition_thickness( X ) ) * x;

                    for ( y = [ 0: n_y - 1] )
                    {
                        y_pos = ( ( __compartment_size( Y ) ) + __partition_thickness( Y ) ) * y;

                        translate( [ x_pos ,  y_pos , 0 ] )
                        {
                            children();
                        }
                    }
                }
            }
        }

        module LabelEachCompartment()
        {
            n_x = __compartments_num( X );
            n_y = __compartments_num( Y );

        for ( x = [ 0: n_x - 1] )
            {
                x_pos = ( __compartment_size( X ) + __partition_thickness( X ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = ( ( __compartment_size( Y ) ) + __partition_thickness( Y ) ) * y;

                    translate( [ x_pos ,  y_pos , 0 ] )
                    {
                        MakeLabel( x, y );
                    }
                }
            }
            
        }        

        module MakeFingerCutout()
        {
            cutout_y = __is_chit_stack_vertical() ? __component_size( __Y2() ) / 2 : __component_size( __Y2() );

            cutout_x = min ( PARTITION_FINGERS * 2, __compartment_size( __X2() ) * .5 );
            cutout_z = m_box_dimensions[ Z ] - 2.0;

            translation = __RotatedResult( _0 = [ __compartment_size( X )/2 - cutout_x/2, 0, __finger_cutouts_bottom() ],
                                         _90 = [ 0, __compartment_size( Y )/2 - cutout_x/2, __finger_cutouts_bottom() ],
                                         _180 = [ __compartment_size( X )/2 - cutout_x/2, 0, __finger_cutouts_bottom() ],
                                         _n90 = [ 0, __compartment_size( Y )/2 - cutout_x/2, __finger_cutouts_bottom() ] );

            cube_rotated = __RotatedResult( _0 = [ cutout_x , cutout_y, cutout_z ],
                                            _90 = [ cutout_y, cutout_x , cutout_z ],
                                            _180 = [ cutout_x , cutout_y, cutout_z ],
                                            _n90 = [ cutout_y, cutout_x , cutout_z ] );


            translate( translation )
            {
                cube( cube_rotated );
            }
        }


        // this rounds out the bottoms regardless of the size of the compartment
        // and doesn't attempt to fit a specific shape.
       module MakeBottomsRounded()
        {
            r = __height_for_rounded_bottom();

            rotated = abs( __component_rotation() ) == 90;

            difference()
            { 
                // blocks
                    
                cube_rotated = __RotatedResult( _0 = [ r, __compartment_size( Y ), r ],
                                                _90 = [ __compartment_size( X ), r, r ],
                                                _180 = [ r, __compartment_size( Y ), r ],
                                                _n90 = [ __compartment_size( X ), r, r ] );


                cube_translated = __RotatedResult( _0 = [ 0, 0, 0 ],
                                                _90 = [ 0, 0, 0, ],
                                                _180 = [ __compartment_size( X ) - r, 0, 0 ],
                                                _n90 = [ 0, __compartment_size( Y ) - r, 0 ] );

                                                echo( __component_rotation(), cube_translated);
               translate( cube_translated )
                {
                    cube ( cube_rotated );
                }

                // cylinders

                cylinder_translated = __RotatedResult( _0 = [ r, __compartment_size( Y ), r ],
                                                _90 = [ 0, r, r ],
                                                _180 = [ __compartment_size( X ) - r, 0, r ],
                                                _n90 = [ __compartment_size( X ), __compartment_size( Y ) - r, r ] );
                    
               translate( cylinder_translated )
                {
                    rotate( [ 90, 0, __component_rotation() ], 0 )
                    {
                        cylinder(h = __compartment_size( __Y2() ), r1 = r, r2 = r);  
                    } 
                }
                
            }
                    
        }

        module MakeBottoms()
        {
            $fn = __component_shape() == "hex" ? 6 : 100;

            r = __compartment_size( __X2() )/2;
 
            translation = __RotatedResult( _0 = [ 0, __partition_thickness( Y ), 0 ],
                                                _90 = [ __partition_thickness( X ), 0, 0, ],
                                                _180 = [ 0, __partition_thickness( Y ), 0 ],
                                                _n90 = [ __partition_thickness( X ), 0, 0 ] );


            translate( translation )
            {
                difference()
                { 
                    // blocks

                cube_rotated = __RotatedResult( _0 = [ r, __compartment_size( Y ), r ],
                                                _90 = [ __compartment_size( X ), r, r ],
                                                _180 = [ r, __compartment_size( Y ), r ],
                                                _n90 = [ __compartment_size( X ), r, r ] );


                cube_translated = __RotatedResult( _0 = [ 0, 0, 0 ],
                                                _90 = [ 0, 0, 0, ],
                                                _180 = [ __compartment_size( X ) - r, 0, 0 ],
                                                _n90 = [ 0, __compartment_size( Y ) - r, 0 ] );

                    cube ( [ __compartment_size( X ), __compartment_size( Y ), __compartment_size( Z ) / 2 ] );
                    

                    // cylinders
                    union()
                    {

                        cylinder_translation = __RotatedResult( _0 = [ r , __compartment_size( Y ) , r ],
                                                                _90 = [ 0 , (__compartment_size( Y ) )/2 , r ],
                                                                _180 = [ r , __compartment_size( Y ) , r ],
                                                                _n90 = [ 0 , (__compartment_size( Y ) )/2 , r ] );

                        translate( cylinder_translation )
                        {
                            cylinder_rotation = __RotatedResult( _0 = [ 1, 0, 0 ],
                                                                _90 = [ 0, 1, 0, ],
                                                                _180 = [ 1, 0, 0 ],
                                                                _n90 = [ 0, 1, 0 ] );

                            rotate( 90, cylinder_rotation )
                            {
                                cylinder(h = __compartment_size( __Y2() ), r1 = r, r2 = r );  
                            } 
                        }

                        // midpoint--up. clear the rest of the compartment
                        translate( [ 0,0, r ])
                        {
                            cube ( [ __compartment_size( X ), __compartment_size( Y ), m_box_dimensions[ Z ]] );
                        }
                    }
                }       
            }    
        }

        module ShapeCompartment()
        {
            $fn = __component_shape() == "hex" ? 6 : 100;

            r = __compartment_smallest_dimension()/2;
 
            {
                difference()
                { 
                    // blocks

                    cube ( [ __compartment_size( X ), __compartment_size( Y ) + __partition_thickness(Y), __compartment_size( Z ) ] );
                    
                    // cylinders

                    translate( [ r , r + __partition_thickness(Y) , r ] )
                    {
                        rotate( 30, [0, 0, 1] )
                        {
                            cylinder(h = __compartment_size( Y ), r1 = r, r2 = r, center = true );  
                        } 
                    }
                }       
            }    
        }

        module MakeLabel( x = 0, y = 0 )
        {
            z_pos = __req_finger_cutouts() ? __finger_cutouts_bottom() - __label_depth( m_component_label ) : - __label_depth( m_component_label );

            translate( [ __compartment_size(X)/2, __compartment_size(Y)/2, z_pos] )
            {
                RotateAboutPoint( __label_rotation( m_component_label ), [0,0,1], [0,0,0] )
                {
                    linear_extrude( 2 * __label_depth( m_component_label ) )
                    {
                        text(text = str( __label_text( m_component_label, x, y ) ), 
                        font="Liberation Sans:style=Bold", 
                        size = __label_size( m_component_label ), 
                        valign = "center", 
                        halign = "center", $fn=1);
                    }
                }
            }
        }

        module MakePartitions()
        {
            InEachCompartment( only_x = true, x_modify = __partition_num_modifier( __X2() ) )   
            {
                MakePartition( axis = __X2() );  
            }

            InEachCompartment( only_y = true, y_modify = __partition_num_modifier( __Y2() ) )  
            {
                MakePartition( axis = __Y2() );  
            }


            InEachCompartment( x_modify = 0, y_modify = 0 )
            {
                if ( __req_bottoms() )
                {
                    if ( __is_chit_stack() )
                    {
                        MakeBottoms();
                    }
                    else if ( __is_tokens() )
                    {
                        MakeBottomsRounded();
                    }
                }
                
                if ( __is_chit_stack_vertical() )
                {
                    ShapeCompartment();
                }
            }
        }

        module MakePartition( axis )
        {
            start_pos_x = __partition_num_modifier( X ) > -1 ? 0 : __compartment_size( X );
            start_pos_y = __partition_num_modifier( Y ) > -1 ? 0 : __compartment_size( Y );

            if ( axis == X )
            {
                translate( [ start_pos_x, 0, 0 ] )
                {
                    cube ( [ __partition_thickness( X ), __component_size( Y ), __partition_height( X )  ] );
                }
            }
            else if ( axis == Y )
            {
                translate( [ 0, start_pos_y, 0 ] )
                {
                    cube ( [ __component_size( X ), __partition_thickness( Y ) , __partition_height( Y ) ] );     
                }  
            }
        }

        module MakeCornerNotch()
        {
            {
                cube([ __notch_length( X ), __notch_depth(), m_notch_height ]);
                cube([__notch_depth(), __notch_length( Y ), m_notch_height]);
            }
        }

        module MakeLidNotches()
        {
            MakeCornerNotch();

            MirrorAboutPoint( [1,0,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MakeCornerNotch();
            }

            MirrorAboutPoint( [0,1,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MakeCornerNotch();
            }

            MirrorAboutPoint( [1,0,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
            {
                MirrorAboutPoint( [0,1,0], [ m_box_dimensions[ X ] / 2, m_box_dimensions[ Y ] / 2, 0] )
                {
                    MakeCornerNotch();    
                }
            }
        }
    }

}














