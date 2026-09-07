#!/usr/bin/env python3
"""Measure lid label depths, readable faces, and retained letter centers.

The CSG checks inspect evaluated extrusion depths rather than source spelling,
including inherited and per-label settings on cap, inset, and sliding lids.
Face checks measure the incision boundaries and readable-side handedness.
Retention additionally checks a rendered O fixture's closed, connected STL mesh.
Only retention needs a CGAL render, which the caller runs separately and serially.
"""
import argparse
import ast
from collections import Counter
import json
import math
from pathlib import Path
import re
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/v4/scad/_lid_label_geometry_case.scad"
LIBRARY = ROOT / "release/lib/boardgame_insert_toolkit_lib.4.scad"


def multiply(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def glyphs(csg, include_frames=False):
    """Find zero-offset glyphs; optionally retain supporting-frame copies too."""
    stack, result = [], []
    for line in csg.splitlines():
        line = line.strip()
        if line == "}":
            stack.pop()
        elif line.endswith("{"):
            stack.append(line[:-1].strip())
        elif line.startswith('text(text = "F",'):
            is_frame = not any(item.startswith("offset(r = 0,") for item in stack)
            if is_frame and not include_frames:
                continue
            matrix = [[int(i == j) for j in range(4)] for i in range(4)]
            height = None
            for item in stack:
                if item.startswith("multmatrix("):
                    matrix = multiply(matrix, ast.literal_eval(item[len("multmatrix("):-1]))
                elif item.startswith("linear_extrude("):
                    height = float(re.search(r"height = ([^,]+)", item).group(1))
            if height is None:
                raise AssertionError("Glyph was not extruded")
            result.append({"height": height, "matrix": matrix, "frame": is_frame})
    if not result:
        raise AssertionError("No measurable glyphs in CSG export")
    return result


def near(actual, expected, meaning):
    if not math.isclose(actual, expected, abs_tol=1e-6):
        raise AssertionError(f"{meaning}: expected {expected}, got {actual}")



def z_bounds(glyph):
    m = glyph["matrix"]
    return sorted([m[2][3], m[2][3] + m[2][2] * glyph["height"]])


class Gate:
    def __init__(self, library, output):
        self.output = output
        self.results = []
        self.frame_heights = {}
        self.source = output / "fixture.scad"
        fixture = FIXTURE.read_text()
        fixture = re.sub(r"include <[^>]+>;", f"include <{library}>;", fixture, count=1)
        self.source.write_text(fixture)

    def compile(self, name, **params):
        # Force F only for numerical inspection; rendered retention fixtures use O.
        params = {"label_text": "F", **params}
        output = self.output / f"{name}.csg"
        output.unlink(missing_ok=True)
        command = ["openscad", "-o", str(output)]
        for key, value in params.items():
            command += ["-D", f"{key}={json.dumps(value)}"]
        command += [str(self.source)]
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        log = result.stdout + result.stderr
        output.with_suffix(".log").write_text(log)
        if result.returncode or re.search(r"\b(?:WARNING|ERROR):", log) or not output.is_file() or not output.stat().st_size:
            raise AssertionError(f"{name}: export failed (status {result.returncode}): {log[-1200:]}")
        parts = glyphs(output.read_text(), include_frames=True)
        self.frame_heights[name] = [part["height"] for part in parts if part["frame"]]
        return [part for part in parts if not part["frame"]]

    def record(self, name, operation):
        try:
            operation()
            self.results.append({"case": name, "passed": True})
        except (AssertionError, subprocess.TimeoutExpired) as error:
            self.results.append({"case": name, "passed": False, "reason": str(error)})

    def depth(self):
        for kind in ("cap", "inset", "slide"):
            for global_depth, override, expected in ((0.5, -1, 0.5), (0.3, -1, 0.3), (0.3, 0.8, 0.8)):
                name = f"depth-{kind}-{global_depth}-{override}"
                def check(name=name, kind=kind, global_depth=global_depth, override=override, expected=expected):
                    parts = self.compile(name, label_kind=kind, label_global_depth=global_depth, label_depth=override)
                    # Last glyph is the incision into the backed label plaque.
                    near(parts[-1]["height"], expected, "backed label incision depth")
                    # Default cap=2; inset adds its 2 mm skirt minus two 0.1 mm
                    # tolerances; sliding subtracts those tolerances from 2 mm.
                    surface = 3.8 if kind == "inset" else 1.8 if kind == "slide" else 2
                    if not self.frame_heights[name]:
                        raise AssertionError("Backed label has no supporting plaque")
                    for height in self.frame_heights[name]:
                        near(height, surface, "label plaque spans the actual lid surface")
                self.record(name, check)
        def stencil():
            parts = self.compile("depth-stencil-cap", label_background=0, label_depth=0.8)
            for part in parts:
                near(part["height"], 2, "zero-background stencil remains a through-cut")
        self.record("depth-stencil-cap", stencil)


    def face(self):
        for kind, surface in (("cap", 2), ("inset", 3.8), ("slide", 1.8)):
            for override, depth in ((-1, 0.5), (0.8, 0.8)):
                name = f"face-{kind}-{override}"
                def check(name=name, kind=kind, surface=surface, override=override, depth=depth):
                    part = self.compile(name, label_kind=kind, label_solid=True, label_depth=override)[-1]
                    expected = [surface-depth, surface] if kind == "slide" else [0, depth]
                    for actual, value in zip(z_bounds(part), expected):
                        near(actual, value, "readable face incision z boundary")
                    near(part["matrix"][0][0], 1 if kind == "slide" else -1, "glyph handedness on the readable face")
                self.record(name, check)


def retention(path):
    """Count connected components and closed edges using only the standard library."""
    data = path.read_bytes()
    triangles = []
    if len(data) >= 84 and 84 + struct.unpack_from("<I", data, 80)[0] * 50 == len(data):
        for offset in range(84, len(data), 50):
            values = struct.unpack_from("<12fH", data, offset)
            triangles.append([values[3:6], values[6:9], values[9:12]])
    else:
        vertices = [tuple(map(float, match)) for match in re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", data)]
        if len(vertices) % 3:
            raise AssertionError("Malformed ASCII STL vertex count")
        triangles = [vertices[i:i+3] for i in range(0, len(vertices), 3)]
    if not triangles:
        raise AssertionError("Retention STL has no triangles")
    parents, edges = {}, Counter()
    def find(vertex):
        parents.setdefault(vertex, vertex)
        while parents[vertex] != vertex:
            parents[vertex] = parents[parents[vertex]]
            vertex = parents[vertex]
        return vertex
    for triangle in triangles:
        # STL repeats identical serialized coordinates at shared vertices.
        # Preserve them exactly: rounding can collapse legitimate tiny bevel edges.
        keys = [tuple(vertex) for vertex in triangle]
        if len(set(keys)) != 3:
            raise AssertionError("Degenerate triangle in retention mesh")
        for a, b in zip(keys, keys[1:] + keys[:1]):
            parents[find(b)] = find(a)
            edges[tuple(sorted((a, b)))] += 1
    components = len({find(vertex) for vertex in parents})
    if components != 1:
        raise AssertionError(f"Letter counter must remain attached: got {components} mesh components")
    if any(count != 2 for count in edges.values()):
        raise AssertionError("Retention mesh has open or nonmanifold edges")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", choices=("depth", "face", "retention"), default="face")
    parser.add_argument("--library", type=Path, default=LIBRARY)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--retention-stl", type=Path)
    args = parser.parse_args()
    if args.phase == "retention" and not args.retention_stl:
        parser.error(f"--phase {args.phase} requires --retention-stl from test_label_lid_inverted.scad")
    with tempfile.TemporaryDirectory(prefix="bit-label-geometry-") as temporary:
        output = (args.output_dir or Path(temporary)).resolve()
        output.mkdir(parents=True, exist_ok=True)
        gate = Gate(args.library.resolve(), output)
        for phase in ("depth", "face"):
            if args.phase == phase:
                getattr(gate, phase)()
        if args.retention_stl:
            gate.record("retention-closed-connected-mesh", lambda: retention(args.retention_stl))
        failed = [result for result in gate.results if not result["passed"]]
        report = {"phase": args.phase, "complete": False,
                  "retention_checked": bool(args.retention_stl),
                  "passed": len(gate.results)-len(failed), "failed": len(failed), "results": gate.results}
        (output / "results.json").write_text(json.dumps(report, indent=2)+"\n")
        print(f"Label geometry ({args.phase}): {report['passed']} passed, {len(failed)} failed")
        for failure in failed:
            print(f"FAIL {failure['case']}: {failure['reason']}")
        return bool(failed)


if __name__ == "__main__":
    raise SystemExit(main())
