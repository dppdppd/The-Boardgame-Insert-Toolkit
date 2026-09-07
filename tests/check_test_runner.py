#!/usr/bin/env python3
"""Prove the render runner rejects failed exporters and stale/empty artifacts.

A fake OpenSCAD process models success, nonzero termination, timeout status 124,
and a successful process that writes no output. These cases have previously been
misreported as passing because shell status was discarded or old output survived.
No geometry renderer or display server is used by this test.
"""
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest

RUNNER = Path(__file__).with_name("run_tests.sh")
FAKE_OPENSCAD = '''#!/usr/bin/env python3
import os, pathlib, sys, time
out = pathlib.Path(sys.argv[sys.argv.index("-o") + 1])
kind = out.suffix[1:]
mode = os.environ.get("FAKE_" + kind.upper(), "success")
if kind == "stl" and os.environ.get("FAKE_READY"):
    pathlib.Path(os.environ["FAKE_READY"]).write_text("ready")
    deadline = time.monotonic() + 10
    while not pathlib.Path(os.environ["FAKE_RELEASE"]).exists():
        if time.monotonic() >= deadline:
            sys.exit(12)
        time.sleep(0.02)
if kind == "png" and not pathlib.Path(sys.argv[-1]).is_file():
    print("render helper disappeared", file=sys.stderr)
    sys.exit(9)
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
    def run_case(self, phase, mode, *, full=False, stale=False, extra_env=None):
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
            env.update(extra_env or {})
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

    def test_compile_cleanup_cannot_remove_another_runs_render_helper(self):
        with tempfile.TemporaryDirectory(prefix="bit-runner-overlap-") as tmp:
            ready, release = Path(tmp) / "ready", Path(tmp) / "release"
            with ThreadPoolExecutor(max_workers=1) as pool:
                render = pool.submit(self.run_case, "csg", "success", full=True,
                                     extra_env={"FAKE_READY": str(ready), "FAKE_RELEASE": str(release)})
                try:
                    deadline = time.monotonic() + 8
                    while not ready.exists() and time.monotonic() < deadline:
                        time.sleep(0.02)
                    self.assertTrue(ready.exists(), "Fake STL exporter did not reach its barrier")
                    compile_result = self.run_case("csg", "success")
                    self.assertEqual(compile_result.returncode, 0, compile_result.stdout + compile_result.stderr)
                finally:
                    release.touch()
                result = render.result(timeout=15)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

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
