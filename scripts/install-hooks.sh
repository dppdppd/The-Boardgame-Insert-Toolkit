#!/usr/bin/env bash
# Point git at the tracked hooks directory so the pre-commit version stamper
# runs automatically. Run once per clone.
set -e

cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath scripts/hooks
echo "Installed: core.hooksPath = scripts/hooks"
echo "  - pre-commit: compares normalized CSG against HEAD, then stamps VERSION"
echo "  - set BIT_VERSION_BUMP=minor for feature releases"
echo "  - set BIT_SKIP_CSG_REGRESSION=1 to bypass the local CSG comparison"
