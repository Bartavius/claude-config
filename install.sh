#!/usr/bin/env bash
# Symlink this repo's files into ~/.claude so edits on either side stay in sync.
# Each agent, command, skill, hook, and rule is linked on its own, so anything already in
# those directories (synced or third-party skills) is left alone. Existing files at a
# target path are moved aside with a timestamped .bak suffix, never overwritten.
# tests/ is not installed.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.claude"
stamp="$(date +%Y%m%d%H%M%S)"

link() {
  local src="$repo/$1" dest="$target/$1"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok       $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak.$stamp"
    echo "backup   $dest.bak.$stamp"
  fi
  ln -s "$src" "$dest"
  echo "linked   $dest -> $src"
}

cd "$repo"
link CLAUDE.md
link settings.json
for f in agents/*.md commands/*.md; do link "$f"; done
for f in hooks/*.sh; do link "$f"; done
for d in skills/*/; do link "${d%/}"; done
find rules -name '*.md' -type f | while read -r f; do link "$f"; done
