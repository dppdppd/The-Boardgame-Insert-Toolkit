// The O counter must remain joined to the patterned cap lid by its solid backing.
// check_lid_label_geometry.py --phase depth measures inherited/overridden cuts;
// its --phase retention mode checks this fixture's exported mesh connectivity.
include <_lid_label_geometry_case.scad>;
// No selector in this retention fixture: the old inverted path must actually cut
// its glyph so the baseline exposes the loose counter, instead of a blank plaque.
label_groups = "";
