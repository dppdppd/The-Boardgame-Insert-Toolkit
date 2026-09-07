include <_lid_label_geometry_case.scad>;
// Active selectors exercise detached labels. Left: body+text; middle: body only;
// right: text only at its matching local position. The numerical placement gate
// checks all lid types and all four sliding directions, in print and preview modes.
label_groups = ["body", "text"];
label_exploded = true;
