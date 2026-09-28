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

- `model: claude-opus-5-5[1m]` — Opus 5.5 with the 1M-token window for the main
  conversation. Effort is left at Claude Code's default (`medium`); change it per
  session with `/effort`.
- `CLAUDE_CODE_SUBAGENT_MODEL: claude-sonnet-5-5` — subagents without their own `model`
  run on Sonnet 5.5 instead of inheriting Opus.
- Opus and Sonnet are pinned to the 5.5 IDs rather than the `opus`/`sonnet` aliases,
  because the 5.5 series is cheaper per token; a pin keeps it that way when a new
  release moves the alias. Update the IDs by hand when switching.
- `CAVEMAN_DEFAULT_MODE: off` — the caveman plugin otherwise switches every session
  to terse output at start; with this, it's on only when you invoke it.
- `disableClaudeAiConnectors` — stops claude.ai connectors from syncing into every
  session. Unused connectors still cost context through their tool listings.
- `statusLine` — runs `statusline.sh` (below), so context usage is always visible.
- `attribution` — empty strings remove the co-author trailer from commits and the
  attribution line from PR descriptions.
- `permissions.defaultMode: default` — sessions start in manual mode, asking before
  edits and commands outside the allowlist. Switch modes per session with Shift+Tab.
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
- `enabledPlugins` / `extraKnownMarketplaces` — the third-party plugins from `SKILLS.md`
  that are in use: `typescript-lsp` and `pyright-lsp` (go-to-definition instead of
  grep), `hookify`, `security-guidance`, and `caveman`. Keeping them here means a fresh
  machine gets the same set; `claude plugin install` writes these keys itself.

**`CLAUDE.md`** — rules for every project: no reading environment variable values, no
AI attribution, when to delegate, a definition of done (don't report finished until
the project's own checks have run and passed, output shown), stopping after two failed
fixes instead of trying a third variant, keeping bulky command output out of context
(quiet flags, `tail`/grep, subagent summaries), and choosing the orchestration level
by risk rather than file count. Also the one-writer-per-file rule (see
`skills/orchestrator`), sending research to `researcher` rather than `general-purpose`,
and `/clear` plus a handoff by around 200k tokens or between unrelated tasks. That
threshold is in tokens because context quality tracks absolute size, not the percentage
of a 1M window.

**`agents/`** — plan with the strongest model, execute and search with cheaper ones,
and verify with a fresh context that didn't write the code.

- `planner` — Opus 5.5 at `effort: high`, read-only. Returns goal,
  shared contracts, and file-disjoint slices, each with a verification command.
- `implementer` — Sonnet 5.5. Builds one slice, touches only its files, reports the real
  verification result.
- `Explore` — Haiku, read-only, skips loading `CLAUDE.md`. Replaces the built-in
  Explore, which otherwise runs on the main conversation's model.
- `reviewer` — Sonnet 5.5, read-only, fresh context. Given the requirements and a base
  ref, it runs the diff itself and returns pass/fail/unverified per requirement with
  evidence, instead of trusting the implementer's own account of the work.
- `challenger` — Opus 5.5 at `effort: high`, read-only. Pressure-tests a plan, an analysis, or a piece of
  reasoning before it's acted on — not line-level code.
- `researcher` — Sonnet 5.5, read-only, with web access. Returns a short brief on external
  docs, APIs, licenses, or how others do something. Each finding has a source and date,
  and is marked verified or secondhand. It exists so research doesn't need
  `general-purpose`, which can write files.

**`commands/`**

- `/orchestrate <task>` — planner → your approval → parallel implementers → full
  verification, then fresh-context review. The reviewer checks the diff against the
  original requirements; blockers get fixed and re-verified.
- `/parallel-review [scope] [autofix]` — orchestration level 2 as a command: three
  fresh-context reviewers, each with its own angle, sorted into fix now / optional /
  ignore. It exists so a thorough review of finished work doesn't depend on Claude
  choosing to do it.
- `/fix-pr <pr>` — on an existing PR's branch, fixes unresolved review threads and
  failing checks. It greps failed CI logs for the error lines instead of taking their
  tail, because the tail is post-job cleanup. Then it verifies, and reports each
  item as fixed, declined, or couldn't reproduce. It doesn't commit, push, or reply on
  the PR unless you ask.

**`skills/`** — `handoff` writes `HANDOFF.md` (goal, findings, dead ends, next action)
so the next session starts without re-deriving anything; `handoff-read` checks it
against the repo and resumes. `orchestrator` is a dial for picking the lowest
orchestration level that fits — direct, one challenger or reviewer, several
fresh-context reviewers, or full `/orchestrate` — plus the rule that each file has one
writer at a time. `test-first` runs a red/green loop: a test has to fail for the right
reason before any code is written, and the full suite runs at the end. `root-cause` goes
reproduce → narrow → one hypothesis at a time → fix the root cause, and stops after two
failed fixes. Both exist because verification, not code generation, is where agent
output usually goes wrong (see `BENCHMARK.md` principle 5).

**`statusline.sh`** — shows the model, the directory, and how much of the context
window is used (percent and tokens), and adds a `/clear` + handoff cue at 200k tokens, the
threshold `CLAUDE.md` sets. Without it, that threshold can't be seen. Needs `jq`.

**`BENCHMARK.md`** — not installed. The criteria only: 10 design principles drawn from
reference setups and production practice, each with a 1–5 rubric and the tests that
decide it, plus the mechanical checks to run. It exists so changes to this config are
judged against stated principles rather than taste.

**`EVALUATION.md`** — not installed. The latest scores against `BENCHMARK.md`, with
evidence, findings, and recommendations, plus a history of earlier rounds and what was
deliberately left out. Kept apart so the criteria don't shift with each evaluation.

**`CONTRIBUTING.md`** — not installed. The checklist for any addition, edit, or
removal: what a new component must prove, context budgets for what loads every
session, how to remove things cleanly, and the checks to run before calling a change
done. It exists so the setup stays small as it changes. `.claude/rules/repo-layout.md`
points Claude to it when config files are edited.

**`SKILLS.md`** — not installed. Third-party skills and plugins worth installing
yourself, with license, install command, and which part of this setup each overlaps.

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

`BENCHMARK.md` draws its design principles partly from two reference ecosystems; the
entries below are what came out of comparing this setup against them.

### Adapted with the author's permission

`agents/reviewer.md`, `agents/challenger.md`, `agents/researcher.md`,
`commands/parallel-review.md`, `commands/fix-pr.md`, and `skills/orchestrator/SKILL.md`
are adapted, with permission, from Anish Sahoo's
[agents-ecosystem](https://github.com/anish-sahoo/agents-ecosystem) (snapshot
`70118dd`). His permission covers the whole repo. `researcher`, `parallel-review`, and
`fix-pr` were rewritten rather than copied:

- `researcher` marks each finding verified or secondhand, and is shorter.
- `parallel-review` uses `reviewer` for all three angles, and has reviewers run the
  diff from a base ref themselves.
- `fix-pr` finds open threads through GraphQL and trims CI logs.

### Ideas only, paraphrased and cited in `BENCHMARK.md`

Design principles from
[FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)
(snapshot `06b3523`, CC BY-SA 4.0) shaped several decisions here. No text was copied
verbatim; `BENCHMARK.md` cites each point back to its source.

### Evaluated, not adopted

- `oracle` — overlaps `challenger`.
- `style-reviewer` — overlaps the built-in `/simplify` and the definition of done's lint
  run.
- Commands `plz-ship`, `plz-plan-feature`, `plz-review-loop` — covered by `/orchestrate`
  and `/parallel-review … autofix`. `plz-security-audit` needs the security trio below;
  the built-in `/security-review` covers it. `plz-parallel-research` — two `researcher`s
  plus `Explore` do it without a command. `plz-help` — a router that isn't worth it for
  four commands. `plz-grill-me` — overlaps built-in clarifying questions, and would
  rarely be reached for.
- `preferences/working-rules.md` — already covered by `CLAUDE.md` and the harness, or
  personal to its author (merge over rebase, humanizer on all output).
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
- The `caveman` skill and other third-party skills — see `SKILLS.md` for what to
  install and how.
