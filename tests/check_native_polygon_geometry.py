#!/usr/bin/env python3
"""Check emitted polygon geometry and diagnostics without a costly mesh render.

The checks inspect actual OpenSCAD CSG primitives, including both chamfer cones,
so a valid enum with a circular chamfer fallback still fails. STL rendering and
physical token fit remain separate gates. Run from any directory with Python 3
and openscad installed; the test uses only the Python standard library.
"""

import ast
import math
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "release/lib/boardgame_insert_toolkit_lib.4.scad"
# Each requested native outline has a fixed side count. Flat-bottom outlines
# have two equally low vertices; pointed-bottom outlines have exactly one.
SHAPES = [("TRI", 3, 2), ("TRI2", 3, 1), ("PENT", 5, 2), ("PENT2", 5, 1)]
IDENTITY = [[int(i == j) for j in range(4)] for i in range(4)]


def multiply(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def cylinders(csg):
    """Return emitted cylinders with their composed parent transformations."""
    stack = [IDENTITY]
    result = []
    for raw in csg.splitlines():
        line = raw.strip()
        if line.endswith("{"):
            matrix = stack[-1]
            if line.startswith("multmatrix("):
                local = ast.literal_eval(line[len("multmatrix("):line.rfind(")")])
                matrix = multiply(matrix, local)
            stack.append(matrix)
        elif line.startswith("}"):
            stack.pop()
        elif line.startswith("cylinder("):
            values = dict(re.findall(r"(\$fn|h|r1|r2) = ([-+.e\d]+)", line))
            result.append(({key: float(value) for key, value in values.items()}, stack[-1]))
    return result


def compile_scad(directory, name, source):
    scad = directory / f"{name}.scad"
    target = directory / f"{name}.csg"
    scad.write_text(f"include <{LIB.as_posix()}>;\n" + source)
    run = subprocess.run(["openscad", "-o", str(target), str(scad)],
                         capture_output=True, text=True, timeout=30)
    assert run.returncode == 0, f"{name}: compiler exit {run.returncode}\n{run.stderr}"
    assert not re.search(r"^(ERROR|WARNING):", run.stderr, re.MULTILINE), f"{name}: {run.stderr}"
    return target.read_text(), run.stderr


def feature_box(shape, vertical, axis, chamfer):
    feature_chamfer = "" if chamfer is None else f"[CHAMFER_N, {chamfer}],"
    return f'''[OBJECT_BOX,[NAME,"{shape}-{vertical}-{axis}-{chamfer}"],
[BOX_SIZE_XYZ,[30,30,24]],[BOX_NO_LID_B,true],
[BOX_FEATURE,[FTR_SHAPE,{shape}],[FTR_COMPARTMENT_SIZE_XYZ,[20,20,18]],
[POSITION_XY,[3,3]],[FTR_SHAPE_VERTICAL_B,{str(vertical).lower()}],
[FTR_SHAPE_AXIS,{axis}],{feature_chamfer}]]'''


def main():
    checked = 0
    with tempfile.TemporaryDirectory(prefix="bit-native-polygons-") as temporary:
        directory = Path(temporary)
        for shape, sides, low_vertices in SHAPES:
            for vertical in [False, True]:
                for axis in ["X", "Y"]:
                    for chamfer in [None, 0]:
                        case = f"{shape}-{vertical}-{axis}-{chamfer}"
                        source = f"Make([[G_PRINT_TYPES,[BOX]],{feature_box(shape, vertical, axis, chamfer)}]);"
                        csg, log = compile_scad(directory, case, source)
                        assert "BGSD_WARNING" not in log, f"{case}: {log}"
                        solids = cylinders(csg)
                        assert solids, f"{case}: no cavity geometry"
                        assert all(s["$fn"] == sides for s, _ in solids), f"{case}: wrong polygon or circular chamfer fallback"
                        cones = [(s, m) for s, m in solids if not math.isclose(s["r1"], s["r2"])]
                        expected_cones = 2 if vertical and chamfer is None else 0
                        assert len(cones) == expected_cones, f"{case}: expected {expected_cones} floor/opening cones, got {len(cones)}"
                        cavity, transform = max(solids, key=lambda pair: pair[0]["h"])
                        if vertical:
                            for _, matrix in solids:
                                assert all(abs(matrix[i][j] - transform[i][j]) < 1e-6 for i in range(3) for j in range(3)), f"{case}: chamfer orientation differs from cavity"
                            ys = [transform[1][0] * math.cos(2 * math.pi * n / sides) + transform[1][1] * math.sin(2 * math.pi * n / sides) for n in range(sides)]
                            assert sum(abs(y - min(ys)) < 1e-5 for y in ys) == low_vertices, f"{case}: incorrect flat/pointed outline"
                            if chamfer is None:
                                # Default surface width is 0.6 mm; perpendicular
                                # inset equals that width / sqrt(2) on every flat.
                                leg = 0.6 / math.sqrt(2)
                                floor = min((s for s, _ in cones), key=lambda s: s["r1"])
                                opening = max((s for s, _ in cones), key=lambda s: s["r2"])
                                assert math.isclose((10 - floor["r1"]) * math.cos(math.pi / sides), leg, abs_tol=1e-4), f"{case}: floor chamfer is not 45 degrees"
                                assert math.isclose((opening["r2"] - 10 - 0.001) * math.cos(math.pi / sides), leg, abs_tol=1e-4), f"{case}: opening chamfer is not 45 degrees"
                        else:
                            # The extrusion direction is the selected horizontal
                            # axis, never the vertical stacking axis.
                            selected = 0 if axis == "X" else 1
                            assert abs(abs(transform[selected][2]) - 1) < 1e-6, f"{case}: wrong extrusion axis"
                            zs = [transform[2][0] * math.cos(2 * math.pi * n / sides) + transform[2][1] * math.sin(2 * math.pi * n / sides) for n in range(sides)]
                            expected_low = 1 if sides == 3 else low_vertices
                            assert sum(abs(z - min(zs)) < 1e-5 for z in zs) == expected_low, f"{case}: incorrect laid-down bottom profile"
                        checked += 1
        # Explicit positive chamfers on unsupported laid-down polygons must be
        # reported for every new outline; silently accepting them is misleading.
        boxes = [feature_box(shape, False, "X", 1) for shape, _, _ in SHAPES]
        _, log = compile_scad(directory, "laid-down-warnings", "Make([[G_PRINT_TYPES,[BOX]]," + ",".join(boxes) + "]);")
        warnings = [line for line in log.splitlines() if "BGSD_WARNING" in line]
        assert len(warnings) == 4, f"expected four unsupported-chamfer diagnostics, got {warnings}"
        assert all("cavity chamfers for laid-down polygon features are unsupported" in line for line in warnings), warnings
    print(f"PASS: {checked} shape/axis/stack/chamfer geometry cases and four explicit laid-down diagnostics")


if __name__ == "__main__":
    main()
