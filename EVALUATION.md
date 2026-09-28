# Evaluation against `BENCHMARK.md`

The latest scores of this setup against the criteria in `BENCHMARK.md`, with the
findings behind them and the history of earlier rounds. When re-evaluating, replace
the "Current" sections and add a row to the history table.

## Current: 43 / 50

Evaluated 2026-09-28 on `main` @ `3b2acbb` plus the uncommitted Opus 5.5 / Sonnet 5.5
changes, including the five enabled plugins. Scored by a fresh-context `challenger`
(Opus 5.5, `effort: high`), which judged from the repo, not from the previous round.

### What this round changed

The goal was to make sure the config runs on Claude Opus 5.5 and Claude Sonnet 5.5,
and that its prompts suit them.

- **Models pinned to the 5.5 IDs.** The main model is `claude-opus-5-5[1m]`, and
  `CLAUDE_CODE_SUBAGENT_MODEL` is `claude-sonnet-5-5`. `challenger` and `planner` use
  `claude-opus-5-5`, and `implementer`, `reviewer`, and `researcher` use
  `claude-sonnet-5-5`. `/parallel-review` names `claude-opus-5-5` for high-risk work.
  The aliases already resolve to 5.5 today (code.claude.com/docs/en/model-config), so
  nothing changes now. The pins keep the cheaper 5.5 series when a later release moves
  the alias; they're changed by hand (`CONTRIBUTING.md` §3). `Explore` stays on
  `haiku`, since Haiku 4.5 is the current Haiku.
- **Effort.** Claude Code's default effort on both models is `medium`. On Opus 5.5
  thinking is always on and effort is the only depth control, and the guidance is
  `high` or above for intelligence-sensitive work. `planner` and `challenger` now set
  `effort: high` (the sub-agent docs list `effort` as a frontmatter field).
  Implementation, review, research, and the main session stay at `medium`.
- **Prompts, for Sonnet 5.5's documented behavior:**
  - `implementer`: a syntax-only check, or a command that failed to start, doesn't
    count as verification. Missing dependencies get reported, not installed, because
    slices share one working tree.
  - `researcher`: check specifics against current sources rather than answering from
    training knowledge.
- **Conventions.** `CONTRIBUTING.md` §3 says to pin Opus and Sonnet to full IDs, and says to control depth with `effort`, not "think harder" prose.
  `rules/claude-code-config.md` says when to set `effort`. The orchestrator skill's
  "Match effort to risk" became "Match the orchestration level to risk", so it can't
  be read as the `effort` setting.
- **Audit result.** A prompt audit of every agent, command, skill, rule, and
  `CLAUDE.md` found nothing else dated. There are no retired model names, no
  "think step by step" or "think harder" prose, and no tool-use discouragement. There
  are no update suppressors, and the only caps-emphasis is one "NOT". Kept on purpose:
  `researcher`'s "~600 words" (a context-budget contract for the caller; thinking
  doesn't count toward it) and `reviewer`'s confidence rubric (judgment, not
  arithmetic).

### Mechanical checks

```
json ok
97 passed, 0 failed
all links ok
(broken-link check printed nothing)
CLAUDE.md: 35 lines (budget 50)
unscoped rules: 0
own agents: 6 (budget 8)
enabled plugins: 5
description lengths: test-first 425 (over ~400), all others <= 361
```

Not run: `/context` in a fresh session, and the new `effort` frontmatter hasn't been
observed in a live `/agents` listing. Neither prompt change was behavior-tested, since
the repo has no eval for them.

### Scorecard

| # | Principle | Score | Evidence |
|---|---|:-:|---|
| 1 | Smallest harness | **3** | Own harness is small (6 agents). The caveman and hookify plugins add about 4 agents and 28 skills. `SKILLS.md:17` still lists caveman's overlap as "none". |
| 2 | Context budget | **4** | `CLAUDE.md` is 35 lines, no unscoped rules, and the 200k cue is at `CLAUDE.md:33`. *Not 5:* `test-first` is 425 characters. Plugin skill and agent listings aren't budgeted or measured. |
| 3 | Agents = context control | **5** | Only `implementer` lacks `tools:`, and it's the writer. `CLAUDE.md:25-26` requires files, boundary, and verification. |
| 4 | Model tiering | **5** | Every agent sets `model`, and `CLAUDE_CODE_SUBAGENT_MODEL=claude-sonnet-5-5`. Opus and Sonnet are pinned to 5.5 IDs under one written convention (`CONTRIBUTING.md` §3), with Haiku the stated alias exception, which closes last round's nit. `effort: high` goes only on the two judgment agents. |
| 5 | Creator/verifier separation | **4** | `/orchestrate` ends with a fresh `reviewer`. *Not 5:* outside it, review happens only when someone asks for it. |
| 6 | Risk-matched orchestration | **4** | Levels 0–3 are in `skills/orchestrator/SKILL.md:17-22`. *Not 5:* nothing routes `caveman:caveman-review` or the cavecrew agents. |
| 7 | Enforcement over advice | **4** | Deny rules, a hook with 97 passing tests, and attribution off. *Not 5:* blocking is regex, not a sandbox. |
| 8 | Externalized state | **5** | `handoff-read` checks drift, and `HANDOFF.md` is git-ignored (`~/.config/git/ignore:2`). |
| 9 | Provenance | **5** | Credits are in the README, and all six adapted files carry a provenance line. |
| 10 | Continuous improvement | **4** | *Not 5:* checks run by hand (no CI, no git hook), and `CONTRIBUTING.md` doesn't point to `hookify`. |

**Total: 43 / 50.** Unchanged. The model work fixed last round's finding 4 (one naming convention), but
principle 4 was already at 5, so no score moved. This is the first round where a
fresh-context scorer and the previous self-score agree.

### Findings

1. **Fixed before recording: `implementer` install step** (High). The first draft said
   to install missing dependencies. With parallel slices in one working tree, that
   writes lockfiles and `node_modules` outside any slice and can race. It now says to
   report them instead.
2. **Main-session effort stays at `medium`** (a decision, not a defect). Level 0–1
   work, the "done" call, and `/orchestrate` verification all run in the main
   session. Opus 5.5 guidance says `high` for intelligence-sensitive work. The option
   is `"effortLevel": "high"` in `settings.json`, at higher cost, or `/effort high`
   per session.
3. **Still open from last round:**
   - Caveman triggers compete with `reviewer`, `Explore`, and `root-cause`, with no
     routing.
   - Plugin listings aren't budgeted.
   - `test-first`'s description is over budget.
   - Checks run by hand.

### Recommendations

Options, in order of impact. None have been applied.

1. **Decide caveman's scope:** route it in `skills/orchestrator`, or install it per
   project (principles 1 and 6).
2. **Decide main-session effort:** keep `medium`, or set `effortLevel: "high"`.
3. **Count plugin agents and skills in `CONTRIBUTING.md` §2**, and trim `test-first`'s
   description to under 400 characters.
4. **Optional:** a pre-commit hook for the §5 checks, and a `CONTRIBUTING.md` line
   pointing repeated corrections to `hookify`.

## History

| Date | Commit | Evaluator | Score | Main movement |
|---|---|---|:-:|---|
| 2026-09-25 | `d4467f1` | main session | 37 | Baseline against the two reference repos |
| 2026-09-25 | working tree on `d4467f1` | main session | 45 | Added `reviewer`, `challenger`, the orchestrator dial, the secrets hook and tests, and Credits |
| 2026-09-25 | `646f5ff` + round 2 | main session | 45 | Production-practice changes; no score moved |
| 2026-09-25 | round 2 working tree | fresh `challenger` (Opus) | 43 | Cold audit: 1 High, 7 Medium, 2 Low |
| 2026-09-25 | after audit fixes (`31ff269`) | main session | 45 | 200k-token threshold, risk-based dial, audit fixes; not re-audited |
| 2026-09-25 | `344c9ab` | main session | 43 | Plugins cost 1, 2, and 6; `CONTRIBUTING.md` raised 10 |
| 2026-09-28 | `3b2acbb` + Opus/Sonnet 5.5 changes | fresh `challenger` (Opus 5.5) | 43 | Pinned Opus/Sonnet 5.5 IDs and effort update; closed the naming-convention nit; no score moved |

### Changes made in earlier rounds

- **Opus 5.5 / Sonnet 5.5** (43 to 43): 5.5 model IDs pinned; `effort: high` on `planner` and `challenger`;
  Sonnet 5.5 verification and current-sources lines in `implementer` and `researcher`;
  model and effort conventions in `CONTRIBUTING.md` and the config rule.
- **Round 1** (37 to 45): a fresh-context `reviewer` at the end of `/orchestrate`; the
  `block-secrets.sh` hook with tests; `challenger` and the orchestrator dial with levels
  0–3; a definition of done in `CLAUDE.md`; a read-only `permissions.allow` list; the
  README Credits section; guidance on when to compact.
- **Round 2** (production practice): `statusline.sh` with a context cue; a
  report-only-what-matters bar for `reviewer` and `challenger`; `test-first` and
  `root-cause` skills; a stop-after-two-failed-fixes line and a bulky-output line in
  `CLAUDE.md`; `SKILLS.md`; `researcher`, `/parallel-review`, and `/fix-pr` from
  agents-ecosystem.
- **Audit fixes:** a 200k-token threshold instead of 40% (40% of a 1M window is 400k,
  while practitioners' 40–60% was of ~200k windows); file count as a reason to consider
  `/orchestrate`, not a trigger; slice-scoped checks for parallel implementers;
  recording failing checks before `/orchestrate` launches; written routing for
  overlapping triggers; `/fix-pr` checks for a dirty tree before checkout; `HANDOFF.md`
  in the global git excludes.

### Deliberately not adopted

- agents-ecosystem's neutral-schema/`MAPPING.md` layer (needed only for multiple CLIs)
  and its security-agent trio (niche for a personal default).
- The guide's MCP and compression tooling. With no MCP servers, deferred tool loading
  keeps that cost near zero.
- Sandbox mode, and a CI run of the hook tests. More machinery than they're worth here.
- A PreToolUse hook that rewrites test commands to filter output. It's project
  specific, and a wrong grep silently hides failures.
- A Stop hook that blocks until tests pass. There's no global test command to gate on.
- Trail of Bits' "anti-rationalization" Stop hook. It adds a model call every turn.
- Ralph loops. They cost 20–200x a normal session.
- Worktree commands. The built-in `isolation: "worktree"` covers them.
- Brainstorm/interview skills. They overlap built-in clarifying behavior.
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW`. Its behavior hasn't been verified.
