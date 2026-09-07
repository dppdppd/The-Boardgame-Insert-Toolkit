#!/usr/bin/env python3
"""Unit checks for exact CSG transition approval; no OpenSCAD renders needed."""
import copy
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest

from csg_expected_changes import read_manifest, verify_transition, TransitionError


class ExpectedChangesTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='bit-expected-csg-unit-')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.before = self.root / 'before.csg'
        self.after = self.root / 'after.csg'
        self.before.write_text('cube(size = [1, 1, 1], center = false);\n')
        self.after.write_text('cube(size = [2, 1, 1], center = false);\n')
        self.manifest = self.root / 'manifest.json'
        self.cache = self.root / 'cache'
        self.entry = {
            'baseline_commit': '1' * 40,
            'test': 'tests/v4/scad/test_example.scad',
            'before_sha256': hashlib.sha256(self.before.read_bytes()).hexdigest(),
            'after_sha256': hashlib.sha256(self.after.read_bytes()).hexdigest(),
            'reason': 'Unit fixture intentionally changes width while preserving height and depth.',
            # A short standalone invariant keeps these dispatch tests independent
            # of the real geometry gates used by production manifest entries.
            'invariant_commands': [[sys.executable, '-c', 'assert 2 > 1']],
        }

    def entries(self, changes=None):
        self.manifest.write_text(json.dumps({'version': 1, 'changes': changes or [self.entry]}))
        return read_manifest(self.manifest)

    def verify(self, entries=None, **overrides):
        arguments = dict(entries=self.entries() if entries is None else entries,
                         baseline=self.entry['baseline_commit'], test=self.entry['test'],
                         before=self.before, after=self.after, root=self.root, cache_dir=self.cache)
        arguments.update(overrides)
        return verify_transition(**arguments)

    def test_exact_reviewed_transition_passes(self):
        self.assertEqual(self.verify(), self.entry['reason'])

    def test_changed_before_is_rejected_before_running_invariant(self):
        self.before.write_text('unexpected baseline\n')
        with self.assertRaisesRegex(TransitionError, 'before hash'):
            self.verify()
        self.assertFalse(self.cache.exists())

    def test_changed_after_is_rejected_before_running_invariant(self):
        self.after.write_text('unexpected current result\n')
        with self.assertRaisesRegex(TransitionError, 'after hash'):
            self.verify()
        self.assertFalse(self.cache.exists())

    def test_unrelated_baseline_is_rejected(self):
        with self.assertRaisesRegex(TransitionError, 'exact baseline'):
            self.verify(baseline='2' * 40)

    def test_unlisted_fixture_is_rejected(self):
        with self.assertRaisesRegex(TransitionError, 'exact baseline'):
            self.verify(test='tests/v4/scad/test_unrelated.scad')

    def test_absent_manifest_accepts_no_transitions(self):
        with self.assertRaisesRegex(TransitionError, 'no reviewed transition'):
            self.verify(entries=read_manifest(self.manifest))

    def test_invariant_failure_rejects_exact_hashes(self):
        self.entry['invariant_commands'] = [[sys.executable, '-c', 'raise SystemExit(3)']]
        with self.assertRaisesRegex(TransitionError, 'invariant command failed'):
            self.verify()
        with self.assertRaisesRegex(TransitionError, 'invariant command failed'):
            self.verify()  # A cached red cannot turn into a green.

    def test_all_invariant_commands_are_required(self):
        self.entry['invariant_commands'].append([sys.executable, '-c', 'raise SystemExit(4)'])
        with self.assertRaisesRegex(TransitionError, 'invariant command failed'):
            self.verify()

    def test_shared_invariant_runs_once_per_gate(self):
        counter = self.root / 'counter.txt'
        self.entry['invariant_commands'] = [[sys.executable, '-c',
            'from pathlib import Path; p=Path("counter.txt"); '
            'p.write_text(str(int(p.read_text())+1) if p.exists() else "1")']]
        self.verify()
        self.verify()
        self.assertEqual(counter.read_text(), '1')
        self.verify(cache_dir=self.root / 'another_gate_cache')
        self.assertEqual(counter.read_text(), '2')

    def test_duplicate_baseline_and_test_is_rejected(self):
        with self.assertRaisesRegex(TransitionError, 'duplicate'):
            self.entries([self.entry, copy.deepcopy(self.entry)])

    def test_reason_and_commands_are_required(self):
        for field in ('reason', 'invariant_commands'):
            with self.subTest(field=field):
                entry = copy.deepcopy(self.entry)
                del entry[field]
                with self.assertRaises(TransitionError):
                    self.entries([entry])

    def test_malformed_hash_and_command_are_rejected(self):
        for field, value in [('after_sha256', '*'), ('baseline_commit', 'HEAD'),
                             ('invariant_commands', ['echo pass']),
                             ('invariant_commands', []), ('reason', '')]:
            with self.subTest(field=field, value=value):
                entry = copy.deepcopy(self.entry)
                entry[field] = value
                with self.assertRaises(TransitionError):
                    self.entries([entry])


if __name__ == '__main__':
    unittest.main()
