#!/usr/bin/env python3
"""Replace import timestamps with source-byte hashes in normalized CSG.

An asset's modification time changes when Git creates a baseline worktree.
Its bytes determine the imported geometry, so compare those instead. Paths
remain in the output; this does not equate differently named assets.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

# Quoted strings are consumed whole before looking for parameter names. A file
# or layer name containing the word "timestamp" must not be rewritten.
TOKENS = re.compile(r'(?P<string>"(?:\\.|[^"\\])*")'
                    r'|(?P<file>\bfile\s*=\s*)'
                    r'|(?P<timestamp>\btimestamp\s*=\s*[-+]?\d+(?:\.\d+)?)')


def normalize_import(line, source, hashes):
    if not re.match(r'\s*import\s*\(', line):
        return line
    tokens = list(TOKENS.finditer(line))
    file_tokens = [index for index, token in enumerate(tokens) if token.lastgroup == 'file']
    if len(file_tokens) != 1:
        raise ValueError('import must have exactly one literal file parameter')
    index = file_tokens[0]
    if (index + 1 >= len(tokens) or tokens[index + 1].lastgroup != 'string'
            or tokens[index].end() != tokens[index + 1].start()):
        raise ValueError('cannot resolve nonliteral import file parameter')
    asset_name = json.loads(tokens[index + 1].group())
    if not asset_name:
        raise ValueError('cannot resolve empty import file parameter')
    asset = Path(asset_name)
    if not asset.is_absolute():
        asset = source.parent / asset
    asset = asset.resolve(strict=True)
    if asset not in hashes:
        digest = hashlib.sha256()
        with asset.open('rb') as contents:
            for block in iter(lambda: contents.read(1024 * 1024), b''):
                digest.update(block)
        hashes[asset] = digest.hexdigest()
    replacement = 'asset_sha256 = "' + hashes[asset] + '"'
    stamps = [token for token in tokens if token.lastgroup == 'timestamp']
    if len(stamps) > 1:
        raise ValueError('import has multiple timestamp parameters')
    if stamps:
        stamp = stamps[0]
        return line[:stamp.start()] + replacement + line[stamp.end():]
    # Some OpenSCAD versions omit the timestamp. Still include an asset hash,
    # because equal filenames alone must never conceal a changed outline.
    closing = re.search(r'\)\s*;\s*$', line)
    if not closing:
        raise ValueError('cannot find end of serialized import')
    return line[:closing.start()] + ', ' + replacement + line[closing.start():]


def normalize_stream(lines, source):
    hashes = {}
    for line in lines:
        yield normalize_import(line, source, hashes)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True,
                        help='Source fixture; relative imports resolve from its parent directory')
    args = parser.parse_args()
    try:
        for line in normalize_stream(sys.stdin, args.source.resolve(strict=True)):
            sys.stdout.write(line)
    except (OSError, ValueError) as error:
        print('CSG asset normalization failed for ' + str(args.source) + ': ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
