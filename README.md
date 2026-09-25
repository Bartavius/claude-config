# claude-config

My user-level [Claude Code](https://code.claude.com) setup — the files that live in
`~/.claude/` and apply to every project.

## Install

```sh
git clone https://github.com/Bartavius/claude-config.git ~/Desktop/projects/claude-config
~/Desktop/projects/claude-config/install.sh
```

`install.sh` symlinks `CLAUDE.md` and `settings.json` into `~/.claude/`, moving any
existing file aside as `*.bak.<timestamp>`. Start a new session and run `/status` to
confirm the settings loaded.

## What's here and why

**`settings.json`**

- `model: opus[1m]` — Opus with the 1M-token window as the main model. Projects route
  execution to cheaper models through their own subagent definitions.
- `disableClaudeAiConnectors` — stops claude.ai connectors from syncing into every
  session. Unused connectors still cost context through their tool listings.
- `attribution` — empty strings remove the co-author trailer from commits and the
  attribution line from PR descriptions.
- `permissions.deny` — blocks reading `.env` files and dumping the environment
  (`env`, `printenv`, `export -p`). Secrets that enter the context can't be removed.

**`CLAUDE.md`** — the two rules that hold in every project: never read environment
variable values, never add AI attribution. Everything project-specific belongs in that
project's own `CLAUDE.md` and `.claude/` directory.

## Not included

- `~/.claude/projects/`, `history.jsonl`, sessions, and caches — per-machine state that
  holds conversation transcripts.
- Skills synced from a claude.ai account — they arrive with the account.
- The `caveman` skill — third-party and unlicensed, so install it from its source and
  put it in `~/.claude/skills/caveman/`.
