#!/usr/bin/env python3
"""Asset bytes, rather than checkout timestamps, define import equality."""
import hashlib
import json
import os
from pathlib import Path
import tempfile
import unittest

from normalize_csg_assets import normalize_stream


class AssetNormalizationTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='bit-asset-normalizer-')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = self.root / 'scad/test_shape.scad'
        self.source.parent.mkdir()
        self.source.write_text('// Fixture paths resolve from this directory.\n')
        self.asset = self.root / 'assets/piece.svg'
        self.asset.parent.mkdir()
        self.asset.write_bytes(b'<svg><path d="M0 0L1 0L0 1Z"/></svg>')

    def csg(self, timestamp, name='../assets/piece.svg'):
        return 'import(file = ' + json.dumps(name) + ', center = true, timestamp = ' + str(timestamp) + ');\n'

    def normalized(self, text):
        return ''.join(normalize_stream(text.splitlines(keepends=True), self.source))

    def test_changed_mtime_same_bytes_remain_equal(self):
        os.utime(self.asset, (1000000000, 1000000000))
        before = self.normalized(self.csg(int(self.asset.stat().st_mtime)))
        os.utime(self.asset, (1700000000, 1700000000))
        after = self.normalized(self.csg(int(self.asset.stat().st_mtime)))
        self.assertEqual(before, after)
        self.assertIn(hashlib.sha256(self.asset.read_bytes()).hexdigest(), after)
        self.assertNotIn('timestamp =', after)

    def test_same_filename_and_mtime_changed_bytes_are_unequal(self):
        os.utime(self.asset, (1000000000, 1000000000))
        before = self.normalized(self.csg(1000000000))
        self.asset.write_bytes(b'<svg><path d="M0 0L2 0L0 2Z"/></svg>')
        os.utime(self.asset, (1000000000, 1000000000))
        self.assertNotEqual(before, self.normalized(self.csg(1000000000)))

    def test_missing_asset_fails_closed(self):
        self.asset.unlink()
        with self.assertRaises(FileNotFoundError):
            self.normalized(self.csg(1000000000))

    def test_unresolved_file_parameter_fails_closed(self):
        with self.assertRaisesRegex(ValueError, 'nonliteral'):
            self.normalized('import(file = unresolved, timestamp = 1000);\n')

    def test_missing_timestamp_still_hashes_asset_bytes(self):
        line = 'import(file = "../assets/piece.svg", center = true);\n'
        result = self.normalized(line)
        self.assertIn('asset_sha256', result)
        self.asset.write_bytes(b'different outline')
        self.assertNotEqual(result, self.normalized(line))

    def test_timestamp_text_inside_filename_is_preserved(self):
        renamed = self.asset.with_name('timestamp = 123.svg')
        self.asset.rename(renamed)
        line = self.csg(456, '../assets/timestamp = 123.svg')
        self.assertIn('file = "../assets/timestamp = 123.svg"', self.normalized(line))
        self.assertNotIn('timestamp = 456', self.normalized(line))

    def test_absolute_path_and_other_geometry_parameters_are_preserved(self):
        line = self.csg(100, str(self.asset))
        result = self.normalized(line)
        self.assertIn(json.dumps(str(self.asset)), result)
        self.assertIn('center = true', result)
        self.assertEqual(self.normalized('cube([1, 2, 3]);\n'), 'cube([1, 2, 3]);\n')


if __name__ == '__main__':
    unittest.main()
