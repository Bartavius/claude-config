#!/usr/bin/env bash
# Status line: model, context used, and a /clear cue at 200k tokens (the CLAUDE.md
# threshold). Tokens, not percent, because quality tracks absolute context size.
# Reads the session JSON Claude Code sends on stdin. Needs jq; prints a hint without it.
input="$(cat)"
command -v jq >/dev/null 2>&1 || { echo "statusline: install jq"; exit 0; }

model="$(jq -r '.model.display_name // "?"' <<<"$input")"
pct="$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)"
tokens="$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")"
dir="$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")"

cue=""
if [ "$tokens" -ge 200000 ]; then
  cue=" · /clear + handoff"
fi

printf '[%s] %s · ctx %s%% (%sk)%s\n' "$model" "${dir##*/}" "$pct" "$((tokens / 1000))" "$cue"
