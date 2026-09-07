#!/usr/bin/env python3
"""Check native OpenSCAD pattern coverage against an oversized lattice.

All comparisons happen in OpenSCAD's 2D geometry engine. Symmetric differences
must be empty, so a translated pattern with the same area cannot pass. The
reference retains the historical centering/stagger but uses a deliberately
oversized fixed index range independent of the production coverage bounds.
Only Python's standard library and OpenSCAD are required.
"""
import argparse
import json
import math
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET

LIBRARY = Path(__file__).resolve().parents[1] / 'release/lib/boardgame_insert_toolkit_lib.4.scad'
# Dimensions, radii, and thicknesses are millimetres. These cover the ordinary
# hex settings, the README's three pattern orientations, and the 70-degree
# failure where even the old PR's two extra columns omit edge material.
CASES = [
    ('small_default', (30, 31, 4, .5, 30, 50, 100, 6)),
    ('large_radius', (60, 60, 8, .5, 30, 50, 100, 6)),
    ('small_radius', (60, 60, 3, .5, 30, 50, 100, 6)),
    ('readme_hex', (33, 35, 4, .5, 0, 10, 140, 6)),
    ('readme_oct', (33, 35, 4, .5, 22.5, 10, 130, 8)),
    ('readme_tri', (33, 35, 4, .5, 60, 10, 140, 3)),
    ('short_pitch_70deg', (15, 17, 4, .5, 70, 50, 100, 6)),
    # Wide column gaps leave alternate rows with no intersecting cells.
    ('sparse_columns', (1, 30, 1, .5, 0, 50, 1000, 6)),
]
# Lock both parities and the transitions around integral counts. These sizes
# come from the default grid pitch, rather than arbitrary unrelated lengths.
DX = math.cos(math.radians(30)) * 8 - .5
DY = 5.5
for name, x_count, y_count in [('even_counts', 4, 4), ('odd_counts', 5, 5),
                              ('below_integer', 4.999, 3.999),
                              ('above_integer', 5.001, 4.001)]:
    CASES.append((name, (x_count * DX, y_count * DY, 4, .5, 30, 50, 100, 6)))

REFERENCE = '''
// Fixed padding deliberately exceeds the radius in grid steps for every case.
// This reproduces the established centering and stagger, not the new bounds.
module ReferencePattern(extra = 12, lower = -12) {
    dx = cos(angle) * R * (1 + col / 100) - t;
    dy = R * (1 + row / 100) - t;
    nx = floor(x / dx);
    ny = floor(y / dy);
    origin_x = (x - (nx + ((nx + 1) % 2) + 2) * dx) / 2;
    origin_y = (y - (ny + (ny % 2) + 2) * dy) / 2;
    // Keep the historical transform grouping as well as the grid phase;
    // reassociating floating-point additions introduces tiny Clipper slivers.
    translate([origin_x, origin_y, 0])
        for (j = [lower:floor(y / dy) + extra])
            translate([(j % 2) * dx / 2, 0, 0])
                for (i = [lower:floor(x / dx) + extra])
                    translate([i * dx, j * dy, 0])
                        rotate(a=angle, v=[0,0,1]) Make2dShape(R, t, n, n);
}
module ActualPattern() {
    Make2DPattern(x=x, y=y, R=R, t=t, pattern_angle=angle,
                 pattern_row_offset=row, pattern_col_offset=col,
                 pattern_n1=n, pattern_n2=n);
}
module ClippedReference(extra = 12, lower = -12) {
    intersection() { square([x,y]); ReferencePattern(extra, lower); }
}
module ClippedActual() {
    intersection() { square([x,y]); ActualPattern(); }
}
'''


def native_export(openscad, output_dir, name, body):
    scad = output_dir / (name + '.scad')
    svg = output_dir / (name + '.svg')
    scad.write_text('include <' + str(LIBRARY) + '>;\n' + body)
    svg.unlink(missing_ok=True)
    result = subprocess.run([openscad, '-o', str(svg), str(scad)],
                            capture_output=True, text=True, timeout=90)
    log = result.stdout + result.stderr
    (output_dir / (name + '.log')).write_text(log)
    return result.returncode, svg, log


def area(svg):
    """Signed contours subtract holes in OpenSCAD's line-only SVG export."""
    root = ET.parse(svg).getroot()
    total = 0.0
    for path in root.findall('{http://www.w3.org/2000/svg}path'):
        for contour in re.split('[zZ]', path.attrib['d']):
            points = [tuple(map(float, pair)) for pair in
                      re.findall(r'([-\d.e+]+),([-\d.e+]+)', contour)]
            if len(points) > 2:
                total += sum(a[0] * b[1] - b[0] * a[1]
                             for a, b in zip(points, points[1:] + points[:1])) / 2
    return abs(total)


def run(output_dir, openscad):
    results = []
    for name, values in CASES:
        x, y, radius, thickness, angle, row, col, n = values
        # Check the independently oversized reference really is oversized.
        dx = math.cos(math.radians(angle)) * radius * (1 + col / 100) - thickness
        dy = radius * (1 + row / 100) - thickness
        assert dx > 0 and dy > 0 and max(radius / dx, radius / dy) < 10
        definitions = '\n'.join(f'{k} = {v!r};' for k, v in
                                zip(('x', 'y', 'R', 't', 'angle', 'row', 'col', 'n'), values))
        prefix = definitions + '\n' + REFERENCE
        rc, svg, log = native_export(openscad, output_dir, name, prefix + '''
// A known disjoint square makes an empty difference exportable as native SVG.
union() {
    translate([-100, 100]) square([1, 1]);
    difference() { ClippedActual(); ClippedReference(); }
    difference() { ClippedReference(); ClippedActual(); }
}
''')
        assert 'WARNING:' not in log and 'ERROR:' not in log, name + ': ' + log
        assert rc == 0 and svg.exists(), name + ': ' + log
        points = []
        for path in ET.parse(svg).getroot().findall('{http://www.w3.org/2000/svg}path'):
            points.extend(tuple(map(float, pair)) for pair in
                          re.findall(r'([-\d.e+]+),([-\d.e+]+)', path.attrib['d']))
        # SVG reverses Y. Exactly the four sentinel corners must remain; this
        # detects any extra contour, even when its area is microscopic.
        assert len(points) == 4 and set(points) == {
            (-100, -100), (-99, -100), (-99, -101), (-100, -101)
        }, name + ': nonempty symmetric difference; see ' + str(svg)
        results.append({'case': name, 'symmetric_difference': 'empty'})
        print('PASS ' + name, flush=True)

        if name == 'short_pitch_70deg':
            # Negative control: the submitted PR's +2 bound still loses material.
            rc, witness, witness_log = native_export(
                openscad, output_dir, 'old_plus_two_missing', prefix +
                'difference() { ClippedReference(); ClippedReference(2, -1); }\n')
            assert rc == 0 and witness.exists(), witness_log
            assert 'WARNING:' not in witness_log and 'ERROR:' not in witness_log, witness_log
            missing = area(witness)
            assert 2.50 < missing < 2.52, f'Expected the known 2.507 mm² defect; got {missing}'
            results.append({'case': 'old_plus_two_negative_control', 'missing_mm2': missing})
            print(f'PASS old_plus_two_negative_control ({missing:.6f} mm² missing)', flush=True)

    # Both zero and reversed spacing must give the named diagnostic before the
    # library divides by the pitch. These are deliberately invalid test inputs.
    for name, arguments in [('zero_x', 'R=1,t=1,pattern_angle=0'),
                            ('negative_x', 'R=1,t=.5,pattern_angle=90'),
                            ('zero_y', 'R=1,t=.5,pattern_row_offset=-50'),
                            ('negative_y', 'R=1,t=.5,pattern_row_offset=-100')]:
        _, svg, log = native_export(openscad, output_dir, 'invalid_' + name,
                                   'Make2DPattern(' + arguments + ');\n')
        assert 'ERROR: Assertion' in log and 'Lid pattern spacing must be positive on both axes' in log, log
        assert not svg.exists(), 'Invalid spacing unexpectedly exported geometry'
        assert 'WARNING:' not in log, 'Invalid spacing produced arithmetic/range warnings: ' + log
        results.append({'case': name, 'diagnostic': 'positive spacing required'})
        print('PASS invalid_' + name, flush=True)
    (output_dir / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(f'PASS: {len(CASES)} coverage cases, one negative control, four invalid-spacing diagnostics.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, help='Keep generated SCAD, SVG, logs, and results here')
    args = parser.parse_args()
    openscad = shutil.which('openscad')
    if not openscad:
        parser.error('OpenSCAD must be installed and on PATH')
    if args.output_dir:
        output_dir = args.output_dir.resolve()
        output_dir.mkdir(parents=True, exist_ok=True)
        run(output_dir, openscad)
    else:
        with tempfile.TemporaryDirectory(prefix='bit-pattern-coverage-') as directory:
            run(Path(directory), openscad)


if __name__ == '__main__':
    main()
