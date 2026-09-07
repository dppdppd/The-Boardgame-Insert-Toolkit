#!/usr/bin/env python3
"""Accept only reviewed, hash-pinned CSG transitions whose invariants pass."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


class TransitionError(ValueError):
    pass


def read_manifest(path):
    if not path.exists():
        return []
    document = json.loads(path.read_text())
    if (not isinstance(document, dict) or set(document) != {'version', 'changes'}
            or type(document['version']) is not int or document['version'] != 1
            or not isinstance(document['changes'], list)):
        raise TransitionError('expected version 1 manifest with a changes list')
    fields = {'baseline_commit', 'test', 'before_sha256', 'after_sha256',
              'reason', 'invariant_commands'}
    seen = set()
    for entry in document['changes']:
        if not isinstance(entry, dict) or set(entry) != fields:
            raise TransitionError('each change must contain exactly ' + ', '.join(sorted(fields)))
        for field, pattern in [('baseline_commit', r'[0-9a-f]{40}'),
                               ('before_sha256', r'[0-9a-f]{64}'),
                               ('after_sha256', r'[0-9a-f]{64}'),
                               ('test', r'tests/v4/scad/test_[A-Za-z0-9_-]+\.scad')]:
            if not isinstance(entry[field], str) or not re.fullmatch(pattern, entry[field]):
                raise TransitionError('invalid ' + field)
        if entry['before_sha256'] == entry['after_sha256']:
            raise TransitionError('a transition must pin different before and after hashes')
        if not isinstance(entry['reason'], str) or not entry['reason'].strip():
            raise TransitionError('each transition needs a human-readable reason')
        commands = entry['invariant_commands']
        if not isinstance(commands, list) or not commands:
            raise TransitionError('each transition needs invariant commands')
        for command in commands:
            if (not isinstance(command, list) or not command
                    or not all(isinstance(arg, str) and arg and '\0' not in arg for arg in command)):
                raise TransitionError('invariant commands must be nonempty argument lists')
        identity = (entry['baseline_commit'], entry['test'])
        if identity in seen:
            raise TransitionError('duplicate baseline/test transition: ' + entry['test'])
        seen.add(identity)
    return document['changes']


def run_invariant(command, root, cache_dir):
    # One command may establish the invariant for many fixtures. Cache only
    # within this gate's fresh output directory, never between separate runs.
    cache_dir.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha256(json.dumps(command).encode()).hexdigest()
    status_file = cache_dir / (key + '.json')
    log_file = cache_dir / (key + '.log')
    if status_file.exists():
        status = json.loads(status_file.read_text())
        if status.get('command') != command:
            raise TransitionError('invariant cache command mismatch')
    else:
        try:
            with log_file.open('w') as output:
                result = subprocess.run(command, cwd=root, stdout=output,
                                        stderr=subprocess.STDOUT, timeout=600)
            status = {'command': command, 'exit_code': result.returncode}
        except (OSError, subprocess.TimeoutExpired) as error:
            status = {'command': command, 'exit_code': -1, 'error': str(error)}
        status_file.write_text(json.dumps(status, indent=2) + '\n')
    if status.get('exit_code') != 0:
        raise TransitionError('invariant command failed: ' + json.dumps(command)
                              + '; see ' + str(log_file))


def verify_transition(entries, baseline, test, before, after, root, cache_dir):
    match = next((entry for entry in entries
                  if entry['baseline_commit'] == baseline and entry['test'] == test), None)
    if match is None:
        raise TransitionError('no reviewed transition for this exact baseline and test')
    before_hash = hashlib.sha256(before.read_bytes()).hexdigest()
    after_hash = hashlib.sha256(after.read_bytes()).hexdigest()
    if before_hash != match['before_sha256']:
        raise TransitionError('baseline normalized CSG does not match the reviewed before hash')
    if after_hash != match['after_sha256']:
        raise TransitionError('current normalized CSG does not match the reviewed after hash')
    for command in match['invariant_commands']:
        run_invariant(command, root, cache_dir)
    return match['reason']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest='action', required=True)
    validate = subparsers.add_parser('validate')
    validate.add_argument('--manifest', type=Path, required=True)
    check = subparsers.add_parser('check')
    check.add_argument('--manifest', type=Path, required=True)
    check.add_argument('--baseline', required=True)
    check.add_argument('--test', required=True)
    check.add_argument('--before', type=Path, required=True)
    check.add_argument('--after', type=Path, required=True)
    check.add_argument('--root', type=Path, required=True)
    check.add_argument('--cache-dir', type=Path, required=True)
    args = parser.parse_args()
    try:
        entries = read_manifest(args.manifest)
        if args.action == 'check':
            print(verify_transition(entries, args.baseline, args.test, args.before,
                                    args.after, args.root, args.cache_dir))
    except (TransitionError, OSError, json.JSONDecodeError) as error:
        print('Expected-change check rejected: ' + str(error))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
