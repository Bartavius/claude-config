# Skills and plugins worth installing

These are third-party, so this repo doesn't vendor them. Install the ones you want
yourself. Each entry says what it overlaps with here, so you don't end up with two
things competing for the same trigger. Checked 2026-09-25. Licenses and install
commands change, so check the repo before installing.

Overlap key: **H** `handoff`, **R** `reviewer`, **P** `planner`/`challenger`,
**O** `/orchestrate`, **D** `root-cause`/`test-first`.

## Recommended

| What | Why | License | Install | Overlaps |
|---|---|---|---|---|
| A code-intelligence (LSP) plugin for your main language | Go-to-definition and references replace grep plus reading many files. Anthropic's costs page lists this as a token saver. | varies | `/plugin`, then search your language | none |
| [anthropics/skills](https://github.com/anthropics/skills) `document-skills` | Reading and writing docx/pdf/pptx/xlsx. Loaded only when a task involves one. | Apache-2.0, but the document skills are source-available | `/plugin marketplace add anthropics/skills` then `/plugin install document-skills@anthropic-agent-skills` | none |
| [caveman](https://github.com/JuliusBrussee/caveman) | Terse output mode for long sessions where you want less prose. You invoke it; it never triggers on its own. | MIT (skill); BSL-1.1 (proxy) | `claude plugin marketplace add JuliusBrussee/caveman` then `claude plugin install caveman@caveman` | none (its bundled review/spec skills partly overlap R, P) |

## Situational

Worth it for a specific need. Most overlap what's here, so install one only if you
want its version of that workflow instead.

| What | Use it for | License | Install | Overlaps |
|---|---|---|---|---|
| [anthropics/claude-code plugins](https://github.com/anthropics/claude-code/tree/main/plugins): `pr-review-toolkit` | Six aspect reviewers (silent failures, type design, test coverage, comments…) when a PR needs more angles than one `reviewer` | Anthropic Commercial ToS | `/plugin` → official marketplace | R |
| same: `hookify` | Turning a behavior you keep correcting into a hook rule | Anthropic Commercial ToS | `/plugin` → official marketplace | none |
| same: `security-guidance` | Warnings on edits that add `eval`, `os.system`, `pickle`, `innerHTML` and similar | Anthropic Commercial ToS | `/plugin` → official marketplace | none |
| [trailofbits/skills](https://github.com/trailofbits/skills) | Security auditing, static analysis, property-based and mutation testing | CC BY-SA 4.0 | `/plugin marketplace add trailofbits/skills` then `/plugin menu` | R (differential review) |
| [obra/superpowers](https://github.com/obra/superpowers) | A full opinionated workflow: brainstorm, plan, TDD, debug, verify, review | MIT | `/plugin marketplace add obra/superpowers-marketplace` then `/plugin install superpowers@superpowers-marketplace` | R, P, O, D |
| [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | A brainstorm → plan → work → review → "compound lessons" loop | MIT | `/plugin marketplace add EveryInc/compound-engineering-plugin` then `/plugin install compound-engineering` | R, P, O, part of H |

superpowers and compound-engineering replace this setup's workflow rather than
adding to it. Running either alongside `/orchestrate` gives two skills competing for
"plan this" and "review this". If you try one, do it in a project-level install.

## Already built in, so no need to install

`/code-review` (bug review in a fresh subagent), `/simplify`, `/security-review`,
`/context` and `/usage` (what's using tokens), `/btw` (side question kept out of
history), `/rewind` (partial compaction), and `isolation: "worktree"` for subagents.

## Looked at, not recommended

- **ykdojo/claude-code-tips.** Good reading, but it's all rights reserved, and its
  `/handoff` duplicates H.
- **trailofbits/claude-code-config.** A reference config to read, not install. Its
  LICENSE file wasn't found, so don't copy from it. Its ideas are summarized in
  `BENCHMARK.md`.
- **Anthropic `ralph-wiggum` and other "loop until done" Stop hooks.** They're for
  unattended runs and cost many times more tokens than a normal session.
