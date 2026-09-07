#!/usr/bin/env python3
"""Prove the render runner rejects failed exporters and stale/empty artifacts.

A fake OpenSCAD process models success, nonzero termination, timeout status 124,
and a successful process that writes no output. These cases have previously been
misreported as passing because shell status was discarded or old output survived.
No geometry renderer or display server is used by this test.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

RUNNER = Path(__file__).with_name("run_tests.sh")
FAKE_OPENSCAD = '''#!/usr/bin/env python3
import os, pathlib, sys
out = pathlib.Path(sys.argv[sys.argv.index("-o") + 1])
kind = out.suffix[1:]
mode = os.environ.get("FAKE_" + kind.upper(), "success")
if mode == "missing":
    out.unlink(missing_ok=True)
elif mode == "empty":
    out.write_bytes(b"")
elif mode != "stale":
    out.write_text("group() {\\n group() {\\n  cube([1,1,1]);\\n }\\n}\\n")
if mode == "error":
    print("ERROR: synthetic compiler failure", file=sys.stderr)
sys.exit(124 if mode == "timeout" else 7 if mode in ("nonzero", "stale") else 0)
'''


class TestRunner(unittest.TestCase):
    def run_case(self, phase, mode, *, full=False, stale=False):
        with tempfile.TemporaryDirectory(prefix="bit-runner-contract-") as tmp:
            root = Path(tmp)
            tests = root / "tests"
            (tests / "v4/scad").mkdir(parents=True)
            (tests / "v4/scad/test_minimal.scad").write_text("cube(1);\n")
            shutil.copy2(RUNNER, tests / "run_tests.sh")
            bin_dir = root / "bin"
            bin_dir.mkdir()
            (bin_dir / "openscad").write_text(FAKE_OPENSCAD)
            (bin_dir / "xvfb-run").write_text('#!/bin/sh\n[ "$1" = "-a" ] && shift\nexec "$@"\n')
            for executable in bin_dir.iterdir():
                executable.chmod(0o755)
            if stale:
                for subdir, filename in (("stl", "test_minimal.stl"), ("renders", "test_minimal_top.png")):
                    output = tests / "v4" / subdir / filename
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_text("previous successful export\n")
            env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ["PATH"])
            env["FAKE_" + phase.upper()] = mode
            options = ["--views", "top"] if full else ["--csg-only"]
            result = subprocess.run(["bash", str(tests / "run_tests.sh"), *options, "test_minimal"],
                                    env=env, text=True, capture_output=True, timeout=15)
            return result

    def test_success(self):
        for full in (False, True):
            with self.subTest(full=full):
                result = self.run_case("csg", "success", full=full)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("1 passed, 0 failed", result.stdout)

    def test_failed_csg_cannot_pass(self):
        for mode in ("nonzero", "timeout", "empty", "missing", "error"):
            with self.subTest(mode=mode):
                result = self.run_case("csg", mode)
                self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("0 passed, 1 failed", result.stdout)

    def test_failed_render_cannot_reuse_stale_artifact(self):
        for phase in ("stl", "png"):
            for mode in ("nonzero", "timeout", "empty", "missing", "stale"):
                with self.subTest(phase=phase, mode=mode):
                    result = self.run_case(phase, mode, full=True, stale=True)
                    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertIn("0 passed, 1 failed", result.stdout)


if __name__ == "__main__":
    unittest.main()
