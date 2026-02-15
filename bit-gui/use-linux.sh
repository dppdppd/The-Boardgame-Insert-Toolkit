#!/bin/bash
# Switch node_modules to Linux platform
cd "$(dirname "$0")"

# Save current if it's Windows
if [ -d node_modules ] && [ ! -L node_modules ]; then
  if [ -f node_modules/electron/dist/electron.exe ]; then
    echo "Saving Windows node_modules..."
    rm -rf node_modules_win
    mv node_modules node_modules_win
  fi
fi

# Remove symlink/dir if exists
rm -rf node_modules 2>/dev/null

if [ -d node_modules_linux ]; then
  ln -s node_modules_linux node_modules
  echo "Linked node_modules -> node_modules_linux"
else
  echo "Installing for Linux..."
  mkdir -p node_modules_linux
  ln -s node_modules_linux node_modules
  npm install
fi
