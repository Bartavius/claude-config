# Changing this setup

Follow this for any addition, removal, or edit to a file that `install.sh` links into
`~/.claude/`, and for plugins and marketplaces enabled in `settings.json`. Every change
here reaches every project's sessions at once, and anything that loads into every
session costs tokens in all of them. The goal is the smallest setup that does the job
well. `BENCHMARK.md` explains the principles behind these rules. This file is the
checklist.

## 1. Earn a place before adding anything

A new component has to pass all four of these checks:

1. **A real problem.** You hit it at least twice, or once at real cost, such as lost
   work or a leaked secret. "Might be useful" doesn't count.
2. **Not already covered.** Check the built-ins listed in `SKILLS.md` ("Already built
   in"), the existing agents, skills, and commands, and the installed plugins
   (`claude plugin list`). If one of them is close, change it instead of adding a new
   one.
3. **The lightest mechanism that works.** Go down this list and stop at the first one
   that does the job:
   1. Change nothing, and say it in the prompt that session.
   2. Edit an existing file.
   3. Add a path-scoped rule, so it loads only when matching files are read.
   4. Add a skill (reusable instructions, loaded on demand) or a command (a
      workflow you invoke yourself).
   5. Add an agent, only when the work needs its own context: parallel work, a fresh
      perspective, or keeping bulky output out of the main session.
   6. Add a hook or a permission rule, only for something that must never happen.
      Instructions only advise.
   7. Add a plugin or an MCP server, only for a remote service with no CLI, or a
      capability you can't write yourself (an LSP, for example).
4. **Clear ownership.** Say what it replaces or what it will be removed alongside. If
   it overlaps something that exists, remove or narrow the old one in the same change.

## 2. Context budgets

These load in every session, so they have hard limits. The baseline on 2026-09-25 is
in parentheses.

| What | Limit | Baseline |
|---|---|---|
| `CLAUDE.md` | 50 lines. Only instructions that change behavior. | 35 lines |
| Unscoped rules (no `paths:`) | None. Put it in `CLAUDE.md` or scope it. | 0 |
| One agent or skill `description` | About 400 characters. What it does, when to use it, and the phrases a user types. | 130–440 |
| Agents | 8. Past that, merge agents or drop one. | 6 |
| Enabled plugins | Each one listed in `SKILLS.md` with a reason, and each one checked for trigger overlap | 5 |
| MCP servers | 0, unless no CLI can do the job | 0 |

Anything else (reference material, examples, long procedures) goes in a file next to
`SKILL.md` and is read only when needed. Moving text out of `CLAUDE.md` into a skill
or scoped rule is always allowed. Moving it the other way needs a reason.

## 3. Editing what exists

- **Triggers.** Changing a `description` changes when something fires. Check the new
  wording against every other description, including plugin skills, so that no two
  compete for the same phrase ("review this", "plan this", "debug this").
- **Models.** Opus for planning and judgment, Sonnet for implementation, Haiku for
  search. Keep the alias convention the other agents use.
- **Tools and permissions.** Read-only agents get an explicit `tools:` list without
  Write or Edit. Keep `allowed-tools` and `permissions.allow` narrow
  (`Bash(git status:*)`, not `Bash`). Never widen a deny rule to fix a prompt.
- **Hooks.** One script, no network calls, and quick enough that you don't notice it
  on every call. Any change to `block-secrets.sh` comes with a new case in
  `tests/block-secrets.test.sh`.
- **Plugin commands edit this repo.** `claude plugin install` and `/plugin` write
  `enabledPlugins` into `settings.json` through the symlink and can reorder its keys.
  Check `git diff settings.json` after each install and put the key order back.
- The file-level conventions (frontmatter, `paths:`, subagent prompts) are in
  `rules/claude-code-config.md` and load when you open one of these files.

## 4. Removing things

Remove anything that:

- a built-in or an installed plugin now does as well,
- hasn't been used in about a month (check with `/context` and your own recall),
- keeps needing corrections that end up in `CLAUDE.md`, or
- competes with something else for the same trigger.

`install.sh` only adds links, it never removes them. After deleting a file, remove its
symlink from `~/.claude/` too, then run the broken-link check below. Remove a plugin
with `claude plugin uninstall <name>`, then make sure `settings.json` no longer lists it.

## 5. Verify before calling it done

Run these from the repo root. All of them must pass:

```sh
python3 -m json.tool settings.json >/dev/null && echo "json ok"
bash tests/block-secrets.test.sh | tail -1               # 0 failed
./install.sh | grep -v '^ok' || echo "all links ok"      # no new backups
find ~/.claude -maxdepth 3 -type l ! -exec test -e {} \; -print   # prints nothing
```

Then start a new session and check:

- `/context`: the always-loaded share didn't grow more than the change explains.
- For a new or reworded agent or skill, try one prompt that should trigger it and one
  similar prompt that shouldn't.
- `/agents`, `/plugin`, and `/status` list what you expect.

For changes to hooks, permissions, or `settings.json`, get a fresh-context `reviewer`
to check the diff before merging.

## 6. Keep the docs in step

In the same change:

- **README "What's here and why"**: add, update, or remove the entry, including the
  reason it exists.
- **`SKILLS.md`**: any third-party skill or plugin, with its license and overlaps.
- **`BENCHMARK.md`**: only when a change affects a principle or its score.
- **Credits**: where any borrowed text came from, with snapshot and license.

## 7. Scope discipline

One purpose per change or PR. Once the change works and the checks pass, stop.
Further hardening, extra review rounds, or "while I'm here" additions go in a new
change, which passes section 1 on its own.
