#!/usr/bin/env bash
# Symlink this repo's files into ~/.claude so edits on either side stay in sync.
# Existing files are moved aside with a timestamped .bak suffix, never overwritten.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.claude"
stamp="$(date +%Y%m%d%H%M%S)"
mkdir -p "$target"

for f in CLAUDE.md settings.json; do
  dest="$target/$f"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$repo/$f" ]; then
    echo "ok       $dest"
    continue
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak.$stamp"
    echo "backup   $dest.bak.$stamp"
  fi
  ln -s "$repo/$f" "$dest"
  echo "linked   $dest -> $repo/$f"
done
