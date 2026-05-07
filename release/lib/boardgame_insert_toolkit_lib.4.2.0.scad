/*
 * The Boardgame Insert Toolkit - Library File
 * Version: 4.2.0
 * 
 * A parametric system for creating custom board game inserts and organizers
 * https://github.com/dppdppd/The-Boardgame-Insert-Toolkit
 * 
 * 
 * Released under the Creative Commons - Attribution - Non-Commercial - Share Alike License.
 * https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
 * 
 * This library provides functions and modules for creating custom board game inserts.
 * It allows the user to define boxes, dividers, lids, and other components for 
 * organizing board game pieces and cards.
 */

// =============================================================================
// TABLE OF CONTENTS
// =============================================================================
//
//   Line  Section
//   ----  -------
//    46   Constants, enums, keywords, internal defaults
//   247   Key-value helpers
//   332   Utility modules (debug, rotate, mirror, colorize, shear)
//   389   Data accessor functions (elements, auto-size, dividers, labels)
//   507   Geometry helpers (Make2dShape, Make2DPattern, MakeStripedGrid)
//   646   Key validation (__ValidateTable, __ValidateElement)
//  1161   MakeAll() — top-level entry point
//  1231   MakeDividers() — card divider generation
//  1350   MakeBox() — box generation
//  1488     MakeLayer() — component processing pipeline
//  1591       Layer positioning (ContainWithinBox, PositionInnerLayer)
//  1727       Lid base geometry (Inset, Cap, Edge)
//  1837       Box shell & spacer
//  1889       Inner layer dispatch
//  2030       Box-level cutout dispatch
//  2070       Lid & box labels
//  2269       Lid assembly (MakeLid, mesh, surface)
//  2453       Iteration helpers (ForEach*, InEach*)
//  2541       Cutout & fillet geometry
//  2823       Compartment shapes
//  2903       Component labels
//  2996       Partitions & margins
//  3045       Lid hardware (notches, tabs, detents)
//  3229   MakeRoundedCubeAxis() — rounded cube utility
//
// =============================================================================


// Version information
VERSION = "4.2.0";
COPYRIGHT_INFO = "\tThe Boardgame Insert Toolkit\n\thttps://github.com/dppdppd/The-Boardgame-Insert-Toolkit\n\n\tCopyright 2020 Ido Magal\n\tCreative Commons - Attribution - Non-Commercial - Share Alike.\n\thttps://creativecommons.org/licenses/by-nc-sa/4.0/legalcode";

// Resolution settings
// Lower resolution for previews (faster) and higher for final rendering
fn = $preview ? 10 : 100;
$fn = fn;

// =============================================================================
// COMMON CONSTANTS AND UTILITY VALUES
// =============================================================================

// Dictionary/associative array indexing constants
k_key = 0;    // Index for keys in key-value pairs
k_value = 1;  // Index for values in key-value pairs

// Small value to prevent z-fighting in preview mode
epsilon = $preview ? 0.02 : 0; // extend cuts by a bit to fight z-fighting during preview

// Coordinate system constants
k_x = 0;      // X-axis index in coordinate arrays
k_y = 1;      // Y-axis index in coordinate arrays
k_z = 2;      // Z-axis index in coordinate arrays

k_hex_d = 0;  // Hex diameter index
k_hex_z = 1;  // Hex height index

// Direction/orientation constants
k_front = 0;
k_back = 1;
k_left = 2;
k_right = 3;

// Corner position constants
k_front_left = 0;
k_back_right = 1;
k_back_left = 2;
k_front_right = 3;

// Boolean aliases for readability
t = true;
f = false;

// PARAMETER KEYWORDS

// Component type identifiers
TYPE = "type";
BOX = "box";
DIVIDERS = "dividers";
SPACER = "spacer";

// New-style element type constants
OBJECT_BOX = "object_box";
OBJECT_DIVIDERS = "object_dividers";
OBJECT_SPACER = "object_spacer";
NAME = "name";

BOX_LID = "box_lid";

// =============================================================================
// DIVIDER PARAMETERS
// =============================================================================
DIV_THICKNESS = "div_thickness";        // Thickness of divider walls
DIV_NUM_DIVIDERS = "div_num_dividers";  // Number of generated dividers
DIV_AXIS = "div_axis";                  // Divider orientation axis, X or Y
X = "x";
Y = "y";

// Tab parameters
DIV_TAB_SIZE_XY = "div_tab_size";       // Size of tabs on dividers [x,y]
DIV_TAB_RADIUS = "div_tab_radius";      // Radius of tab corners
DIV_TAB_CYCLE = "div_tab_cycle";        // Pattern of tab placement
DIV_TAB_CYCLE_START = "div_tab_cycle_start"; // Starting position in pattern

// Tab text parameters
DIV_TAB_TEXT = "div_tab_text";          // Text to display on tabs
DIV_TAB_TEXT_SIZE = "DIV_TAB_TEXT_size"; // Text size
DIV_TAB_TEXT_FONT = "DIV_TAB_TEXT_font"; // Text font
DIV_TAB_TEXT_SPACING = "DIV_TAB_TEXT_spacing"; // Spacing between characters
DIV_TAB_TEXT_CHAR_THRESHOLD = "DIV_TAB_TEXT_char_threshold"; // Min chars for text display
DIV_TAB_TEXT_EMBOSSED_B = "div_tab_text_embossed_b"; // true = raised text, false = cut text (default)

// Frame parameters
DIV_FRAME_SIZE_XY = "div_frame_size";   // Size of divider frame [x,y]
DIV_FRAME_TOP = "div_frame_top";        // Frame top edge settings
DIV_FRAME_BOTTOM = "div_frame_bottom";  // Frame bottom edge settings
DIV_FRAME_COLUMN = "div_frame_column";  // Frame column settings
DIV_FRAME_RADIUS = "div_frame_radius";  // Corner radius of frame
DIV_FRAME_NUM_COLUMNS = "div_frame_num_columns"; // Number of columns in frame

// =============================================================================
// BOX PARAMETERS
// =============================================================================
BOX_SIZE_XYZ = "box_size";              // Box dimensions [x,y,z]
BOX_FEATURE = "component";            // Component to be contained in box
FTR_DIVIDERS = "dividers";             // Divider subgroup inside a box component
BOX_VISUALIZATION = "visualization";    // Visualization settings

BOX_WALL_THICKNESS = "wall_thickness";  // Per-box wall thickness override
BOX_NO_LID_B = "no_lid";                // Boolean: box has no lid
BOX_STACKABLE_B = "stackable";          // Boolean: box can be stacked
CHAMFER_N = "chamfer_n";                // Number: chamfer surface width in mm (diagonal of the 45° face)

// =============================================================================
// LID PARAMETERS
// =============================================================================
LID_FIT_UNDER_B = "fit_lid_under";      // Boolean: lid fits under box when not in use
LID_SOLID_B = "box_lid_solid";          // Boolean: lid is solid (no pattern)
LID_HEIGHT = "lid_height";              // Height of lid
LID_CUTOUT_SIDES_4B = "lid_cutout_sides"; // Boolean array: which sides have cutouts [front,back,left,right]
LID_LABELS_INVERT_B = "lid_label_inverted"; // Boolean: invert label imprint
LID_SOLID_LABELS_DEPTH = "lid_label_depth"; // Depth of embossed/debossed labels
LID_LABELS_BG_THICKNESS = "lid_label_bg_thickness"; // Thickness of label background
LID_LABELS_BORDER_THICKNESS = "lid_label_border_thickness"; // Thickness of label border
LID_STRIPE_WIDTH = "lid_stripe_width";  // Width of decorative stripes on lid
LID_STRIPE_SPACE = "lid_stripe_space";  // Space between stripes
LID_TYPE = "lid_type";                  // Lid style: LID_CAP, LID_INSET, or LID_SLIDING
LID_SLIDE_SIDE = "lid_slide_side";      // Side a sliding lid opens from: FRONT, BACK, LEFT, or RIGHT
LID_FRAME_WIDTH = "lid_frame_width";    // Width of patterned lid perimeter frame
LID_INSET_B = "lid_inset";              // Boolean: lid is inset into box
LID_TABS_4B = "lid_tabs";               // Boolean array: which sides have tabs [front,back,left,right]

LID_CAP = "cap";
LID_INSET = "inset";
LID_SLIDING = "sliding";

// Lid pattern parameters
LID_PATTERN_RADIUS = "lid_hex_radius";  // Radius of hex pattern elements
LID_PATTERN_N1 = "lid_pattern_n1";      // Pattern density parameter 1
LID_PATTERN_N2 = "lid_pattern_n2";      // Pattern density parameter 2
LID_PATTERN_ANGLE = "lid_pattern_angle"; // Rotation angle of pattern
LID_PATTERN_ROW_OFFSET = "lid_pattern_row_offset"; // Offset between pattern rows
LID_PATTERN_COL_OFFSET = "lid_pattern_col_offset"; // Offset between pattern columns
LID_PATTERN_THICKNESS = "lid_pattern_thickness";  // Thickness of pattern elements

// =============================================================================
// COMPARTMENT PARAMETERS
// =============================================================================
FTR_NUM_COMPARTMENTS_XY = "num_compartments";
FTR_COMPARTMENT_SIZE_XYZ = "compartment_size";
FTR_SHAPE = "shape";
FTR_SHAPE_ROTATED_B = "shape_rotated_90";
FTR_SHAPE_VERTICAL_B = "shape_vertical";
FTR_PADDING_XY = "padding";
FTR_PADDING_HEIGHT_ADJUST_XY = "padding_height_adjust";
FTR_MARGIN_FBLR = "margin_dim";
FTR_CUTOUT_SIDES_4B = "cutout_sides";
FTR_CUTOUT_CORNERS_4B = "cutout_corners";
FTR_CUTOUT_HEIGHT_PCT = "cutout_height_percent";
FTR_CUTOUT_DEPTH_PCT = "cutout_depth_percent";
FTR_CUTOUT_WIDTH_PCT = "cutout_width_percent";
FTR_CUTOUT_BOTTOM_B = "cutout_bottom";
FTR_CUTOUT_BOTTOM_PCT = "cutout_bottom_percent";
FTR_CUTOUT_TYPE = "cutout_type";
FTR_CUTOUT_DEPTH_MAX = "cutout_depth_max"; // Maximum absolute cutout depth in mm
DIV_SLOT_DEPTH = "div_slot_depth";
DIV_RAILS_B = "div_rails_b";            // true = add box-side divider rails
DIV_OUTPUT_ONLY_B = "div_output_only_b"; // true = output only generated feature dividers
FTR_SHEAR = "shear";
FTR_FILLET_RADIUS = "fillet_radius";
FTR_PEDESTAL_BASE_B = "push_base";

// =============================================================================
// LABEL PARAMETERS
// =============================================================================
LBL_TEXT = "text";
LBL_IMAGE = "image";
LBL_SIZE = "size";
LBL_PLACEMENT = "placement";
LBL_FONT = "font";
LBL_DEPTH = "depth";
LBL_SPACING = "spacing";
LBL_AUTO_SCALE_FACTOR = "label_scale_factor";
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
BOTTOM = "bottom";
///

AUTO = "auto";
MAX = "max";

ENABLED_B = "enabled";
DEBUG_B = "_debug";
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

INTERIOR = "interior";
EXTERIOR = "exterior";
BOTH = "both";


// INTERNAL DEFAULTS (magic numbers extracted for clarity)
DEFAULT_INSET_LID_HEIGHT = 2.0;       // Default lid wall height for inset lids
DEFAULT_CAP_LID_HEIGHT = 4.0;         // Default lid wall height for cap lids
DEFAULT_PEDESTAL_BASE_FRACTION = 0.4;  // Fraction of compartment height for pedestal base
DEFAULT_MAX_LABEL_WIDTH = 100;         // Maximum auto-width for labels
DEFAULT_STRIPE_ANGLE = 45;            // Rotation angle for lid stripe grid
DEFAULT_MAX_CUTOUT_CORNER_RADIUS = 3;  // Maximum radius for cutout corners
DEFAULT_CORNER_CUTOUT_INSET_FRACTION = 1/4; // Fraction of compartment inset for corner cutouts
DEFAULT_DETENT_SPHERE_RADIUS = 1;      // Radius of detent bump spheres
LID_TAB_MODIFIER_SCALE = 10;          // Scale factor for lid tab size modifier
LABEL_FRAME_HULL_EXTENT = 200;        // Hull extent for label frame generation
DEFAULT_DIV_TAB_RADIUS = 4;           // Default divider tab corner radius
DEFAULT_TAB_TEXT_WIDTH_FRACTION = 0.8; // Fraction of tab width used for text scaling
MIN_CORNER_RADIUS = 0.001;            // Minimum corner radius for MakeRoundedCubeAxis
MIN_PRINTABLE_WALL_THICKNESS = 0.8;   // Physical validation threshold for printable walls
MIN_PRINTABLE_DETAIL_THICKNESS = 0.4; // Physical validation threshold for thin printed details
HULL_EPSILON = 0.01;                  // Small height for hull/cap operations

DISTANCE_BETWEEN_PARTS = 2;

// Default data array (empty, overridden by Make() parameter)
DATA = [];

// Global string constants for globals-in-data pattern (CTD-style)
G_PRINT_LID_B = "g_print_lid_b";
G_PRINT_BOX_B = "g_print_box_b";
G_PRINT_DIVIDERS = "g_print_dividers";
G_PRINT_DIVIDERS_ONLY_B = "g_print_dividers_only";
G_FIT_TEST_B = "g_fit_test_b";
G_ISOLATED_PRINT_BOX = "g_isolated_print_box";
G_VISUALIZATION_B = "g_visualization_b";
G_PREVIEW_NO_LABELS_B = "g_preview_no_labels_b";
G_VALIDATE_KEYS_B = "g_validate_keys_b";
G_VALIDATE_PHYSICAL_B = "g_validate_physical_b";
G_WALL_THICKNESS = "g_wall_thickness";
G_DETENT_THICKNESS = "g_detent_thickness";
G_DETENT_SPACING = "g_detent_spacing";
G_DETENT_DIST_FROM_CORNER = "g_detent_dist_from_corner";
G_DETENT_MIN_SPACING = "g_detent_min_spacing";
G_LID_THICKNESS = "g_lid_thickness";
G_COLORIZE_B = "g_colorize_b";
G_TOLERANCE = "g_tolerance";
G_TOLERANCE_DETENT_POS = "g_tolerance_detent_pos";
G_PRINT_MMU_LAYER = "g_print_mmu_layer";
G_DEFAULT_FONT = "g_default_font";

// key-values helpers

// =============================================================================
// KEY-VALUE HELPERS
// =============================================================================

function __index_of_key( table, key ) = search( [ key ], table )[ k_key ];
function __value( table, key, default = false ) = __index_of_key( table, key ) == [] ? default : table[ __index_of_key( table, key ) ][ k_value ];

// Return the whole sub-entry for a key (for nested blocks like BOX_LID, BOX_FEATURE, LABEL)
function __find_entry(table, key, default=[]) =
    let(idx = __index_of_key(table, key))
    idx == [] ? default : table[idx];

// determines whether lids are output.
$g_print_lid_b = t;

// determines whether boxes are output.
$g_print_box_b = t; 

// Determines which generated divider panels are output. true = all,
// false = none, string/list = matching divider/component/box names.
$g_print_dividers = t;

// When true, suppresses boxes and lids and outputs only selected dividers.
$g_print_dividers_only_b = f;

// determines whether to output everything as placeholders.
$g_fit_test_b = f;

// Focus on one box
$g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together.
$g_visualization_b = f;
$g_vis_actual_b = $g_visualization_b && $preview;

// Turn off labels during preview. 
$g_preview_no_labels_b = f;
$g_no_labels_actual_b = $g_preview_no_labels_b && $preview;

// Validate user-provided keys and echo messages for unrecognized ones.
// Set to false to suppress key/type validation output.
$g_validate_keys_b = t;

// Validate physical fit and printability risks.
// Defaults to key validation when G_VALIDATE_PHYSICAL_B is not provided,
// preserving legacy G_VALIDATE_KEYS_B=false behavior.
$g_validate_physical_b = t;

// Wall thickness in mm. Default = 2.0
// Increasing this makes stronger but heavier components
$g_wall_thickness = 2.0;

// Thickness of lid and box detent mechanism in mm
// For a looser snap fit, reduce this value
// For a tighter snap fit, increase this value
// Recommended 0.05 increments for adjustments
$g_detent_thickness = 0.25;

// Translates to length of detent in mm
$g_detent_spacing = 2;

// Distance from corner to start detent placement
$g_detent_dist_from_corner = 1.5;

// If the distance from the corner to the tab is greater than this,
// add another detent next to the tab
$g_detent_min_spacing = 40;

// Thickness of the box lid in mm. false = same as wall thickness
$g_lid_thickness = false;

// Colorization for development
// When true, gives each compartment a different color to help
// visualize the structure during development
$g_colorize_b = true;

// Tolerance for fittings in mm
// This is the gap between fitting pieces such as lids and boxes
// Increase to loosen the fit, decrease to tighten it
$g_tolerance = 0.1;

// Adjusts the position of lid detents downwards
// The larger the value, the bigger the gap between lid and box
$g_tolerance_detent_pos = 0.1;

// Multi-material printing configuration
// This determines whether the default single material version is output, or,
// when printing in multiple materials, which layer to output.
// Options:
//   - "default": standard single material output
//   - "mmu_box_layer": the box layer for multi-material printing
//   - "mmu_label_layer": the label layer for multi-material printing
$g_print_mmu_layer = "default";

// Default font for labels
$g_default_font = "Liberation Sans:style=Regular";


m_corner_width = 6;

m_lid_notch_height = 2.0;
m_lid_notches = true;


// =============================================================================
// UTILITY MODULES
// =============================================================================

module debug( w = 0.2, l = 100 )
{
    // X-axis (red by default in OpenSCAD)
    #translate( [ -w/2, -w/2, -l/2])
        cube( [ w , w, l ] );
    
    // Y-axis (green by default in OpenSCAD)
    #translate( [ -w/2, -l/2, -w/2])
        cube( [ w , l, w ] );
    
    // Z-axis (blue by default in OpenSCAD)
    #translate( [ -l/2, -w/2, -w/2])
        cube( [ l , w, w ] );                
}

/**
 * Rotates children and moves them back to origin based on bounding box
 * Useful for orientation changes while maintaining position
 *
 * @param a Rotation angle in degrees (supports 90, -90, and -180)
 * @param extents The dimensions [x,y,z] of the object being rotated
 */
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



// =============================================================================
// DATA ACCESSOR FUNCTIONS
// =============================================================================

function __element( i ) = $data[ i ];
function __num_elements() = len( $data );

// Map OBJECT_* key → internal type constant
function __type_from_key(k) =
    k == OBJECT_BOX ? BOX :
    k == OBJECT_SPACER ? SPACER :
    k == OBJECT_DIVIDERS ? DIVIDERS : undef;

// Get type for element at index i (checks data key first, falls back to TYPE property)
function __type_at(i) =
    let(k = $data[i][k_key])
    __type_from_key(k) != undef ? __type_from_key(k)
    : __value(__element(i), TYPE, default = BOX);

// Legacy: get type from element params (for internal callers that have the list)
function __type( lmnt ) =
    let(from_key = __type_from_key(lmnt[0]))
    from_key != undef ? from_key
    : __value( lmnt, TYPE, default = BOX);

// Get display name: NAME property (new-style) or string key (old-style)
function __element_name(i) =
    __type_from_key($data[i][k_key]) != undef
        ? __value(__element(i), NAME, default = "")
        : $data[i][k_key];

// Isolated print: search by NAME across all elements
function __find_isolated_index() =
    $g_isolated_print_box == "" ? undef :
    let(matches = [for (i=[0:len($data)-1]) if (__element_name(i) == $g_isolated_print_box) i])
    len(matches) > 0 ? matches[0] : undef;

function __is_element_isolated_for_print() = __find_isolated_index() != undef;

function __is_element_enabled( lmnt ) = __value( lmnt, ENABLED_B, default = true);
function __is_element_debug( lmnt ) = __value( lmnt, DEBUG_B, default = false);

// --- Auto-size helpers ---
// Compute a single component's total size from its parameter table.
// Mirrors the formula in MakeLayer: compartment * num + (num-1) * padding + margins
function __cmp_auto_compartment_size( comp ) = __value( comp, FTR_COMPARTMENT_SIZE_XYZ, default = [10, 10, 10] );
function __cmp_auto_num( comp ) = __value( comp, FTR_NUM_COMPARTMENTS_XY, default = [1, 1] );
function __cmp_auto_padding( comp ) = __value( comp, FTR_PADDING_XY, default = [1, 1] );
function __cmp_auto_margin( comp ) = __value( comp, FTR_MARGIN_FBLR, default = [0, 0, 0, 0] );

function __cmp_auto_size( comp, D ) = 
    D == k_z ? __cmp_auto_compartment_size( comp )[ k_z ] :
    D == k_x ? __cmp_auto_compartment_size( comp )[ k_x ] * __cmp_auto_num( comp )[ k_x ]
               + max( 0, __cmp_auto_num( comp )[ k_x ] - 1 ) * __cmp_auto_padding( comp )[ k_x ]
               + __cmp_auto_margin( comp )[ k_left ] + __cmp_auto_margin( comp )[ k_right ] :
    // k_y
               __cmp_auto_compartment_size( comp )[ k_y ] * __cmp_auto_num( comp )[ k_y ]
               + max( 0, __cmp_auto_num( comp )[ k_y ] - 1 ) * __cmp_auto_padding( comp )[ k_y ]
               + __cmp_auto_margin( comp )[ k_front ] + __cmp_auto_margin( comp )[ k_back ];

// Scan all BOX_FEATURE entries in box, return the max component size per dimension.
// For centered components (default), the box needs to fit the largest one.
// For explicitly positioned components, compute position + size to find the envelope.
function __box_max_component_extent( box, D, i = 0 ) = 
    !is_list( box ) || i >= len( box ) ? 0 :
    ( is_list( box[i] ) && len( box[i] ) >= 2 && box[i][ k_key ] == BOX_FEATURE ) ?
        let(
            comp = box[i],
            pos_raw = __value( comp, POSITION_XY, default = [ CENTER, CENTER ] ),
            comp_size = ( D == k_z ) ? __cmp_auto_size( comp, k_z ) :
                        __cmp_auto_size( comp, D ),
            // For centered/max positions, extent is just the component size.
            // For numeric positions, extent is position + component size.
            di = ( D == k_z ) ? 0 : ( D == k_x ? 0 : 1 ),
            pos_val = ( D == k_z ) ? 0 :
                      ( is_list( pos_raw ) && len( pos_raw ) > di ) ? pos_raw[ di ] : CENTER,
            extent = ( D == k_z ) ? comp_size :
                     ( is_num( pos_val ) ) ? pos_val + comp_size :
                     comp_size  // CENTER or MAX — just use component size
        )
        max( extent, __box_max_component_extent( box, D, i + 1 ) ) :
    __box_max_component_extent( box, D, i + 1 );

// Auto-calculate box size from components + wall thickness.
function __box_auto_size( box ) = 
    let(
        wt = __value( box, BOX_WALL_THICKNESS, default = $g_wall_thickness ),
        cx = __box_max_component_extent( box, k_x ),
        cy = __box_max_component_extent( box, k_y ),
        cz = __box_max_component_extent( box, k_z )
    )
    [ cx + 2 * wt, cy + 2 * wt, cz + wt ];

function __element_dimensions(lmnt_or_i) =
    is_num(lmnt_or_i)
        ? __element_dimensions_impl(__element(lmnt_or_i), __type_at(lmnt_or_i))
        : __element_dimensions_impl(lmnt_or_i, __type(lmnt_or_i));

function __element_dimensions_impl(lmnt, etype) = !is_list(lmnt)
    ? [100, 100, 100]
    : etype == DIVIDERS
        ? [__div_frame_size(lmnt)[k_x], __div_total_height(lmnt)]
        : __value(lmnt, BOX_SIZE_XYZ, default = false) != false
            ? __value(lmnt, BOX_SIZE_XYZ) : __box_auto_size(lmnt);

function __element_position_x( i ) = __element( i - 1 ) == undef ? 0 : __is_element_enabled( __element( i - 1 ) ) ? __element_dimensions( __element( i - 1 ) )[ k_x ] + __element_position_x( i - 1 ) + DISTANCE_BETWEEN_PARTS : __element_position_x( i - 2 );

//vis
function __box_vis_data( box ) = __value( box, BOX_VISUALIZATION, default = "");
function __box_vis_position( box ) = __value( __box_vis_data( box ), POSITION_XY );
function __box_vis_rotation( box ) = __value( __box_vis_data( box ), ROTATION );

function __div_thickness( div ) = __value( div, DIV_THICKNESS, default = 0.5 );
function __div_tab_size( div ) = __value( div, DIV_TAB_SIZE_XY, default = [32, 14] );
function __div_tab_radius( div ) = __value( div, DIV_TAB_RADIUS, default = DEFAULT_DIV_TAB_RADIUS );
function __div_tab_cycle( div ) = __value( div, DIV_TAB_CYCLE, default = 3 );
function __div_tab_cycle_start( div ) = __value( div, DIV_TAB_CYCLE_START, default = 1 );

function __div_total_height( div ) = __div_tab_size( div )[k_y] + __div_frame_size( div )[k_y];

function __div_tab_text ( div ) = __value( div, DIV_TAB_TEXT, default = ["001","002", "003" ] );
function __div_tab_text_size ( div ) = __value( div, DIV_TAB_TEXT_SIZE, default = 7 );
function __div_tab_text_font ( div ) = __value( div, DIV_TAB_TEXT_FONT, default = "Stencil Std:style=Bold" );
function __div_tab_text_spacing ( div ) = __value( div, DIV_TAB_TEXT_SPACING, default = 1.1 );
function __div_tab_text_char_threshold ( div ) = __value( div, DIV_TAB_TEXT_CHAR_THRESHOLD, default = 4 );
function __div_tab_text_embossed ( div ) = __value( div, DIV_TAB_TEXT_EMBOSSED_B, default = false );

function __div_frame_size( div ) = __value( div, DIV_FRAME_SIZE_XY, default = [80, 80] );
function __div_frame_top( div ) = __value( div, DIV_FRAME_TOP, default = 10 );
function __div_frame_bottom( div ) = __value( div, DIV_FRAME_BOTTOM, default = 10 );
function __div_frame_column( div ) = __value( div, DIV_FRAME_COLUMN, default = 7 );
function __div_frame_radius( div ) = __value( div, DIV_FRAME_RADIUS, default = 4 );
function __div_frame_num_columns( div ) = __value( div, DIV_FRAME_NUM_COLUMNS, default = -1 );

// is the text a string or a list of strings?
function __is_text( label ) = is_string( __value( label, LBL_TEXT ) ) || is_list(__value( label, LBL_TEXT ) );
function __is_multitext( label ) = is_list(__value( label, LBL_TEXT ));
function __is_multiimage( label ) = is_list(__value( label, LBL_IMAGE ));

function __label_text( label, r = 0, c = 0 ) = __is_text( label ) ?
    ( __is_multitext( label ) ?  __value( label, LBL_TEXT, default = "" )[c][r] : __value( label, LBL_TEXT, default = "" ) ) :
    "";
function __label_image( label, r = 0, c = 0 ) = !__is_text( label ) ?
    ( __is_multiimage( label ) ?  __value( label, LBL_IMAGE, default = "" )[c][r] : __value( label, LBL_IMAGE, default = "" ) ) :
    "";
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
function __label_placement_is_bottom( label ) = __label_placement_raw( label ) == BOTTOM;
function __label_placement_is_wall( label ) = 
    __label_placement_raw( label ) == BACK_WALL ||
    __label_placement_raw( label ) == FRONT_WALL ||
    __label_placement_raw( label ) == LEFT_WALL ||
    __label_placement_raw( label ) == RIGHT_WALL ;

function __label_offset( label ) = __value( label, POSITION_XY, default = [0,0] );
function __label_font( label ) = __value( label, LBL_FONT, default = $g_default_font );
function __label_spacing( label ) = __value( label, LBL_SPACING, default = 1 );
function __label_scale_factor( label ) = __value( label, LBL_AUTO_SCALE_FACTOR, default = 1.2 );
function __label_scale_magic_factor( label ) = __label_scale_factor( label ) + (1 * abs(tan( __label_rotation( label ) % 90 )) );
function __label_auto_width( label, x, y) = __label_size_is_auto( label ) ? 
            (  cos( __label_rotation( label ) ) * ( x/__label_scale_magic_factor( label ) )) + 
            ( abs( sin( __label_rotation( label ) ) ) * ( y/__label_scale_magic_factor( label ) )) :
            __is_text( label ) ? 0 : __label_size( label );

module Colorize()
{
    if ( $g_vis_actual_b )
    {
        color( rands(0,1,3), 0.5 )
            children();
    }
    else
    {
        children();
    }
}

module __MaybeDebug( do_debug )
{
    if ( do_debug ) # children();
    else children();
}

module Shear( x, y, height )
{
     translate( [0,0,height/2])
        multmatrix(m =  [
            [ 1, 0, tan(x), 0],
            [ 0, 1, tan(y), 0],
            [ 0, 0, 1, 0]
                    ])
            translate( [0,0,-height/2])
                children();
}

// ======================================================================
// ======================================================================

// Generate an n-sided polygon ring with outer radius R and inner radius R-t.
// Replaces the former hand-unrolled Tri/Quad/Pent/Hex/Sept/Oct modules.

// =============================================================================
// =============================================================================

function __ngon_points( R, t, n, i = 0 ) = i == n ? [] : 
    concat( [[ ( R - t ) * cos( i * 2 * ( PI / n) * 180 / PI ), ( R - t ) * sin( i * 2 * ( PI / n) * 180 / PI ) ]],
        __ngon_points( R, t, n, i + 1 ) );

function __ngon_indices( b, e, i = 0 ) = i == e ? [] :
    concat ( i, __ngon_indices( b, e, i + 1) );

module Make2dShape( R, t, n1, n2 )
{
    outer = __ngon_points( R, 0, n1 );
    inner = __ngon_points( R, t, n2 );

    polygon( concat( outer, inner ),
             concat( [ __ngon_indices( 0, n1 ) ], [ __ngon_indices( n1, n1 + n2, n1 ) ] ) );
};        


module Make2DPattern( x = 200, y = 200, R = 1, t = 0.5, pattern_angle = 0, pattern_col_offset = 0, pattern_row_offset = 0, pattern_n1 = 6, pattern_n2 = 6 )
{
    r = cos( pattern_angle ) * R;

    dx = r * ( 1 + pattern_col_offset / 100 ) - t;
    dy = R * ( 1 + ( pattern_row_offset / 100 ) ) - t;

    x_count = x / dx;
    y_count = y / dy;

    // Calculate offset to center pattern in the x direction
    x_count_i = floor(x_count);
    x_count_odd = x_count_i + 1*((x_count_i + 1) % 2);
    x_total = (x_count_odd + 2) * dx;
    x_offset = (x - x_total) / 2.0;

    // Calculate offset to center pattern in the y direction
    y_count_i = floor(y_count);
    y_count_even = y_count_i + 1*((y_count_i + 0) % 2);
    y_total = (y_count_even + 2) * dy;
    y_offset = (y - y_total) / 2.0;

    //echo( str(x, " ", dx, " ", x_count_i, " ", x_count_odd, "\n") );
    //echo( str(y, " ", dy, " ", y_count_i, " ", y_count_even, "\n") );

    translate( [x_offset, y_offset, 0 ] )
    for( j = [ -1: y_count + 1 ] )
        translate( [ ( j % 2 ) * dx/2, 0, 0 ] )
            for( i = [ -1: x_count + 1 ] )
                translate( [ i * dx, j * dy, 0 ] )
                    rotate( a = pattern_angle, v=[ 0, 0, 1 ] )
                    {
                        Make2dShape( R, t, pattern_n1, pattern_n2 );
                    }
}

module MakeStripedGrid( x = 200, y = 200, w = 1, dx = 0, dy = 0, depth_ratio = 0.5, thickness = 1 )
{

    _thickness = thickness * depth_ratio;

    x_count = x / ( w + dx );
    y_count = y / ( w + dy );

    if ( dx > 0 )
    {
        for( j = [ 0: x_count ] )
        {
            translate( [ j * ( w + dx ), 0, thickness - _thickness ] )
                cube( [ w, y, _thickness]);
        }
    }

    if ( dy > 0 )
    {
        for( j = [ 0: y_count ] )
        {
            translate( [ 0, j * ( w + dy ), thickness - _thickness  ] )
                cube( [ x, w, _thickness ]);
        }
    }
}




// =============================================================================
// KEY VALIDATION
// =============================================================================
// Valid keys for each context. Used by __ValidateElement to detect typos
// and other common mistakes in user data definitions.

// Helper: check if a value exists in a flat list
function __is_valid_key( key, valid_keys ) = 
    len( search( [key], valid_keys ) ) > 0 && search( [key], valid_keys )[0] != [];

// Box-level valid keys (TYPE=BOX or TYPE=SPACER)
__VALID_BOX_KEYS = [
    TYPE, NAME, BOX_SIZE_XYZ, BOX_FEATURE, BOX_LID, BOX_VISUALIZATION,
    BOX_NO_LID_B, BOX_STACKABLE_B, BOX_WALL_THICKNESS, CHAMFER_N,
    ENABLED_B, DEBUG_B, LABEL, ROTATION, POSITION_XY
];

// Divider-level valid keys (TYPE=DIVIDERS)
__VALID_DIVIDER_KEYS = [
    TYPE, NAME, ENABLED_B,
    DIV_OUTPUT_ONLY_B,
    DIV_THICKNESS,
    DIV_TAB_SIZE_XY, DIV_TAB_RADIUS, DIV_TAB_CYCLE, DIV_TAB_CYCLE_START,
    DIV_TAB_TEXT, DIV_TAB_TEXT_SIZE, DIV_TAB_TEXT_FONT, DIV_TAB_TEXT_SPACING, DIV_TAB_TEXT_CHAR_THRESHOLD,
    DIV_TAB_TEXT_EMBOSSED_B,
    DIV_FRAME_SIZE_XY, DIV_FRAME_TOP, DIV_FRAME_BOTTOM, DIV_FRAME_COLUMN,
    DIV_FRAME_RADIUS, DIV_FRAME_NUM_COLUMNS
];

// Feature divider subgroup keys (inside BOX_FEATURE > FTR_DIVIDERS)
__VALID_FEATURE_DIVIDER_KEYS = [
    NAME, ENABLED_B, DEBUG_B,
    DIV_OUTPUT_ONLY_B,
    DIV_NUM_DIVIDERS, DIV_AXIS,
    DIV_SLOT_DEPTH, DIV_RAILS_B,
    DIV_THICKNESS,
    DIV_TAB_SIZE_XY, DIV_TAB_RADIUS, DIV_TAB_CYCLE, DIV_TAB_CYCLE_START,
    DIV_TAB_TEXT, DIV_TAB_TEXT_SIZE, DIV_TAB_TEXT_FONT, DIV_TAB_TEXT_SPACING, DIV_TAB_TEXT_CHAR_THRESHOLD,
    DIV_TAB_TEXT_EMBOSSED_B,
    DIV_FRAME_SIZE_XY, DIV_FRAME_TOP, DIV_FRAME_BOTTOM, DIV_FRAME_COLUMN,
    DIV_FRAME_RADIUS, DIV_FRAME_NUM_COLUMNS
];

// Component-level valid keys (inside BOX_FEATURE)
__VALID_COMPONENT_KEYS = [
    NAME, FTR_COMPARTMENT_SIZE_XYZ, FTR_NUM_COMPARTMENTS_XY,
    FTR_SHAPE, FTR_SHAPE_ROTATED_B, FTR_SHAPE_VERTICAL_B,
    FTR_PADDING_XY, FTR_PADDING_HEIGHT_ADJUST_XY,
    FTR_MARGIN_FBLR,
    FTR_CUTOUT_SIDES_4B, FTR_CUTOUT_CORNERS_4B,
    FTR_CUTOUT_HEIGHT_PCT, FTR_CUTOUT_DEPTH_PCT, FTR_CUTOUT_WIDTH_PCT,
    FTR_CUTOUT_BOTTOM_B, FTR_CUTOUT_BOTTOM_PCT, FTR_CUTOUT_TYPE,
    FTR_CUTOUT_DEPTH_MAX,
    FTR_SHEAR, FTR_FILLET_RADIUS, FTR_PEDESTAL_BASE_B, CHAMFER_N,
    ENABLED_B, DEBUG_B, LABEL, FTR_DIVIDERS, ROTATION, POSITION_XY
];

// Lid-level valid keys (inside BOX_LID)
__VALID_LID_KEYS = [
    NAME, LID_FIT_UNDER_B, LID_SOLID_B, LID_HEIGHT, LID_TYPE, LID_SLIDE_SIDE, LID_FRAME_WIDTH, LID_INSET_B,
    LID_CUTOUT_SIDES_4B, LID_TABS_4B,
    LID_LABELS_INVERT_B, LID_SOLID_LABELS_DEPTH,
    LID_LABELS_BG_THICKNESS, LID_LABELS_BORDER_THICKNESS,
    LID_STRIPE_WIDTH, LID_STRIPE_SPACE,
    LID_PATTERN_RADIUS, LID_PATTERN_N1, LID_PATTERN_N2,
    LID_PATTERN_ANGLE, LID_PATTERN_ROW_OFFSET, LID_PATTERN_COL_OFFSET,
    LID_PATTERN_THICKNESS,
    DEBUG_B, LABEL
];

// Label-level valid keys (inside LABEL)
__VALID_LABEL_KEYS = [
    NAME, LBL_TEXT, LBL_IMAGE, LBL_SIZE, LBL_PLACEMENT,
    LBL_FONT, LBL_DEPTH, LBL_SPACING, LBL_AUTO_SCALE_FACTOR,
    ENABLED_B, ROTATION, POSITION_XY
];

// Valid shape enum values
__VALID_SHAPES = [ SQUARE, HEX, HEX2, OCT, OCT2, ROUND, FILLET ];

// Valid cutout type enum values
__VALID_CUTOUT_TYPES = [ INTERIOR, EXTERIOR, BOTH ];

// Valid label placement enum values
__VALID_PLACEMENTS = [ FRONT, BACK, LEFT, RIGHT, FRONT_WALL, BACK_WALL, LEFT_WALL, RIGHT_WALL, CENTER, BOTTOM ];

// Valid element type enum values
__VALID_TYPES = [ BOX, DIVIDERS, SPACER ];

// Valid lid type enum values
__VALID_LID_TYPES = [ LID_CAP, LID_INSET, LID_SLIDING ];

// Valid sliding lid open-side enum values
__VALID_LID_SLIDE_SIDES = [ FRONT, BACK, LEFT, RIGHT ];

// Type-check helper functions
function __is_list_of_len( v, n ) = is_list( v ) && len( v ) == n;
function __is_list_min_len( v, n ) = is_list( v ) && len( v ) >= n;
function __is_num_or_special( v ) = is_num( v ) || v == CENTER || v == MAX;
function __all_bool_4( v ) = is_list( v ) && len( v ) == 4 && 
    is_bool( v[0] ) && is_bool( v[1] ) && is_bool( v[2] ) && is_bool( v[3] );
function __all_num_list( v, n ) = is_list( v ) && len( v ) == n &&
    ( n < 1 || is_num( v[0] ) ) && ( n < 2 || is_num( v[1] ) ) && 
    ( n < 3 || is_num( v[2] ) ) && ( n < 4 || is_num( v[3] ) );
function __all_numbers( v, i = 0 ) =
    is_list( v ) && ( i >= len( v ) ? true : is_num( v[ i ] ) && __all_numbers( v, i + 1 ) );
function __all_strings( v, i = 0 ) =
    is_list( v ) && ( i >= len( v ) ? true : is_string( v[ i ] ) && __all_strings( v, i + 1 ) );
function __optional_bool_value_ok( table, key ) =
    !__is_valid_key( key, table ) || is_bool( __value( table, key ) );
function __enabled_for_physical_validation( table ) =
    let( enabled = __value( table, ENABLED_B, default = true ) )
    is_bool( enabled ) && enabled;
function __key_display_name( key ) =
    key == TYPE ? "TYPE" :
    key == NAME ? "NAME" :
    key == ENABLED_B ? "ENABLED_B" :
    key == DEBUG_B ? "DEBUG_B" :
    key == ROTATION ? "ROTATION" :
    key == POSITION_XY ? "POSITION_XY" :
    key == G_PRINT_LID_B ? "G_PRINT_LID_B" :
    key == G_PRINT_BOX_B ? "G_PRINT_BOX_B" :
    key == G_PRINT_DIVIDERS ? "G_PRINT_DIVIDERS" :
    key == G_PRINT_DIVIDERS_ONLY_B ? "G_PRINT_DIVIDERS_ONLY_B" :
    key == G_FIT_TEST_B ? "G_FIT_TEST_B" :
    key == G_ISOLATED_PRINT_BOX ? "G_ISOLATED_PRINT_BOX" :
    key == G_VISUALIZATION_B ? "G_VISUALIZATION_B" :
    key == G_PREVIEW_NO_LABELS_B ? "G_PREVIEW_NO_LABELS_B" :
    key == G_VALIDATE_KEYS_B ? "G_VALIDATE_KEYS_B" :
    key == G_VALIDATE_PHYSICAL_B ? "G_VALIDATE_PHYSICAL_B" :
    key == G_WALL_THICKNESS ? "G_WALL_THICKNESS" :
    key == G_DETENT_THICKNESS ? "G_DETENT_THICKNESS" :
    key == G_DETENT_SPACING ? "G_DETENT_SPACING" :
    key == G_DETENT_DIST_FROM_CORNER ? "G_DETENT_DIST_FROM_CORNER" :
    key == G_DETENT_MIN_SPACING ? "G_DETENT_MIN_SPACING" :
    key == G_LID_THICKNESS ? "G_LID_THICKNESS" :
    key == G_COLORIZE_B ? "G_COLORIZE_B" :
    key == G_TOLERANCE ? "G_TOLERANCE" :
    key == G_TOLERANCE_DETENT_POS ? "G_TOLERANCE_DETENT_POS" :
    key == G_PRINT_MMU_LAYER ? "G_PRINT_MMU_LAYER" :
    key == G_DEFAULT_FONT ? "G_DEFAULT_FONT" :
    key == BOX_SIZE_XYZ ? "BOX_SIZE_XYZ" :
    key == BOX_FEATURE ? "BOX_FEATURE" :
    key == BOX_LID ? "BOX_LID" :
    key == BOX_VISUALIZATION ? "BOX_VISUALIZATION" :
    key == BOX_NO_LID_B ? "BOX_NO_LID_B" :
    key == BOX_STACKABLE_B ? "BOX_STACKABLE_B" :
    key == BOX_WALL_THICKNESS ? "BOX_WALL_THICKNESS" :
    key == CHAMFER_N ? "CHAMFER_N" :
    key == FTR_COMPARTMENT_SIZE_XYZ ? "FTR_COMPARTMENT_SIZE_XYZ" :
    key == FTR_NUM_COMPARTMENTS_XY ? "FTR_NUM_COMPARTMENTS_XY" :
    key == FTR_SHAPE ? "FTR_SHAPE" :
    key == FTR_SHAPE_ROTATED_B ? "FTR_SHAPE_ROTATED_B" :
    key == FTR_SHAPE_VERTICAL_B ? "FTR_SHAPE_VERTICAL_B" :
    key == FTR_PADDING_XY ? "FTR_PADDING_XY" :
    key == FTR_PADDING_HEIGHT_ADJUST_XY ? "FTR_PADDING_HEIGHT_ADJUST_XY" :
    key == FTR_MARGIN_FBLR ? "FTR_MARGIN_FBLR" :
    key == FTR_CUTOUT_SIDES_4B ? "FTR_CUTOUT_SIDES_4B" :
    key == FTR_CUTOUT_CORNERS_4B ? "FTR_CUTOUT_CORNERS_4B" :
    key == FTR_CUTOUT_HEIGHT_PCT ? "FTR_CUTOUT_HEIGHT_PCT" :
    key == FTR_CUTOUT_DEPTH_PCT ? "FTR_CUTOUT_DEPTH_PCT" :
    key == FTR_CUTOUT_WIDTH_PCT ? "FTR_CUTOUT_WIDTH_PCT" :
    key == FTR_CUTOUT_BOTTOM_B ? "FTR_CUTOUT_BOTTOM_B" :
    key == FTR_CUTOUT_BOTTOM_PCT ? "FTR_CUTOUT_BOTTOM_PCT" :
    key == FTR_CUTOUT_TYPE ? "FTR_CUTOUT_TYPE" :
    key == FTR_CUTOUT_DEPTH_MAX ? "FTR_CUTOUT_DEPTH_MAX" :
    key == FTR_DIVIDERS ? "FTR_DIVIDERS" :
    key == FTR_SHEAR ? "FTR_SHEAR" :
    key == FTR_FILLET_RADIUS ? "FTR_FILLET_RADIUS" :
    key == FTR_PEDESTAL_BASE_B ? "FTR_PEDESTAL_BASE_B" :
    key == LID_FIT_UNDER_B ? "LID_FIT_UNDER_B" :
    key == LID_SOLID_B ? "LID_SOLID_B" :
    key == LID_HEIGHT ? "LID_HEIGHT" :
    key == LID_TYPE ? "LID_TYPE" :
    key == LID_SLIDE_SIDE ? "LID_SLIDE_SIDE" :
    key == LID_FRAME_WIDTH ? "LID_FRAME_WIDTH" :
    key == LID_INSET_B ? "LID_INSET_B" :
    key == LID_CUTOUT_SIDES_4B ? "LID_CUTOUT_SIDES_4B" :
    key == LID_TABS_4B ? "LID_TABS_4B" :
    key == LID_LABELS_INVERT_B ? "LID_LABELS_INVERT_B" :
    key == LID_SOLID_LABELS_DEPTH ? "LID_SOLID_LABELS_DEPTH" :
    key == LID_LABELS_BG_THICKNESS ? "LID_LABELS_BG_THICKNESS" :
    key == LID_LABELS_BORDER_THICKNESS ? "LID_LABELS_BORDER_THICKNESS" :
    key == LID_STRIPE_WIDTH ? "LID_STRIPE_WIDTH" :
    key == LID_STRIPE_SPACE ? "LID_STRIPE_SPACE" :
    key == LID_PATTERN_RADIUS ? "LID_PATTERN_RADIUS" :
    key == LID_PATTERN_N1 ? "LID_PATTERN_N1" :
    key == LID_PATTERN_N2 ? "LID_PATTERN_N2" :
    key == LID_PATTERN_ANGLE ? "LID_PATTERN_ANGLE" :
    key == LID_PATTERN_ROW_OFFSET ? "LID_PATTERN_ROW_OFFSET" :
    key == LID_PATTERN_COL_OFFSET ? "LID_PATTERN_COL_OFFSET" :
    key == LID_PATTERN_THICKNESS ? "LID_PATTERN_THICKNESS" :
    key == LBL_TEXT ? "LBL_TEXT" :
    key == LBL_IMAGE ? "LBL_IMAGE" :
    key == LBL_SIZE ? "LBL_SIZE" :
    key == LBL_PLACEMENT ? "LBL_PLACEMENT" :
    key == LBL_FONT ? "LBL_FONT" :
    key == LBL_DEPTH ? "LBL_DEPTH" :
    key == LBL_SPACING ? "LBL_SPACING" :
    key == LBL_AUTO_SCALE_FACTOR ? "LBL_AUTO_SCALE_FACTOR" :
    key == DIV_THICKNESS ? "DIV_THICKNESS" :
    key == DIV_NUM_DIVIDERS ? "DIV_NUM_DIVIDERS" :
    key == DIV_AXIS ? "DIV_AXIS" :
    key == DIV_OUTPUT_ONLY_B ? "DIV_OUTPUT_ONLY_B" :
    key == DIV_SLOT_DEPTH ? "DIV_SLOT_DEPTH" :
    key == DIV_RAILS_B ? "DIV_RAILS_B" :
    key == DIV_TAB_SIZE_XY ? "DIV_TAB_SIZE_XY" :
    key == DIV_TAB_RADIUS ? "DIV_TAB_RADIUS" :
    key == DIV_TAB_CYCLE ? "DIV_TAB_CYCLE" :
    key == DIV_TAB_CYCLE_START ? "DIV_TAB_CYCLE_START" :
    key == DIV_TAB_TEXT ? "DIV_TAB_TEXT" :
    key == DIV_TAB_TEXT_SIZE ? "DIV_TAB_TEXT_SIZE" :
    key == DIV_TAB_TEXT_FONT ? "DIV_TAB_TEXT_FONT" :
    key == DIV_TAB_TEXT_SPACING ? "DIV_TAB_TEXT_SPACING" :
    key == DIV_TAB_TEXT_CHAR_THRESHOLD ? "DIV_TAB_TEXT_CHAR_THRESHOLD" :
    key == DIV_TAB_TEXT_EMBOSSED_B ? "DIV_TAB_TEXT_EMBOSSED_B" :
    key == DIV_FRAME_SIZE_XY ? "DIV_FRAME_SIZE_XY" :
    key == DIV_FRAME_TOP ? "DIV_FRAME_TOP" :
    key == DIV_FRAME_BOTTOM ? "DIV_FRAME_BOTTOM" :
    key == DIV_FRAME_COLUMN ? "DIV_FRAME_COLUMN" :
    key == DIV_FRAME_RADIUS ? "DIV_FRAME_RADIUS" :
    key == DIV_FRAME_NUM_COLUMNS ? "DIV_FRAME_NUM_COLUMNS" :
    str( key );

// Emit structured diagnostics that BGSD can surface in its toolbar panel.
module __TypeMsg( key, context, expected, got )
{
    key_name = __key_display_name( key );
    echo( str( "BGSD_WARNING [code=BIT-TYPE] [key=", key_name, "]: wrong type for ", key_name, " in ", context,
               ". Expected ", expected, ", got: ", got ) );
}

module __PhysicalMsg( context, message )
{
    echo( str( "BGSD_WARNING [code=BIT-PHYSICAL]: physical validation: ", context, " ", message ) );
}

function __is_box_feature_entry( entry ) =
    is_list( entry ) && len( entry ) >= 2 && entry[ k_key ] == BOX_FEATURE;

function __component_physical_values_ok( comp ) =
    __all_num_list( __value( comp, FTR_COMPARTMENT_SIZE_XYZ, default = [10, 10, 10] ), 3 ) &&
    __all_num_list( __value( comp, FTR_NUM_COMPARTMENTS_XY, default = [1, 1] ), 2 ) &&
    __all_num_list( __value( comp, FTR_PADDING_XY, default = [1, 1] ), 2 ) &&
    __all_num_list( __value( comp, FTR_MARGIN_FBLR, default = [0, 0, 0, 0] ), 4 );

function __component_physical_position_ok( comp ) =
    let( pos = __value( comp, POSITION_XY, default = [ CENTER, CENTER ] ) )
    is_list( pos ) && len( pos ) == 2 &&
    __is_num_or_special( pos[ k_x ] ) && __is_num_or_special( pos[ k_y ] );

function __component_physical_supported_footprint( comp ) =
    let(
        rotation = __value( comp, ROTATION, default = 0 ),
        shear = __value( comp, FTR_SHEAR, default = [0, 0] )
    )
    is_num( rotation ) && rotation % 360 == 0 &&
    __all_num_list( shear, 2 ) && shear[ k_x ] == 0 && shear[ k_y ] == 0;

function __component_physical_supported_transformed_footprint( comp ) =
    let(
        rotation = __value( comp, ROTATION, default = 0 ),
        shear = __value( comp, FTR_SHEAR, default = [0, 0] )
    )
    is_num( rotation ) && __all_num_list( shear, 2 );

function __component_cutout_physical_values_ok( comp ) =
    __component_physical_values_ok( comp ) &&
    __all_bool_4( __value( comp, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] ) ) &&
    is_num( __value( comp, FTR_CUTOUT_HEIGHT_PCT, default = 100 ) ) &&
    is_num( __value( comp, FTR_CUTOUT_DEPTH_PCT, default = 25 ) ) &&
    is_num( __value( comp, FTR_CUTOUT_WIDTH_PCT, default = 50 ) ) &&
    is_num( __value( comp, FTR_CUTOUT_BOTTOM_PCT, default = 80 ) ) &&
    is_num( __value( comp, FTR_CUTOUT_DEPTH_MAX, default = 0 ) ) &&
    is_bool( __value( comp, FTR_CUTOUT_BOTTOM_B, default = false ) ) &&
    is_bool( __value( comp, FTR_PEDESTAL_BASE_B, default = false ) ) &&
    __is_valid_key( __value( comp, FTR_CUTOUT_TYPE, default = BOTH ), __VALID_CUTOUT_TYPES );

function __component_corner_cutout_physical_values_ok( comp ) =
    __component_physical_values_ok( comp ) &&
    __all_bool_4( __value( comp, FTR_CUTOUT_CORNERS_4B, default = [false, false, false, false] ) );

function __component_has_side_cutouts( comp ) =
    let( sides = __value( comp, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] ) )
    __all_bool_4( sides ) &&
    ( sides[ k_front ] || sides[ k_back ] || sides[ k_left ] || sides[ k_right ] );

function __component_has_corner_cutouts( comp ) =
    let( corners = __value( comp, FTR_CUTOUT_CORNERS_4B, default = [false, false, false, false] ) )
    __all_bool_4( corners ) &&
    ( corners[ k_front_left ] || corners[ k_back_right ] ||
      corners[ k_back_left ] || corners[ k_front_right ] );

function __component_has_bottom_cutout( comp ) =
    let(
        bottom = __value( comp, FTR_CUTOUT_BOTTOM_B, default = false ),
        push_base = __value( comp, FTR_PEDESTAL_BASE_B, default = false ),
        shape = __value( comp, FTR_SHAPE, default = SQUARE )
    )
    is_bool( bottom ) && is_bool( push_base ) && bottom && !push_base && shape != FILLET;

function __component_dividers( comp ) = __find_entry( comp, FTR_DIVIDERS, default = [] );
function __feature_dividers_enabled( dividers ) =
    is_list( dividers ) && len( dividers ) > 0 &&
    is_bool( __value( dividers, ENABLED_B, default = true ) ) &&
    __value( dividers, ENABLED_B, default = true );

function __feature_dividers_output_only( dividers ) =
    __feature_dividers_enabled( dividers ) &&
    is_bool( __value( dividers, DIV_OUTPUT_ONLY_B, default = false ) ) &&
    __value( dividers, DIV_OUTPUT_ONLY_B, default = false );

function __feature_divider_rails_enabled( dividers ) =
    __feature_dividers_enabled( dividers ) &&
    is_bool( __value( dividers, DIV_RAILS_B, default = true ) ) &&
    __value( dividers, DIV_RAILS_B, default = true );

function __divider_axis_valid( dividers ) =
    let( axis = __value( dividers, DIV_AXIS, default = X ) )
    axis == X || axis == Y;

function __divider_axis( dividers ) =
    let( axis = __value( dividers, DIV_AXIS, default = X ) )
    axis == Y ? k_y : k_x;

function __divider_count_spec_valid( dividers ) =
    let( count = __value( dividers, DIV_NUM_DIVIDERS, default = 0 ) )
    is_num( count );

function __divider_count_raw_for_axis( dividers, D ) =
    let(
        count = __value( dividers, DIV_NUM_DIVIDERS, default = 0 ),
        axis = __divider_axis( dividers )
    )
    is_num( count ) && D == axis ? count : 0;

function __divider_count_for_axis( dividers, D ) =
    max( 0, floor( __divider_count_raw_for_axis( dividers, D ) ) );

function __divider_centerlines_for_axis( dividers, extent, D ) =
    let( count = __divider_count_for_axis( dividers, D ) )
    count <= 0 ? [] :
        [ for ( i = [ 0 : count - 1 ] ) extent * ( i + 1 ) / ( count + 1 ) ];

function __component_dividers_output_only( comp ) =
    __feature_dividers_output_only( __component_dividers( comp ) );

function __box_has_divider_output_only( box, i = 0 ) =
    i >= len( box ) ? false :
    (
        box[ i ][ k_key ] == BOX_FEATURE &&
        __component_dividers_output_only( box[ i ] )
    ) || __box_has_divider_output_only( box, i + 1 );

function __divider_print_selector_valid( selector ) =
    is_bool( selector ) ||
    is_string( selector ) ||
    __all_strings( selector );

function __divider_print_match_name( selector, box_name, component_name, divider_name ) =
    selector == divider_name ||
    selector == component_name ||
    selector == box_name ||
    ( divider_name != "" && selector == str( box_name, "/", divider_name ) ) ||
    ( component_name != "" && selector == str( box_name, "/", component_name ) ) ||
    ( component_name != "" && divider_name != "" && selector == str( box_name, "/", component_name, "/", divider_name ) );

function __divider_print_selector_match_list( selector, box_name, component_name, divider_name, i = 0 ) =
    i >= len( selector ) ? false :
    __divider_print_match_name( selector[ i ], box_name, component_name, divider_name ) ||
    __divider_print_selector_match_list( selector, box_name, component_name, divider_name, i + 1 );

function __divider_print_selector_matches( selector, box_name, component ) =
    let(
        dividers = __component_dividers( component ),
        component_name = __value( component, NAME, default = "" ),
        divider_name = __value( dividers, NAME, default = component_name )
    )
    is_bool( selector ) ? selector :
    is_string( selector ) ? __divider_print_match_name( selector, box_name, component_name, divider_name ) :
    __all_strings( selector ) ? __divider_print_selector_match_list( selector, box_name, component_name, divider_name ) :
    false;

function __component_divider_slot_width( comp ) =
    let(
        dividers = __component_dividers( comp ),
        thickness = __div_thickness( dividers )
    )
    is_num( thickness ) ? thickness + max( 0, $g_tolerance ) : thickness;

function __component_divider_slots_physical_values_ok( comp ) =
    let(
        dividers = __component_dividers( comp )
    )
    __component_physical_values_ok( comp ) &&
    __feature_dividers_enabled( dividers ) &&
    __divider_axis_valid( dividers ) &&
    __divider_count_spec_valid( dividers ) &&
    is_num( __component_divider_slot_width( comp ) ) &&
    is_num( __value( dividers, DIV_SLOT_DEPTH, default = 1 ) );

function __component_has_divider_slots( comp ) =
    let(
        dividers = __component_dividers( comp ),
        count_x = __divider_count_for_axis( dividers, k_x ),
        count_y = __divider_count_for_axis( dividers, k_y )
    )
    __feature_dividers_enabled( dividers ) &&
    __divider_axis_valid( dividers ) &&
    __divider_count_spec_valid( dividers ) &&
    ( count_x > 0 || count_y > 0 );

function __component_has_divider_rails( comp ) =
    __component_has_divider_slots( comp ) &&
    __feature_divider_rails_enabled( __component_dividers( comp ) );

function __box_physical_auto_size_values_ok( box, i = 0 ) =
    i >= len( box ) ? true :
    (
        __is_box_feature_entry( box[i] ) ?
            __component_physical_values_ok( box[i] ) &&
            __component_physical_position_ok( box[i] ) :
            true
    ) && __box_physical_auto_size_values_ok( box, i + 1 );

function __box_physical_size_values_ok( box ) =
    let( raw_size = __value( box, BOX_SIZE_XYZ, default = false ) )
    raw_size == false ?
        __box_physical_auto_size_values_ok( box ) :
        __all_num_list( raw_size, 3 );

function __box_lid_type_for_cutout_validation( box ) =
    let(
        lid = __find_entry( box, BOX_LID ),
        raw = __value( lid, LID_TYPE, default = false ),
        legacy_inset = __value( box, BOX_STACKABLE_B, default = false ) == true ||
                       __value( lid, LID_INSET_B, default = false ) == true
    )
    ( raw == LID_CAP || raw == LID_INSET || raw == LID_SLIDING ) ?
        raw :
        ( legacy_inset ? LID_INSET : LID_CAP );

function __box_lid_external_z_for_cutout_validation( box, wall_thickness ) =
    let(
        lid = __find_entry( box, BOX_LID ),
        lid_type = __box_lid_type_for_cutout_validation( box ),
        lid_sliding = lid_type == LID_SLIDING,
        lid_inset = lid_type == LID_INSET,
        default_height = lid_inset ? DEFAULT_INSET_LID_HEIGHT : DEFAULT_CAP_LID_HEIGHT,
        raw_height = __value( lid, LID_HEIGHT, default = false ),
        lid_height = is_num( raw_height ) ? raw_height : default_height
    )
    lid_sliding ?
        __lid_thickness_for_validation( wall_thickness ) :
        wall_thickness + lid_height;

function __cutout_side_name( side ) =
    side == k_front ? "front" :
    side == k_back ? "back" :
    side == k_left ? "left" : "right";

function __cutout_side_context( ctx, side ) =
    str( ctx, " > cutout[", __cutout_side_name( side ), "]" );

function __cutout_corner_name( corner ) =
    corner == k_front_left ? "front-left" :
    corner == k_back_right ? "back-right" :
    corner == k_back_left ? "back-left" : "front-right";

function __cutout_corner_context( ctx, corner ) =
    str( ctx, " > cutout[", __cutout_corner_name( corner ), "]" );

function __cutout_corner_pair_context( ctx, corner_a, corner_b ) =
    str( ctx, " > cutout[", __cutout_corner_name( corner_a ), "/", __cutout_corner_name( corner_b ), "]" );

function __axis_name( D ) =
    D == k_x ? "x" :
    D == k_y ? "y" : "z";

function __cutout_main_axis( side ) =
    ( side == k_back || side == k_front ) ? k_y : k_x;

function __cutout_perp_axis( side ) =
    ( side == k_back || side == k_front ) ? k_x : k_y;

function __cutout_side_depth_raw( comp, side ) =
    let(
        main_d = __cutout_main_axis( side ),
        comp_size = __cmp_auto_compartment_size( comp ),
        padding = __cmp_auto_padding( comp ),
        depth_frac = __value( comp, FTR_CUTOUT_DEPTH_PCT, default = 25 ) / 100
    )
    padding[ main_d ] / 2 + comp_size[ main_d ] * depth_frac;

function __cutout_side_depth( comp, side ) =
    let(
        raw = __cutout_side_depth_raw( comp, side ),
        depth_max = __value( comp, FTR_CUTOUT_DEPTH_MAX, default = 0 )
    )
    depth_max > 0 ? min( raw, depth_max ) : raw;

function __cutout_side_depth_inside( comp, side ) =
    let(
        main_d = __cutout_main_axis( side ),
        padding = __cmp_auto_padding( comp )
    )
    max( 0, __cutout_side_depth( comp, side ) - padding[ main_d ] / 2 );

function __cutout_side_width( comp, side ) =
    let(
        perp_d = __cutout_perp_axis( side ),
        comp_size = __cmp_auto_compartment_size( comp ),
        width_frac = __value( comp, FTR_CUTOUT_WIDTH_PCT, default = 50 ) / 100
    )
    comp_size[ perp_d ] * width_frac;

function __cutout_side_height_frac( comp ) =
    __value( comp, FTR_CUTOUT_HEIGHT_PCT, default = 100 ) / 100;

function __cutout_side_top( box_size, wall_thickness, lid_external_z ) =
    box_size[ k_z ] + lid_external_z - wall_thickness + HULL_EPSILON;

function __cutout_side_bottom( comp, box_size, wall_thickness ) =
    box_size[ k_z ] * ( 1 - __cutout_side_height_frac( comp ) ) -
    wall_thickness - HULL_EPSILON;

function __cutout_side_z( comp, box_size, wall_thickness, lid_external_z ) =
    max( HULL_EPSILON,
        __cutout_side_top( box_size, wall_thickness, lid_external_z ) -
        __cutout_side_bottom( comp, box_size, wall_thickness ) );

function __cutout_side_round_bottom( comp, box_size, wall_thickness ) =
    __cutout_side_bottom( comp, box_size, wall_thickness ) >
    box_size[ k_z ] - __cmp_auto_compartment_size( comp )[ k_z ];

function __cutout_side_size( comp, side, box_size, wall_thickness, lid_external_z ) =
    let(
        width = __cutout_side_width( comp, side ),
        depth = __cutout_side_depth( comp, side ),
        z = __cutout_side_z( comp, box_size, wall_thickness, lid_external_z )
    )
    ( side == k_front || side == k_back ) ?
        [ width, depth, z ] :
        [ depth, width, z ];

function __cutout_side_shape_standard( sides, side ) =
    side == k_front ? [ !sides[ k_back ], !sides[ k_back ], true, true ] :
    side == k_back ? [ true, true, !sides[ k_front ], !sides[ k_front ] ] :
    side == k_left ? [ !sides[ k_right ], true, !sides[ k_right ], true ] :
    [ true, !sides[ k_left ], true, !sides[ k_left ] ];

function __cutout_side_shape( comp, side, box_size, wall_thickness, lid_external_z ) =
    let(
        sides = __value( comp, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] ),
        round_bottom = __cutout_side_round_bottom( comp, box_size, wall_thickness )
    )
    round_bottom ? [ true, true, true, true ] :
    __component_has_bottom_cutout( comp ) ? [ false, false, false, false ] :
    __cutout_side_shape_standard( sides, side );

function __cutout_shape_radius( rounded ) =
    rounded ? DEFAULT_MAX_CUTOUT_CORNER_RADIUS : MIN_CORNER_RADIUS;

function __cutout_shape_min_x_span( shape ) =
    max(
        __cutout_shape_radius( shape[0] ) + __cutout_shape_radius( shape[1] ),
        __cutout_shape_radius( shape[2] ) + __cutout_shape_radius( shape[3] )
    );

function __cutout_shape_min_y_span( shape ) =
    max(
        __cutout_shape_radius( shape[0] ) + __cutout_shape_radius( shape[2] ),
        __cutout_shape_radius( shape[1] ) + __cutout_shape_radius( shape[3] )
    );

function __cutout_corner_size( comp ) =
    let(
        comp_size = __cmp_auto_compartment_size( comp ),
        padding = __cmp_auto_padding( comp ),
        inset_frac = DEFAULT_CORNER_CUTOUT_INSET_FRACTION
    )
    [
        padding[ k_x ] / 2 + comp_size[ k_x ] * inset_frac,
        padding[ k_y ] / 2 + comp_size[ k_y ] * inset_frac
    ];

function __cutout_corner_inner_span( comp, D ) =
    let(
        comp_size = __cmp_auto_compartment_size( comp ),
        inset_frac = DEFAULT_CORNER_CUTOUT_INSET_FRACTION
    )
    comp_size[ D ] * inset_frac;

function __component_validation_position_raw( comp, D ) =
    let(
        pos = __value( comp, POSITION_XY, default = [ CENTER, CENTER ] ),
        pi = D == k_x ? 0 : 1
    )
    is_list( pos ) && len( pos ) > pi ? pos[ pi ] : CENTER;

function __component_validation_position( comp, box_size, wall_thickness, D ) =
    let(
        raw = __component_validation_position_raw( comp, D ),
        comp_size = __cmp_auto_size( comp, D )
    )
    raw == CENTER ? ( box_size[ D ] - comp_size ) / 2 :
    raw == MAX ? box_size[ D ] - wall_thickness - comp_size :
    raw + wall_thickness;

function __component_validation_min( comp, box_size, wall_thickness, D ) =
    __component_validation_position( comp, box_size, wall_thickness, D );

function __component_validation_max( comp, box_size, wall_thickness, D ) =
    __component_validation_position( comp, box_size, wall_thickness, D ) + __cmp_auto_size( comp, D );

function __component_validation_rotated_point( point, angle, center ) =
    let(
        dx = point[ k_x ] - center[ k_x ],
        dy = point[ k_y ] - center[ k_y ]
    )
    [
        center[ k_x ] + dx * cos( angle ) - dy * sin( angle ),
        center[ k_y ] + dx * sin( angle ) + dy * cos( angle )
    ];

function __component_validation_transformed_corners( comp, box_size, wall_thickness ) =
    let(
        w = __cmp_auto_size( comp, k_x ),
        d = __cmp_auto_size( comp, k_y ),
        z = __cmp_auto_size( comp, k_z ),
        rotation = __value( comp, ROTATION, default = 0 ),
        shear = __value( comp, FTR_SHEAR, default = [0, 0] ),
        shear_x = abs( tan( shear[ k_x ] ) * z / 2 ),
        shear_y = abs( tan( shear[ k_y ] ) * z / 2 ),
        center = [ w / 2, d / 2 ],
        position = [
            __component_validation_position( comp, box_size, wall_thickness, k_x ),
            __component_validation_position( comp, box_size, wall_thickness, k_y )
        ],
        local = [
            [ -shear_x, -shear_y ],
            [ w + shear_x, -shear_y ],
            [ w + shear_x, d + shear_y ],
            [ -shear_x, d + shear_y ]
        ],
        rotated = [ for ( p = local ) __component_validation_rotated_point( p, rotation, center ) ]
    )
    [ for ( p = rotated ) [ p[ k_x ] + position[ k_x ], p[ k_y ] + position[ k_y ] ] ];

function __component_validation_transformed_min( comp, box_size, wall_thickness, D ) =
    let( corners = __component_validation_transformed_corners( comp, box_size, wall_thickness ) )
    min( corners[0][ D ], corners[1][ D ], corners[2][ D ], corners[3][ D ] );

function __component_validation_transformed_max( comp, box_size, wall_thickness, D ) =
    let( corners = __component_validation_transformed_corners( comp, box_size, wall_thickness ) )
    max( corners[0][ D ], corners[1][ D ], corners[2][ D ], corners[3][ D ] );

function __ranges_overlap( a_min, a_max, b_min, b_max ) =
    a_min < b_max && b_min < a_max;

function __components_overlap_xy( a, b, box_size, wall_thickness ) =
    __ranges_overlap(
        __component_validation_transformed_min( a, box_size, wall_thickness, k_x ),
        __component_validation_transformed_max( a, box_size, wall_thickness, k_x ),
        __component_validation_transformed_min( b, box_size, wall_thickness, k_x ),
        __component_validation_transformed_max( b, box_size, wall_thickness, k_x )
    ) &&
    __ranges_overlap(
        __component_validation_transformed_min( a, box_size, wall_thickness, k_y ),
        __component_validation_transformed_max( a, box_size, wall_thickness, k_y ),
        __component_validation_transformed_min( b, box_size, wall_thickness, k_y ),
        __component_validation_transformed_max( b, box_size, wall_thickness, k_y )
    );

// Validate value types for box-level keys
module __ValidateBoxTypes( table, ctx )
{
    v_size = __value( table, BOX_SIZE_XYZ, default = false );
    if ( v_size != false && !__all_num_list( v_size, 3 ) )
        __TypeMsg( BOX_SIZE_XYZ, ctx, "[x, y, z] (3 numbers)", v_size );

    v_name = __value( table, NAME, default = false );
    if ( v_name != false && !is_string( v_name ) )
        __TypeMsg( NAME, ctx, "string", v_name );

    v_nolid = __value( table, BOX_NO_LID_B, default = false );
    if ( __is_valid_key( BOX_NO_LID_B, table ) && !is_bool( v_nolid ) )
        __TypeMsg( BOX_NO_LID_B, ctx, "boolean (true/false)", v_nolid );

    v_stack = __value( table, BOX_STACKABLE_B, default = false );
    if ( __is_valid_key( BOX_STACKABLE_B, table ) && !is_bool( v_stack ) )
        __TypeMsg( BOX_STACKABLE_B, ctx, "boolean (true/false)", v_stack );

    v_wt = __value( table, BOX_WALL_THICKNESS, default = false );
    if ( v_wt != false && !is_num( v_wt ) )
        __TypeMsg( BOX_WALL_THICKNESS, ctx, "number", v_wt );

    v_ch = __value( table, CHAMFER_N, default = false );
    if ( v_ch != false && !is_num( v_ch ) )
        __TypeMsg( CHAMFER_N, ctx, "number", v_ch );

    v_en = __value( table, ENABLED_B, default = false );
    if ( __is_valid_key( ENABLED_B, table ) && !is_bool( v_en ) )
        __TypeMsg( ENABLED_B, ctx, "boolean (true/false)", v_en );

    v_rot = __value( table, ROTATION, default = false );
    if ( v_rot != false && !is_num( v_rot ) )
        __TypeMsg( ROTATION, ctx, "number (degrees)", v_rot );
}

// Validate value types for component-level keys
module __ValidateComponentTypes( table, ctx )
{
    v_size = __value( table, FTR_COMPARTMENT_SIZE_XYZ, default = false );
    if ( v_size != false && !__all_num_list( v_size, 3 ) )
        __TypeMsg( FTR_COMPARTMENT_SIZE_XYZ, ctx, "[x, y, z] (3 numbers)", v_size );

    v_num = __value( table, FTR_NUM_COMPARTMENTS_XY, default = false );
    if ( v_num != false && !__all_num_list( v_num, 2 ) )
        __TypeMsg( FTR_NUM_COMPARTMENTS_XY, ctx, "[nx, ny] (2 numbers)", v_num );

    v_shape = __value( table, FTR_SHAPE, default = false );
    if ( v_shape != false && !__is_valid_key( v_shape, __VALID_SHAPES ) )
        __TypeMsg( FTR_SHAPE, ctx, "one of SQUARE, HEX, HEX2, OCT, OCT2, ROUND, FILLET", v_shape );

    v_sr = __value( table, FTR_SHAPE_ROTATED_B, default = false );
    if ( __is_valid_key( FTR_SHAPE_ROTATED_B, table ) && !is_bool( v_sr ) )
        __TypeMsg( FTR_SHAPE_ROTATED_B, ctx, "boolean (true/false)", v_sr );

    v_sv = __value( table, FTR_SHAPE_VERTICAL_B, default = false );
    if ( __is_valid_key( FTR_SHAPE_VERTICAL_B, table ) && !is_bool( v_sv ) )
        __TypeMsg( FTR_SHAPE_VERTICAL_B, ctx, "boolean (true/false)", v_sv );

    v_pad = __value( table, FTR_PADDING_XY, default = false );
    if ( v_pad != false && !__all_num_list( v_pad, 2 ) )
        __TypeMsg( FTR_PADDING_XY, ctx, "[px, py] (2 numbers)", v_pad );

    v_padh = __value( table, FTR_PADDING_HEIGHT_ADJUST_XY, default = false );
    if ( v_padh != false && !__all_num_list( v_padh, 2 ) )
        __TypeMsg( FTR_PADDING_HEIGHT_ADJUST_XY, ctx, "[ax, ay] (2 numbers)", v_padh );

    v_margin = __value( table, FTR_MARGIN_FBLR, default = false );
    if ( v_margin != false && !__all_num_list( v_margin, 4 ) )
        __TypeMsg( FTR_MARGIN_FBLR, ctx, "[front, back, left, right] (4 numbers)", v_margin );

    v_cs = __value( table, FTR_CUTOUT_SIDES_4B, default = false );
    if ( v_cs != false && !__all_bool_4( v_cs ) )
        __TypeMsg( FTR_CUTOUT_SIDES_4B, ctx, "[f,b,l,r] (4 booleans)", v_cs );

    v_cc = __value( table, FTR_CUTOUT_CORNERS_4B, default = false );
    if ( v_cc != false && !__all_bool_4( v_cc ) )
        __TypeMsg( FTR_CUTOUT_CORNERS_4B, ctx, "[fl,br,bl,fr] (4 booleans)", v_cc );

    v_chp = __value( table, FTR_CUTOUT_HEIGHT_PCT, default = false );
    if ( v_chp != false && !is_num( v_chp ) )
        __TypeMsg( FTR_CUTOUT_HEIGHT_PCT, ctx, "number (0-100)", v_chp );

    v_cdp = __value( table, FTR_CUTOUT_DEPTH_PCT, default = false );
    if ( v_cdp != false && !is_num( v_cdp ) )
        __TypeMsg( FTR_CUTOUT_DEPTH_PCT, ctx, "number (0-100)", v_cdp );

    v_cwp = __value( table, FTR_CUTOUT_WIDTH_PCT, default = false );
    if ( v_cwp != false && !is_num( v_cwp ) )
        __TypeMsg( FTR_CUTOUT_WIDTH_PCT, ctx, "number (0-100)", v_cwp );

    v_cb = __value( table, FTR_CUTOUT_BOTTOM_B, default = false );
    if ( __is_valid_key( FTR_CUTOUT_BOTTOM_B, table ) && !is_bool( v_cb ) )
        __TypeMsg( FTR_CUTOUT_BOTTOM_B, ctx, "boolean (true/false)", v_cb );

    v_cbp = __value( table, FTR_CUTOUT_BOTTOM_PCT, default = false );
    if ( v_cbp != false && !is_num( v_cbp ) )
        __TypeMsg( FTR_CUTOUT_BOTTOM_PCT, ctx, "number (0-100)", v_cbp );

    v_ct = __value( table, FTR_CUTOUT_TYPE, default = false );
    if ( v_ct != false && !__is_valid_key( v_ct, __VALID_CUTOUT_TYPES ) )
        __TypeMsg( FTR_CUTOUT_TYPE, ctx, "one of INTERIOR, EXTERIOR, BOTH", v_ct );

    v_cdm = __value( table, FTR_CUTOUT_DEPTH_MAX, default = false );
    if ( v_cdm != false && !is_num( v_cdm ) )
        __TypeMsg( FTR_CUTOUT_DEPTH_MAX, ctx, "number (mm)", v_cdm );

    v_shear = __value( table, FTR_SHEAR, default = false );
    if ( v_shear != false && !__all_num_list( v_shear, 2 ) )
        __TypeMsg( FTR_SHEAR, ctx, "[sx, sy] (2 numbers)", v_shear );

    v_fr = __value( table, FTR_FILLET_RADIUS, default = false );
    if ( v_fr != false && !is_num( v_fr ) )
        __TypeMsg( FTR_FILLET_RADIUS, ctx, "number", v_fr );

    v_fch = __value( table, CHAMFER_N, default = false );
    if ( v_fch != false && !is_num( v_fch ) )
        __TypeMsg( CHAMFER_N, ctx, "number", v_fch );

    v_pb = __value( table, FTR_PEDESTAL_BASE_B, default = false );
    if ( __is_valid_key( FTR_PEDESTAL_BASE_B, table ) && !is_bool( v_pb ) )
        __TypeMsg( FTR_PEDESTAL_BASE_B, ctx, "boolean (true/false)", v_pb );

    v_en = __value( table, ENABLED_B, default = false );
    if ( __is_valid_key( ENABLED_B, table ) && !is_bool( v_en ) )
        __TypeMsg( ENABLED_B, ctx, "boolean (true/false)", v_en );

    v_rot = __value( table, ROTATION, default = false );
    if ( v_rot != false && !is_num( v_rot ) )
        __TypeMsg( ROTATION, ctx, "number (degrees)", v_rot );

    v_pos = __value( table, POSITION_XY, default = false );
    if ( v_pos != false )
    {
        if ( !__is_list_of_len( v_pos, 2 ) )
            __TypeMsg( POSITION_XY, ctx, "[x, y] (2 values: numbers, CENTER, or MAX)", v_pos );
        else if ( !__is_num_or_special( v_pos[0] ) || !__is_num_or_special( v_pos[1] ) )
            __TypeMsg( POSITION_XY, ctx, "[x, y] where each is a number, CENTER, or MAX", v_pos );
    }
}

// Validate value types for lid-level keys
module __ValidateLidTypes( table, ctx )
{
    v_fu = __value( table, LID_FIT_UNDER_B, default = false );
    if ( __is_valid_key( LID_FIT_UNDER_B, table ) && !is_bool( v_fu ) )
        __TypeMsg( LID_FIT_UNDER_B, ctx, "boolean (true/false)", v_fu );

    v_sol = __value( table, LID_SOLID_B, default = false );
    if ( __is_valid_key( LID_SOLID_B, table ) && !is_bool( v_sol ) )
        __TypeMsg( LID_SOLID_B, ctx, "boolean (true/false)", v_sol );

    v_h = __value( table, LID_HEIGHT, default = false );
    if ( v_h != false && !is_num( v_h ) )
        __TypeMsg( LID_HEIGHT, ctx, "number", v_h );

    v_type = __value( table, LID_TYPE, default = false );
    if ( v_type != false && !__is_valid_key( v_type, __VALID_LID_TYPES ) )
        __TypeMsg( LID_TYPE, ctx, "one of LID_CAP, LID_INSET, LID_SLIDING", v_type );

    v_slide_side = __value( table, LID_SLIDE_SIDE, default = false );
    if ( v_slide_side != false && !__is_valid_key( v_slide_side, __VALID_LID_SLIDE_SIDES ) )
        __TypeMsg( LID_SLIDE_SIDE, ctx, "one of FRONT, BACK, LEFT, RIGHT", v_slide_side );

    v_frame_width = __value( table, LID_FRAME_WIDTH, default = false );
    if ( v_frame_width != false && !is_num( v_frame_width ) )
        __TypeMsg( LID_FRAME_WIDTH, ctx, "number", v_frame_width );

    v_in = __value( table, LID_INSET_B, default = false );
    if ( __is_valid_key( LID_INSET_B, table ) && !is_bool( v_in ) )
        __TypeMsg( LID_INSET_B, ctx, "boolean (true/false)", v_in );

    v_lcs = __value( table, LID_CUTOUT_SIDES_4B, default = false );
    if ( v_lcs != false && !__all_bool_4( v_lcs ) )
        __TypeMsg( LID_CUTOUT_SIDES_4B, ctx, "[f,b,l,r] (4 booleans)", v_lcs );

    v_tabs = __value( table, LID_TABS_4B, default = false );
    if ( v_tabs != false && !__all_bool_4( v_tabs ) )
        __TypeMsg( LID_TABS_4B, ctx, "[f,b,l,r] (4 booleans)", v_tabs );

    v_inv = __value( table, LID_LABELS_INVERT_B, default = false );
    if ( __is_valid_key( LID_LABELS_INVERT_B, table ) && !is_bool( v_inv ) )
        __TypeMsg( LID_LABELS_INVERT_B, ctx, "boolean (true/false)", v_inv );

    // All numeric lid keys
    _num_keys = [ LID_SOLID_LABELS_DEPTH, LID_LABELS_BG_THICKNESS, LID_LABELS_BORDER_THICKNESS,
                  LID_STRIPE_WIDTH, LID_STRIPE_SPACE,
                  LID_PATTERN_RADIUS, LID_PATTERN_N1, LID_PATTERN_N2,
                  LID_PATTERN_ANGLE, LID_PATTERN_ROW_OFFSET, LID_PATTERN_COL_OFFSET,
                  LID_PATTERN_THICKNESS ];
    for ( ki = [ 0 : len( _num_keys ) - 1 ] )
    {
        _k = _num_keys[ ki ];
        _v = __value( table, _k, default = false );
        if ( _v != false && !is_num( _v ) )
            __TypeMsg( _k, ctx, "number", _v );
    }
}

// Validate value types for label-level keys
module __ValidateLabelTypes( table, ctx )
{
    v_text = __value( table, LBL_TEXT, default = false );
    if ( v_text != false && !is_string( v_text ) && !is_list( v_text ) )
        __TypeMsg( LBL_TEXT, ctx, "string or list of strings", v_text );

    v_img = __value( table, LBL_IMAGE, default = false );
    if ( v_img != false && !is_string( v_img ) && !is_list( v_img ) )
        __TypeMsg( LBL_IMAGE, ctx, "string (file path) or list", v_img );

    v_size = __value( table, LBL_SIZE, default = false );
    if ( v_size != false && !is_num( v_size ) && v_size != AUTO )
        __TypeMsg( LBL_SIZE, ctx, "number or AUTO", v_size );

    v_pl = __value( table, LBL_PLACEMENT, default = false );
    if ( v_pl != false && !__is_valid_key( v_pl, __VALID_PLACEMENTS ) )
        __TypeMsg( LBL_PLACEMENT, ctx,
            "one of FRONT, BACK, LEFT, RIGHT, FRONT_WALL, BACK_WALL, LEFT_WALL, RIGHT_WALL, CENTER, BOTTOM", v_pl );

    v_font = __value( table, LBL_FONT, default = false );
    if ( v_font != false && !is_string( v_font ) )
        __TypeMsg( LBL_FONT, ctx, "string (font name)", v_font );

    v_depth = __value( table, LBL_DEPTH, default = false );
    if ( v_depth != false && !is_num( v_depth ) )
        __TypeMsg( LBL_DEPTH, ctx, "number", v_depth );

    v_sp = __value( table, LBL_SPACING, default = false );
    if ( v_sp != false && !is_num( v_sp ) )
        __TypeMsg( LBL_SPACING, ctx, "number", v_sp );

    v_sf = __value( table, LBL_AUTO_SCALE_FACTOR, default = false );
    if ( v_sf != false && !is_num( v_sf ) )
        __TypeMsg( LBL_AUTO_SCALE_FACTOR, ctx, "number", v_sf );

    v_rot = __value( table, ROTATION, default = false );
    if ( v_rot != false && !is_num( v_rot ) )
        __TypeMsg( ROTATION, ctx, "number (degrees)", v_rot );

    v_pos = __value( table, POSITION_XY, default = false );
    if ( v_pos != false && !__all_num_list( v_pos, 2 ) )
        __TypeMsg( POSITION_XY, ctx, "[x, y] (2 numbers)", v_pos );
}

// Validate value types for divider-level keys
module __ValidateDividerTypes( table, ctx )
{
    v_thick = __value( table, DIV_THICKNESS, default = false );
    if ( v_thick != false && !is_num( v_thick ) )
        __TypeMsg( DIV_THICKNESS, ctx, "number", v_thick );

    v_ts = __value( table, DIV_TAB_SIZE_XY, default = false );
    if ( v_ts != false && !__all_num_list( v_ts, 2 ) )
        __TypeMsg( DIV_TAB_SIZE_XY, ctx, "[x, y] (2 numbers)", v_ts );

    v_tr = __value( table, DIV_TAB_RADIUS, default = false );
    if ( v_tr != false && !is_num( v_tr ) )
        __TypeMsg( DIV_TAB_RADIUS, ctx, "number", v_tr );

    v_tc = __value( table, DIV_TAB_CYCLE, default = false );
    if ( v_tc != false && !is_num( v_tc ) )
        __TypeMsg( DIV_TAB_CYCLE, ctx, "number", v_tc );

    v_tcs = __value( table, DIV_TAB_CYCLE_START, default = false );
    if ( v_tcs != false && !is_num( v_tcs ) )
        __TypeMsg( DIV_TAB_CYCLE_START, ctx, "number", v_tcs );

    v_tt = __value( table, DIV_TAB_TEXT, default = false );
    if ( v_tt != false && !is_list( v_tt ) )
        __TypeMsg( DIV_TAB_TEXT, ctx, "list of strings", v_tt );

    v_tts = __value( table, DIV_TAB_TEXT_SIZE, default = false );
    if ( v_tts != false && !is_num( v_tts ) )
        __TypeMsg( DIV_TAB_TEXT_SIZE, ctx, "number", v_tts );

    v_ttf = __value( table, DIV_TAB_TEXT_FONT, default = false );
    if ( v_ttf != false && !is_string( v_ttf ) )
        __TypeMsg( DIV_TAB_TEXT_FONT, ctx, "string (font name)", v_ttf );

    v_ttsp = __value( table, DIV_TAB_TEXT_SPACING, default = false );
    if ( v_ttsp != false && !is_num( v_ttsp ) )
        __TypeMsg( DIV_TAB_TEXT_SPACING, ctx, "number", v_ttsp );

    v_ttct = __value( table, DIV_TAB_TEXT_CHAR_THRESHOLD, default = false );
    if ( v_ttct != false && !is_num( v_ttct ) )
        __TypeMsg( DIV_TAB_TEXT_CHAR_THRESHOLD, ctx, "number", v_ttct );

    v_tte = __value( table, DIV_TAB_TEXT_EMBOSSED_B, default = false );
    if ( v_tte != false && !is_bool( v_tte ) )
        __TypeMsg( DIV_TAB_TEXT_EMBOSSED_B, ctx, "boolean (true/false)", v_tte );

    v_oo = __value( table, DIV_OUTPUT_ONLY_B, default = false );
    if ( __is_valid_key( DIV_OUTPUT_ONLY_B, table ) && !is_bool( v_oo ) )
        __TypeMsg( DIV_OUTPUT_ONLY_B, ctx, "boolean (true/false)", v_oo );

    v_fs = __value( table, DIV_FRAME_SIZE_XY, default = false );
    if ( v_fs != false && !__all_num_list( v_fs, 2 ) )
        __TypeMsg( DIV_FRAME_SIZE_XY, ctx, "[x, y] (2 numbers)", v_fs );

    _frame_nums = [ DIV_FRAME_TOP, DIV_FRAME_BOTTOM, DIV_FRAME_COLUMN, DIV_FRAME_RADIUS, DIV_FRAME_NUM_COLUMNS ];
    for ( ki = [ 0 : len( _frame_nums ) - 1 ] )
    {
        _k = _frame_nums[ ki ];
        _v = __value( table, _k, default = false );
        if ( _v != false && !is_num( _v ) )
            __TypeMsg( _k, ctx, "number", _v );
    }

    v_en = __value( table, ENABLED_B, default = false );
    if ( __is_valid_key( ENABLED_B, table ) && !is_bool( v_en ) )
        __TypeMsg( ENABLED_B, ctx, "boolean (true/false)", v_en );
}

module __ValidateFeatureDividerTypes( table, ctx )
{
    __ValidateDividerTypes( table, ctx );

    v_count = __value( table, DIV_NUM_DIVIDERS, default = false );
    if ( v_count != false && !is_num( v_count ) )
        __TypeMsg( DIV_NUM_DIVIDERS, ctx, "number", v_count );

    v_axis = __value( table, DIV_AXIS, default = false );
    if ( v_axis != false && !( v_axis == X || v_axis == Y ) )
        __TypeMsg( DIV_AXIS, ctx, "X or Y", v_axis );

    v_dsd = __value( table, DIV_SLOT_DEPTH, default = false );
    if ( v_dsd != false && !is_num( v_dsd ) )
        __TypeMsg( DIV_SLOT_DEPTH, ctx, "number (mm)", v_dsd );

    v_rails = __value( table, DIV_RAILS_B, default = false );
    if ( __is_valid_key( DIV_RAILS_B, table ) && !is_bool( v_rails ) )
        __TypeMsg( DIV_RAILS_B, ctx, "boolean (true/false)", v_rails );
}

module __ValidateDividerPhysical( table, ctx )
{
    _thickness = __value( table, DIV_THICKNESS, default = 0.5 );
    if ( is_num( _thickness ) && _thickness > 0 && _thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "has DIV_THICKNESS ", _thickness,
            "mm, below printable detail threshold ", MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

    _tab_size = __value( table, DIV_TAB_SIZE_XY, default = [32, 14] );
    if ( is_num( _thickness ) && __all_num_list( _tab_size, 2 ) && _tab_size[ k_y ] < _thickness )
        __PhysicalMsg( ctx, str( "has DIV_TAB_SIZE_XY height ", _tab_size[ k_y ],
            "mm smaller than DIV_THICKNESS ", _thickness, "mm." ) );
}

function __lid_wall_height_for_validation( lid, lid_type ) =
    let(
        lid_inset = lid_type == LID_INSET,
        raw_height = __value( lid, LID_HEIGHT, default = false )
    )
    is_num( raw_height ) ?
        raw_height :
        ( lid_inset ? DEFAULT_INSET_LID_HEIGHT : DEFAULT_CAP_LID_HEIGHT );

function __lid_wall_thickness_for_validation( lid_type, wall_thickness ) =
    lid_type == LID_INSET ? 2 * wall_thickness :
    ( lid_type == LID_SLIDING ? wall_thickness : wall_thickness / 2 );

function __lid_internal_size_xy_for_validation( box_size, wall_thickness, lid_type ) =
    let( lid_wall_thickness = __lid_wall_thickness_for_validation( lid_type, wall_thickness ) )
    [
        box_size[ k_x ] - 2 * lid_wall_thickness,
        box_size[ k_y ] - 2 * lid_wall_thickness
    ];

function __lid_surface_thickness_for_validation( lid, lid_type, wall_thickness ) =
    lid_type == LID_SLIDING ?
        __sliding_lid_panel_thickness_for_validation( wall_thickness ) :
        ( lid_type == LID_INSET ?
            __lid_thickness_for_validation( wall_thickness ) +
                __lid_wall_height_for_validation( lid, lid_type ) -
                2 * __sliding_lid_fit_tolerance_for_validation() :
            __lid_thickness_for_validation( wall_thickness ) );

function __lid_surface_frame_size_for_validation( box_size, wall_thickness, lid, lid_type ) =
    lid_type == LID_INSET ?
        let( internal = __lid_internal_size_xy_for_validation( box_size, wall_thickness, lid_type ) )
        [
            internal[ k_x ] + 2 * __sliding_lid_fit_tolerance_for_validation(),
            internal[ k_y ] + 2 * __sliding_lid_fit_tolerance_for_validation()
        ] :
        ( lid_type == LID_SLIDING ?
            __sliding_lid_raw_size_xy_for_validation( box_size, wall_thickness, lid ) :
            [ box_size[ k_x ], box_size[ k_y ] ] );

function __sliding_lid_stop_clearance_for_validation( wall_thickness ) =
    __sliding_lid_rail_width_for_validation( wall_thickness ) +
    __sliding_lid_fit_tolerance_for_validation();

function __sliding_lid_raw_size_xy_for_validation( box_size, wall_thickness, lid ) =
    let(
        slides_x = __sliding_lid_slides_x_for_validation( lid ),
        side_clearance = __sliding_lid_rail_side_clearance_for_validation( wall_thickness ),
        stop_clearance = __sliding_lid_stop_clearance_for_validation( wall_thickness )
    )
    slides_x ?
        [ box_size[ k_x ] - stop_clearance, box_size[ k_y ] - 2 * side_clearance ] :
        [ box_size[ k_x ] - 2 * side_clearance, box_size[ k_y ] - stop_clearance ];

module __ValidateLidPhysical( element, box_size, lid, ctx, wall_thickness )
{
    _lid_type = __box_lid_type_for_cutout_validation( element );
    _lid_sliding = _lid_type == LID_SLIDING;
    _lid_inset = _lid_type == LID_INSET;
    _lid_cap = _lid_type == LID_CAP;
    _lid_solid = __value( lid, LID_SOLID_B, default = false );
    _lid_patterned = _lid_solid != true;
    _lid_thickness = __lid_thickness_for_validation( wall_thickness );
    _lid_height = __lid_wall_height_for_validation( lid, _lid_type );
    _lid_surface_thickness = __lid_surface_thickness_for_validation( lid, _lid_type, wall_thickness );
    _pattern_thickness = __value( lid, LID_PATTERN_THICKNESS, default = 0.5 );
    _frame_width = __value( lid, LID_FRAME_WIDTH, default = wall_thickness );

    if ( is_num( _lid_thickness ) && _lid_thickness <= 0 )
        __PhysicalMsg( ctx, str( "has generated lid thickness ", _lid_thickness,
            "mm from ", G_LID_THICKNESS, "; expected >0mm." ) );
    else if ( is_num( _lid_thickness ) && _lid_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "has generated lid thickness ", _lid_thickness,
            "mm, below printable detail threshold ", MIN_PRINTABLE_DETAIL_THICKNESS,
            "mm. Increase ", G_LID_THICKNESS, " or ", BOX_WALL_THICKNESS, "." ) );

    if ( is_num( _lid_surface_thickness ) && _lid_surface_thickness <= 0 )
        __PhysicalMsg( ctx, str( "generates lid surface/panel thickness ",
            _lid_surface_thickness, "mm after tolerance ", $g_tolerance,
            "mm; expected >0mm." ) );
    else if ( is_num( _lid_surface_thickness ) &&
              _lid_surface_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "generates lid surface/panel thickness ",
            _lid_surface_thickness, "mm after tolerance ", $g_tolerance,
            "mm; below printable detail threshold ",
            MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

    if ( !_lid_sliding && is_num( _lid_height ) && _lid_height <= 0 )
        __PhysicalMsg( ctx, str( "has ", LID_HEIGHT, " ", _lid_height,
            "mm; expected >0mm for ", _lid_type, " lids." ) );
    else if ( !_lid_sliding && is_num( _lid_height ) &&
              _lid_height < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "has ", LID_HEIGHT, " ", _lid_height,
            "mm, below printable detail threshold ",
            MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

    if ( _lid_cap && __all_num_list( box_size, 3 ) && is_num( wall_thickness ) && is_num( $g_tolerance ) )
    {
        _cap_skirt_material = wall_thickness / 2 - __sliding_lid_fit_tolerance_for_validation();
        if ( _cap_skirt_material <= 0 )
            __PhysicalMsg( ctx, str( "cap lid skirt material collapses to ",
                _cap_skirt_material, "mm after tolerance ", $g_tolerance,
                "mm from wall thickness ", wall_thickness, "mm. Reduce ",
                G_TOLERANCE, " or increase ", BOX_WALL_THICKNESS, "." ) );
        else if ( _cap_skirt_material < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( ctx, str( "cap lid skirt material is ",
                _cap_skirt_material, "mm after tolerance ", $g_tolerance,
                "mm from wall thickness ", wall_thickness,
                "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );
    }

    if ( _lid_inset && __all_num_list( box_size, 3 ) && is_num( wall_thickness ) && is_num( $g_tolerance ) )
    {
        _internal = __lid_internal_size_xy_for_validation( box_size, wall_thickness, _lid_type );
        _surface = __lid_surface_frame_size_for_validation( box_size, wall_thickness, lid, _lid_type );
        for ( D = [ k_x : k_y ] )
        {
            if ( _internal[ D ] <= 0 )
                __PhysicalMsg( ctx, str( "inset lid internal ",
                    __axis_name( D ), " span collapses to ", _internal[ D ],
                    "mm from box size ", box_size[ D ], "mm and wall thickness ",
                    wall_thickness, "mm. Increase box ", __axis_name( D ),
                    " size or reduce ", BOX_WALL_THICKNESS, "." ) );
            else if ( _internal[ D ] < MIN_PRINTABLE_DETAIL_THICKNESS )
                __PhysicalMsg( ctx, str( "inset lid internal ",
                    __axis_name( D ), " span is ", _internal[ D ],
                    "mm; below printable detail threshold ",
                    MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

            if ( _surface[ D ] <= 0 )
                __PhysicalMsg( ctx, str( "inset lid surface ",
                    __axis_name( D ), " span collapses to ", _surface[ D ],
                    "mm after tolerance ", $g_tolerance,
                    "mm. Reduce ", G_TOLERANCE, " or ", BOX_WALL_THICKNESS, "." ) );
            else if ( _surface[ D ] < MIN_PRINTABLE_DETAIL_THICKNESS )
                __PhysicalMsg( ctx, str( "inset lid surface ",
                    __axis_name( D ), " span is ", _surface[ D ],
                    "mm after tolerance ", $g_tolerance,
                    "mm; below printable detail threshold ",
                    MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );
        }
    }

    if ( _lid_sliding && __all_num_list( box_size, 3 ) && is_num( wall_thickness ) && is_num( $g_tolerance ) )
    {
        _raw_panel_thickness = _lid_thickness - 2 * __sliding_lid_fit_tolerance_for_validation();
        _raw_size = __sliding_lid_raw_size_xy_for_validation( box_size, wall_thickness, lid );
        if ( _raw_panel_thickness <= 0 )
            __PhysicalMsg( ctx, str( "sliding lid panel thickness collapses to ",
                _raw_panel_thickness, "mm from generated lid thickness ",
                _lid_thickness, "mm minus tolerance ", $g_tolerance,
                "mm above and below. Increase ", G_LID_THICKNESS,
                " or reduce ", G_TOLERANCE, "." ) );
        else if ( _raw_panel_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( ctx, str( "sliding lid panel thickness is ",
                _raw_panel_thickness, "mm from generated lid thickness ",
                _lid_thickness, "mm minus tolerance ", $g_tolerance,
                "mm above and below; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

        for ( D = [ k_x : k_y ] )
        {
            if ( _raw_size[ D ] <= 0 )
                __PhysicalMsg( ctx, str( "sliding raw lid ",
                    __axis_name( D ), " extent collapses to ", _raw_size[ D ],
                    "mm before clamp from tolerance ", $g_tolerance,
                    "mm and wall thickness ", wall_thickness,
                    "mm. Increase box ", __axis_name( D ),
                    " size, reduce ", G_TOLERANCE, ", or reduce ",
                    BOX_WALL_THICKNESS, "." ) );
            else if ( _raw_size[ D ] < MIN_PRINTABLE_DETAIL_THICKNESS )
                __PhysicalMsg( ctx, str( "sliding raw lid ",
                    __axis_name( D ), " extent is ", _raw_size[ D ],
                    "mm before clamp from tolerance ", $g_tolerance,
                    "mm and wall thickness ", wall_thickness,
                    "mm; below printable detail threshold ",
                    MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );
        }
    }

    if ( _lid_patterned && is_num( _pattern_thickness ) &&
         _pattern_thickness > 0 && _pattern_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "has LID_PATTERN_THICKNESS ", _pattern_thickness,
            "mm, below printable detail threshold ", MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

    if ( _lid_patterned && is_num( _frame_width ) &&
         _frame_width > 0 && _frame_width < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( ctx, str( "has LID_FRAME_WIDTH ", _frame_width,
            "mm, below printable detail threshold ", MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );

    if ( _lid_patterned && __all_num_list( box_size, 3 ) &&
         is_num( wall_thickness ) && is_num( _frame_width ) && _frame_width > 0 )
    {
        _frame_size = __lid_surface_frame_size_for_validation( box_size, wall_thickness, lid, _lid_type );
        if ( __all_num_list( _frame_size, 2 ) )
        {
            _usable_x = _frame_size[ k_x ] - 2 * _frame_width;
            _usable_y = _frame_size[ k_y ] - 2 * _frame_width;
            if ( _usable_x <= 0 || _usable_y <= 0 )
                __PhysicalMsg( ctx, str( "requests patterned ", LID_FRAME_WIDTH,
                    " ", _frame_width, "mm on usable lid surface ",
                    _frame_size, "mm, consuming the patterned opening." ) );
            else if ( _usable_x < MIN_PRINTABLE_DETAIL_THICKNESS ||
                      _usable_y < MIN_PRINTABLE_DETAIL_THICKNESS )
                __PhysicalMsg( ctx, str( "requests patterned ", LID_FRAME_WIDTH,
                    " ", _frame_width, "mm on usable lid surface ",
                    _frame_size, "mm, leaving patterned opening [",
                    _usable_x, ", ", _usable_y,
                    "]mm below printable detail threshold ",
                    MIN_PRINTABLE_DETAIL_THICKNESS, "mm." ) );
        }
    }

    _has_lid = __optional_bool_value_ok( element, BOX_NO_LID_B ) &&
        !__value( element, BOX_NO_LID_B, default = false );
    _lid_fit_under = __optional_bool_value_ok( lid, LID_FIT_UNDER_B ) &&
        __value( lid, LID_FIT_UNDER_B, default = true );
    if ( _has_lid && !_lid_sliding && _lid_fit_under &&
         __all_num_list( box_size, 3 ) && is_num( wall_thickness ) && is_num( _lid_height ) )
    {
        _lid_ext_z = __box_lid_external_z_for_cutout_validation( element, wall_thickness );
        _box_interior_z = box_size[ k_z ] - wall_thickness;
        if ( _lid_ext_z > _box_interior_z )
            __PhysicalMsg( ctx, str( "has ", LID_FIT_UNDER_B,
                " enabled but lid external height ", _lid_ext_z,
                "mm exceeds box interior height ", _box_interior_z,
                "mm. The lid will not fit underneath." ) );
    }
}

function __sliding_lid_slide_side_for_validation( lid ) =
    let( raw = __value( lid, LID_SLIDE_SIDE, default = FRONT ) )
    ( raw == FRONT || raw == BACK || raw == LEFT || raw == RIGHT ) ? raw : FRONT;

function __sliding_lid_slides_x_for_validation( lid ) =
    let( slide_side = __sliding_lid_slide_side_for_validation( lid ) )
    slide_side == LEFT || slide_side == RIGHT;

function __sliding_lid_open_side_for_validation( lid ) =
    let( slide_side = __sliding_lid_slide_side_for_validation( lid ) )
    slide_side == FRONT ? k_front :
    slide_side == BACK ? k_back :
    slide_side == LEFT ? k_left :
    k_right;

function __lid_thickness_for_validation( wall_thickness ) =
    $g_fit_test_b ? 0.5 :
    ( $g_lid_thickness == false ? wall_thickness : $g_lid_thickness );

function __sliding_lid_bevel_for_validation( wall_thickness ) =
    max( HULL_EPSILON, min( __lid_thickness_for_validation( wall_thickness ) / 2, wall_thickness / 2 ) );

function __sliding_lid_rail_width_for_validation( wall_thickness ) =
    max( HULL_EPSILON, wall_thickness - __sliding_lid_bevel_for_validation( wall_thickness ) );

function __sliding_lid_fit_tolerance_for_validation() =
    max( 0, $g_tolerance );

function __sliding_lid_rail_side_clearance_for_validation( wall_thickness ) =
    __sliding_lid_rail_width_for_validation( wall_thickness ) +
    2 * __sliding_lid_fit_tolerance_for_validation();

function __sliding_lid_panel_thickness_for_validation( wall_thickness ) =
    max( HULL_EPSILON, __lid_thickness_for_validation( wall_thickness ) - 2 * __sliding_lid_fit_tolerance_for_validation() );

function __sliding_lid_raw_cross_extent_for_detent_validation( box_size, wall_thickness, lid ) =
    let(
        slides_x = __sliding_lid_slides_x_for_validation( lid ),
        side_clearance = __sliding_lid_rail_side_clearance_for_validation( wall_thickness )
    )
    slides_x ?
        box_size[ k_y ] - 2 * side_clearance :
        box_size[ k_x ] - 2 * side_clearance;

function __sliding_detent_height_for_validation( wall_thickness ) =
    min( max( HULL_EPSILON, $g_detent_thickness ), wall_thickness / 2, __lid_thickness_for_validation( wall_thickness ) / 2 );

function __sliding_detent_width_for_validation( wall_thickness ) =
    max( HULL_EPSILON, __sliding_lid_rail_width_for_validation( wall_thickness ) - 2 * __sliding_lid_fit_tolerance_for_validation() );

function __sliding_detent_requested_length_for_validation( wall_thickness ) =
    max( $g_detent_spacing * 2, wall_thickness * 2 );

function __sliding_detent_available_length_for_validation( cross_extent ) =
    max( HULL_EPSILON, cross_extent - 2 * $g_detent_dist_from_corner );

function __sliding_detent_start_for_validation( extent, length ) =
    max( 0, ( extent - length ) / 2 );

function __sliding_detent_cross_min_for_validation( box_size, wall_thickness, lid ) =
    let(
        cross_extent = max( 0.01, __sliding_lid_raw_cross_extent_for_detent_validation( box_size, wall_thickness, lid ) ),
        detent_length = min(
            __sliding_detent_requested_length_for_validation( wall_thickness ),
            __sliding_detent_available_length_for_validation( cross_extent )
        )
    )
    __sliding_lid_rail_side_clearance_for_validation( wall_thickness ) +
    __sliding_detent_start_for_validation( cross_extent, detent_length );

function __sliding_detent_cross_max_for_validation( box_size, wall_thickness, lid ) =
    let(
        cross_extent = max( 0.01, __sliding_lid_raw_cross_extent_for_detent_validation( box_size, wall_thickness, lid ) ),
        detent_length = min(
            __sliding_detent_requested_length_for_validation( wall_thickness ),
            __sliding_detent_available_length_for_validation( cross_extent )
        )
    )
    __sliding_detent_cross_min_for_validation( box_size, wall_thickness, lid ) + detent_length;

function __side_cutout_margin_cross_min_for_validation( comp, box_size, wall_thickness, side, compartment_index ) =
    let(
        cross_d = __cutout_perp_axis( side ),
        comp_pos = __component_validation_position( comp, box_size, wall_thickness, cross_d ),
        comp_size = __cmp_auto_compartment_size( comp ),
        padding = __cmp_auto_padding( comp ),
        margin = __value( comp, FTR_MARGIN_FBLR, default = [0, 0, 0, 0] ),
        margin_start = cross_d == k_x ? margin[ k_left ] : margin[ k_front ],
        width = __cutout_side_width( comp, side )
    )
    comp_pos + margin_start + ( comp_size[ cross_d ] + padding[ cross_d ] ) * compartment_index +
    comp_size[ cross_d ] / 2 - width / 2;

function __side_cutout_margin_cross_max_for_validation( comp, box_size, wall_thickness, side, compartment_index ) =
    __side_cutout_margin_cross_min_for_validation( comp, box_size, wall_thickness, side, compartment_index ) +
    __cutout_side_width( comp, side );

module __ValidateSlidingDetentPhysical( ctx, box_size, wall_thickness, lid )
{
    _detent_ctx = str( ctx, " > lid > sliding detent" );
    _detent_enabled = is_num( $g_detent_thickness ) && $g_detent_thickness > 0;
    _values_ok =
        _detent_enabled &&
        __all_num_list( box_size, 3 ) &&
        is_num( wall_thickness ) && wall_thickness > 0 &&
        is_num( $g_detent_spacing ) &&
        is_num( $g_detent_dist_from_corner ) &&
        is_num( $g_tolerance );

    if ( _values_ok )
    {
        _slide_side = __sliding_lid_slide_side_for_validation( lid );
        _cross_d = __sliding_lid_slides_x_for_validation( lid ) ? k_y : k_x;
        _raw_cross_extent = __sliding_lid_raw_cross_extent_for_detent_validation( box_size, wall_thickness, lid );
        _cross_extent = max( 0.01, _raw_cross_extent );
        _lid_thickness = __lid_thickness_for_validation( wall_thickness );
        _detent_height_limit = min( wall_thickness / 2, _lid_thickness / 2 );
        _detent_height = __sliding_detent_height_for_validation( wall_thickness );
        _rail_width = __sliding_lid_rail_width_for_validation( wall_thickness );
        _detent_width_raw = _rail_width - 2 * __sliding_lid_fit_tolerance_for_validation();
        _detent_width = __sliding_detent_width_for_validation( wall_thickness );
        _panel_thickness = __sliding_lid_panel_thickness_for_validation( wall_thickness );
        _remaining_lid_skin = _panel_thickness - _detent_height;
        _requested_length = __sliding_detent_requested_length_for_validation( wall_thickness );
        _available_length_raw = _cross_extent - 2 * $g_detent_dist_from_corner;
        _available_length = __sliding_detent_available_length_for_validation( _cross_extent );
        _detent_length = min( _requested_length, _available_length );
        _detent_start = __sliding_detent_start_for_validation( _cross_extent, _detent_length );

        if ( $g_detent_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "has ", G_DETENT_THICKNESS, " ",
                $g_detent_thickness, "mm, below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ", G_DETENT_THICKNESS,
                " or set it to 0 to disable sliding-lid detents." ) );
        else if ( _detent_height < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "generates detent height ",
                _detent_height, "mm from ", G_DETENT_THICKNESS, " ",
                $g_detent_thickness, "mm and wall/lid thickness ",
                [ wall_thickness, _lid_thickness ], "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                BOX_WALL_THICKNESS, " or ", G_LID_THICKNESS, "." ) );

        if ( $g_detent_thickness > _detent_height_limit )
            __PhysicalMsg( _detent_ctx, str( "has ", G_DETENT_THICKNESS, " ",
                $g_detent_thickness, "mm exceeding the sliding detent height limit ",
                _detent_height_limit, "mm from wall/lid thickness ",
                [ wall_thickness, _lid_thickness ], "mm; generated height clamps to ",
                _detent_height, "mm. Reduce ", G_DETENT_THICKNESS,
                " or increase ", BOX_WALL_THICKNESS, " / ", G_LID_THICKNESS, "." ) );

        if ( _detent_width_raw <= 0 )
            __PhysicalMsg( _detent_ctx, str( "has flat rail width ", _rail_width,
                "mm after chamfer and tolerance ", $g_tolerance,
                "mm, leaving no detent width after tolerance on both sides. Generated width clamps to ",
                _detent_width, "mm. Increase ", BOX_WALL_THICKNESS,
                " or reduce ", G_TOLERANCE, "." ) );
        else if ( _detent_width < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "generates detent base width ",
                _detent_width, "mm from flat rail width ", _rail_width,
                "mm after chamfer minus tolerance on both sides; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                BOX_WALL_THICKNESS, " or reduce ", G_TOLERANCE, "." ) );

        if ( _detent_height >= _panel_thickness )
            __PhysicalMsg( _detent_ctx, str( "matching groove height ",
                _detent_height, "mm reaches/exceeds sliding lid panel thickness ",
                _panel_thickness, "mm after tolerance ", $g_tolerance,
                "mm. Reduce ", G_DETENT_THICKNESS, " or ",
                G_TOLERANCE, ", or increase ", BOX_WALL_THICKNESS, "." ) );
        else if ( _remaining_lid_skin < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "leaves ", _remaining_lid_skin,
                "mm of lid material above the detent groove in panel thickness ",
                _panel_thickness, "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Reduce ",
                G_DETENT_THICKNESS, " or ", G_TOLERANCE, ", or increase ",
                BOX_WALL_THICKNESS, "." ) );

        if ( $g_detent_spacing <= 0 )
            __PhysicalMsg( _detent_ctx, str( "has ", G_DETENT_SPACING, " ",
                $g_detent_spacing, "mm; expected >0mm. Increase ",
                G_DETENT_SPACING, " so the detent has a meaningful requested length." ) );

        if ( $g_detent_dist_from_corner < 0 )
            __PhysicalMsg( _detent_ctx, str( "has ", G_DETENT_DIST_FROM_CORNER, " ",
                $g_detent_dist_from_corner, "mm; expected >=0mm. Negative values expand the allowed detent span beyond the lid corners." ) );

        if ( _raw_cross_extent <= 0 )
            __PhysicalMsg( _detent_ctx, str( "has sliding lid cross-axis ",
                __axis_name( _cross_d ), " span ", _raw_cross_extent,
                "mm after rail side clearances for slide side ", _slide_side,
                "; generated lid span clamps to 0.01mm. Increase box ",
                __axis_name( _cross_d ), " size or reduce ",
                BOX_WALL_THICKNESS, " / ", G_TOLERANCE, "." ) );
        else if ( _cross_extent < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "has computed sliding lid cross-axis ",
                __axis_name( _cross_d ), " span ", _cross_extent,
                "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase box ",
                __axis_name( _cross_d ), " size or reduce ",
                BOX_WALL_THICKNESS, " / ", G_TOLERANCE, "." ) );

        if ( _available_length_raw <= 0 )
            __PhysicalMsg( _detent_ctx, str( "has ", G_DETENT_DIST_FROM_CORNER, " ",
                $g_detent_dist_from_corner, "mm on computed cross-axis span ",
                _cross_extent, "mm, leaving available detent length ",
                _available_length_raw, "mm. Generated length collapses to ",
                _available_length, "mm. Reduce ", G_DETENT_DIST_FROM_CORNER,
                " below half the computed lid cross-axis span." ) );
        else if ( _available_length < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "leaves available detent length ",
                _available_length, "mm after ", G_DETENT_DIST_FROM_CORNER,
                " on computed cross-axis span ", _cross_extent,
                "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Reduce ",
                G_DETENT_DIST_FROM_CORNER, " or increase box ",
                __axis_name( _cross_d ), " size." ) );
        else if ( _requested_length > _available_length )
            __PhysicalMsg( _detent_ctx, str( "requests detent length ",
                _requested_length, "mm from ", G_DETENT_SPACING, " ",
                $g_detent_spacing, "mm and wall thickness ",
                wall_thickness, "mm, but only ", _available_length,
                "mm is available after ", G_DETENT_DIST_FROM_CORNER,
                ". Generated length clamps to ", _detent_length,
                "mm. Reduce ", G_DETENT_SPACING, " / ",
                G_DETENT_DIST_FROM_CORNER, " or increase box ",
                __axis_name( _cross_d ), " size." ) );

        if ( _available_length_raw > 0 &&
             _detent_length < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "generates detent length ",
                _detent_length, "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase box ",
                __axis_name( _cross_d ), " size or reduce ",
                G_DETENT_DIST_FROM_CORNER, "." ) );

        if ( _raw_cross_extent > 0 &&
             _detent_length > 0 &&
             _detent_start < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _detent_ctx, str( "starts the generated detent ",
                _detent_start, "mm from each cross-axis corner on span ",
                _cross_extent, "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                G_DETENT_DIST_FROM_CORNER, " or reduce ",
                G_DETENT_SPACING, "." ) );
    }
}

module __ValidateSlidingDetentCutoutCollision( comp, ctx, box_size, wall_thickness, lid )
{
    _open_side = __sliding_lid_open_side_for_validation( lid );
    _cutout_type = __value( comp, FTR_CUTOUT_TYPE, default = BOTH );
    _values_ok =
        __component_cutout_physical_values_ok( comp ) &&
        __component_physical_position_ok( comp ) &&
        __component_physical_supported_footprint( comp ) &&
        is_num( wall_thickness ) && wall_thickness > 0 &&
        is_num( $g_detent_thickness ) && $g_detent_thickness > 0 &&
        is_num( $g_detent_spacing ) &&
        is_num( $g_detent_dist_from_corner ) &&
        is_num( $g_tolerance );

    if ( _values_ok )
    {
        _sides = __value( comp, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] );
        _lid_external_z = 2 * wall_thickness;
        _cutout_top = __cutout_side_bottom( comp, box_size, wall_thickness ) +
            __cutout_side_z( comp, box_size, wall_thickness, _lid_external_z );
        _cross_d = __cutout_perp_axis( _open_side );
        _compartments = __value( comp, FTR_NUM_COMPARTMENTS_XY, default = [1, 1] );
        _detent_min = __sliding_detent_cross_min_for_validation( box_size, wall_thickness, lid );
        _detent_max = __sliding_detent_cross_max_for_validation( box_size, wall_thickness, lid );

        if ( _sides[ _open_side ] &&
             _cutout_type != INTERIOR &&
             _cutout_top > box_size[ k_z ] )
            for ( i = [ 0 : max( _compartments[ _cross_d ] - 1, 0 ) ] )
            {
                _cutout_min = __side_cutout_margin_cross_min_for_validation( comp, box_size, wall_thickness, _open_side, i );
                _cutout_max = __side_cutout_margin_cross_max_for_validation( comp, box_size, wall_thickness, _open_side, i );

                if ( __ranges_overlap( _cutout_min, _cutout_max, _detent_min, _detent_max ) )
                    __PhysicalMsg( str( ctx, " > cutout[", __cutout_side_name( _open_side ), "]" ),
                        str( "opening-side side cutout compartment ", i,
                            " overlaps sliding detent span [", _detent_min, ", ", _detent_max,
                            "] along box ", __axis_name( _cross_d ),
                            " with cutout span [", _cutout_min, ", ", _cutout_max,
                            "] and reaches the rail/detent height. This can cut away the sliding detent or opening rail; use ",
                            FTR_CUTOUT_TYPE, "=", INTERIOR, ", move the feature, reduce ",
                            FTR_CUTOUT_WIDTH_PCT, ", or disable this opening-side cutout." ) );
            }
    }
}

module __ValidateCutoutPercentRange( comp, ctx, key, default )
{
    _value = __value( comp, key, default = default );
    if ( is_num( _value ) && ( _value < 0 || _value > 100 ) )
        __PhysicalMsg( ctx, str( "has ", key, " ", _value,
            "% outside expected range 0..100%; normalized value is ",
            _value / 100, "." ) );
}

module __ValidateSideCutoutPhysical( comp, ctx, side, box_size, wall_thickness, lid_external_z )
{
    _cutout_ctx = __cutout_side_context( ctx, side );
    _main_d = __cutout_main_axis( side );
    _perp_d = __cutout_perp_axis( side );
    _comp_size = __cmp_auto_compartment_size( comp );
    _cutout_type = __value( comp, FTR_CUTOUT_TYPE, default = BOTH );
    _height_frac = __cutout_side_height_frac( comp );
    _depth = __cutout_side_depth( comp, side );
    _depth_inside = __cutout_side_depth_inside( comp, side );
    _width = __cutout_side_width( comp, side );
    _round_bottom = __cutout_side_round_bottom( comp, box_size, wall_thickness );
    _remaining_top_edge = ( _comp_size[ _perp_d ] - _width ) / 2;
    _remaining_depth = _comp_size[ _main_d ] - _depth_inside;
    _remaining_lower_wall = box_size[ k_z ] * ( 1 - _height_frac );

    if ( _width <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "has computed width ", _width,
            "mm; expected >0mm. Increase ", FTR_CUTOUT_WIDTH_PCT, "." ) );
    else if ( _width > _comp_size[ _perp_d ] )
        __PhysicalMsg( _cutout_ctx, str( "has computed width ", _width,
            "mm, exceeding compartment ", __axis_name( _perp_d ), " size ",
            _comp_size[ _perp_d ], "mm. Reduce ", FTR_CUTOUT_WIDTH_PCT, "." ) );
    else if ( _remaining_top_edge < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( _cutout_ctx, str( "leaves ", _remaining_top_edge,
            "mm of top-edge material on each side of computed width ", _width,
            "mm across compartment ", __axis_name( _perp_d ), " size ",
            _comp_size[ _perp_d ], "mm; below printable detail threshold ",
            MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Reduce ", FTR_CUTOUT_WIDTH_PCT,
            " or widen the compartment." ) );

    if ( !_round_bottom && _depth <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "has computed depth ", _depth,
            "mm; expected >0mm. Increase ", FTR_CUTOUT_DEPTH_PCT,
            " or ", FTR_CUTOUT_DEPTH_MAX, "." ) );
    else if ( !_round_bottom && _depth_inside >= _comp_size[ _main_d ] )
        __PhysicalMsg( _cutout_ctx, str( "removes the full compartment depth: computed inside depth ",
            _depth_inside, "mm versus compartment ", __axis_name( _main_d ), " size ",
            _comp_size[ _main_d ], "mm. Reduce ", FTR_CUTOUT_DEPTH_PCT,
            " or set a smaller ", FTR_CUTOUT_DEPTH_MAX, "." ) );
    else if ( !_round_bottom && _remaining_depth < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( _cutout_ctx, str( "leaves ", _remaining_depth,
            "mm of material behind computed inside depth ", _depth_inside,
            "mm on compartment ", __axis_name( _main_d ), "; below printable detail threshold ",
            MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Reduce ", FTR_CUTOUT_DEPTH_PCT,
            " or set ", FTR_CUTOUT_DEPTH_MAX, "." ) );

    if ( _height_frac <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "has normalized ", FTR_CUTOUT_HEIGHT_PCT,
            " ", _height_frac, ", leaving no side-wall opening. Increase ",
            FTR_CUTOUT_HEIGHT_PCT, "." ) );
    else if ( _remaining_lower_wall > 0 &&
              _remaining_lower_wall < MIN_PRINTABLE_WALL_THICKNESS )
        __PhysicalMsg( _cutout_ctx, str( "leaves ", _remaining_lower_wall,
            "mm lower wall below the cutout from normalized ",
            FTR_CUTOUT_HEIGHT_PCT, " ", _height_frac,
            "; below printable wall threshold ", MIN_PRINTABLE_WALL_THICKNESS,
            "mm. Set ", FTR_CUTOUT_HEIGHT_PCT,
            " to 100 to remove the thin strip, or lower it enough to leave a stronger wall." ) );
}

module __ValidateSideCutoutRoundedShapePhysical( comp, ctx, side, box_size, wall_thickness, lid_external_z )
{
    _cutout_ctx = __cutout_side_context( ctx, side );
    _main_d = __cutout_main_axis( side );
    _perp_d = __cutout_perp_axis( side );
    _shape = __cutout_side_shape( comp, side, box_size, wall_thickness, lid_external_z );
    _size = __cutout_side_size( comp, side, box_size, wall_thickness, lid_external_z );
    _round_bottom = __cutout_side_round_bottom( comp, box_size, wall_thickness );
    _radius = DEFAULT_MAX_CUTOUT_CORNER_RADIUS;
    _diameter = 2 * _radius;
    _min_x = __cutout_shape_min_x_span( _shape );
    _min_y = __cutout_shape_min_y_span( _shape );
    _x_action = ( side == k_front || side == k_back ) ?
        str( "Increase ", FTR_CUTOUT_WIDTH_PCT, " or ", FTR_COMPARTMENT_SIZE_XYZ,
            "[", _perp_d, "]." ) :
        str( "Increase ", FTR_CUTOUT_DEPTH_PCT, " or ", FTR_CUTOUT_DEPTH_MAX, "." );
    _y_action = ( side == k_front || side == k_back ) ?
        str( "Increase ", FTR_CUTOUT_DEPTH_PCT, " or ", FTR_CUTOUT_DEPTH_MAX, "." ) :
        str( "Increase ", FTR_CUTOUT_WIDTH_PCT, " or ", FTR_COMPARTMENT_SIZE_XYZ,
            "[", _perp_d, "]." );

    if ( _round_bottom )
    {
        _width = __cutout_side_width( comp, side );
        _cutout_z = __cutout_side_z( comp, box_size, wall_thickness, lid_external_z );

        if ( _width < _diameter )
            __PhysicalMsg( _cutout_ctx, str( "uses rounded-bottom finger geometry with computed width ",
                _width, "mm, below fixed rounded diameter ", _diameter,
                "mm from radius ", _radius, "mm. Increase ", FTR_CUTOUT_WIDTH_PCT,
                " or ", FTR_COMPARTMENT_SIZE_XYZ, "[", _perp_d, "]." ) );

        if ( _cutout_z < _diameter )
            __PhysicalMsg( _cutout_ctx, str( "uses rounded-bottom finger geometry with computed vertical span ",
                _cutout_z, "mm, below fixed rounded diameter ", _diameter,
                "mm from radius ", _radius, "mm. Increase ", FTR_CUTOUT_HEIGHT_PCT,
                ", box height, or lid height." ) );
    }
    else
    {
        if ( _min_x > MIN_PRINTABLE_DETAIL_THICKNESS && _size[ k_x ] < _min_x )
            __PhysicalMsg( _cutout_ctx, str( "uses rounded side-cutout shape ",
                _shape, " with computed local x span ", _size[ k_x ],
                "mm, below fixed rounded-corner requirement ", _min_x,
                "mm from radius ", _radius, "mm. ", _x_action ) );

        if ( _min_y > MIN_PRINTABLE_DETAIL_THICKNESS && _size[ k_y ] < _min_y )
            __PhysicalMsg( _cutout_ctx, str( "uses rounded side-cutout shape ",
                _shape, " with computed local y span ", _size[ k_y ],
                "mm, below fixed rounded-corner requirement ", _min_y,
                "mm from radius ", _radius, "mm. ", _y_action ) );
    }
}

module __ValidateCornerCutoutPhysical( comp, ctx, corner )
{
    _cutout_ctx = __cutout_corner_context( ctx, corner );
    _comp_size = __cmp_auto_compartment_size( comp );
    _padding = __cmp_auto_padding( comp );
    _cutout_size = __cutout_corner_size( comp );
    _inner_span_x = __cutout_corner_inner_span( comp, k_x );
    _inner_span_y = __cutout_corner_inner_span( comp, k_y );
    _remaining_x = _comp_size[ k_x ] - _inner_span_x;
    _remaining_y = _comp_size[ k_y ] - _inner_span_y;
    _fixed_radius = DEFAULT_MAX_CUTOUT_CORNER_RADIUS;
    _fixed_diameter = 2 * _fixed_radius;

    if ( _cutout_size[ k_x ] <= 0 || _cutout_size[ k_y ] <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "has computed corner cutout size ",
            _cutout_size, "mm from compartment floor ",
            [ _comp_size[ k_x ], _comp_size[ k_y ] ], "mm, padding ",
            _padding, "mm, and fixed inset fraction ",
            DEFAULT_CORNER_CUTOUT_INSET_FRACTION,
            "; expected positive x/y spans. Increase ",
            FTR_COMPARTMENT_SIZE_XYZ, " or ", FTR_PADDING_XY, "." ) );

    if ( _comp_size[ k_x ] > 0 && _cutout_size[ k_x ] > 0 )
    {
        if ( _inner_span_x >= _comp_size[ k_x ] )
            __PhysicalMsg( _cutout_ctx, str( "computed interior x span ",
                _inner_span_x, "mm reaches/exceeds compartment x size ",
                _comp_size[ k_x ], "mm, leaving ", _remaining_x,
                "mm before the opposite side. Corner cutouts use fixed inset fraction ",
                DEFAULT_CORNER_CUTOUT_INSET_FRACTION,
                "; increase ", FTR_COMPARTMENT_SIZE_XYZ, "[0]." ) );
        else if ( _remaining_x < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _cutout_ctx, str( "leaves ", _remaining_x,
                "mm of local x material after computed interior corner span ",
                _inner_span_x, "mm in compartment x size ",
                _comp_size[ k_x ], "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                FTR_COMPARTMENT_SIZE_XYZ, "[0]." ) );

        if ( _cutout_size[ k_x ] < _fixed_diameter )
            __PhysicalMsg( _cutout_ctx, str( "has computed x span ",
                _cutout_size[ k_x ], "mm, smaller than the fixed corner-cutout rounded diameter ",
                _fixed_diameter, "mm from radius ", _fixed_radius,
                "mm. Increase ", FTR_COMPARTMENT_SIZE_XYZ,
                "[0] or ", FTR_PADDING_XY, "[0] before enabling this corner cutout." ) );
    }

    if ( _comp_size[ k_y ] > 0 && _cutout_size[ k_y ] > 0 )
    {
        if ( _inner_span_y >= _comp_size[ k_y ] )
            __PhysicalMsg( _cutout_ctx, str( "computed interior y span ",
                _inner_span_y, "mm reaches/exceeds compartment y size ",
                _comp_size[ k_y ], "mm, leaving ", _remaining_y,
                "mm before the opposite side. Corner cutouts use fixed inset fraction ",
                DEFAULT_CORNER_CUTOUT_INSET_FRACTION,
                "; increase ", FTR_COMPARTMENT_SIZE_XYZ, "[1]." ) );
        else if ( _remaining_y < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _cutout_ctx, str( "leaves ", _remaining_y,
                "mm of local y material after computed interior corner span ",
                _inner_span_y, "mm in compartment y size ",
                _comp_size[ k_y ], "mm; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                FTR_COMPARTMENT_SIZE_XYZ, "[1]." ) );

        if ( _cutout_size[ k_y ] < _fixed_diameter )
            __PhysicalMsg( _cutout_ctx, str( "has computed y span ",
                _cutout_size[ k_y ], "mm, smaller than the fixed corner-cutout rounded diameter ",
                _fixed_diameter, "mm from radius ", _fixed_radius,
                "mm. Increase ", FTR_COMPARTMENT_SIZE_XYZ,
                "[1] or ", FTR_PADDING_XY, "[1] before enabling this corner cutout." ) );
    }
}

module __ValidateCornerCutoutPairPhysical( comp, ctx, corner_a, corner_b, D )
{
    _corners = __value( comp, FTR_CUTOUT_CORNERS_4B, default = [false, false, false, false] );
    _comp_size = __cmp_auto_compartment_size( comp );
    _inner_span = __cutout_corner_inner_span( comp, D );
    _bridge = _comp_size[ D ] - 2 * _inner_span;
    _axis_idx = D == k_x ? 0 : 1;

    if ( _corners[ corner_a ] && _corners[ corner_b ] &&
         _comp_size[ D ] > 0 && _inner_span > 0 )
    {
        _pair_ctx = __cutout_corner_pair_context( ctx, corner_a, corner_b );

        if ( _bridge <= 0 )
            __PhysicalMsg( _pair_ctx, str( "computed corner cutouts overlap along local ",
                __axis_name( D ), ": each removes ", _inner_span,
                "mm in compartment ", __axis_name( D ), " size ",
                _comp_size[ D ], "mm, leaving bridge ", _bridge,
                "mm. Increase ", FTR_COMPARTMENT_SIZE_XYZ, "[", _axis_idx, "]." ) );
        else if ( _bridge < MIN_PRINTABLE_DETAIL_THICKNESS )
            __PhysicalMsg( _pair_ctx, str( "leaves ", _bridge,
                "mm bridge between computed corner spans along local ",
                __axis_name( D ), "; below printable detail threshold ",
                MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Increase ",
                FTR_COMPARTMENT_SIZE_XYZ, "[", _axis_idx, "]." ) );
    }
}

module __ValidateCornerCutoutsPhysical( comp, ctx )
{
    _corners = __value( comp, FTR_CUTOUT_CORNERS_4B, default = [false, false, false, false] );

    for ( corner = [ k_front_left : k_front_right ] )
        if ( _corners[ corner ] )
            __ValidateCornerCutoutPhysical( comp, ctx, corner );

    // These pairings follow MakeCornerCutouts()'s local placement table.
    __ValidateCornerCutoutPairPhysical( comp, ctx, k_front_left, k_back_left, k_x );
    __ValidateCornerCutoutPairPhysical( comp, ctx, k_front_right, k_back_right, k_x );
    __ValidateCornerCutoutPairPhysical( comp, ctx, k_front_left, k_front_right, k_y );
    __ValidateCornerCutoutPairPhysical( comp, ctx, k_back_left, k_back_right, k_y );
}

module __ValidateBottomCutoutPhysical( comp, ctx, box_size, wall_thickness )
{
    _cutout_ctx = str( ctx, " > bottom cutout" );
    _comp_size = __cmp_auto_compartment_size( comp );
    _frac = __value( comp, FTR_CUTOUT_BOTTOM_PCT, default = 80 ) / 100;
    _cutout_size = [ _comp_size[ k_x ] * _frac, _comp_size[ k_y ] * _frac ];
    _floor_thickness = box_size[ k_z ] - _comp_size[ k_z ] - wall_thickness;
    _rim_x = ( _comp_size[ k_x ] - _cutout_size[ k_x ] ) / 2;
    _rim_y = ( _comp_size[ k_y ] - _cutout_size[ k_y ] ) / 2;
    _min_rim = min( _rim_x, _rim_y );

    if ( _frac <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "has normalized ", FTR_CUTOUT_BOTTOM_PCT,
            " ", _frac, ", producing computed opening ", _cutout_size,
            "mm. Increase ", FTR_CUTOUT_BOTTOM_PCT, "." ) );
    else if ( _cutout_size[ k_x ] > _comp_size[ k_x ] ||
              _cutout_size[ k_y ] > _comp_size[ k_y ] )
        __PhysicalMsg( _cutout_ctx, str( "has computed opening ", _cutout_size,
            "mm exceeding compartment floor ", [ _comp_size[ k_x ], _comp_size[ k_y ] ],
            "mm. Reduce ", FTR_CUTOUT_BOTTOM_PCT, "." ) );

    if ( _floor_thickness < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( _cutout_ctx, str( "leaves computed floor thickness ",
            _floor_thickness, "mm from box height ", box_size[ k_z ],
            "mm, compartment height ", _comp_size[ k_z ], "mm, and wall thickness ",
            wall_thickness, "mm; below printable detail threshold ",
            MIN_PRINTABLE_DETAIL_THICKNESS, "mm. Reduce compartment height or increase box height." ) );

    if ( _min_rim <= 0 )
        __PhysicalMsg( _cutout_ctx, str( "leaves no printable floor rim around computed opening ",
            _cutout_size, "mm inside compartment floor ",
            [ _comp_size[ k_x ], _comp_size[ k_y ] ], "mm. Reduce ",
            FTR_CUTOUT_BOTTOM_PCT, "." ) );
    else if ( _min_rim < MIN_PRINTABLE_DETAIL_THICKNESS )
        __PhysicalMsg( _cutout_ctx, str( "leaves minimum floor rim ", _min_rim,
            "mm around computed opening ", _cutout_size,
            "mm; below printable detail threshold ", MIN_PRINTABLE_DETAIL_THICKNESS,
            "mm. Reduce ", FTR_CUTOUT_BOTTOM_PCT,
            " or enlarge the compartment floor." ) );
}

module __ValidateCutoutPhysical( comp, ctx, box_size, wall_thickness, lid_external_z )
{
    _has_side_cutouts = __component_has_side_cutouts( comp );
    _has_corner_cutouts = __component_has_corner_cutouts( comp );
    _has_bottom_cutout = __component_has_bottom_cutout( comp );

    if ( _has_side_cutouts )
    {
        __ValidateCutoutPercentRange( comp, ctx, FTR_CUTOUT_HEIGHT_PCT, 100 );
        __ValidateCutoutPercentRange( comp, ctx, FTR_CUTOUT_DEPTH_PCT, 25 );
        __ValidateCutoutPercentRange( comp, ctx, FTR_CUTOUT_WIDTH_PCT, 50 );

        _depth_max = __value( comp, FTR_CUTOUT_DEPTH_MAX, default = 0 );
        if ( is_num( _depth_max ) && _depth_max < 0 )
            __PhysicalMsg( ctx, str( "has ", FTR_CUTOUT_DEPTH_MAX, " ",
                _depth_max, "mm outside expected range >=0mm; negative values are ignored by cutout sizing." ) );
    }

    if ( _has_bottom_cutout )
        __ValidateCutoutPercentRange( comp, ctx, FTR_CUTOUT_BOTTOM_PCT, 80 );

    if ( __component_cutout_physical_values_ok( comp ) &&
         __component_physical_supported_footprint( comp ) )
    {
        _sides = __value( comp, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] );
        for ( side = [ k_front : k_right ] )
            if ( _sides[ side ] )
                __ValidateSideCutoutRoundedShapePhysical( comp, ctx, side, box_size, wall_thickness, lid_external_z );

        if ( __value( comp, FTR_SHAPE, default = SQUARE ) == SQUARE )
        {
            for ( side = [ k_front : k_right ] )
                if ( _sides[ side ] )
                    __ValidateSideCutoutPhysical( comp, ctx, side, box_size, wall_thickness, lid_external_z );

            if ( _has_bottom_cutout )
                __ValidateBottomCutoutPhysical( comp, ctx, box_size, wall_thickness );
        }
    }

    if ( _has_corner_cutouts &&
         __component_corner_cutout_physical_values_ok( comp ) &&
         __component_physical_supported_footprint( comp ) )
        __ValidateCornerCutoutsPhysical( comp, ctx );
}

module __ValidateDividerSlotAxisPhysical( ctx, key, slots, width, rail_width, extent )
{
    if ( len( slots ) > 0 )
        for ( i = [ 0 : len( slots ) - 1 ] )
        {
            centerline = slots[ i ];
            if ( centerline < 0 || centerline > extent )
                __PhysicalMsg( ctx, str( "has ", key, " centerline ", centerline,
                    "mm outside component bounds 0..", extent, "mm." ) );
            else if ( centerline - width / 2 - rail_width < 0 ||
                      centerline + width / 2 + rail_width > extent )
                __PhysicalMsg( ctx, str( "has ", key, " centerline ", centerline,
                    "mm too close to component edge for divider groove width ",
                    width, "mm plus positive rail width ", rail_width,
                    "mm within bounds 0..", extent, "mm." ) );
        }
}

function __divider_slot_rail_width_for_validation( wall_thickness ) =
    max( MIN_PRINTABLE_DETAIL_THICKNESS, wall_thickness / 2 );

module __ValidateFeatureDividerCountPhysical( dividers, ctx )
{
    _count = __value( dividers, DIV_NUM_DIVIDERS, default = 0 );
    _count_ctx = str( ctx, " > dividers" );

    _axis = __value( dividers, DIV_AXIS, default = X );
    if ( !( _axis == X || _axis == Y ) )
        __PhysicalMsg( _count_ctx, str( "has ", DIV_AXIS,
            " ", _axis, "; expected X or Y." ) );

    if ( is_num( _count ) )
    {
        if ( _count < 0 )
            __PhysicalMsg( _count_ctx, str( "has ", DIV_NUM_DIVIDERS,
                " ", _count, "; expected >=0." ) );
        if ( _count != floor( _count ) )
            __PhysicalMsg( _count_ctx, str( "has ", DIV_NUM_DIVIDERS,
                " ", _count, "; expected an integer count." ) );
    }
}

module __ValidateDividerSlotsPhysical( comp, ctx, box_size, wall_thickness )
{
    if ( __component_has_divider_rails( comp ) &&
         __component_divider_slots_physical_values_ok( comp ) )
    {
        _dividers = __component_dividers( comp );
        _width = __component_divider_slot_width( comp );
        _depth = __value( _dividers, DIV_SLOT_DEPTH, default = wall_thickness );
        _rail_width = __divider_slot_rail_width_for_validation( wall_thickness );
        _comp_size = [
            __cmp_auto_size( comp, k_x ),
            __cmp_auto_size( comp, k_y ),
            __cmp_auto_size( comp, k_z )
        ];
        _slots_x = __divider_centerlines_for_axis( _dividers, _comp_size[ k_x ], k_x );
        _slots_y = __divider_centerlines_for_axis( _dividers, _comp_size[ k_y ], k_y );
        _slot_ctx = str( ctx, " > divider rail grooves" );

        if ( _width <= 0 )
            __PhysicalMsg( _slot_ctx, str( "has inferred divider slot width ",
                _width, "mm from DIV_THICKNESS + G_TOLERANCE; expected >0mm." ) );

        if ( _depth <= 0 )
            __PhysicalMsg( _slot_ctx, str( "has ", DIV_SLOT_DEPTH,
                " ", _depth, "mm; expected >0mm." ) );
        else
        {
            if ( len( _slots_x ) > 0 && 2 * _depth > _comp_size[ k_y ] )
                __PhysicalMsg( _slot_ctx, str( "requests ", DIV_SLOT_DEPTH,
                    " ", _depth, "mm for x-axis dividers",
                    ", causing front/back positive rails to overlap across component y span ",
                    _comp_size[ k_y ], "mm. Geometry clamps the rail projection." ) );
            if ( len( _slots_y ) > 0 && 2 * _depth > _comp_size[ k_x ] )
                __PhysicalMsg( _slot_ctx, str( "requests ", DIV_SLOT_DEPTH,
                    " ", _depth, "mm for y-axis dividers",
                    ", causing left/right positive rails to overlap across component x span ",
                    _comp_size[ k_x ], "mm. Geometry clamps the rail projection." ) );
        }

        if ( _width > 0 )
        {
            __ValidateDividerSlotAxisPhysical( _slot_ctx, "DIV_NUM_DIVIDERS x-axis",
                _slots_x, _width, _rail_width, _comp_size[ k_x ] );
            __ValidateDividerSlotAxisPhysical( _slot_ctx, "DIV_NUM_DIVIDERS y-axis",
                _slots_y, _width, _rail_width, _comp_size[ k_y ] );
        }
    }
}

module __ValidateFeatureDividersPhysical( comp, ctx, box_size, wall_thickness )
{
    _dividers = __component_dividers( comp );
    if ( __feature_dividers_enabled( _dividers ) )
    {
        __ValidateDividerPhysical( _dividers, str( ctx, " > dividers" ) );
        __ValidateFeatureDividerCountPhysical( _dividers, ctx );
        __ValidateDividerSlotsPhysical( comp, ctx, box_size, wall_thickness );
    }
}

module __ValidateComponentPhysical( comp, ctx, box_ctx, box_size, wall_thickness, lid_external_z )
{
    if ( __component_physical_values_ok( comp ) )
    {
        _comp_size = [
            __cmp_auto_size( comp, k_x ),
            __cmp_auto_size( comp, k_y ),
            __cmp_auto_size( comp, k_z )
        ];

        if ( _comp_size[ k_x ] <= 0 || _comp_size[ k_y ] <= 0 || _comp_size[ k_z ] <= 0 )
            __PhysicalMsg( ctx, str( "has non-positive total size ", _comp_size, "." ) );

        if ( _comp_size[ k_z ] + wall_thickness > box_size[ k_z ] )
            __PhysicalMsg( ctx, str( "is too tall: compartment height ", _comp_size[ k_z ],
                "mm plus bottom wall ", wall_thickness, "mm exceeds box height ",
                box_size[ k_z ], "mm." ) );

        if ( __component_physical_position_ok( comp ) && __component_physical_supported_transformed_footprint( comp ) )
        {
            _min_x = __component_validation_transformed_min( comp, box_size, wall_thickness, k_x );
            _max_x = __component_validation_transformed_max( comp, box_size, wall_thickness, k_x );
            _min_y = __component_validation_transformed_min( comp, box_size, wall_thickness, k_y );
            _max_y = __component_validation_transformed_max( comp, box_size, wall_thickness, k_y );

            if ( _min_x < wall_thickness || _min_y < wall_thickness ||
                 _max_x > box_size[ k_x ] - wall_thickness ||
                 _max_y > box_size[ k_y ] - wall_thickness )
                __PhysicalMsg( ctx, str( "footprint [", _min_x, ", ", _min_y,
                    "] to [", _max_x, ", ", _max_y, "] exceeds usable interior [",
                    wall_thickness, ", ", wall_thickness, "] to [",
                    box_size[ k_x ] - wall_thickness, ", ",
                    box_size[ k_y ] - wall_thickness, "] in ", box_ctx, "." ) );
        }
    }

    __ValidateCutoutPhysical( comp, ctx, box_size, wall_thickness, lid_external_z );
    __ValidateFeatureDividersPhysical( comp, ctx, box_size, wall_thickness );
}

module __ValidateFeatureOverlaps( element, box_ctx, box_size, wall_thickness )
{
    for ( i = [ 0 : max( len( element ) - 1, 0 ) ] )
        if ( i < len( element ) - 1 &&
             __is_box_feature_entry( element[i] ) &&
             __enabled_for_physical_validation( element[i] ) &&
             __component_physical_values_ok( element[i] ) &&
             __component_physical_position_ok( element[i] ) &&
             __component_physical_supported_transformed_footprint( element[i] ) )
            for ( j = [ i + 1 : max( len( element ) - 1, 0 ) ] )
                if ( __is_box_feature_entry( element[j] ) &&
                     __enabled_for_physical_validation( element[j] ) &&
                     __component_physical_values_ok( element[j] ) &&
                     __component_physical_position_ok( element[j] ) &&
                     __component_physical_supported_transformed_footprint( element[j] ) &&
                     __components_overlap_xy( element[i], element[j], box_size, wall_thickness ) )
                    __PhysicalMsg( box_ctx, str( "component[", i, "] overlaps component[", j,
                        "] in XY footprint. Move one feature or reduce size/padding/margins." ) );
}

// Validate a key-value table against a set of valid keys.
// Echoes a message for each unrecognized key.
module __ValidateTable( table, valid_keys, context_name )
{
    if ( is_list( table ) )
    {
        for ( i = [ 0 : max( len( table ) - 1, 0 ) ] )
        {
            entry = table[i];
            if ( is_list( entry ) && len( entry ) >= 2 )
            {
                key = entry[ k_key ];
                if ( is_string( key ) )
                {
                    if ( !__is_valid_key( key, valid_keys ) )
                        echo( str( "BGSD_WARNING [code=BIT-KEY] [key=", key, "]: unrecognized key \"", key, "\" in ", context_name,
                                   ". Check spelling. Valid keys: ", valid_keys ) );
                }
                else
                {
                    echo( str( "BGSD_WARNING [code=BIT-KEY]: non-string key at index ", i, " in ", context_name,
                               ". Keys must be strings, got: ", key ) );
                }
            }
            else if ( is_list( entry ) && len( entry ) < 2 )
            {
                echo( str( "BGSD_WARNING [code=BIT-KEY]: malformed entry at index ", i, " in ", context_name,
                           ". Expected [key, value] pair, got: ", entry ) );
            }
            // bare strings (type keys like BOX_FEATURE, BOX_LID, LABEL) are silently skipped
        }
    }
}

// Validate all labels found in a key-value table (keys + types).
module __ValidateLabels( table, context_name )
{
    if ( is_list( table ) )
    {
        for ( i = [ 0 : max( len( table ) - 1, 0 ) ] )
        {
            if ( is_list( table[i] ) && len( table[i] ) >= 2 )
            {
                if ( table[i][ k_key ] == LABEL )
                {
                    _lbl_ctx = str( context_name, " > label" );
                    __ValidateTable( table[i], __VALID_LABEL_KEYS, _lbl_ctx );
                    __ValidateLabelTypes( table[i], _lbl_ctx );
                }
            }
        }
    }
}

// Validate divider subgroups found inside a feature table.
module __ValidateFeatureDividers( table, context_name )
{
    if ( is_list( table ) )
    {
        for ( i = [ 0 : max( len( table ) - 1, 0 ) ] )
        {
            if ( is_list( table[i] ) && len( table[i] ) >= 2 )
            {
                if ( table[i][ k_key ] == FTR_DIVIDERS )
                {
                    _div_ctx = str( context_name, " > dividers" );
                    __ValidateTable( table[i], __VALID_FEATURE_DIVIDER_KEYS, _div_ctx );
                    __ValidateFeatureDividerTypes( table[i], _div_ctx );
                }
            }
        }
    }
}

// Validate a complete element (box or divider) and its sub-structures.
// Key/type validation and physical validation can be enabled independently.
module __ValidateElement( element, element_name, element_type = undef )
{
    element_type = element_type != undef ? element_type : __type( element );

    if ( element_type == DIVIDERS )
    {
        _ctx = str( "dividers \"", element_name, "\"" );
        if ( $g_validate_keys_b )
        {
            __ValidateTable( element, __VALID_DIVIDER_KEYS, _ctx );
            __ValidateDividerTypes( element, _ctx );
        }
        if ( $g_validate_physical_b &&
             __enabled_for_physical_validation( element ) )
            __ValidateDividerPhysical( element, _ctx );
    }
    else
    {
        // Box or Spacer
        _ctx = str( "box \"", element_name, "\"" );
        if ( $g_validate_keys_b )
        {
            __ValidateTable( element, __VALID_BOX_KEYS, _ctx );
            __ValidateBoxTypes( element, _ctx );
        }

        // Report auto-sized box dimensions
        if ( $g_validate_keys_b &&
             __value( element, BOX_SIZE_XYZ, default = false ) == false )
        {
            _auto = __box_auto_size( element );
            echo( str( "BGSD_INFO [code=BIT-AUTO-SIZE] [key=", __key_display_name( BOX_SIZE_XYZ ), "]: ", _ctx, " has no BOX_SIZE_XYZ — auto-calculated as ",
                       _auto, " from components." ) );
        }

        _box_size_values_ok = __box_physical_size_values_ok( element );
        _box_size = _box_size_values_ok ? __element_dimensions_impl( element, element_type ) : false;
        _wt = __value( element, BOX_WALL_THICKNESS, default = $g_wall_thickness );

        if ( $g_validate_physical_b )
        {
            if ( is_num( _wt ) && _wt <= 0 )
                __PhysicalMsg( _ctx, str( "has non-positive wall thickness ", _wt, "mm." ) );
            else if ( is_num( _wt ) && _wt < MIN_PRINTABLE_WALL_THICKNESS )
                __PhysicalMsg( _ctx, str( "has wall thickness ", _wt,
                    "mm, below printable wall threshold ", MIN_PRINTABLE_WALL_THICKNESS, "mm." ) );
        }

        // Validate lid sub-table (keys + types)
        lid = __find_entry( element, BOX_LID );
        if ( is_list( lid ) && len( lid ) > 0 )
        {
            _lid_ctx = str( _ctx, " > lid" );
            if ( $g_validate_keys_b )
            {
                __ValidateTable( lid, __VALID_LID_KEYS, _lid_ctx );
                __ValidateLidTypes( lid, _lid_ctx );
                __ValidateLabels( lid, _lid_ctx );
            }
            if ( $g_validate_physical_b &&
                 __all_num_list( _box_size, 3 ) && is_num( _wt ) )
                __ValidateLidPhysical( element, _box_size, lid, _lid_ctx, _wt );

            if ( $g_validate_physical_b &&
                 __optional_bool_value_ok( element, BOX_NO_LID_B ) &&
                 !__value( element, BOX_NO_LID_B, default = false ) &&
                 __box_lid_type_for_cutout_validation( element ) == LID_SLIDING &&
                 __all_num_list( _box_size, 3 ) && is_num( _wt ) )
                __ValidateSlidingDetentPhysical( _ctx, _box_size, _wt, lid );
        }

        // Validate each component sub-table (keys + types)
        for ( i = [ 0 : max( len( element ) - 1, 0 ) ] )
        {
            if ( is_list( element[i] ) && len( element[i] ) >= 2 )
            {
                if ( element[i][ k_key ] == BOX_FEATURE )
                {
                    comp = element[i];
                    _comp_ctx = str( _ctx, " > component[", i, "]" );
                    if ( $g_validate_keys_b )
                    {
                        __ValidateTable( comp, __VALID_COMPONENT_KEYS, _comp_ctx );
                        __ValidateComponentTypes( comp, _comp_ctx );
                        __ValidateLabels( comp, _comp_ctx );
                        __ValidateFeatureDividers( comp, _comp_ctx );
                    }

                    // #3: Warn when FTR_COMPARTMENT_SIZE_XYZ is missing
                    if ( $g_validate_keys_b &&
                         __value( comp, FTR_COMPARTMENT_SIZE_XYZ, default = false ) == false )
                        echo( str( "BGSD_WARNING [code=BIT-DEFAULT-FEATURE-SIZE] [key=", __key_display_name( FTR_COMPARTMENT_SIZE_XYZ ), "]: ", _comp_ctx,
                            " has no FTR_COMPARTMENT_SIZE_XYZ — using default [10, 10, 10].",
                            " This is probably not what you want." ) );

                    if ( $g_validate_physical_b &&
                         __enabled_for_physical_validation( comp ) &&
                         __all_num_list( _box_size, 3 ) && is_num( _wt ) )
                    {
                        _lid_external_z = __box_lid_external_z_for_cutout_validation( element, _wt );
                        __ValidateComponentPhysical( comp, _comp_ctx, _ctx, _box_size, _wt, _lid_external_z );
                        if ( __optional_bool_value_ok( element, BOX_NO_LID_B ) &&
                             !__value( element, BOX_NO_LID_B, default = false ) &&
                             __box_lid_type_for_cutout_validation( element ) == LID_SLIDING )
                            __ValidateSlidingDetentCutoutCollision( comp, _comp_ctx, _box_size, _wt, lid );
                    }
                }
            }
        }

        if ( $g_validate_physical_b &&
             __all_num_list( _box_size, 3 ) && is_num( _wt ) )
            __ValidateFeatureOverlaps( element, _ctx, _box_size, _wt );

        // Validate box-level labels
        if ( $g_validate_keys_b )
            __ValidateLabels( element, _ctx );
    }
}

// =============================================================================
// ENTRY POINT
// =============================================================================

// Top-level entry point. Accepts a DATA array containing globals and elements.
// Extracts globals, filters to element entries, then dispatches each element.
module Make(DATA = DATA)
{
    // Extract all globals from DATA array (dynamic scoping shadows file-level defaults)
    $g_print_lid_b = __value(DATA, G_PRINT_LID_B, default = $g_print_lid_b);
    $g_print_box_b = __value(DATA, G_PRINT_BOX_B, default = $g_print_box_b);
    $g_print_dividers = __value(DATA, G_PRINT_DIVIDERS, default = $g_print_dividers);
    $g_print_dividers_only_b = __value(DATA, G_PRINT_DIVIDERS_ONLY_B, default = $g_print_dividers_only_b);
    $g_fit_test_b = __value(DATA, G_FIT_TEST_B, default = $g_fit_test_b);
    $g_isolated_print_box = __value(DATA, G_ISOLATED_PRINT_BOX, default = $g_isolated_print_box);
    $g_visualization_b = __value(DATA, G_VISUALIZATION_B, default = $g_visualization_b);
    $g_vis_actual_b = $g_visualization_b && $preview;
    $g_preview_no_labels_b = __value(DATA, G_PREVIEW_NO_LABELS_B, default = $g_preview_no_labels_b);
    $g_no_labels_actual_b = $g_preview_no_labels_b && $preview;
    $g_validate_keys_b = __value(DATA, G_VALIDATE_KEYS_B, default = $g_validate_keys_b);
    $g_validate_physical_b = __value(
        DATA,
        G_VALIDATE_PHYSICAL_B,
        default = __value( DATA, G_VALIDATE_KEYS_B, default = $g_validate_keys_b ) ?
            $g_validate_physical_b :
            false
    );
    $g_wall_thickness = __value(DATA, G_WALL_THICKNESS, default = $g_wall_thickness);
    $g_detent_thickness = __value(DATA, G_DETENT_THICKNESS, default = $g_detent_thickness);
    $g_detent_spacing = __value(DATA, G_DETENT_SPACING, default = $g_detent_spacing);
    $g_detent_dist_from_corner = __value(DATA, G_DETENT_DIST_FROM_CORNER, default = $g_detent_dist_from_corner);
    $g_detent_min_spacing = __value(DATA, G_DETENT_MIN_SPACING, default = $g_detent_min_spacing);
    $g_lid_thickness = __value(DATA, G_LID_THICKNESS, default = $g_lid_thickness);
    $g_colorize_b = __value(DATA, G_COLORIZE_B, default = $g_colorize_b);
    $g_tolerance = __value(DATA, G_TOLERANCE, default = $g_tolerance);
    $g_tolerance_detent_pos = __value(DATA, G_TOLERANCE_DETENT_POS, default = $g_tolerance_detent_pos);
    $g_print_mmu_layer = __value(DATA, G_PRINT_MMU_LAYER, default = $g_print_mmu_layer);
    $g_default_font = __value(DATA, G_DEFAULT_FONT, default = $g_default_font);

    // Filter DATA to element entries only (skip globals) — uses $data for dynamic scoping
    $data = [for (entry = DATA) if (is_list(entry) && __type_from_key(entry[0]) != undef) entry];

    echo( str( "\n\n\n", COPYRIGHT_INFO, "\n\n\tVersion ", VERSION, "\n\n" ));

    if ( $g_validate_keys_b )
    {
        if ( !__divider_print_selector_valid( $g_print_dividers ) )
            __TypeMsg( G_PRINT_DIVIDERS, "global data", "boolean, string, or list of strings", $g_print_dividers );

        if ( !is_bool( $g_print_dividers_only_b ) )
            __TypeMsg( G_PRINT_DIVIDERS_ONLY_B, "global data", "boolean (true/false)", $g_print_dividers_only_b );
    }

    // Validate all elements if key/type or physical validation is enabled
    if ( $g_validate_keys_b || $g_validate_physical_b )
    {
        if ( __is_element_isolated_for_print() )
        {
            _iso_idx = __find_isolated_index();
            __ValidateElement( __element( _iso_idx ), __element_name( _iso_idx ), __type_at( _iso_idx ) );
        }
        else
        {
            for ( vi = [ 0 : __num_elements() - 1 ] )
            {
                __ValidateElement( __element( vi ), __element_name( vi ), __type_at( vi ) );
            }
        }
    }

    if ( __is_element_isolated_for_print() )
    {
        _iso_idx = __find_isolated_index();
        element = __element( _iso_idx );

        __MaybeDebug( __is_element_debug( element ) )
        {
            if ( __type_at( _iso_idx ) == DIVIDERS )
            {
                MakeDividers( element );
            }
            else
            {
                MakeBox( element );
            }
        }
    }
    else
    {
        for( i = [ 0: __num_elements() - 1 ] )
        {
            element = __element( i );

            element_position = ( $g_vis_actual_b && is_list( __box_vis_position( element ) ) ) ? __box_vis_position( element ) : [ __element_position_x( i ), 0, 0 ];
            element_rotation = ( $g_vis_actual_b && is_num( __box_vis_rotation( element ) ) ) ? __box_vis_rotation( element ) : 0;

            translate( element_position )
                RotateAndMoveBackToOrigin( element_rotation, __element_dimensions( i ) )
                {
                    if ( __is_element_enabled( element ) )
                    {
                        __MaybeDebug( __is_element_debug( element ) )
                        Colorize()
                        {
                           if ( __type_at( i ) == DIVIDERS )
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


// =============================================================================
// DIVIDERS
// =============================================================================

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
    number_of_letters_before_scale_to_fit = __div_tab_text_char_threshold( div );
    text_embossed = __div_tab_text_embossed( div );

    divider_bottom = __div_frame_bottom( div );
    divider_top = __div_frame_top( div );
    divider_column = __div_frame_column( div );
    divider_corner_radius = __div_frame_radius( div );
    raw_num_columns = __div_frame_num_columns( div );
    num_columns = is_num( raw_num_columns ) ? floor( raw_num_columns ) : -1;

    number_of_tabs_per_row = __div_tab_cycle( div );
    tab_starting_position = __div_tab_cycle_start( div );

    space_between_tabs = (width - tab_width ) / ( number_of_tabs_per_row - 1 );

    for (idx = [ 0 : len( tab_text ) - 1 ] ) 
    {
        tab_idx = (idx + tab_starting_position - 1) % number_of_tabs_per_row;
        tab_offset = space_between_tabs * tab_idx;

        y_offset = idx * ( height + tab_height + DISTANCE_BETWEEN_PARTS );


        translate( [ 0, y_offset, 0])
            MakeDivider(title = tab_text[idx], tab_offset = tab_offset );
    }

    module MakeDivider( title, tab_offset  )
    {

        column_height = height - tab_height/2;

        difference()
        {
            MakeRoundedCubeAxis( [ width, height, depth ], divider_corner_radius, [t, t, t, t], k_z);

            if ( num_columns >= 0 )
            {
                gap_size = ( width - ( ( 2 + num_columns ) * divider_column ) ) / ( num_columns + 1 );
                opening_height = height - divider_bottom - divider_top;

                if ( gap_size > 0 && opening_height > 0 )
                    for (c = [ 0 : num_columns ] )
                    {
                        translate( [ divider_column + ( divider_column + gap_size ) * c, divider_bottom, 0 ] )
                            MakeRoundedCubeAxis( [ gap_size, opening_height, depth ], divider_corner_radius, k_z );
                    }
            }

        }

        // TAB
        height_overlap = tab_radius;
        title_pos = [ tab_offset, height - height_overlap, 0];
        text_pos = title_pos + [ tab_width/2, font_size * 2, 0 ];
        text_width = len(title) > number_of_letters_before_scale_to_fit ? tab_width * DEFAULT_TAB_TEXT_WIDTH_FRACTION : 0;

        if ( text_embossed )
        {
            // tab shape
            translate( title_pos )
                MakeRoundedCubeAxis( [ tab_width, tab_height + height_overlap, depth], tab_radius, [f, f, t, t], k_z);

            // raised text on top of tab
            translate( text_pos + [0, 0, depth] )
                resize([ text_width, 0, 0 ], auto=[ true, true, false])
                    linear_extrude( depth )
                        text(text = title, 
                            font = font, 
                            size = font_size, 
                            valign = "top",
                            halign = "center", 
                            spacing = font_spacing,
                            $fn = fn);
        }
        else
        {
            // debossed: cut text through full depth (v3 default behavior)
            difference()
            {
                // tab shape
                translate( title_pos )
                    MakeRoundedCubeAxis( [ tab_width, tab_height + height_overlap, depth], tab_radius, [f, f, t, t], k_z);

                // words — cut through full depth
                translate( text_pos )
                    resize([ text_width, 0, 0 ], auto=[ true, true, false])
                        linear_extrude( depth )
                            text(text = title, 
                                font = font, 
                                size = font_size, 
                                valign = "top",
                                halign = "center", 
                                spacing = font_spacing,
                                $fn = fn);
            }
        }

        
    }
}

/**
 * MakeBox - Main module for creating a box component
 * 
 * This module is the central function of the Boardgame Insert Toolkit that
 * creates box components with optional features like compartments, lids,
 * labels, stackability, and more.
 *
 * @param box A data structure containing all the parameters for the box:
 *   - TYPE: The type of component ("box", "spacer", etc.)
 *   - BOX_SIZE_XYZ: [x,y,z] dimensions of the box
 *   - BOX_FEATURE: Sub-components like compartments
 *   - BOX_LID: Lid parameters
 *   - BOX_STACKABLE_B: Whether the box should be stackable
 *   - BOX_NO_LID_B: Whether the box should have no lid
 *   - LABEL: Text or image labels for the box
 *   - And many other optional parameters
 */

// =============================================================================
// MAKEBOX — Rectangular box generation
// =============================================================================
// Generates a rectangular box with optional lid, compartments, labels, cutouts,
// and stackable features. Uses cube() for shell geometry.
// Key variables set here: m_box_size[x,y,z], k_z=k_z,
// m_lid_size_ext/int, m_notch_length_base (used by shared accessor functions).

module MakeBox( box )
{
    m_num_components =  len( box );



    m_box_is_spacer = ( __type( box )  == SPACER ) || $g_fit_test_b;

    m_box_is_stackable = __value( box, BOX_STACKABLE_B, default = false );

    m_wall_thickness = $g_fit_test_b ? 0.5 : __value( box, BOX_WALL_THICKNESS, default = $g_wall_thickness );

    // CHAMFER_N is the surface (diagonal) width of the 45° chamfer face;
    // m_box_chamfer is the perpendicular leg used by every consumer (exterior
    // shell, cavity bottom/top chamfers). leg = surface_width / sqrt(2).
    m_box_chamfer = $g_fit_test_b ? 0 : __value( box, CHAMFER_N, default = 0.6 ) / sqrt(2);

    m_lid = __find_entry( box, BOX_LID );

    m_lid_solid = __value( m_lid, LID_SOLID_B, default = false );
    m_lid_type_raw = __value( m_lid, LID_TYPE, default = false );
    m_legacy_lid_inset = m_box_is_stackable || __value( m_lid, LID_INSET_B, default = false );
    m_lid_type = ( m_lid_type_raw == LID_CAP || m_lid_type_raw == LID_INSET || m_lid_type_raw == LID_SLIDING ) ?
        m_lid_type_raw :
        ( m_legacy_lid_inset ? LID_INSET : LID_CAP );
    m_lid_sliding = m_lid_type == LID_SLIDING;
    m_lid_inset = m_lid_type == LID_INSET;
    m_lid_cap = m_lid_type == LID_CAP;
    m_lid_slide_side_raw = __value( m_lid, LID_SLIDE_SIDE, default = FRONT );
    m_lid_slide_side = ( m_lid_slide_side_raw == FRONT || m_lid_slide_side_raw == BACK || m_lid_slide_side_raw == LEFT || m_lid_slide_side_raw == RIGHT ) ?
        m_lid_slide_side_raw :
        FRONT;
    m_lid_slides_x = m_lid_slide_side == LEFT || m_lid_slide_side == RIGHT;
    m_lid_fit_under = !m_lid_sliding && __value( m_lid, LID_FIT_UNDER_B, default = true );

    m_lid_thickness = $g_fit_test_b ? 0.5 :
        ( $g_lid_thickness == false ? m_wall_thickness : $g_lid_thickness );

    // the part of the lid that overlaps the box
    m_lid_wall_height = m_lid_sliding ?
        m_lid_thickness :
        __value( m_lid, LID_HEIGHT, default = m_lid_inset ? DEFAULT_INSET_LID_HEIGHT : DEFAULT_CAP_LID_HEIGHT );
    m_lid_wall_thickness = m_lid_inset ? 2*m_wall_thickness : ( m_lid_sliding ? m_wall_thickness : m_wall_thickness/2 );

    m_sliding_lid_bevel = max( HULL_EPSILON, min( m_lid_thickness / 2, m_wall_thickness / 2 ) );
    // Sliding lids bear on a half-wall-depth shelf below the 45-degree rail wedge.
    m_sliding_lid_groove_depth = m_sliding_lid_bevel;
    m_sliding_lid_rail_width = max( HULL_EPSILON, m_wall_thickness - m_sliding_lid_groove_depth );
    m_sliding_lid_rail_lip_width = m_sliding_lid_rail_width + m_sliding_lid_groove_depth;
    m_sliding_lid_fit_tolerance = max( 0, $g_tolerance );
    m_sliding_lid_rail_side_clearance = m_sliding_lid_rail_width + 2*m_sliding_lid_fit_tolerance;
    m_sliding_lid_stop_clearance = m_sliding_lid_rail_width + m_sliding_lid_fit_tolerance;
    m_sliding_lid_panel_thickness = max( HULL_EPSILON, m_lid_thickness - 2*m_sliding_lid_fit_tolerance );

    m_box_has_lid = !__value( box, BOX_NO_LID_B, default = false );
    m_global_divider_output_only = is_bool( $g_print_dividers_only_b ) && $g_print_dividers_only_b;
    m_has_feature_divider_output_only = __box_has_divider_output_only( box );
    m_divider_output_only = m_global_divider_output_only || m_has_feature_divider_output_only;

    m_box_size = ( $g_fit_test_b && m_box_has_lid ) ?
            [   __element_dimensions( box )[ k_x ], 
                __element_dimensions( box )[ k_y ], 
                __element_dimensions( box )[ k_z ] + __lid_external_size( k_z )
            ] :
            __element_dimensions( box );


    // Precomputed dimension arrays for lid sizing (box type specific)
    m_lid_size_ext = m_lid_sliding ?
        ( m_lid_slides_x ?
            [
                max( 0.01, m_box_size[ k_x ] - m_sliding_lid_stop_clearance ),
                max( 0.01, m_box_size[ k_y ] - 2*m_sliding_lid_rail_side_clearance ),
                m_sliding_lid_panel_thickness
            ] :
            [
                max( 0.01, m_box_size[ k_x ] - 2*m_sliding_lid_rail_side_clearance ),
                max( 0.01, m_box_size[ k_y ] - m_sliding_lid_stop_clearance ),
                m_sliding_lid_panel_thickness
            ] ) :
        [ m_box_size[ k_x ], m_box_size[ k_y ], m_lid_thickness + m_lid_wall_height ];
    m_lid_size_int = m_lid_sliding ?
        m_lid_size_ext :
        [ m_box_size[ k_x ] - 2*m_lid_wall_thickness, m_box_size[ k_y ] - 2*m_lid_wall_thickness, m_lid_wall_height ];
    m_notch_length_base = [ m_box_size[ k_x ] / 5.0, m_box_size[ k_y ] / 5.0 ];

    function __notch_length( D ) = m_notch_length_base[ D ];

    function __lid_notch_depth() = m_wall_thickness / 2;

    function __lid_external_size( D ) = m_lid_size_ext[ D ];

    m_has_solid_lid = m_lid_solid || $g_vis_actual_b;
    m_lid_has_labels = !!__value( m_lid, LABEL, default = false );
    m_lid_solid_label_depth = __value( m_lid, LID_SOLID_LABELS_DEPTH, default = 0.5 );

    function __lid_internal_size( D ) = m_lid_size_int[ D ];

    function __feature_divider_should_print( component ) =
        __component_has_divider_slots( component ) &&
        __divider_print_selector_matches( $g_print_dividers, __value( box, NAME, default = "" ), component ) &&
        ( !m_has_feature_divider_output_only || m_global_divider_output_only || __component_dividers_output_only( component ) );

    function __feature_divider_should_print_at( i ) =
        box[ i ][ k_key ] == BOX_FEATURE && __feature_divider_should_print( box[ i ] );

    function __feature_divider_output_index( i, j = 0, count = 0 ) =
        j >= i ? count :
        __feature_divider_output_index(
            i,
            j + 1,
            count + ( __feature_divider_should_print_at( j ) ? 1 : 0 ) );

    function __feature_divider_position_index( i ) =
        m_divider_output_only ? __feature_divider_output_index( i ) : i + 1;

    m_lid_cutout_sides = __value( m_lid, LID_CUTOUT_SIDES_4B, default = [f,f,f,f]);
    m_lid_is_inverted = __value( m_lid, LID_LABELS_INVERT_B, default = false );


    m_lid_tab_sides = __value( m_lid, LID_TABS_4B, default = [t,t,t,t]);

    m_lid_label_bg_thickness = __value( m_lid, LID_LABELS_BG_THICKNESS, default = 2.0 );
    m_lid_label_border_thickness = __value( m_lid, LID_LABELS_BORDER_THICKNESS, default = 0.3 );
    m_lid_stripe_width = __value( m_lid, LID_STRIPE_WIDTH, default = 0.5 );
    m_lid_stripe_space = __value( m_lid, LID_STRIPE_SPACE, default = 1 );
    m_lid_frame_width = __value( m_lid, LID_FRAME_WIDTH, default = m_wall_thickness );

    m_lid_pattern_n1 = __value( m_lid, LID_PATTERN_N1, default = 6 );
    m_lid_pattern_n2 = __value( m_lid, LID_PATTERN_N2, default = 6 );
    m_lid_pattern_angle = __value( m_lid, LID_PATTERN_ANGLE, default = 30 );
    m_lid_pattern_row_offset = __value( m_lid, LID_PATTERN_ROW_OFFSET, default = 50 );
    m_lid_pattern_col_offset = __value( m_lid, LID_PATTERN_COL_OFFSET, default = 100 );
    m_lid_pattern_thickness = __value( m_lid, LID_PATTERN_THICKNESS, default = 0.5 );

    m_lid_pattern_radius = __value( m_lid, LID_PATTERN_RADIUS, default = 4.0 );



    m_lid_tab = [ max( m_box_size[ k_x ]/4, $g_detent_spacing * 2 ), m_wall_thickness,  __lid_external_size( k_z ) + 1];    

    m_box_inner_position_min = [ m_wall_thickness, m_wall_thickness, m_wall_thickness ];
    m_box_inner_position_max = m_box_size - m_box_inner_position_min;

    if ( m_box_is_spacer )
    {
        MakeLayer( layer = "layer_spacer" );
    }  
    else
    {
        if( !m_divider_output_only && $g_print_lid_b  && m_box_has_lid )
        {
            MakeLayer( layer = "layer_lid");
        }

        if ( $g_print_box_b && !m_divider_output_only )
        {
            difference()
            {

                // carve out the compartments from the box
                difference()
                {
                    MakeLayer( layer = "outerbox" );

                    difference() // we want to preserve the corners regardless
                    {
                        // create a negative of the component
                        for( i = [ 0: m_num_components - 1 ] )
                        {
                            if ( box[ i ][ k_key ] == BOX_FEATURE )
                            {
                                component = box[ i ];
                                __MaybeDebug( __value( component, DEBUG_B, default = false ) )
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
                }
                // lid carve outs
                MakeLayer( layer = "lid_substractions" );
            }
        }

        for( i = [ 0: m_num_components - 1 ] )
        {
            if ( box[ i ][ k_key ] == BOX_FEATURE )
            {
                component = box[ i ];
                if ( __feature_divider_should_print( component ) )
                {
                    if ( $preview && !m_divider_output_only )
                        MakeLayer( component, layer = "feature_dividers_preview" );
                    else
                        translate( [
                            0,
                            -( m_box_size[ k_y ] + DISTANCE_BETWEEN_PARTS ) * __feature_divider_position_index( i ),
                            0 ] )
                            MakeLayer( component, layer = "feature_dividers" );
                }
            }
        }
    }

    // MakeLayer — the core CSG pipeline for box construction.
    // Called multiple times per component with different layer values:
    //   "outerbox"                    — outer shell geometry
    //   "layer_lid"                   — lid geometry (pattern, surface, labels)
    //   "layer_spacer"                — stackable spacer between boxes
    //   "lid_substractions"           — shapes subtracted from lid
    //   "component_subtractions"      — compartment holes subtracted from box
    //   "component_additions"         — walls/partitions added between compartments
    //   "final_component_subtractions"— cutouts, fillets, labels applied last
    module MakeLayer( component, layer = "" )
    {
        m_is_outerbox = layer == "outerbox";
        m_is_lid = layer == "layer_lid";
        m_is_spacer = layer == "layer_spacer";
        m_is_lid_subtractions = layer == "lid_substractions";

        m_is_component_subtractions = layer == "component_subtractions";
        m_is_component_additions = layer == "component_additions";
        m_is_final_component_subtractions = layer == "final_component_subtractions";
        m_is_feature_dividers = layer == "feature_dividers";
        m_is_feature_dividers_preview = layer == "feature_dividers_preview";

        m_push_base = __value( component, FTR_PEDESTAL_BASE_B, default = f );

        function __compartment_size( D ) = __value( component, FTR_COMPARTMENT_SIZE_XYZ, default = [10.0, 10.0, 10.0] )[ D ];
        function __compartments_num( D ) = __value( component, FTR_NUM_COMPARTMENTS_XY, default = [1,1] )[ D ];

        function __component_rotation() = __value( component, ROTATION, default = 0 );
        function __is_component_enabled() = __value( component, ENABLED_B, default = true);
        function __is_component_debug() = __value( component, DEBUG_B, default = false);

        /////////

        m_component_margin_side = __value( component, FTR_MARGIN_FBLR, default = [0,0,0,0] );

        function __component_margin_start_axis( D ) = D == k_x ? m_component_margin_side[ k_left ] :
                                                        D == k_y ? m_component_margin_side[ k_front ] :
                                                        0;

        function __component_margins_sum( D ) = D == k_x ? m_component_margin_side[ k_left ] + m_component_margin_side[ k_right ] :
                                                D == k_y ? m_component_margin_side[ k_front ] + m_component_margin_side[ k_back ] :
                                                0;

        m_component_cutout_side = __value( component, FTR_CUTOUT_SIDES_4B, default = [false, false, false, false] );

        m_component_has_side_cutouts = m_component_cutout_side[ k_front ] || 
                                        m_component_cutout_side[ k_back ] ||
                                        m_component_cutout_side[ k_left ] ||
                                        m_component_cutout_side[ k_right ];


        m_component_cutout_corner = __value( component, FTR_CUTOUT_CORNERS_4B, default = [false, false, false, false] );

        m_component_cutout_type = __value( component, FTR_CUTOUT_TYPE, default = BOTH );
        m_cutout_depth_max = __value( component, FTR_CUTOUT_DEPTH_MAX, default = 0 );
        m_component_cutout_bottom = __value( component, FTR_CUTOUT_BOTTOM_B, default = false );
        m_component_cutout_bottom_percent = __value( component, FTR_CUTOUT_BOTTOM_PCT, default = 80) / 100;
        m_actually_cutout_the_bottom = !__component_is_fillet() && m_component_cutout_bottom && !m_push_base;

        m_dividers = __component_dividers( component );
        m_divider_slots_x = __divider_centerlines_for_axis( m_dividers, __compartment_size( k_x ), k_x );
        m_divider_slots_y = __divider_centerlines_for_axis( m_dividers, __compartment_size( k_y ), k_y );
        m_divider_slot_width = __component_divider_slot_width( component );
        m_divider_slot_depth = __value( m_dividers, DIV_SLOT_DEPTH, default = m_wall_thickness );

        m_cutout_height_pct = __value( component, FTR_CUTOUT_HEIGHT_PCT, default = 100 ) / 100;
        m_cutout_size_frac_aligned = __value( component, FTR_CUTOUT_DEPTH_PCT, default = 25 ) / 100;
        m_cutout_size_frac_perpindicular = __value( component, FTR_CUTOUT_WIDTH_PCT, default = 50 ) / 100;

        function __component_padding( D ) = __value( component, FTR_PADDING_XY, default = [1.0, 1.0] )[ D ];
        function __component_padding_height_adjust( D ) = __value( component, FTR_PADDING_HEIGHT_ADJUST_XY, default = [0.0, 0.0] )[ D ];
        function __component_shape() = __value( component, FTR_SHAPE, default = SQUARE );
        function __component_shape_rotated_90() = __value( component, FTR_SHAPE_ROTATED_B, default = false );
        function __component_shape_vertical() = __value( component, FTR_SHAPE_VERTICAL_B, default = false );
        function __component_is_hex() = __component_shape() == HEX;
        function __component_is_hex2() = __component_shape() == HEX2;
        function __component_is_oct() = __component_shape() == OCT;
        function __component_is_oct2() = __component_shape() == OCT2;        

        function __component_is_square() = __component_shape() == SQUARE;
        function __component_is_fillet() = __component_shape() == FILLET;
        function __component_fillet_radius() = __value( component, FTR_FILLET_RADIUS, default = min( __compartment_size( k_z ), 10) );

        // Feature-level CHAMFER_N (surface width, mm), converted to perpendicular
        // leg. Falls back to box-level m_box_chamfer (already a leg) when unset.
        function __component_chamfer() = let(
            v = __value( component, CHAMFER_N, default = false )
        ) v == false ? m_box_chamfer : v / sqrt(2);

        function __component_shear( D ) = __value( component, FTR_SHEAR, default = [0.0, 0.0] )[ D ];
        ///////////
    


        m_component_base_height = m_box_size[ k_z ] - __component_size( k_z ) - m_wall_thickness;

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




        function __compartment_largest_dimension() = ( __compartment_size( k_x ) > __compartment_size( k_y ) ) ? __compartment_size( k_x ) : __compartment_size( k_y );

        function __partitions_num( D )= __compartments_num( D ) - 1;

        // calculated __element local dimensions
        function __component_size( D )= ( D == k_z ) ? __compartment_size( k_z ) : 
                                                ( __compartment_size( D ) * __compartments_num( D )) + 
                                                ( __partitions_num( D ) * __component_padding( D ) 
                                                + __component_margins_sum( D ));

        function __partition_height( D ) = __component_size( k_z ) + __component_padding_height_adjust( D );
        function __smallest_partition_height() = min( __partition_height( k_x ), __partition_height( k_y ) );

        // ----- LAYER POSITIONING -----

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

        module PositionInnerLayer()
        {
            ContainWithinBox()
                RotateAboutPoint( __component_rotation(), [0,0,1], [__component_position( k_x ) + __component_size( k_x )/2, __component_position( k_y )+ __component_size( k_y )/2, 0] ) 
                    translate( [ __component_position( k_x ), __component_position( k_y ), m_wall_thickness ] )
                        Shear( __component_shear( k_x ), __component_shear( k_y ), __component_size( k_z ) )
                            children();
        }

        if ( __is_component_enabled() )
        {
            // we only want the labels for an mmu pass
            if ( $g_print_mmu_layer == "mmu_label_layer" )
            {
                if ( m_is_lid )
                {
                    color([0,0,1])
                        MakeDetachedLidLabels();

                    color([0,0,1])
                        MakeAllBoxLabels();                        
                }
                else if ( layer == "component_additions" )
                {
                    PositionInnerLayer()
                        if ( !$g_no_labels_actual_b)
                        {
                            color([0,0,1])
                                LabelEachCompartment();
                        }
                }
            }
            else if ( m_is_spacer )
            {
                MakeSpacer();
            }
            else if ( m_is_lid )
            {
                MakeLid();
            }
            else if ( m_is_outerbox )
            {
                // 'outerbox' is the insert. It may contain one or more 'components' that each
                // define a repeated compartment type.
                //
                difference()
                {
                    if ( m_lid_sliding )
                    {
                        MakeBoxShellWithSlidingLidBits();
                    }
                    else if ( !m_lid_inset )
                    {
                        MakeBoxShell();
                    }
                    else
                        MakeBoxShellWithNewLidBits();

                    color([0,0,1])
                        MakeAllBoxLabels();
                }
            }
            else if ( m_is_lid_subtractions )
            {
               // box top lid accommodation
                if ( m_lid_cap && m_box_has_lid )
                {
                    translate( [ 0,0, m_box_size[ k_z ] - __lid_internal_size( k_z ) ] )
                        MirrorAboutPoint( v=[0,0,1], pt=[0,0,__lid_external_size(k_z)/2])
                            MakeLidBase_Cap();

                    notch_pos_z =  m_box_size[ k_z ] - m_lid_wall_height + __lid_notch_depth();                    

                    if ( m_lid_notches )
                     translate([ 0, 0, notch_pos_z]) 
                            MakeLidCornerNotches();                              
                }

                // bottom of the box
                if ( m_lid_inset && m_box_is_stackable )
                {
                    difference()
                    {
                        cube( [ m_box_size[ k_x ], m_box_size[ k_y ], __lid_external_size(k_z) ]);

                        MirrorAboutPoint( v=[0,0,1], pt=[0,0,__lid_external_size(k_z)/2])
                            MakeLidBase_Inset( tolerance = $g_tolerance, tolerance_detent_pos = $g_tolerance_detent_pos, omit_detents = !m_lid_inset );

                    }            
                }
                
                if ( m_lid_fit_under && m_box_has_lid )
                {
                    if ( m_lid_inset )
                        translate( [ 0, 0, - __lid_external_size( k_z) ] ) // move it down
                            MakeLidTabs( mod = 0 );    
                    else
                    {
                        translate( [ 0, 0, - m_lid_thickness ] )
                                MakeLidBase_Cap( omit_detents = false );
                    }
 
                }     

            }
            else if ( m_is_feature_dividers )
            {
                MakeFeatureDividers();
            }
            else if ( m_is_feature_dividers_preview )
            {
                PositionInnerLayer()
                    MakeFeatureDividers( preview_b = true );
            }
            
            else
            { 
                PositionInnerLayer()
                    InnerLayer();   
             }
        }

        // ----- LID BASE GEOMETRY -----

        module MakeLidBase_Inset( tolerance = 0, tolerance_detent_pos = 0, omit_detents = false )
        {
            difference() 
                {
                    // main __element
                    cube([__lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )]);

                    // lid exterior lip
            
                    translate( [ 0, 0, __lid_external_size( k_z )/2 ])
                    {
                        cube([ __lid_external_size( k_x ), __lid_notch_depth() + tolerance, __lid_external_size( k_z )/1]);   
                        cube([ __lid_notch_depth() + tolerance, __lid_external_size( k_y ), __lid_external_size( k_z )/1]);   

                        MirrorAboutPoint( v=[0,1,0], pt= [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, m_lid_wall_height/2 ] )
                            MirrorAboutPoint( v=[1,0,0], pt= [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, m_lid_wall_height/2 ] )
                            {
                                cube([ __lid_external_size( k_x ), __lid_notch_depth() + tolerance, __lid_external_size( k_z )/1]);   
                                cube([ __lid_notch_depth() + tolerance, __lid_external_size( k_y ), __lid_external_size( k_z )/1]);   
                            }
                    }

                    difference()
                    {
                        MakeLidEdges( extra_depth = tolerance, extra_height = __lid_external_size( k_z ) );

                        translate( [ 0, 0, 0 ] )
                            MirrorAboutPoint( v=[0,0,1], pt= [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, 0] )
                                hull()
                                {
                                    MakeLidEdges( extra_depth = tolerance );

                                    translate( [ 0, 0, -__lid_notch_depth() ] )
                                        MakeLidEdges( offset = m_wall_thickness/2 + tolerance, extra_depth = tolerance);

                                }
                    }  
                }
                    //detents
                    if ( !omit_detents )
                    {
                        detent_height = ( __lid_external_size( k_z ) + __lid_notch_depth() )/2 + tolerance_detent_pos;
                        translate([ 0, 0, detent_height ]) // lower because tolerance
                                MakeDetents( mod = -tolerance, offset = tolerance ); 
                    }                             

        }

        module MakeLidBase_Cap( tolerance = 0, tolerance_detent_pos = 0, omit_detents = false )
        {
            difference()
            {
                    // main __element (chamfer sides + bottom — bottom is the visible lid top when placed on box)
                __MakeChamferedBoxShell(
                    [__lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )],
                    m_box_chamfer, chamfer_top = false, chamfer_bottom = true );

                // #TODO: modulize this!
                translate( [ 0, 0, __lid_external_size( k_z ) - __lid_notch_depth() ] )
                    hull()
                    {
                        translate( [ __lid_notch_depth() , __lid_notch_depth(), 0 ] )
                            cube([__lid_internal_size( k_x ), __lid_internal_size( k_y ), 1]);

                        translate( [ 0, 0, __lid_notch_depth() ] )
                            __MakeChamferedBoxShell(
                                [__lid_external_size( k_x ), __lid_external_size( k_y ), HULL_EPSILON],
                                m_box_chamfer, chamfer_top = false, chamfer_bottom = false );
                    }

                // big hollow (match exterior chamfer so hollow follows the chamfer slope)
                translate( [ __lid_notch_depth() - tolerance, __lid_notch_depth() - tolerance, 0 ])
                    __MakeChamferedBoxShell(
                        [__lid_internal_size( k_x ) + 2*tolerance, __lid_internal_size( k_y ) + 2*tolerance, __lid_external_size( k_z )],
                        m_box_chamfer, chamfer_top = false, chamfer_bottom = true );
            }

            //detents
            if ( !omit_detents )
            {
                detent_height = ( m_lid_wall_height - __lid_notch_depth() )/2 + m_lid_thickness + tolerance_detent_pos;
                translate([ 0, 0, detent_height ]) // lower because tolerance
                        MakeDetents( mod = 0, offset = -tolerance );      
            }

        }




        module MakeLidEdge( extra_height = 0, extra_depth = 0, offset = 0 )
        {
            translate( [ offset, offset, 0 ] )
            {
                cube( [  m_box_size[ k_x ] - ( 2 * offset ),
                        __lid_notch_depth() + extra_depth, 
                        m_lid_wall_height + extra_height ] );   

                cube( [  __lid_notch_depth() + extra_depth,
                        m_box_size[ k_y ] - ( 2 * offset ),
                        m_lid_wall_height + extra_height ] ); 
            }
        }

        module MakeLidEdges( extra_height = 0, extra_depth = 0, offset = 0 )
        {
                MakeLidEdge( extra_height = extra_height, extra_depth = extra_depth, offset = offset );

                MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                    MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                        MakeLidEdge( extra_height = extra_height, extra_depth = extra_depth, offset = offset );

        }

        // ----- BOX SHELL & SPACER -----

        // Creates a box shape with chamfered edges.
        // chamfer_top/chamfer_bottom: control which horizontal edges get chamfered.
        // Vertical corner chamfers are always applied.
        module __MakeChamferedBoxShell( size, c, chamfer_top = false, chamfer_bottom = true )
        {
            x = size[0]; y = size[1]; z = size[2];
            eps = 0.001;

            if ( c <= 0 || c >= min( x, y ) / 2 )
            {
                cube( size );
            }
            else
            {
                z_lo = chamfer_bottom ? c : 0;
                z_hi = chamfer_top ? z - c : z;

                hull()
                {
                    if ( chamfer_bottom )
                        translate([ c, c, 0 ])         cube([ x - 2*c, y - 2*c, eps ]);

                    if ( chamfer_top )
                        translate([ c, c, z - eps ])   cube([ x - 2*c, y - 2*c, eps ]);

                    // Side faces spanning z_lo to z_hi (vertical chamfers)
                    translate([ c, 0, z_lo ])          cube([ x - 2*c, eps, z_hi - z_lo ]);
                    translate([ c, y - eps, z_lo ])    cube([ x - 2*c, eps, z_hi - z_lo ]);
                    translate([ 0, c, z_lo ])          cube([ eps, y - 2*c, z_hi - z_lo ]);
                    translate([ x - eps, c, z_lo ])    cube([ eps, y - 2*c, z_hi - z_lo ]);
                }
            }
        }

        module MakeBoxShell()
        {
            __MakeChamferedBoxShell(
                [ m_box_size[ k_x ], m_box_size[ k_y ], m_box_size[ k_z ] ],
                m_box_chamfer
            );
        }

        module MakeBoxShellWithNewLidBits()
        {
            difference()
            {
                union()
                {
                    MakeBoxShell();

                    if ( m_box_has_lid || m_box_is_stackable )
                    {
                        // create the structure above the box that holds the lid
                        translate([ 0, 0, m_box_size[ k_z ] ])
                            difference()
                            {
                                __MakeChamferedBoxShell(
                                    [ m_box_size[ k_x ], m_box_size[ k_y ], __lid_external_size( k_z ) ],
                                    m_box_chamfer, chamfer_top = false, chamfer_bottom = false );

                                MirrorAboutPoint( v=[0,0,1], pt=[0,0,__lid_external_size(k_z)/2])
                                    MakeLidBase_Inset();
                            }     
                    }
                }

                // subtract tabs

                    translate( [ 0, 0, m_box_size[ k_z ] - m_lid_tab[ k_z ] + 1 ])
                        MakeLidTabs( mod = 0, square = true ); // this needs to be wide 
            }  
        }

        module MakeSlidingLidRails()
        {
            vertical_height = max( HULL_EPSILON, m_lid_thickness - m_sliding_lid_bevel );
            opening_lip_clearance = 0;

            module MakeRailVertical( pos, size )
            {
                translate( [ pos[ k_x ], pos[ k_y ], 0 ] )
                    cube( [ size[ k_x ], size[ k_y ], vertical_height ] );
            }

            module MakeRailLip( base_pos, base_size, top_pos, top_size )
            {
                hull()
                {
                    translate( [ base_pos[ k_x ], base_pos[ k_y ], vertical_height - HULL_EPSILON ] )
                        cube( [ base_size[ k_x ], base_size[ k_y ], HULL_EPSILON ] );

                    translate( [ top_pos[ k_x ], top_pos[ k_y ], m_lid_thickness - HULL_EPSILON ] )
                        cube( [ top_size[ k_x ], top_size[ k_y ], HULL_EPSILON ] );
                }
            }

            union()
            {
                if ( !m_lid_slides_x )
                {
                    lip_y = m_lid_slide_side == FRONT ? opening_lip_clearance : 0;
                    lip_len_y = m_box_size[ k_y ] - opening_lip_clearance;

                    // Side guides; front/back controls which end is top-open.
                    MakeRailVertical( [ 0, 0 ], [ m_sliding_lid_rail_width, m_box_size[ k_y ] ] );
                    MakeRailVertical(
                        [ m_box_size[ k_x ] - m_sliding_lid_rail_width, 0 ],
                        [ m_sliding_lid_rail_width, m_box_size[ k_y ] ] );

                    if ( lip_len_y > HULL_EPSILON )
                    {
                        MakeRailLip(
                            [ 0, lip_y ],
                            [ m_sliding_lid_rail_width, lip_len_y ],
                            [ 0, lip_y ],
                            [ m_sliding_lid_rail_lip_width, lip_len_y ] );

                        MakeRailLip(
                            [ m_box_size[ k_x ] - m_sliding_lid_rail_width, lip_y ],
                            [ m_sliding_lid_rail_width, lip_len_y ],
                            [ m_box_size[ k_x ] - m_sliding_lid_rail_lip_width, lip_y ],
                            [ m_sliding_lid_rail_lip_width, lip_len_y ] );
                    }

                    if ( m_lid_slide_side == FRONT )
                    {
                        MakeRailVertical(
                            [ 0, m_box_size[ k_y ] - m_sliding_lid_rail_width ],
                            [ m_box_size[ k_x ], m_sliding_lid_rail_width ] );

                        MakeRailLip(
                            [ 0, m_box_size[ k_y ] - m_sliding_lid_rail_width ],
                            [ m_box_size[ k_x ], m_sliding_lid_rail_width ],
                            [ 0, m_box_size[ k_y ] - m_sliding_lid_rail_lip_width ],
                            [ m_box_size[ k_x ], m_sliding_lid_rail_lip_width ] );
                    }
                    else
                    {
                        MakeRailVertical( [ 0, 0 ], [ m_box_size[ k_x ], m_sliding_lid_rail_width ] );

                        MakeRailLip(
                            [ 0, 0 ],
                            [ m_box_size[ k_x ], m_sliding_lid_rail_width ],
                            [ 0, 0 ],
                            [ m_box_size[ k_x ], m_sliding_lid_rail_lip_width ] );
                    }
                }
                else
                {
                    lip_x = m_lid_slide_side == LEFT ? opening_lip_clearance : 0;
                    lip_len_x = m_box_size[ k_x ] - opening_lip_clearance;

                    // Front/back guides; left/right controls which end is top-open.
                    MakeRailVertical( [ 0, 0 ], [ m_box_size[ k_x ], m_sliding_lid_rail_width ] );
                    MakeRailVertical(
                        [ 0, m_box_size[ k_y ] - m_sliding_lid_rail_width ],
                        [ m_box_size[ k_x ], m_sliding_lid_rail_width ] );

                    if ( lip_len_x > HULL_EPSILON )
                    {
                        MakeRailLip(
                            [ lip_x, 0 ],
                            [ lip_len_x, m_sliding_lid_rail_width ],
                            [ lip_x, 0 ],
                            [ lip_len_x, m_sliding_lid_rail_lip_width ] );

                        MakeRailLip(
                            [ lip_x, m_box_size[ k_y ] - m_sliding_lid_rail_width ],
                            [ lip_len_x, m_sliding_lid_rail_width ],
                            [ lip_x, m_box_size[ k_y ] - m_sliding_lid_rail_lip_width ],
                            [ lip_len_x, m_sliding_lid_rail_lip_width ] );
                    }

                    if ( m_lid_slide_side == LEFT )
                    {
                        MakeRailVertical(
                            [ m_box_size[ k_x ] - m_sliding_lid_rail_width, 0 ],
                            [ m_sliding_lid_rail_width, m_box_size[ k_y ] ] );

                        MakeRailLip(
                            [ m_box_size[ k_x ] - m_sliding_lid_rail_width, 0 ],
                            [ m_sliding_lid_rail_width, m_box_size[ k_y ] ],
                            [ m_box_size[ k_x ] - m_sliding_lid_rail_lip_width, 0 ],
                            [ m_sliding_lid_rail_lip_width, m_box_size[ k_y ] ] );
                    }
                    else
                    {
                        MakeRailVertical( [ 0, 0 ], [ m_sliding_lid_rail_width, m_box_size[ k_y ] ] );

                        MakeRailLip(
                            [ 0, 0 ],
                            [ m_sliding_lid_rail_width, m_box_size[ k_y ] ],
                            [ 0, 0 ],
                            [ m_sliding_lid_rail_lip_width, m_box_size[ k_y ] ] );
                    }
                }
            }
        }

        function __sliding_detent_height() =
            min( max( HULL_EPSILON, $g_detent_thickness ), m_wall_thickness / 2, m_lid_thickness / 2 );
        function __sliding_detent_width() = max( HULL_EPSILON, m_sliding_lid_rail_width - 2*m_sliding_lid_fit_tolerance );
        function __sliding_detent_length() =
            let( cross_extent = m_lid_slides_x ? __lid_external_size( k_y ) : __lid_external_size( k_x ) )
            min(
                max( $g_detent_spacing * 2, m_wall_thickness * 2 ),
                max( HULL_EPSILON, cross_extent - 2*$g_detent_dist_from_corner )
            );
        function __sliding_detent_start( extent, length ) = max( 0, ( extent - length ) / 2 );
        function __sliding_detent_near_edge_pos() = m_sliding_lid_fit_tolerance;
        function __sliding_detent_far_edge_pos( extent ) =
            extent - m_sliding_lid_rail_width + m_sliding_lid_fit_tolerance;

        module MakeSlidingLidDetentPrismX( length, width, height, high_at_max_y )
        {
            hull()
            {
                cube( [ length, HULL_EPSILON, HULL_EPSILON ] );

                translate( [ 0, width - HULL_EPSILON, 0 ] )
                    cube( [ length, HULL_EPSILON, HULL_EPSILON ] );

                translate( [ 0, high_at_max_y ? width - HULL_EPSILON : 0, height ] )
                    cube( [ length, HULL_EPSILON, HULL_EPSILON ] );
            }
        }

        module MakeSlidingLidDetentPrismY( length, width, height, high_at_max_x )
        {
            hull()
            {
                cube( [ HULL_EPSILON, length, HULL_EPSILON ] );

                translate( [ width - HULL_EPSILON, 0, 0 ] )
                    cube( [ HULL_EPSILON, length, HULL_EPSILON ] );

                translate( [ high_at_max_x ? width - HULL_EPSILON : 0, 0, height ] )
                    cube( [ HULL_EPSILON, length, HULL_EPSILON ] );
            }
        }

        module MakeSlidingLidDetentCavityPrismX( length, width, height, high_at_max_y )
        {
            MirrorAboutPoint( [0, 0, 1], [0, 0, height / 2] )
                MakeSlidingLidDetentPrismX( length, width, height, high_at_max_y );
        }

        module MakeSlidingLidDetentCavityPrismY( length, width, height, high_at_max_x )
        {
            MirrorAboutPoint( [0, 0, 1], [0, 0, height / 2] )
                MakeSlidingLidDetentPrismY( length, width, height, high_at_max_x );
        }

        module MakeSlidingLidOpeningDetent()
        {
            if ( $g_detent_thickness > 0 )
            {
                detent_h = __sliding_detent_height();
                detent_w = __sliding_detent_width();
                detent_len = __sliding_detent_length();

                if ( !m_lid_slides_x )
                {
                    x = m_sliding_lid_rail_side_clearance + __sliding_detent_start( __lid_external_size( k_x ), detent_len );
                    y = m_lid_slide_side == FRONT ?
                        __sliding_detent_near_edge_pos() :
                        __sliding_detent_far_edge_pos( m_box_size[ k_y ] );

                    translate( [ x, y, 0 ] )
                        MakeSlidingLidDetentPrismX( detent_len, detent_w, detent_h, m_lid_slide_side == FRONT );
                }
                else
                {
                    x = m_lid_slide_side == LEFT ?
                        __sliding_detent_near_edge_pos() :
                        __sliding_detent_far_edge_pos( m_box_size[ k_x ] );
                    y = m_sliding_lid_rail_side_clearance + __sliding_detent_start( __lid_external_size( k_y ), detent_len );

                    translate( [ x, y, 0 ] )
                        MakeSlidingLidDetentPrismY( detent_len, detent_w, detent_h, m_lid_slide_side == LEFT );
                }
            }
        }

        module MakeSlidingLidRailsWithExteriorChamfer()
        {
            intersection()
            {
                union()
                {
                    MakeSlidingLidRails();
                    MakeSlidingLidOpeningDetent();
                }

                translate( [ 0, 0, -m_box_size[ k_z ] ] )
                    __MakeChamferedBoxShell(
                        [ m_box_size[ k_x ], m_box_size[ k_y ], m_box_size[ k_z ] + m_lid_thickness ],
                        m_box_chamfer
                    );
            }
        }

        module MakeBoxShellWithSlidingLidBits()
        {
            union()
            {
                MakeBoxShell();

                if ( m_box_has_lid )
                    translate( [ 0, 0, m_box_size[ k_z ] ] )
                        MakeSlidingLidRailsWithExteriorChamfer();
            }
        }

        module MakeSpacer()
        {
            {
                difference()
                {
                    __MakeChamferedBoxShell(
                        [ m_box_size[ k_x ], m_box_size[ k_y ], m_box_size[ k_z ] ],
                        m_box_chamfer
                    );

                    translate( [ m_wall_thickness, m_wall_thickness, 0 ])
                        cube( [ m_box_size[ k_x ] - ( 2 * m_wall_thickness ), m_box_size[ k_y ] - ( 2 * m_wall_thickness ), m_box_size[ k_z ] ] );
                }
            }
        }

        module MakeDividerSlotRails()
        {
            width = is_num( m_divider_slot_width ) ? m_divider_slot_width : 0;
            depth = is_num( m_divider_slot_depth ) ? m_divider_slot_depth : 0;
            rail_width = max( MIN_PRINTABLE_DETAIL_THICKNESS, m_wall_thickness / 2 );
            rail_height = __compartment_size( k_z );
            rail_z = m_component_base_height;
            x_depth = min( depth, __compartment_size( k_y ) / 2 );
            y_depth = min( depth, __compartment_size( k_x ) / 2 );

            module MakeDividerSlotClipShape()
            {
                if ( __component_is_fillet() )
                    cube( [ __compartment_size( k_x ), __compartment_size( k_y ), rail_z + rail_height ] );
                else
                    MakeCompartmentShape();
            }

            module MakeClippedDividerRail( pos, size )
            {
                intersection()
                {
                    translate( pos )
                        cube( size );
                    MakeDividerSlotClipShape();
                }
            }

            if ( __feature_divider_rails_enabled( m_dividers ) &&
                 width > 0 && depth > 0 && __all_numbers( m_divider_slots_x ) )
                InEachCompartment()
                    for ( centerline = m_divider_slots_x )
                {
                    MakeClippedDividerRail(
                        [ centerline - width / 2 - rail_width, 0, rail_z ],
                        [ rail_width, x_depth, rail_height ] );
                    MakeClippedDividerRail(
                        [ centerline + width / 2, 0, rail_z ],
                        [ rail_width, x_depth, rail_height ] );
                    MakeClippedDividerRail(
                        [ centerline - width / 2 - rail_width, __compartment_size( k_y ) - x_depth, rail_z ],
                        [ rail_width, x_depth, rail_height ] );
                    MakeClippedDividerRail(
                        [ centerline + width / 2, __compartment_size( k_y ) - x_depth, rail_z ],
                        [ rail_width, x_depth, rail_height ] );
                }

            if ( __feature_divider_rails_enabled( m_dividers ) &&
                 width > 0 && depth > 0 && __all_numbers( m_divider_slots_y ) )
                InEachCompartment()
                    for ( centerline = m_divider_slots_y )
                {
                    MakeClippedDividerRail(
                        [ 0, centerline - width / 2 - rail_width, rail_z ],
                        [ y_depth, rail_width, rail_height ] );
                    MakeClippedDividerRail(
                        [ 0, centerline + width / 2, rail_z ],
                        [ y_depth, rail_width, rail_height ] );
                    MakeClippedDividerRail(
                        [ __compartment_size( k_x ) - y_depth, centerline - width / 2 - rail_width, rail_z ],
                        [ y_depth, rail_width, rail_height ] );
                    MakeClippedDividerRail(
                        [ __compartment_size( k_x ) - y_depth, centerline + width / 2, rail_z ],
                        [ y_depth, rail_width, rail_height ] );
                }
        }

        module MakeFeatureDividers( preview_b = false )
        {
            divider_depth = __div_thickness( m_dividers );
            panel_height = __compartment_size( k_z );
            rail_z = m_component_base_height;

            tab_width = __div_tab_size( m_dividers )[ k_x ];
            tab_height = __div_tab_size( m_dividers )[ k_y ];
            tab_radius = __div_tab_radius( m_dividers );
            fitted_tab_height = min( max( 0, tab_height ), max( 0, panel_height - MIN_PRINTABLE_DETAIL_THICKNESS ) );
            body_height = panel_height - fitted_tab_height;
            tab_text = __div_tab_text( m_dividers );
            font_size = __div_tab_text_size( m_dividers );
            font = __div_tab_text_font( m_dividers );
            font_spacing = __div_tab_text_spacing( m_dividers );
            number_of_letters_before_scale_to_fit = __div_tab_text_char_threshold( m_dividers );
            text_embossed = __div_tab_text_embossed( m_dividers );
            tabs_per_row = max( 1, floor( __div_tab_cycle( m_dividers ) ) );
            tab_starting_position = __div_tab_cycle_start( m_dividers );

            divider_bottom = __div_frame_bottom( m_dividers );
            divider_top = __div_frame_top( m_dividers );
            divider_column = __div_frame_column( m_dividers );
            divider_corner_radius = __div_frame_radius( m_dividers );
            raw_num_columns = __div_frame_num_columns( m_dividers );
            num_columns = is_num( raw_num_columns ) ? floor( raw_num_columns ) : -1;

            row_pitch = panel_height + DISTANCE_BETWEEN_PARTS;
            compartment_count_x = __compartments_num( k_x );
            compartment_count_y = __compartments_num( k_y );
            compartment_count = compartment_count_x * compartment_count_y;
            x_slot_count = len( m_divider_slots_x ) * compartment_count;

            function __feature_divider_title( idx ) =
                len( tab_text ) > idx ? str( tab_text[ idx ] ) : str( idx + 1 );

            function __feature_divider_has_shaped_tab_sides( axis ) =
                !__component_shape_vertical() &&
                !__component_is_square() &&
                !__component_is_fillet() &&
                (
                    ( axis == k_x && __component_shape_rotated_90() ) ||
                    ( axis == k_y && !__component_shape_rotated_90() )
                );

            function __feature_divider_round_tab_side_width( print_width ) =
                let(
                    r = print_width / 2,
                    y = min( max( 0, body_height ), 2 * r )
                )
                min( print_width, 2 * sqrt( max( 0, r*r - ( r - y ) * ( r - y ) ) ) );

            function __feature_divider_linear_tab_side_width( print_width ) =
                min(
                    print_width,
                    max(
                        MIN_PRINTABLE_DETAIL_THICKNESS,
                        print_width * min( 1, max( 0, body_height ) / max( MIN_PRINTABLE_DETAIL_THICKNESS, panel_height ) )
                    )
                );

            function __feature_divider_tab_side_width( print_width, axis ) =
                __feature_divider_has_shaped_tab_sides( axis ) ?
                    ( __component_shape() == ROUND ?
                        __feature_divider_round_tab_side_width( print_width ) :
                        __feature_divider_linear_tab_side_width( print_width ) ) :
                    print_width;

            function __feature_divider_tab_side_margin( print_width, axis ) =
                ( print_width - __feature_divider_tab_side_width( print_width, axis ) ) / 2;

            function __feature_divider_tab_width( print_width, axis ) =
                min( max( 0, tab_width ), __feature_divider_tab_side_width( print_width, axis ) );

            function __feature_divider_tab_corner_radius( print_width, axis ) =
                min(
                    max( 0, tab_radius ),
                    __feature_divider_tab_width( print_width, axis ) / 4,
                    fitted_tab_height / 4
                );

            function __feature_divider_tab_offset( idx, print_width, axis ) =
                let(
                    side_width = __feature_divider_tab_side_width( print_width, axis ),
                    side_margin = __feature_divider_tab_side_margin( print_width, axis ),
                    fitted_tab_width = __feature_divider_tab_width( print_width, axis ),
                    tab_span = max( 0, side_width - fitted_tab_width ),
                    space_between_tabs = tabs_per_row <= 1 ? 0 : tab_span / ( tabs_per_row - 1 ),
                    tab_idx = ( idx + tab_starting_position - 1 ) % tabs_per_row,
                    raw_offset = space_between_tabs * tab_idx
                )
                side_margin + min( max( 0, raw_offset ), tab_span );

            module MakeFeatureDividerClipShape()
            {
                if ( __component_is_fillet() )
                    cube( [ __compartment_size( k_x ), __compartment_size( k_y ), rail_z + panel_height ] );
                else
                    MakeCompartmentShape();
            }

            module MakeLocalDividerSlice( axis, centerline )
            {
                if ( __component_is_square() || __component_is_fillet() )
                {
                    if ( axis == k_x )
                        translate( [ centerline - divider_depth / 2, -HULL_EPSILON, rail_z ] )
                            cube( [ divider_depth, __compartment_size( k_y ) + 2 * HULL_EPSILON, panel_height ] );
                    else
                        translate( [ -HULL_EPSILON, centerline - divider_depth / 2, rail_z ] )
                            cube( [ __compartment_size( k_x ) + 2 * HULL_EPSILON, divider_depth, panel_height ] );
                }
                else
                {
                    intersection()
                    {
                        MakeFeatureDividerClipShape();

                        if ( axis == k_x )
                            translate( [ centerline - divider_depth / 2, -HULL_EPSILON, rail_z ] )
                                cube( [ divider_depth, __compartment_size( k_y ) + 2 * HULL_EPSILON, panel_height ] );
                        else
                            translate( [ -HULL_EPSILON, centerline - divider_depth / 2, rail_z ] )
                                cube( [ __compartment_size( k_x ) + 2 * HULL_EPSILON, divider_depth, panel_height ] );
                    }
                }
            }

            module OrientDividerSliceForPrint( axis, centerline )
            {
                if ( axis == k_x )
                    multmatrix( [
                        [ 0, 1, 0, 0 ],
                        [ 0, 0, 1, -rail_z ],
                        [ 1, 0, 0, -( centerline - divider_depth / 2 ) ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        children();
                else
                    multmatrix( [
                        [ 1, 0, 0, 0 ],
                        [ 0, 0, 1, -rail_z ],
                        [ 0, 1, 0, -( centerline - divider_depth / 2 ) ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        children();
            }

            module OrientDividerSliceFromPrint( axis, centerline )
            {
                if ( axis == k_x )
                    multmatrix( [
                        [ 0, 0, 1, centerline - divider_depth / 2 ],
                        [ 1, 0, 0, 0 ],
                        [ 0, 1, 0, rail_z ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        children();
                else
                    multmatrix( [
                        [ 1, 0, 0, 0 ],
                        [ 0, 0, 1, centerline - divider_depth / 2 ],
                        [ 0, 1, 0, rail_z ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        children();
            }

            module PositionFeatureDividerPreviewCompartment( comp_idx )
            {
                x_idx = floor( comp_idx / compartment_count_y );
                y_idx = comp_idx % compartment_count_y;
                x_pos = m_component_margin_side[ k_left ] +
                    ( __compartment_size( k_x ) + __component_padding( k_x ) ) * x_idx;
                y_pos = m_component_margin_side[ k_front ] +
                    ( __compartment_size( k_y ) + __component_padding( k_y ) ) * y_idx;

                translate( [ x_pos, y_pos, 0 ] )
                    children();
            }

            module MakeFeatureDividerFrameCutouts( print_width )
            {
                opening_height = body_height - divider_bottom - divider_top;

                if ( num_columns >= 0 && opening_height > 0 )
                {
                    gap_size = ( print_width - ( ( 2 + num_columns ) * divider_column ) ) / ( num_columns + 1 );

                    if ( gap_size > 0 )
                        for ( c = [ 0 : num_columns ] )
                        {
                            translate( [ divider_column + ( divider_column + gap_size ) * c, divider_bottom, -HULL_EPSILON ] )
                                MakeRoundedCubeAxis(
                                    [ gap_size, opening_height, divider_depth + 2 * HULL_EPSILON ],
                                    divider_corner_radius,
                                    k_z );
                        }
                }
            }

            module MakeFeatureDividerTabShape( tab_offset, print_width, axis )
            {
                fitted_tab_width = __feature_divider_tab_width( print_width, axis );
                tab_corner_radius = __feature_divider_tab_corner_radius( print_width, axis );
                height_overlap = min( tab_corner_radius, body_height );
                title_pos = [ tab_offset, body_height - height_overlap, 0 ];

                module MakeConstrainedFeatureDividerTabShape()
                {
                    intersection()
                    {
                        translate( title_pos )
                            MakeRoundedCubeAxis(
                                [ fitted_tab_width, fitted_tab_height + height_overlap, divider_depth ],
                                tab_corner_radius,
                                [ f, f, t, t ],
                                k_z );

                        translate( [
                            __feature_divider_tab_side_margin( print_width, axis ) - HULL_EPSILON,
                            body_height - height_overlap - HULL_EPSILON,
                            -HULL_EPSILON
                        ] )
                            cube( [
                                __feature_divider_tab_side_width( print_width, axis ) + 2 * HULL_EPSILON,
                                fitted_tab_height + height_overlap + 2 * HULL_EPSILON,
                                divider_depth + 2 * HULL_EPSILON
                            ] );
                    }
                }

                if ( fitted_tab_width > 0 && fitted_tab_height > 0 )
                    MakeConstrainedFeatureDividerTabShape();
            }

            module MakeFeatureDividerTabText( title, tab_offset, print_width, axis, z_offset = 0 )
            {
                fitted_tab_width = __feature_divider_tab_width( print_width, axis );
                text_pos = [ tab_offset + fitted_tab_width / 2, panel_height - HULL_EPSILON, z_offset ];
                text_width = len( title ) > number_of_letters_before_scale_to_fit ?
                    fitted_tab_width * DEFAULT_TAB_TEXT_WIDTH_FRACTION : 0;

                if ( fitted_tab_width > 0 && fitted_tab_height > 0 )
                    translate( text_pos )
                        resize( [ text_width, 0, 0 ], auto=[ true, true, false ] )
                            linear_extrude( divider_depth )
                                text(
                                    text = title,
                                    font = font,
                                    size = min( font_size, fitted_tab_height ),
                                    valign = "top",
                                    halign = "center",
                                    spacing = font_spacing,
                                    $fn = fn );
            }

            module MakeFeatureDividerModel( axis, centerline, idx )
            {
                print_width = axis == k_x ? __compartment_size( k_y ) : __compartment_size( k_x );
                title = __feature_divider_title( idx );
                tab_offset = __feature_divider_tab_offset( idx, print_width, axis );

                intersection()
                {
                    difference()
                    {
                        union()
                        {
                            translate( [ -HULL_EPSILON, -HULL_EPSILON, -HULL_EPSILON ] )
                                cube( [
                                    print_width + 2 * HULL_EPSILON,
                                    body_height + HULL_EPSILON,
                                    divider_depth + 2 * HULL_EPSILON
                                ] );

                            MakeFeatureDividerTabShape( tab_offset, print_width, axis );
                        }

                        MakeFeatureDividerFrameCutouts( print_width );

                        if ( !text_embossed )
                            MakeFeatureDividerTabText( title, tab_offset, print_width, axis );
                    }

                    intersection()
                    {
                        OrientDividerSliceForPrint( axis, centerline )
                            MakeLocalDividerSlice( axis, centerline );

                        translate( [ -HULL_EPSILON, -HULL_EPSILON, -HULL_EPSILON ] )
                            cube( [
                                print_width + 2 * HULL_EPSILON,
                                panel_height + 2 * HULL_EPSILON,
                                divider_depth + 2 * HULL_EPSILON
                            ] );
                    }
                }

                if ( text_embossed )
                    MakeFeatureDividerTabText( title, tab_offset, print_width, axis, divider_depth );
            }

            module MakeFeatureDivider( axis, centerline, idx )
            {
                if ( preview_b )
                    OrientDividerSliceFromPrint( axis, centerline )
                        MakeFeatureDividerModel( axis, centerline, idx );
                else
                    translate( [ 0, -idx * row_pitch, 0 ] )
                        MakeFeatureDividerModel( axis, centerline, idx );
            }

            if ( __feature_dividers_enabled( m_dividers ) &&
                 divider_depth > 0 && __all_numbers( m_divider_slots_x ) && __all_numbers( m_divider_slots_y ) )
            {
                if ( len( m_divider_slots_x ) > 0 )
                    for ( comp_idx = [ 0 : compartment_count - 1 ] )
                        for ( slot_idx = [ 0 : len( m_divider_slots_x ) - 1 ] )
                            if ( preview_b )
                                PositionFeatureDividerPreviewCompartment( comp_idx )
                                    MakeFeatureDivider(
                                        k_x,
                                        m_divider_slots_x[ slot_idx ],
                                        comp_idx * len( m_divider_slots_x ) + slot_idx );
                            else
                                MakeFeatureDivider(
                                    k_x,
                                    m_divider_slots_x[ slot_idx ],
                                    comp_idx * len( m_divider_slots_x ) + slot_idx );

                if ( len( m_divider_slots_y ) > 0 )
                    for ( comp_idx = [ 0 : compartment_count - 1 ] )
                        for ( slot_idx = [ 0 : len( m_divider_slots_y ) - 1 ] )
                            if ( preview_b )
                                PositionFeatureDividerPreviewCompartment( comp_idx )
                                    MakeFeatureDivider(
                                        k_y,
                                        m_divider_slots_y[ slot_idx ],
                                        x_slot_count + comp_idx * len( m_divider_slots_y ) + slot_idx );
                            else
                                MakeFeatureDivider(
                                    k_y,
                                    m_divider_slots_y[ slot_idx ],
                                    x_slot_count + comp_idx * len( m_divider_slots_y ) + slot_idx );
            }
        }

        // ----- INNER LAYER DISPATCH -----
        // Routes each MakeLayer call to the appropriate geometry stage:
        // outerbox, lid, spacer, component subtractions/additions, final subtractions.

        module InnerLayer()
        {

            if ( m_is_component_subtractions ) 
            {
                // 'carve-outs' are the big shapes of the 'components.' Each is then subdivided
                // by adding partitions.

                // we carve all the way to the bottom and then fill it back up
                cut_height = m_lid_sliding ?
                    m_box_size[ k_z ] - m_wall_thickness + HULL_EPSILON :
                    m_box_size[ k_z ] + __lid_external_size(k_z);

                cube([  __component_size( k_x ), 
                    __component_size( k_y ), 
                    cut_height ]);
            }
            else if ( m_is_component_additions )
            {
                MakePartitions();

                InEachCompartment()
                {
                    if ( !__component_is_square() && !__component_is_fillet() )
                    {
                        difference()
                        {
                            cube ( [ __compartment_size( k_x ), __compartment_size( k_y ), __smallest_partition_height() + m_component_base_height] );
                            MakeCompartmentShape();
                        }
                    }

                    if ( __component_is_fillet())
                    {
                        translate( [0, 0, m_component_base_height])
                            AddFillets();
                    }

                    if ( __component_chamfer() > 0 )
                    {
                        translate( [0, 0, m_component_base_height])
                            AddCompartmentChamfers();
                    }
                }

                if ( m_push_base && m_component_base_height > 0 )
                {
                    frac = DEFAULT_PEDESTAL_BASE_FRACTION;

                    InEachCompartment()
                        translate( [ (__compartment_size( k_x) * (1-frac))/2, (__compartment_size( k_y) * (1-frac))/2, 0 ])
                            resize( [ 0, 0, m_component_base_height ], auto=false )  // fit it to the base
                                scale( v = [ frac, frac, 1 ]) // bring in the sides
                                    MakeCompartmentShape();
                                                        
                }
                else
                {
                    // fill in the bottom
                    cube ( [ __component_size( k_x ), __component_size( k_y ), m_component_base_height ] );
                }

                MakeDividerSlotRails();
                
            }
            else if ( m_is_final_component_subtractions )
            {
                // Some shapes, such as the finger cutouts for card compartments
                // need to be done at the end because they substract from the 
                // entire box.

                if ( m_component_has_side_cutouts )
                {
                    // finger cutouts
                    insetx = m_component_cutout_side[ k_left ]  ? m_cutout_size_frac_aligned * __compartment_size( k_x ) + m_component_margin_side[ k_left]  : 0;
                    insety = m_component_cutout_side[ k_front ] ? m_cutout_size_frac_aligned * __compartment_size( k_y ) + m_component_margin_side[ k_front] : 0;

                    // Count how many cutouts are made in each direction to substract it from the size of the inner stencil box
                    x_cutouts = (m_component_cutout_side[ k_left ]?1:0) + (m_component_cutout_side[ k_right ]?1:0);
                    y_cutouts = (m_component_cutout_side[ k_front ]?1:0) + (m_component_cutout_side[ k_back ]?1:0);

                    sizex = __component_size( k_x) - x_cutouts * m_cutout_size_frac_aligned * __compartment_size( k_x ) - __component_margins_sum( k_x );
                    sizey = __component_size( k_y) - y_cutouts * m_cutout_size_frac_aligned * __compartment_size( k_y ) - __component_margins_sum( k_y );
                
                    if ( m_component_cutout_type == BOTH )
                    {
                        MakeAllBoxSideCutouts();
                    }
                    else if ( m_component_cutout_type == INTERIOR )
                    {
                        intersection()
                        {

                            translate( [ insetx, insety, -m_wall_thickness ] )
                                cube ( [ sizex, sizey, m_box_size[ k_z ]]);

                            MakeAllBoxSideCutouts();
                        }                    
                    }
                    else if ( m_component_cutout_type == EXTERIOR )
                    {
                        exterior_stencil_height =
                            m_box_size[ k_z ] +
                            ( m_lid_sliding ? m_lid_thickness : __lid_external_size( k_z ) ) +
                            HULL_EPSILON;

                        intersection()
                        {
                            // Create a stencil for the cutout
                            difference()
                            {
                                // From the whole box ..
                                translate( [ -__component_position(k_x),-__component_position(k_y), -m_wall_thickness ] )
                                    cube( [ m_box_size[ k_x], m_box_size[ k_y], exterior_stencil_height ]);

                                // .. remove the inner area of the whole compartment
                                translate( [ insetx, insety, -m_wall_thickness ] )
                                    cube ( [ sizex, sizey, exterior_stencil_height ]);
                            }

                            MakeAllBoxSideCutouts();
                        }
                    }
                }

                MakeAllBoxCornerCutouts();

                InEachCompartment( )
                {
                    frac = m_component_cutout_bottom_percent;

                    // this is the finger cutout underneath
                    if ( m_actually_cutout_the_bottom )
                        translate( [ (__compartment_size( k_x) * (1-frac))/2, (__compartment_size( k_y) * (1-frac))/2, -m_wall_thickness ])
                            scale( v = [ frac, frac, 1 ]) // bring in the sides
                                MakeCompartmentShape();

                    // chamfer the cavity opening (top edge): flares outward by c
                    if ( __component_chamfer() > 0 )
                        AddCompartmentTopChamfers();
                }

                if ( !$g_no_labels_actual_b)
                {
                    // Clip label subtraction geometry to the component bounds
                    // to prevent sheared/offset labels from cutting outside the box walls
                    intersection()
                    {
                        translate( [ -__component_padding( k_x ), -__component_padding( k_y ), -m_wall_thickness ] )
                            cube( [ __component_size( k_x ) + 2 * __component_padding( k_x ),
                                    __component_size( k_y ) + 2 * __component_padding( k_y ),
                                    m_box_size[ k_z ] ] );
                        LabelEachCompartment();
                    }
                }
            }
        }

        // ----- BOX-LEVEL CUTOUT DISPATCH -----

        module MakeAllBoxSideCutouts()
        {

            ForEachCompartment( k_x )
            {
                    if ( m_component_cutout_side[ k_front ])
                        MakeSideCutouts( k_front, margin = true );

                    if ( m_component_cutout_side[ k_back ])    
                        MakeSideCutouts( k_back, margin = true );
            }

            ForEachCompartment( k_y )
            {
                    if ( m_component_cutout_side[ k_left ])    
                        MakeSideCutouts( k_left, margin = true );

                    if ( m_component_cutout_side[ k_right ])    
                        MakeSideCutouts( k_right, margin = true );
            }   

            InEachCompartment( )
            {
                for ( side = [ k_front:k_right ])
                    if ( m_component_cutout_side[ side ])
                        MakeSideCutouts( side );                     
            }                
        }

        module MakeAllBoxCornerCutouts()
        {
            InEachCompartment( )
            {
                for ( side = [ k_front_left:k_front_right ])
                    if ( m_component_cutout_corner[ side ])
                        MakeCornerCutouts( side );                            
            }        
        }
        // ----- LID & BOX LABELS -----

        module MoveToLidInterior( tolerance = 0)
        {
            translate([ m_lid_wall_thickness + tolerance , m_lid_wall_thickness + tolerance, 0]) 
                children();
        }

        module MakeAllLidLabels( offset = 0, thickness = m_lid_thickness )
        {
            for( i = [ 0 : max(len( m_lid ) - 1, 0)])
            {
                if ( m_lid[ i ][ k_key ] == LABEL )
                {
                    label = m_lid[ i ];

                    if ( __value( label, ENABLED_B, default = true ) )
                        MakeLidLabel( label, offset = offset, thickness = thickness );
                }
            }
        }

        module MakeAllBoxLabels()
        {
            x = m_box_size[ k_x ] / 2;
            y = m_box_size[ k_y ] / 2;

            for( i = [ 0 : len( box ) - 1])
            {
                if ( box[ i ][ k_key ] == LABEL )
                {
                    label = box[ i ];

                    if ( __value( label, ENABLED_B, default = true ) )
                        MakeBoxLabel( label, x, y )
                            Helper_MakeBoxLabel( label, x, y );
                }
            }
        }        

        module Make2dLidLabel( label, width, offset )
        {
            resize([ width,0,0], auto=true )
                offset( r = offset )
                    if ( __is_text( label ) )
                    {
                        text(text = str( __label_text( label ) ),
                            font = __label_font( label ),
                            size = __label_size( label ),
                            spacing = __label_spacing( label ),
                            valign = CENTER,
                            halign = CENTER,
                            $fn = fn);
                    }
                    else
                    {
                        import(str( __label_image( label ) ),
                            center = true);
                    }
        }

        module MakeLidLabel( label, offset = 0, thickness = m_lid_thickness )
        {
            xpos = __lid_external_size( k_x )/2 + __label_offset( label )[k_x];
            ypos = __lid_external_size( k_y )/2 + __label_offset( label )[k_y];

            auto_width = __label_auto_width( label, __lid_external_size( k_x ), __lid_external_size( k_y ) );
            width = auto_width != 0 ? min( DEFAULT_MAX_LABEL_WIDTH, auto_width ) + offset : 0;

            // For solid lids, limit label depth instead of cutting all the way through.
            // Use per-label LBL_DEPTH if set, otherwise fall back to LID_SOLID_LABELS_DEPTH.
            _lbl_depth = __value( label, LBL_DEPTH, default = false );
            _effective_thickness = m_has_solid_lid
                ? ( _lbl_depth != false ? _lbl_depth : m_lid_solid_label_depth )
                : thickness;
            _solid_label_z = m_lid_sliding ? 0 : thickness - _effective_thickness;

            translate( [ 0, 0, m_has_solid_lid ? _solid_label_z : 0 ] )
                linear_extrude( _effective_thickness )
                    translate( [ xpos, ypos, 0 ] )
                        MirrorAboutPoint( [ 1,0,0],[0,0, _effective_thickness / 2])
                            RotateAboutPoint( __label_rotation( label ), [0,0,1], [0,0,0] )
                                Make2dLidLabel( label, width, offset );
        }

        module Helper_MakeBoxLabel( label, x = 0, y = 0 )
        {
            width = __label_auto_width( label, m_box_size[ k_x ] - m_lid_notch_height , m_box_size[ k_y ] - m_lid_notch_height );

            RotateAboutPoint( __label_rotation( label ), [ 0,1,0], [0,0,0] )
                RotateAboutPoint( 90, [1,0,0], [0,0,0] )
                    translate( [ __label_offset( label )[k_x], __label_offset( label )[k_y], 0])
                        resize( [ width, 0, 0], auto=true)
                            translate([0,0,-__label_depth( label )]) 
                                linear_extrude( height =  __label_depth( label ) )
                                    if ( __is_text( label ) )
                                    {
                                        text(text = str( __label_text( label, x) ),
                                            font = __label_font( label ),
                                            size = __label_size( label ),
                                            spacing = __label_spacing( label ),
                                            valign = CENTER,
                                            halign = CENTER,
                                            $fn = fn);
                                    }
                                    else
                                    {
                                        import(str( __label_image( label, x ) ),
                                            center = true);
                                    }
            }

        module MakeBoxLabel( label, x = 0, y = 0 )
        {
            z_pos = 0;
            z_pos_vertical = (m_box_size[ k_z ] - m_lid_notch_height) / 2;

            if ( __label_placement_is_front( label) )
            {
                translate( [ m_box_size[k_x]/2, 0, z_pos_vertical ] )
                    children();
            }
            else if ( __label_placement_is_back( label) )
            {
                translate( [ m_box_size[k_x]/2, m_box_size[k_y], z_pos_vertical ] )
                    rotate( 180, [ 0,0,1])
                        children();
            }
            else if ( __label_placement_is_left( label) )
            {
                translate( [ 0, m_box_size[k_y]/2, z_pos_vertical ] )
                    rotate( -90, [ 0,0,1])
                        rotate( -90, [ 0,1,0])
                            children();
            }
            else if ( __label_placement_is_right( label) )
            {            
                translate( [ m_box_size[k_x], m_box_size[k_y]/2, z_pos_vertical ] )
                    rotate( 90, [ 0,0,1])
                        rotate( 90, [ 0,1,0])
                            children();
            }
            else if ( __label_placement_is_bottom( label) )
            {
                translate( [ m_box_size[k_x]/2, m_box_size[k_y]/2, 0 ] )
                    rotate( 90, [ 1,0,0])
                        children();
            }            
        }



        module MakeAllLidLabelFrames( offset = 0, thickness = m_lid_thickness )
        {
            for( i = [ 0 : max(len( m_lid ) - 1, 0)])
            {
                if ( m_lid[ i ][ k_key ] == LABEL )
                {
                    label = m_lid[ i ];

                    if ( __value( label, ENABLED_B, default = true ) )
                        MakeLidLabelFrame( label, offset = offset, thickness = thickness );
                }
            }
        }

        module MakeLidLabelFrame( label, offset = 0, thickness = m_lid_thickness )
        {
            xpos = __lid_external_size( k_x )/2 + __label_offset( label )[k_x];
            ypos = __lid_external_size( k_y )/2 + __label_offset( label )[k_y];

            auto_width = __label_auto_width( label, __lid_external_size( k_x ), __lid_external_size( k_y ) );
            width = auto_width != 0 ? min( DEFAULT_MAX_LABEL_WIDTH, auto_width ) + offset : 0;

            linear_extrude( thickness )
                translate( [ xpos, ypos, 0 ] )
                    MirrorAboutPoint( [ 1,0,0],[0,0, thickness / 2])
                        RotateAboutPoint( __label_rotation( label ), [0,0,1], [0,0,0] )
                            offset( r = offset )
                                intersection()
                                {
                                    hull()
                                    {
                                        translate( [ -LABEL_FRAME_HULL_EXTENT,0,0])
                                            Make2dLidLabel( label, width, offset );

                                        translate( [ LABEL_FRAME_HULL_EXTENT,0,0])
                                            Make2dLidLabel( label, width, offset );
                                    }
                                    hull()
                                    {
                                        translate( [ -0,-LABEL_FRAME_HULL_EXTENT,0])
                                            Make2dLidLabel( label, width, offset );

                                        translate( [ 0,LABEL_FRAME_HULL_EXTENT,0])
                                            Make2dLidLabel( label, width, offset );
                                    }         
                                }    
                                
        }

        module MakeDetachedLidLabels()
        {
            lid_print_position = [0, m_box_size[ k_y ] + DISTANCE_BETWEEN_PARTS, 0 ];

            MoveToLidInterior( tolerance = -$g_tolerance )
                translate( $g_vis_actual_b ? lid_vis_position : lid_print_position ) 
                    RotateAboutPoint( $g_vis_actual_b ? 180 : 0, [0, 1, 0], [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, 0] )            
                        MakeAllLidLabels();
        }
    
        // ----- LID ASSEMBLY -----

        module MakeLid() 
        {

            module MakeMesh( thickness )
            {

                linear_extrude( thickness )
                {
                    R = m_lid_pattern_radius;
                    t = m_lid_pattern_thickness;

                    if ( !m_has_solid_lid )
                        Make2DPattern( x = __lid_external_size( k_x ), y = __lid_external_size( k_y ), R = R, t = t, pattern_angle = m_lid_pattern_angle, pattern_col_offset = m_lid_pattern_col_offset, pattern_row_offset = m_lid_pattern_row_offset, pattern_n1 = m_lid_pattern_n1, pattern_n2 = m_lid_pattern_n2 );
                    else
                        square( [ __lid_external_size( k_x ), __lid_external_size( k_y ) ] );
                }
            }

            function __lid_surface_thickness() =
                m_lid_sliding ? __lid_external_size( k_z ) :
                m_lid_inset ? m_lid_thickness + m_lid_wall_height - 2* $g_tolerance :
                m_lid_thickness;

            function __lid_surface_frame_origin() =
                m_lid_inset ?
                    [ m_lid_wall_thickness - $g_tolerance, m_lid_wall_thickness - $g_tolerance ] :
                    [ 0, 0 ];

            function __lid_surface_frame_size() =
                m_lid_inset ?
                    [ __lid_internal_size( k_x ) + 2*$g_tolerance, __lid_internal_size( k_y ) + 2*$g_tolerance ] :
                    [ __lid_external_size( k_x ), __lid_external_size( k_y ) ];

            module MakePatternedLidFrame( thickness = __lid_surface_thickness() )
            {
                frame_size = __lid_surface_frame_size();
                frame_origin = __lid_surface_frame_origin();
                frame_width = min(
                    max( 0, m_lid_frame_width ),
                    frame_size[ k_x ]/3,
                    frame_size[ k_y ]/3
                );

                if ( !m_has_solid_lid && frame_width > 0 )
                    translate( [ frame_origin[ k_x ], frame_origin[ k_y ], 0 ] )
                        difference()
                        {
                            cube([ frame_size[ k_x ], frame_size[ k_y ], thickness ]);

                            translate( [ frame_width, frame_width, -epsilon ] )
                                cube([
                                    max( 0.01, frame_size[ k_x ] - 2*frame_width ),
                                    max( 0.01, frame_size[ k_y ] - 2*frame_width ),
                                    thickness + 2*epsilon
                                ]);
                        }
            }

            module MakeLidSurface()
            {
                thickness = __lid_surface_thickness();

                // pattern
                difference()
                {
                    // if it's in an inset lid then we want the pattern all the way down so it's flush
                    // and holds pieces in place.


                    union()
                    {
                        MakeMesh( thickness = thickness );
                        MakePatternedLidFrame( thickness = thickness );
                    }

                        // stencil out the text
                    
                    union()
                    {

                        if ( m_lid_label_bg_thickness > 0 && !m_has_solid_lid )
                            MakeAllLidLabelFrames( offset = m_lid_label_bg_thickness, thickness = thickness );

                            MakeAllLidLabels( thickness = thickness );
                    }       
                } 

                if ( m_lid_has_labels )
                {
                    if ( !m_has_solid_lid )
                    {
                        // grid
                        if ( !m_lid_is_inverted )
                        {
                            // edge
                            if ( m_lid_label_bg_thickness > 0 )
                                difference()
                                {
                                    MakeAllLidLabelFrames( offset = m_lid_label_bg_thickness, thickness = thickness);
                                    MakeAllLidLabelFrames( offset = m_lid_label_bg_thickness - m_lid_label_border_thickness, thickness = thickness );
                                }

                            // pattern
                            if ( m_lid_label_bg_thickness > 0 )
                                difference()
                                {
                                    intersection()
                                    {
                                        theta = DEFAULT_STRIPE_ANGLE;

                                        x = __lid_external_size( k_x );
                                        y = __lid_external_size( k_y );

                                        x2 = y*sin(theta) + x*cos(theta);
                                        y2 = y*cos(theta) + x*sin(theta);                                     

                                        translate( [x/2-x2/2, y/2-y2/2, 0])
                                            RotateAboutPoint( theta, [0,0,1], [x2/2,y2/2,0] )
                                                MakeStripedGrid( x = x2, y = y2, w = m_lid_stripe_width, dx = m_lid_stripe_space, dy = 0, depth_ratio = 0.5, thickness = thickness );

                                        MakeAllLidLabelFrames( offset = m_lid_label_bg_thickness, thickness = thickness );
                                    }

                                    // in the case of mmu, we want to cut out the labels
                                    if ( $g_print_mmu_layer == "mmu_box_layer" )
                                        MakeAllLidLabels( ); 
                                }

                            // positive text
                            if ( $g_print_mmu_layer != "mmu_box_layer" )
                                MakeAllLidLabels( ); 
                        }
                        else if ( m_lid_label_bg_thickness > 0 )
                        {  
                            // negative text
                            difference()
                            {
                                {
                                    MakeAllLidLabelFrames( offset = m_lid_label_bg_thickness );
                                    MakeAllLidLabels();
                                }
                            }    
                        }
                        else
                        {
                            difference()
                            {
                                {
                                    MakeAllLidLabels( offset = m_lid_label_border_thickness );
                                    MakeAllLidLabels();
                                }
                            }                             
                        }
                    }
                }

            }

            module MakeSlidingLidEnvelope()
            {
                __MakeChamferedBoxShell(
                    [ __lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z ) ],
                    m_sliding_lid_bevel,
                    chamfer_top = false,
                    chamfer_bottom = true );
            }

            module MakeSlidingLidSurface()
            {
                MakeLidSurface();
            }

            module MakeSlidingLidDetentGroove()
            {
                if ( $g_detent_thickness > 0 )
                {
                    detent_h = __sliding_detent_height();
                    detent_w = __sliding_detent_width();
                    detent_len = __sliding_detent_length();

                    if ( !m_lid_slides_x )
                    {
                        x = __sliding_detent_start( __lid_external_size( k_x ), detent_len );
                        y = m_lid_slide_side == FRONT ?
                            __sliding_detent_near_edge_pos() :
                            __sliding_detent_far_edge_pos( __lid_external_size( k_y ) );

                        translate( [ x, y, __lid_external_size( k_z ) - detent_h ] )
                            MakeSlidingLidDetentCavityPrismX( detent_len, detent_w, detent_h + HULL_EPSILON, m_lid_slide_side == FRONT );
                    }
                    else
                    {
                        x = m_lid_slide_side == LEFT ?
                            __sliding_detent_near_edge_pos() :
                            __sliding_detent_far_edge_pos( __lid_external_size( k_x ) );
                        y = __sliding_detent_start( __lid_external_size( k_y ), detent_len );

                        translate( [ x, y, __lid_external_size( k_z ) - detent_h ] )
                            MakeSlidingLidDetentCavityPrismY( detent_len, detent_w, detent_h + HULL_EPSILON, m_lid_slide_side == LEFT );
                    }
                }
            }

            module Helper__BuildLid()
            {
                if ( m_lid_sliding )
                {
                    difference()
                    {
                        intersection()
                        {
                            MakeSlidingLidEnvelope();

                            MakeSlidingLidSurface();
                        }

                        MakeSlidingLidDetentGroove();
                    }
                }
                else if ( m_lid_cap )
                {
                    MakeLidBase_Cap( tolerance = $g_tolerance, tolerance_detent_pos = $g_tolerance_detent_pos );

                    // lid surface ( pattern and labels )
                    intersection() // clip to lid extents
                    {
                        __MakeChamferedBoxShell(
                            [__lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )],
                            m_box_chamfer, chamfer_top = false, chamfer_bottom = true );

                        MakeLidSurface();
                    }
                }
                else if ( m_lid_inset )
                {
                    // main structure of lid minus center
                    difference()
                    {
                        MakeLidBase_Inset( tolerance = $g_tolerance, tolerance_detent_pos = $g_tolerance_detent_pos );

                        // hollow the center
                        MoveToLidInterior()
                            cube([  __lid_internal_size( k_x ), __lid_internal_size( k_y ),  __lid_external_size( k_z )]);
                    }

                    // add the flat notch tabs to the sides
                    // difference()
                    // {
                    //     cube( [ __lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )/2 ]   );

                    //     // hollow the center
                    //     MoveToLidInterior()
                    //         cube([  __lid_internal_size( k_x ), __lid_internal_size( k_y ),  __lid_external_size( k_z )]);

                    //     MakeCorners( mod = 1 );
                    // }

                    // add tabs
                    MakeLidTabs( mod = -$g_tolerance );

                    // lid surface ( pattern and labels )
                    intersection() // clip to lid extents
                    {
                        MoveToLidInterior( tolerance = -$g_tolerance )
                            cube([  __lid_internal_size( k_x ) + 2*$g_tolerance, __lid_internal_size( k_y ) + 2*$g_tolerance,  __lid_external_size( k_z)]);

                        MakeLidSurface();
                    }
                }
                else
                {
                    // lid surface ( pattern and labels )
                    intersection() // clip to lid extents
                    {
                        __MakeChamferedBoxShell(
                            [__lid_external_size( k_x ), __lid_external_size( k_y ), __lid_external_size( k_z )],
                            m_box_chamfer, chamfer_top = false, chamfer_bottom = true );

                        MakeLidSurface();
                    }
                }
            }


            lid_print_position = [ 0, m_box_size[ k_y ] + DISTANCE_BETWEEN_PARTS, m_lid_sliding ? __lid_external_size( k_z ) : 0 ];
            lid_vis_position = [ 0, 0, m_box_size[ k_z ] + m_lid_thickness ];
            lid_sliding_closed_position = !m_lid_slides_x ?
                ( m_lid_slide_side == FRONT ?
                    [ m_sliding_lid_rail_side_clearance, 0, m_box_size[ k_z ] + m_sliding_lid_fit_tolerance + __lid_external_size( k_z ) ] :
                    [ m_sliding_lid_rail_side_clearance, m_sliding_lid_stop_clearance, m_box_size[ k_z ] + m_sliding_lid_fit_tolerance + __lid_external_size( k_z ) ] ) :
                ( m_lid_slide_side == LEFT ?
                    [ 0, m_sliding_lid_rail_side_clearance, m_box_size[ k_z ] + m_sliding_lid_fit_tolerance + __lid_external_size( k_z ) ] :
                    [ m_sliding_lid_stop_clearance, m_sliding_lid_rail_side_clearance, m_box_size[ k_z ] + m_sliding_lid_fit_tolerance + __lid_external_size( k_z ) ] );
            lid_position = ( m_lid_sliding && $g_vis_actual_b ) ?
                lid_sliding_closed_position :
                ( $g_vis_actual_b ? lid_vis_position : lid_print_position );
            lid_rotation = m_lid_sliding ? 180 : ( $g_vis_actual_b ? 180 : 0 );

            translate( lid_position )
                RotateAboutPoint( lid_rotation, [0, 1, 0], [__lid_external_size( k_x )/2, __lid_external_size( k_y )/2, 0] )
                    difference()
                    {
                        Helper__BuildLid();

                        // if lid is going to be used to hold cards (e.g. discard pile)
                        if ( m_lid_cap )
                            for ( side = [ k_front:k_right ])
                                if ( m_lid_cutout_sides[ side ])
                                    MakeSideCutouts( side );
                    }        
         }

        // ----- ITERATION HELPERS -----

        module ForEachPartition( D,  )
        {
            start = 0;
            end = __partitions_num( D ) - 1;

            if ( end >= start )
            {
                firstpos = __compartment_size( D ) + __component_margin_start_axis( D );

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
                    side = D == k_x ? k_left : k_front;
                    dim1 = m_component_margin_side[ side ] + ( __component_padding( D ) + __compartment_size( D )) * a ;

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
                x_pos = m_component_margin_side[ k_left ] + ( __compartment_size( k_x ) + __component_padding( k_x ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = m_component_margin_side[ k_front ] + ( ( __compartment_size( k_y ) ) + __component_padding( k_y ) ) * y;

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
                x_pos = m_component_margin_side[ k_left ] + ( __compartment_size( k_x ) + __component_padding( k_x ) ) * x;

                for ( y = [ 0: n_y - 1] )
                {
                    y_pos = m_component_margin_side[ k_front ] + ( ( __compartment_size( k_y ) ) + __component_padding( k_y ) ) * y;

                    translate( [ x_pos ,  y_pos , m_component_base_height ] ) // to compartment origin
                    {
                        for( i = [ 0 : len( component ) - 1])
                        {
                            if ( component[ i ][ k_key ] == LABEL )
                            {
                                label = component[ i ];

                                if ( __value( label, ENABLED_B, default = true ) )
                                    MakeLabel( label, x, y )
                                        Helper_MakeLabel( label, x, y );
                            }
                        }

                    }
                }
            } 
        }

        // ----- CUTOUT & FILLET GEOMETRY -----

        module MakeSideCutouts( side, margin = false )
        {

            function __box_side_cutout_top() =
                m_box_size[ k_z ] +
                ( m_lid_sliding ? m_lid_thickness : __lid_external_size( k_z ) ) -
                m_wall_thickness + HULL_EPSILON;
            function __cutout_z() = m_is_lid ? m_lid_wall_height + m_lid_thickness :
                                    max( HULL_EPSILON, __box_side_cutout_top() - __finger_cutouts_bottom() );
            function __padding( D ) = m_is_lid ? 0 : __component_padding( D );
            function __size( D ) = m_is_lid ? __lid_external_size( D ) : __compartment_size( D );
            function __finger_cutouts_bottom() = m_is_lid ? __lid_external_size( k_z ) - __cutout_z() :
                                                m_box_size[ k_z ] * (1-m_cutout_height_pct) - m_wall_thickness - HULL_EPSILON;
            function __round_bottom() = __finger_cutouts_bottom() > m_box_size[ k_z ] - __size( k_z );
            module MakeRoundedBottomProfile( width, height )
            {
                r = min( radius, width / 2, height / 2 );
                point_r = MIN_CORNER_RADIUS;

                hull()
                {
                    translate( [ r, r ] )
                        circle( r = r );
                    translate( [ width - r, r ] )
                        circle( r = r );
                    translate( [ point_r, height - point_r ] )
                        circle( r = point_r, $fn = 4 );
                    translate( [ width - point_r, height - point_r ] )
                        circle( r = point_r, $fn = 4 );
                }
            }

            module MakeRoundedBottomSideCutout( side, size )
            {
                if ( side == k_front || side == k_back )
                    multmatrix( [
                        [ 1, 0, 0, 0 ],
                        [ 0, 0, 1, 0 ],
                        [ 0, 1, 0, 0 ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        linear_extrude( height = size[ k_y ] )
                            MakeRoundedBottomProfile( size[ k_x ], size[ k_z ] );
                else
                    multmatrix( [
                        [ 0, 0, 1, 0 ],
                        [ 1, 0, 0, 0 ],
                        [ 0, 1, 0, 0 ],
                        [ 0, 0, 0, 1 ],
                    ] )
                        linear_extrude( height = size[ k_x ] )
                            MakeRoundedBottomProfile( size[ k_y ], size[ k_z ] );
            }

            // main and perpendicular dimensions
            main_d = ( side == k_back || side == k_front ) ? k_y : k_x; 
            perp_d = ( side == k_back || side == k_front ) ? k_x : k_y;

            max_radius = DEFAULT_MAX_CUTOUT_CORNER_RADIUS;
            radius = max_radius;

            // main and perpendicular size of hole
            //  main dimension intrudes into the compartment by some fraction ( e.g. 1/5 )
            // Wall-breach guarantee: the margin slot must punch through the actual
            // outer wall (m_wall_thickness, set per-box) plus the radius worth of
            // corner curvature on each end, otherwise thicker walls leave a sliver
            // at the outer surface and the cutout doesn't reach daylight.
            main_size_raw = margin ? m_component_margin_side[ side ] + m_wall_thickness + 2 * radius :
                        __padding( main_d )/2  + __size( main_d ) * m_cutout_size_frac_aligned;
            main_size = ( m_cutout_depth_max > 0 && !margin ) ? min( main_size_raw, m_cutout_depth_max ) : main_size_raw;

            //  perp dimension is a half of the width and no more than 3cm
            perp_size = __size( perp_d ) * m_cutout_size_frac_perpindicular ;

            pos_standard = [
                // front
                [  
                    __size( k_x )/2  - perp_size/2,       
                    - __padding( k_y )/2,               
                    __finger_cutouts_bottom() 
                ], 
                // back
                [  
                    __size( k_x )/2  - perp_size/2,                     
                    __size( main_d ) - main_size + __padding( k_y )/2, 
                    __finger_cutouts_bottom() 
                ],
                // left
                [   
                    - __padding( k_x )/2, 
                    __size( k_y )/2  - perp_size/2, 
                    __finger_cutouts_bottom() 
                ],
                // right
                [   
                    __size( main_d ) - main_size + __padding( k_x )/2, 
                    __size( k_y )/2  - perp_size/2, 
                    __finger_cutouts_bottom()
                ], 
            ];

            pos_margin = [
                // front
                [
                    __size( k_x )/2  - perp_size/2,
                    -__padding( main_d )/2 - m_wall_thickness - radius,
                    __finger_cutouts_bottom()
                ],
                // back
                [
                    __size( k_x )/2  - perp_size/2,
                    __component_size( k_y) - m_component_margin_side[ k_back] + __padding( main_d )/2 - radius,
                    __finger_cutouts_bottom()
                ],
                // left
                [
                    -__padding( main_d )/2 - m_wall_thickness - radius,
                    __size( k_y )/2  - perp_size/2,
                    __finger_cutouts_bottom()
                ],
                // right
                [
                    __component_size( k_x ) - m_component_margin_side[ k_right ] + __padding( main_d )/2 - radius,
                    __size( k_y )/2  - perp_size/2,
                    __finger_cutouts_bottom()
                ],


            ];

            pos = margin ? pos_margin : pos_standard;

            size = [

                [ perp_size, main_size, __cutout_z() ], // front
                [ perp_size, main_size, __cutout_z() ], // back
                [ main_size , perp_size, __cutout_z() ], // left 
                [ main_size , perp_size, __cutout_z() ] // right
            ];

            cutouts = m_is_lid ?
                [
                    m_lid_cutout_sides[ k_front ],
                    m_lid_cutout_sides[ k_back ],
                    m_lid_cutout_sides[ k_left ],
                    m_lid_cutout_sides[ k_right ],
                ] :
                [
                    m_component_cutout_side[ k_front ],
                    m_component_cutout_side[ k_back ],
                    m_component_cutout_side[ k_left ],
                    m_component_cutout_side[ k_right ],
                ];

            shape_standard =
            [
                //front
                [ !cutouts[ k_back ],!cutouts[ k_back ],t,t ],

                //back
                [ t,t,!cutouts[ k_front ],!cutouts[ k_front ]],

                //left
                [ !cutouts[ k_right ],t,!cutouts[ k_right ],t ],

                //right
                [ t,!cutouts[ k_left ],t,!cutouts[ k_left ]],
            ];

            shape_square = [ f,f,f,f];

            shape = __round_bottom() ? [ t,t,t,t] : 
                m_actually_cutout_the_bottom ? shape_square : shape_standard[ side ];
            
            translate( pos[ side ] )
                if ( __round_bottom() )
                    MakeRoundedBottomSideCutout( side, size[ side ] );
                else
                    MakeRoundedCubeAxis( size[ side ], radius, shape, k_z);
        }

        module MakeCornerCutouts( corner )
        {
            function __cutout_z() = ( m_is_lid ? m_lid_wall_height + m_lid_thickness : m_box_size[ k_z ] + __lid_external_size( k_z ) * 2 );
            function __padding( D ) = m_is_lid ? 0 : __component_padding( D );
            function __size( D ) = m_is_lid ? __lid_internal_size( D ) : __compartment_size( D );
            function __finger_cutouts_bottom() = m_is_lid ?__lid_external_size( k_z ) - __cutout_z() : 
                                                - __lid_external_size( k_z );

            inset_into_compartment_fraction = DEFAULT_CORNER_CUTOUT_INSET_FRACTION;
            inverse_inset = 1 - inset_into_compartment_fraction;

            // k_front_left = 0;
            // k_back_right = 1;
            // k_back_left = 2;
            // k_front_right = 3;

            pos = [
                    // k_front_left
                    [  
                        - __padding( k_x )/2 ,       
                        - __padding( k_y )/2  ,                
                        __finger_cutouts_bottom() 
                    ], 
                    // k_back_right
                    [  
                        __size( k_x ) * inverse_inset,                     
                        __size( k_y ) * inverse_inset , 
                        __finger_cutouts_bottom() 
                    ],
                    // k_back_left
                    [   
                        __size( k_x ) * inverse_inset , 
                        - __padding( k_y )/2  , 
                        __finger_cutouts_bottom()                        

                    ],
                    // k_front_right
                    [   
                        - __padding( k_x )/2,  
                        __size( k_y ) * inverse_inset ,                        

                        __finger_cutouts_bottom() 
                    ], 
                ];

            shape = [
                        //k_front_left
                        [ 
                            !m_component_cutout_corner[ k_back_left ] && !m_component_cutout_corner[ k_front_right ],
                            !m_component_cutout_corner[ k_front_right ],
                            !m_component_cutout_corner[ k_back_left ],
                            t
                        ],

                        //k_back_right
                        [ 
                            t,
                            !m_component_cutout_corner[ k_front_right ],
                            !m_component_cutout_corner[ k_back_left ],
                            !m_component_cutout_corner[ k_back_left ] && !m_component_cutout_corner[ k_front_right ],

                        ],

                        //k_back_left
                        [  
                            !m_component_cutout_corner[ k_back_right ],
                            !m_component_cutout_corner[ k_front_left ] && !m_component_cutout_corner[ k_back_right ],
                            t,
                            !m_component_cutout_corner[ k_front_left ],
                        ],

                        //k_front_right
                        [ 
                            !m_component_cutout_corner[ k_back_right ],
                            t,
                            !m_component_cutout_corner[ k_front_left ] && !m_component_cutout_corner[ k_back_right ],
                            !m_component_cutout_corner[ k_front_left ],

                        ],            
                    ];

            size = [ __padding( k_x )/2  + __size( k_x ) * inset_into_compartment_fraction, 
                    __padding( k_y )/2 + __size( k_y ) * inset_into_compartment_fraction, 
                    __cutout_z() ];

            translate( pos[ corner ] )
                MakeRoundedCubeAxis( size, 3, shape[ corner], k_z);


        }

        // Adds 45-degree chamfer wedges at the floor-to-wall corner of a compartment.
        // Square: prisms along the four bottom edges + the four vertical corners.
        // Vertical hex/oct/round: a tapered ring whose outer wall matches the cavity
        // wall and whose inner wall slopes inward at 45° (zero width at z=c).
        // Laid-down hex/oct: cavity floor is curved (a tangent line where the
        // cylinder meets the floor), so chamfer is not applicable — no-op.
        module AddCompartmentChamfers()
        {
            c = __component_chamfer();
            cx = __compartment_size( k_x );
            cy = __compartment_size( k_y );
            cz = __compartment_size( k_z );
            eps = 0.001;

            if ( __component_is_square() )
            {
                // --- Bottom edges (floor-to-wall) ---

                // Front edge (along X at y=0)
                hull() { cube([ cx, c, eps ]); cube([ cx, eps, c ]); }

                // Back edge (along X at y=cy)
                translate([ 0, cy, 0 ]) mirror([ 0, 1, 0 ])
                    hull() { cube([ cx, c, eps ]); cube([ cx, eps, c ]); }

                // Left edge (along Y at x=0)
                hull() { cube([ c, cy, eps ]); cube([ eps, cy, c ]); }

                // Right edge (along Y at x=cx)
                translate([ cx, 0, 0 ]) mirror([ 1, 0, 0 ])
                    hull() { cube([ c, cy, eps ]); cube([ eps, cy, c ]); }

                // --- Vertical edges (wall-to-wall corners) ---

                // Front-left corner
                hull() { cube([ c, eps, cz ]); cube([ eps, c, cz ]); }

                // Front-right corner
                translate([ cx, 0, 0 ]) mirror([ 1, 0, 0 ])
                    hull() { cube([ c, eps, cz ]); cube([ eps, c, cz ]); }

                // Back-left corner
                translate([ 0, cy, 0 ]) mirror([ 0, 1, 0 ])
                    hull() { cube([ c, eps, cz ]); cube([ eps, c, cz ]); }

                // Back-right corner
                translate([ cx, cy, 0 ]) mirror([ 1, 0, 0 ]) mirror([ 0, 1, 0 ])
                    hull() { cube([ c, eps, cz ]); cube([ eps, c, cz ]); }
            }
            else if ( __component_shape_vertical() )
            {
                // Match MakeVerticalShape: same fn/angle/radius/center as the cavity.
                fn  = __component_is_hex() || __component_is_hex2() ? 6
                    : __component_is_oct() || __component_is_oct2() ? 8 : 100;
                ang = __component_is_hex() ? 30
                    : __component_is_oct() ? 22.5 : 0;
                r   = __compartment_largest_dimension() / 2;
                // 45° chamfer means the perpendicular inset of each wall equals
                // the height. For an n-gon, perpendicular wall-to-wall distance
                // between concentric polygons equals the radius difference times
                // cos(180/n), so the inner cone's circumradius must be reduced
                // by c/cos(180/n) to inset the apothem (and thus each flat) by c.
                r_inner = r - c / cos( 180 / fn );

                if ( r_inner > 0 )
                {
                    // Fatten outer by oeps to overlap (rather than coincide with) the
                    // cavity wall, and overshoot the inner cone past outer at the top
                    // so the ring closes cleanly with finite thickness — both tricks
                    // avoid the coincident/degenerate faces that trip CGAL's manifold
                    // check when several non-square chamfers exist in one box.
                    oeps = 0.01;
                    r_outer = r + oeps;

                    intersection()
                    {
                        cube([ cx, cy, c ]);  // clip to compartment box (polygon may exceed it)
                        translate([ cx/2, cy/2, 0 ])
                            rotate( a = ang, v = [ 0, 0, 1 ] )
                                difference()
                                {
                                    cylinder( h = c, r = r_outer, $fn = fn );
                                    translate([ 0, 0, -eps ])
                                        cylinder( h = c + 2*eps, r1 = r_inner, r2 = r_outer + oeps, $fn = fn );
                                }
                    }
                }
            }
        }

        // 45° chamfer at the cavity opening (where the wall meets the box top).
        // This is a SUBTRACTION (called from final_component_subtractions): the
        // inverted-cone shape removes wall material so the opening flares outward
        // by c at z=top, matching the cavity wall at z=top-c.
        // Square: 4 inverted prisms (eats into surrounding wall/partition material).
        // Vertical hex/oct/round: tapered ring whose inner wall matches the cavity
        // and outer wall is offset c perpendicular outward.
        // Laid-down hex/oct: opening is the full bounding cube — no-op.
        module AddCompartmentTopChamfers()
        {
            c = __component_chamfer();
            cx = __compartment_size( k_x );
            cy = __compartment_size( k_y );
            cz = __compartment_size( k_z );
            eps = 0.001;
            top_z = m_component_base_height + cz;

            module MakeTopCornerChamfer()
            {
                hull()
                {
                    translate([ 0, 0, top_z - eps ])
                        linear_extrude( 2*eps )
                            polygon([ [0, 0], [c + eps, 0], [0, c + eps] ]);

                    translate([ c, 0, top_z - c - eps ])
                        cube([ eps, eps, eps ]);

                    translate([ 0, c, top_z - c - eps ])
                        cube([ eps, eps, eps ]);
                }
            }

            if ( __component_is_square() )
            {
                // Each edge: flares out by c at z=top, matches cavity wall at z=top-c.
                // Wall slabs are nudged inward by eps to prevent coincident faces.
                // Front edge (flares out into -y)
                hull() {
                    translate([ 0, -c,    top_z         ]) cube([ cx, c,   eps ]);
                    translate([ 0,  eps,  top_z - c - eps ]) cube([ cx, eps, c   ]);
                }
                // Back edge (flares out into +y)
                hull() {
                    translate([ 0, cy,        top_z         ]) cube([ cx, c,   eps ]);
                    translate([ 0, cy - 2*eps, top_z - c - eps ]) cube([ cx, eps, c   ]);
                }
                // Left edge (flares out into -x)
                hull() {
                    translate([ -c,    0, top_z         ]) cube([ c,   cy, eps ]);
                    translate([  eps,  0, top_z - c - eps ]) cube([ eps, cy, c   ]);
                }
                // Right edge (flares out into +x)
                hull() {
                    translate([ cx,        0, top_z         ]) cube([ c,   cy, eps ]);
                    translate([ cx - 2*eps, 0, top_z - c - eps ]) cube([ eps, cy, c   ]);
                }

                // Trim the vertical wall-to-wall corner filler after it has been
                // added, so the top opening chamfer stays continuous at corners.
                MakeTopCornerChamfer();

                translate([ cx, 0, 0 ]) mirror([ 1, 0, 0 ])
                    MakeTopCornerChamfer();

                translate([ 0, cy, 0 ]) mirror([ 0, 1, 0 ])
                    MakeTopCornerChamfer();

                translate([ cx, cy, 0 ]) mirror([ 1, 0, 0 ]) mirror([ 0, 1, 0 ])
                    MakeTopCornerChamfer();
            }
            else if ( __component_shape_vertical() )
            {
                fn  = __component_is_hex() || __component_is_hex2() ? 6
                    : __component_is_oct() || __component_is_oct2() ? 8 : 100;
                ang = __component_is_hex() ? 30
                    : __component_is_oct() ? 22.5 : 0;
                r   = __compartment_largest_dimension() / 2;
                r_outer = r + c / cos( 180 / fn );

                // shift down by eps with a tiny inset so the cone's outer face
                // doesn't coincide with the cavity wall (avoids non-manifold)
                translate([ cx/2, cy/2, top_z - c - eps ])
                    rotate( a = ang, v = [ 0, 0, 1 ] )
                        cylinder( h = c + 2*eps, r1 = r - eps, r2 = r_outer + eps, $fn = fn );
            }
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

        // ----- COMPARTMENT SHAPES -----

        module MakeVerticalShape( h, x, r )
        {
            compartment_z_min = m_wall_thickness;
            compartment_internal_z = __compartment_size( k_z ) - compartment_z_min;

            cylinder_translation = [ __compartment_size( k_x )/2 , __compartment_size(k_y)/2 , 0 ];

            translate( cylinder_translation )
            {
                angle = __component_is_hex() ? 30 : __component_is_oct() ? 22.5 : 0;

                rotate( a=angle, v=[0, 0, 1] )
                    cylinder(h, r, r, center = false );                      
            }
                
        }

        module MakeCompartmentShape()
        {
            $fn = __component_is_hex() || __component_is_hex2() ? 6 : __component_is_oct() || __component_is_oct2() ? 8 : __component_is_square() ? 4 : 100;

            if ( __component_is_square() )
            {
                cube( [ __compartment_size( k_x ), __compartment_size( k_y ), __compartment_size( k_z ) + m_component_base_height]);
            }
            else if ( __component_shape_vertical() )
            {
                r = __compartment_largest_dimension()/2;
                x = __component_is_hex()  ? r * sin( 360/ $fn ) : r;

                MakeVerticalShape(h = __compartment_size( k_z ) + m_component_base_height + epsilon, x = x, r = r);
            }
            else
            {

                dim1 = __component_shape_rotated_90() ? k_y : k_x;
                dim2 = __component_shape_rotated_90() ? k_x : k_y;

                r = __compartment_size( dim1 ) / 2 / cos( 30 / $fn );

                translate( [0, 0, m_component_base_height + epsilon])
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

        // ----- COMPONENT LABELS -----

        module Helper_MakeLabel( label, x = 0, y = 0 )
        {
            label_on_side = __label_placement_is_wall( label );

            width = __label_auto_width( label, __compartment_size( k_x ), __compartment_size( k_y ) );

            // since we build from the bottom--up, we need to reverse the order in which we read the label rows
            label_y_reverse = ( __is_text( label ) && __is_multitext( label )) ?
                len(__value( label, LBL_TEXT)) - y - 1:
                ( !__is_text( label ) && __is_multiimage( label )) ?
                    len(__value( label, LBL_IMAGE)) - y - 1: 0;

            rotate_vector = label_on_side ? [ 0,1,0] : [0,0,1];
            label_needs_to_be_180ed = __label_placement_is_front( label) && __label_placement_is_wall( label);

                RotateAboutPoint( label_needs_to_be_180ed ? 180 : 0, [0,0,1], [0,0,0] )
                    RotateAboutPoint( __label_rotation( label ), rotate_vector, [0,0,0] )
                        RotateAboutPoint( label_on_side ? 90:0, [1,0,0], [0,0,0] )
                            translate( [ __label_offset( label )[k_x], __label_offset( label )[k_y], 0])
                                resize( [ width, 0, 0], auto=true)
                                    translate([0,0,-__label_depth( label )]) 
                                        linear_extrude( height =  __label_depth( label ) )
                                            if ( __is_text( label ) )
                                            {
                                                text(text = str( __label_text( label, x, label_y_reverse) ),
                                                    font = __label_font( label ),
                                                    size = __label_size( label ),
                                                    spacing = __label_spacing( label ),
                                                    valign = CENTER,
                                                    halign = CENTER,
                                                    $fn = fn);
                                            }
                                            else
                                            {
                                                import(str( __label_image( label, x, label_y_reverse ) ),
                                                    center = true);
                                            }
            }

        module MakeLabel( label, x = 0, y = 0 )
        {
            z_pos = 0;
            z_pos_vertical = __compartment_size(k_z)/2 ;

            if ( __label_placement_is_center( label) )
            {
                translate( [ __compartment_size(k_x)/2, __compartment_size(k_y)/2, z_pos] )
                    children();
            }
            else if ( __label_placement_is_front( label) )
            {
                if ( __label_placement_is_wall( label ) )
                    translate( [ __compartment_size(k_x)/2, 0, z_pos_vertical ] )
                        children();
               else               
                    translate( [ __compartment_size(k_x)/2, -__component_padding( k_y )/4, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_back( label) )
            {
                if ( __label_placement_is_wall( label ) )
                    translate( [ __compartment_size(k_x)/2, __compartment_size(k_y), z_pos_vertical ] )
                        children();
                else
                    translate( [ __compartment_size(k_x)/2, __compartment_size(k_y) + __component_padding( k_y )/4, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_left( label) )
            {
                if ( __label_placement_is_wall( label ) )
                    translate( [ 0, __compartment_size(k_y)/2, z_pos_vertical ] )
                        rotate( 90, [ 0,0,1])
                            rotate( -90, [ 0,1,0])
                                children();
                else
                    translate( [ - __component_padding(k_x)/4, __compartment_size(k_y)/2, __partition_height( k_y ) + z_pos] )
                        children();
            }
            else if ( __label_placement_is_right( label) )
            {            
                if ( __label_placement_is_wall( label ) )
                    translate( [ __compartment_size(k_x), __compartment_size(k_y)/2, z_pos_vertical ] )
                        rotate( -90, [ 0,0,1])
                            rotate( 90, [ 0,1,0])
                                children();
                else
                    translate( [ __compartment_size(k_x) + __component_padding(k_x)/4, __compartment_size(k_y)/2, __partition_height( k_y ) + z_pos] )
                        children();
            }
        }

        // ----- PARTITIONS & MARGINS -----

        module MakePartitions()
        {
            MakeMargin( side = k_front );
            MakeMargin( side = k_back );     
            MakeMargin( side = k_left );
            MakeMargin( side = k_right );

            ForEachPartition( k_x )   
            {
                MakePartition( axis = k_x );  
            }


            ForEachPartition( k_y )  
            {
                MakePartition( axis = k_y );  
            }
            
        }

        module MakeMargin( side )
        {
            if ( side == k_left )
                cube ( [ m_component_margin_side[ k_left ], __component_size( k_y ), __partition_height( k_x ) + m_component_base_height  ] );
            else if ( side == k_right )
                translate( [ __component_size( k_x ) - m_component_margin_side[ k_right ] , 0 , 0])
                   cube ( [ m_component_margin_side[ k_right ], __component_size( k_y ), __partition_height( k_x ) + m_component_base_height  ] );
            else if ( side == k_front )
                cube ( [  __component_size( k_x ), m_component_margin_side[ k_front ], __partition_height( k_x ) + m_component_base_height  ] );
            else if ( side == k_back )
                translate( [ 0, __component_size( k_y ) - m_component_margin_side[ k_back ], 0])
                    cube ( [ __component_size( k_x ), m_component_margin_side[ k_back ], __partition_height( k_x ) + m_component_base_height  ] );

        }

        module MakePartition( axis )
        {
            if ( axis == k_x )
            {
                cube ( [ __component_padding( k_x ), __component_size( k_y ), __partition_height( k_x ) + m_component_base_height  ] );
            }
            else if ( axis == k_y )
            {
                cube ( [ __component_size( k_x ), __component_padding( k_y ) , __partition_height( k_y ) + m_component_base_height ] );     
            }
        }

        // ----- LID HARDWARE (notches, tabs, detents) -----

        module MakeLidCornerNotches()
        {
            module MakeLidCornerNotch()
            {
                {
                    translate( [ 0, 0, -m_lid_notch_height ])
                    {
                        cube([ __notch_length( k_x ), __lid_notch_depth(), m_lid_notch_height ]);
                        cube([__lid_notch_depth(), __notch_length( k_y ), m_lid_notch_height]);
                    }
                }
            }

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

        module MakeLidTabs( mod = 0.0, square = false )
        {
            module MakeLidTab( mod )
            {

                x = m_lid_tab[ k_x ] + LID_TAB_MODIFIER_SCALE * mod;
                y = m_lid_tab[ k_y ] + mod;
                z = m_lid_tab[ k_z ] + mod;

                // square part
                translate( [ -x/2, 0, 0])
                    cube( [ x, y, z  ], center = false );

                if ( square )
                {
                    translate( [ -x/2, 0, z ])
                        cube( [ x, y, y + m_lid_wall_height ], center = false );
                }
               else
                    // prism part
                    translate( [ -x/2, 0, z ])
                    {
                        hull()
                        {
                         cube( [ x, y, HULL_EPSILON ], center = false );

                            translate( [0, 0, y  ])
                                rotate( v=[ 0,1,0], a=90)
                                    cylinder( h= x, r=HULL_EPSILON);

                        }
                    }       
            }            

            translate( [ ( m_box_size[ k_x ])/2, 0, 0])
            {
;                if ( m_lid_tab_sides[ k_front ] )
                    MakeLidTab( mod );

                if ( m_lid_tab_sides[ k_back ] )
                 MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                        MakeLidTab( mod );
            }


            translate( [ 0, ( m_box_size[ k_y ])/2, 0])
            {
                if ( m_lid_tab_sides[ k_left ] )
                rotate( -90 )
                        MakeLidTab( mod );

                if ( m_lid_tab_sides[ k_right ] )
                    MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                        rotate( -90 )
                            MakeLidTab( mod );
            }

        }

        module MakeDetents( mod = 0, offset = 0 )
        {
            module MakeDetent( mod )
            {
                // Create one squished sphere
                resize( [$g_detent_thickness*2 + mod, 1, 1.0])
                    sphere( r = DEFAULT_DETENT_SPHERE_RADIUS, $fn = 12 ); 
            }

            module MakeOneSet( mod )
            {
                num_detents = 2;

                // Create two squished spheres $g_detent_spacing apart and wrap them in a hull
                // Place on the front wall g_detent_distance right of corner
                translate( [0, offset ,0 ])
                hull()
                    for ( i = [ 0 : num_detents - 1 ] )
                        translate( [ m_wall_thickness/2 + $g_detent_spacing * i + $g_detent_dist_from_corner, m_wall_thickness/2, 0] )
                            rotate( 90 )
                                MakeDetent( mod );

                // Create two squished spheres $g_detent_spacing apart and wrap them in a hull
                // Place on the front wall g_detent_distance left of tab
                if ( (m_box_size[ k_x] - m_lid_tab[ k_x]) / 2.0 > $g_detent_min_spacing ) {
                translate( [0, offset ,0 ])
                hull()
                    for ( i = [ 0 : num_detents - 1 ] )
                        translate( [((m_box_size[ k_x] - m_lid_tab[ k_x]) / 2.0)  - ($g_detent_spacing * i + $g_detent_dist_from_corner), m_wall_thickness/2, 0] )
                            rotate( 90 )
                                MakeDetent( mod );
                }

                // Create two squished spheres $g_detent_spacing apart and wrap them in a hull
                // Place on the left wall g_detent_distance up from corner
                translate( [offset, 0 ,0 ])
                hull()
                    for ( i = [ 0 : num_detents - 1 ] )
                        translate( [m_wall_thickness/2, m_wall_thickness/2 + $g_detent_spacing * i + $g_detent_dist_from_corner, 0] )
                            MakeDetent( mod );

                // Create two squished spheres $g_detent_spacing apart and wrap them in a hull
                // Place on the front wall g_detent_distance down from tab
                if ( (m_box_size[ k_y] - m_lid_tab[ k_x]) / 2.0 > $g_detent_min_spacing ) {
                translate( [offset, 0 ,0 ])
                hull()
                    for ( i = [ 0 : num_detents - 1 ] )
                        translate( [m_wall_thickness/2, ((m_box_size[ k_y] - m_lid_tab[ k_x]) / 2.0) - ($g_detent_spacing * i + $g_detent_dist_from_corner), 0] )
                            MakeDetent( mod );
                }
            }

            // Lower Left Corner
            MakeOneSet( mod );

            // Upper Left Corner
            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeOneSet( mod );
            }

            // Lower Right Corner
            MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MakeOneSet( mod );
            }

            // Upper Right Corner
            MirrorAboutPoint( [1,0,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
            {
                MirrorAboutPoint( [0,1,0], [ m_box_size[ k_x ] / 2, m_box_size[ k_y ] / 2, 0] )
                {
                    MakeOneSet( mod );    
                }
            }

        }
    }

}





// =============================================================================
// UTILITY: Rounded cube
// =============================================================================

module MakeRoundedCubeAxis( vec3, radius, vecRounded = [ t, t, t, t ], axis = k_z ) {
    radii = 
    [
        vecRounded[ 0 ] ? radius : MIN_CORNER_RADIUS,
        vecRounded[ 1 ] ? radius : MIN_CORNER_RADIUS,
        vecRounded[ 2 ] ? radius : MIN_CORNER_RADIUS,
        vecRounded[ 3 ] ? radius : MIN_CORNER_RADIUS,
    ];
    
    pos =
    [
        [
            [ radii[0], 0,  radii[0] ],
            [ vec3[k_x] - radii[1], 0, radii[1] ],
            [ radii[0], 0, vec3[k_z] - radii[0] ],
            [ vec3[k_x] - radii[1], 0, vec3[k_z] - radii[1] ],
        ],
        [
            [ 0, radii[0], radii[0] ],
            [ 0, vec3[k_y] - radii[1], radii[1] ],
            [ 0, radii[0], vec3[k_z] - radii[0] ],
            [ 0, vec3[k_y] - radii[1], vec3[k_z] - radii[1] ],
        ], 
        [
            [ radii[0], radii[0], 0 ],
            [ vec3[k_x] - radii[1], radii[1], 0 ],
            [ radii[2], vec3[k_y] - radii[2], 0 ],
            [ vec3[k_x] - radii[3], vec3[k_y] - radii[3], 0 ]
        ]
    ] ;
    
    rot =
    [
        [270,0,0],
        [0,90,0],
        [0,0,0]
    ] ;
    
    hull()
    {
        h = vec3[axis];
        
        for ( idx = [ 0 : 3] )
        {
            // collapse the cylinder if we're approximating a point
            fn = radii[ idx ] >= 1 ? $fn: 4;
            
            translate( pos[ axis ][ idx ])
                rotate(rot[ axis ])
                    cylinder(r=radii[ idx ], h=h, $fn = fn);
        }
    }
}
