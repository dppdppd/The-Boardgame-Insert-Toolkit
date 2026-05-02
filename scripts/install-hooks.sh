#!/usr/bin/env bash
# Point git at the tracked hooks directory so the pre-commit version stamper
# runs automatically. Run once per clone.
set -e

cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath scripts/hooks
echo "Installed: core.hooksPath = scripts/hooks"
echo "  - pre-commit: stamps VERSION = 4.0.<commits-since-v4.0.0+1> into the lib"
