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
one directory at a time, so skills you already have are left alone; hooks are linked
the same way, one script at a time. Start a new session and run `/status` and
`/agents` to confirm everything loaded.

## What's here and why

**`settings.json`**

- `model: opus[1m]` — Opus with the 1M-token window for the main conversation.
- `CLAUDE_CODE_SUBAGENT_MODEL: sonnet` — subagents without their own `model` run on
  Sonnet instead of inheriting Opus.
- `disableClaudeAiConnectors` — stops claude.ai connectors from syncing into every
  session. Unused connectors still cost context through their tool listings.
- `attribution` — empty strings remove the co-author trailer from commits and the
  attribution line from PR descriptions.
- `permissions.allow` — read-only commands (`git status`/`diff`/`log`/`show`/
  `ls-files`/`blame`/`rev-parse`, `git branch --show-current`, `ls`, `rg`, `wc`, `pwd`,
  `which`) that don't need a prompt every time, so approvals stay reserved for things
  that actually change something.
- `permissions.deny` — blocks reading `.env` files and dumping the environment
  (`env`, `printenv`, `export -p`); secrets that enter the context can't be removed.
  Also denies `git … --output` and `rg --pre` in any argument position, because those flags
  would let an otherwise read-only, allowed command write a file or run a program.
- `hooks` — registers `block-secrets.sh` (see `hooks/` below) as a `PreToolUse` hook
  on `Bash`, so the secrets rule is enforced rather than just advised.

**`CLAUDE.md`** — rules for every project: no reading environment variable values, no
AI attribution, when to delegate, a definition of done (don't report finished until
the project's own checks have run and passed, output shown), the orchestration levels
and the one-writer-per-file rule (see `skills/orchestrator`), and when to compact
(around 65% full, or `/clear` plus a handoff between unrelated tasks).

**`agents/`** — plan with the strongest model, execute and search with cheaper ones,
and verify with a fresh context that didn't write the code.

- `planner` — Opus 5.5 (pinned to `claude-opus-5-5`), read-only. Returns goal,
  shared contracts, and file-disjoint slices, each with a verification command.
- `implementer` — Sonnet. Builds one slice, touches only its files, reports the real
  verification result.
- `Explore` — Haiku, read-only, skips loading `CLAUDE.md`. Replaces the built-in
  Explore, which otherwise runs on the main conversation's model.
- `reviewer` — Sonnet, read-only, fresh context. Given the requirements and a base
  ref, it runs the diff itself and returns pass/fail/unverified per requirement with
  evidence, instead of trusting the implementer's own account of the work.
- `challenger` — Opus, read-only. Pressure-tests a plan, an analysis, or a piece of
  reasoning before it's acted on — not line-level code.

**`commands/orchestrate.md`** — `/orchestrate <task>`: planner → your approval →
parallel implementers → full verification, then fresh-context review. The reviewer
checks the diff against the original requirements; blockers get fixed and
re-verified.

**`skills/`** — `handoff` writes `HANDOFF.md` (goal, findings, dead ends, next action)
so the next session starts without re-deriving anything; `handoff-read` checks it
against the repo and resumes. `orchestrator` is a dial for picking the lowest
orchestration level that fits — direct, one challenger or reviewer, several
fresh-context reviewers, or full `/orchestrate` — plus the rule that each file has one
writer at a time.

**`hooks/`** — linked into `~/.claude/hooks/`. `block-secrets.sh` is a `PreToolUse`
hook on `Bash` that blocks commands printing environment values (`env`, `printenv`,
`export`/`set`/`declare`/`typeset` dumps, `echo`/`printf` of `$VAR`s), reading `.env`
files (`cat`, `sed`, `awk`, `grep`, `rg`, `source`, `< .env` and similar), and
interpreter one-liners or heredocs that touch `os.environ`, `process.env`, `ENV` and the
like. It matches only where a command starts: after a separator, `$(`, `-c`, `eval`, or
`-exec`, and past assignments (`X=1`), keywords (`do`, `if`), wrappers and their
options (`sudo -u root`, `timeout 5`, `env -i`), and path or backslash prefixes
(`/usr/bin/env`, `\env`). So `ls env`, `python -m venv env` and `rg 'export' src/`
still run. It exists because permission deny rules only match exact command prefixes,
so `CLAUDE.md` was the only thing stopping `echo $VAR`. Heredoc bodies such as PR
descriptions and commit messages are treated as text, unless the heredoc feeds a shell
(`bash <<EOF`, `| sh`). Written for bash 3.2 with BSD `grep`/`sed`/`awk`, no `jq` or
`python`, and adds about 20 ms per command. `bash tests/block-secrets.test.sh` covers
97 cases.

It's a guard rail, not a sandbox. Known gaps:

- `git show HEAD:.env`, recursive searches that include `.env` (`grep -r`, `rg -uu`),
  and globs like `cat .en*`.
- a script file that reads the environment, and interpreters it doesn't list.
- wrapper forms it doesn't parse, such as `sudo` options whose value looks like a
  command.
- heredocs sent to a remote shell (`ssh host <<EOF`), whose body is treated as text.

Known false positives: any `echo` of an uppercase variable, including harmless ones
like `$HOME` or `${PIPESTATUS[0]}`, and `grep -c "set"`-style arguments.

**`tests/`** — not installed; these test the config itself, not a project.
`block-secrets.test.sh` exercises the hook's blocked and allowed cases. Run it with
`bash tests/block-secrets.test.sh`.

**`rules/`** — linked into `~/.claude/rules/`. A rule with `paths:` frontmatter loads
only when Claude reads a file matching one of its globs. A rule without frontmatter
loads every session, the same as `CLAUDE.md`. `claude-code-config.md` holds the
conventions for writing agents, skills, commands, rules, and settings, and loads only
when one of those files is opened. That keeps it out of every other session.

This repo's own `.claude/rules/repo-layout.md` is not installed. It reminds Claude that
edits here are global and that `install.sh` and this README need to stay in sync.

A project's own `.claude/agents/` or `.claude/commands/` file with the same name
overrides these, which is the place for repo-specific variants.

## Credits

`BENCHMARK.md` compares this setup's design principles against two reference
ecosystems; the entries below are what came out of that comparison.

### Adapted with the author's permission

`agents/reviewer.md`, `agents/challenger.md`, and `skills/orchestrator/SKILL.md` are
adapted, with permission, from Anish Sahoo's
[agents-ecosystem](https://github.com/anish-sahoo/agents-ecosystem) (snapshot
`70118dd`).

### Ideas only, paraphrased and cited in `BENCHMARK.md`

Design principles from
[FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)
(snapshot `06b3523`, CC BY-SA 4.0) shaped several decisions here. No text was copied
verbatim; `BENCHMARK.md` cites each point back to its source.

### Evaluated, not adopted

- `oracle` — overlaps `challenger`.
- `humanizer` — third-party (MIT), niche, 473 lines.
- `ask-questions-if-underspecified` — third-party, CC BY-SA share-alike, overlaps
  built-in clarifying behavior.
- The security-agent trio (`pentester`, `security-auditor`, `secrets-deps-scanner`) —
  niche for a personal default.
- The `MAPPING.md` neutral schema — solves a multi-CLI problem this setup doesn't
  have.

## Not included

- `~/.claude/projects/` (auto-memory), `history.jsonl`, sessions, and caches —
  per-machine state that holds project details and conversation transcripts.
- Skills synced from a claude.ai account — they arrive with the account, and several
  are licensed "all rights reserved".
- The `caveman` skill — third-party and unlicensed, so install it from its source and
  put it in `~/.claude/skills/caveman/`.
