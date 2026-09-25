# claude-config

My user-level [Claude Code](https://code.claude.com) setup — the files that live in
`~/.claude/` and apply to every project.

## Install

```sh
git clone https://github.com/Bartavius/claude-config.git ~/Desktop/projects/claude-config
~/Desktop/projects/claude-config/install.sh
```

`install.sh` symlinks each file below into the matching place under `~/.claude/`,
moving anything already at that path aside as `*.bak.<timestamp>`. Skills are linked
one directory at a time, so skills you already have are left alone. Start a new
session and run `/status` and `/agents` to confirm everything loaded.

## What's here and why

**`settings.json`**

- `model: opus[1m]` — Opus with the 1M-token window for the main conversation.
- `CLAUDE_CODE_SUBAGENT_MODEL: sonnet` — subagents without their own `model` run on
  Sonnet instead of inheriting Opus.
- `disableClaudeAiConnectors` — stops claude.ai connectors from syncing into every
  session. Unused connectors still cost context through their tool listings.
- `attribution` — empty strings remove the co-author trailer from commits and the
  attribution line from PR descriptions.
- `permissions.deny` — blocks reading `.env` files and dumping the environment
  (`env`, `printenv`, `export -p`). Secrets that enter the context can't be removed.

**`CLAUDE.md`** — rules for every project: no reading environment variable values, no
AI attribution, when to delegate, and what `/compact` should keep.

**`agents/`** — plan with the strongest model, execute and search with cheaper ones.

- `planner` — Opus 5.5, read-only. Returns goal, shared contracts, and file-disjoint
  slices, each with a verification command.
- `implementer` — Sonnet. Builds one slice, touches only its files, reports the real
  verification result.
- `Explore` — Haiku, read-only, skips loading `CLAUDE.md`. Replaces the built-in
  Explore, which otherwise runs on the main conversation's model.

**`commands/orchestrate.md`** — `/orchestrate <task>`: planner → your approval →
parallel implementers → full verification.

**`skills/`** — `handoff` writes `HANDOFF.md` (goal, findings, dead ends, next action)
so the next session starts without re-deriving anything; `handoff-read` checks it
against the repo and resumes.

**`rules/`** — linked into `~/.claude/rules/`. A rule with `paths:` frontmatter loads
only when Claude reads a file matching one of its globs. A rule without frontmatter
loads every session, the same as `CLAUDE.md`. `claude-code-config.md` holds the
conventions for writing agents, skills, commands, rules, and settings, and loads only
when one of those files is opened. That keeps it out of every other session.

This repo's own `.claude/rules/repo-layout.md` is not installed. It reminds Claude that
edits here are global and that `install.sh` and this README need to stay in sync.

A project's own `.claude/agents/` or `.claude/commands/` file with the same name
overrides these, which is the place for repo-specific variants.

## Not included

- `~/.claude/projects/` (auto-memory), `history.jsonl`, sessions, and caches —
  per-machine state that holds project details and conversation transcripts.
- Skills synced from a claude.ai account — they arrive with the account, and several
  are licensed "all rights reserved".
- The `caveman` skill — third-party and unlicensed, so install it from its source and
  put it in `~/.claude/skills/caveman/`.
