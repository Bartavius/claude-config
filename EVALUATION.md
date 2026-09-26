# Evaluation against `BENCHMARK.md`

The latest scores of this setup against the criteria in `BENCHMARK.md`, with the
findings behind them and the history of earlier rounds. When re-evaluating, replace
the "Current" sections and add a row to the history table.

## Current: 43 / 50

Evaluated 2026-09-25 on `config-guidelines` @ `344c9ab`, including the five enabled
plugins. Scored in the main session, not by a fresh-context `challenger`. A cold audit
may score it differently (the last one came in 2 points lower than the self-score).

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
```

Not run: `/context` in a fresh session, so the always-loaded token cost of plugin
listings is estimated from the skill and agent listing, not measured.

### Scorecard

| # | Principle | Score | Evidence |
|---|---|:-:|---|
| 1 | Smallest harness | **3** | The repo's own harness is small: 6 agents, 3 commands, 5 skills, 1 scoped rule, 1 hook. The plugins add about 30 more. `caveman` brings ~24 skills and 3 agents, and `hookify` brings 4 skills and 1 agent. That makes 10 non-built-in agents against the 8 in `CONTRIBUTING.md`, though that budget doesn't say whether plugin agents count. Several plugin components compete with this repo's (finding 1), and `SKILLS.md` lists caveman's overlap as "none" apart from R and P. |
| 2 | Context budget | **4** | `CLAUDE.md` is 35 of 50 lines and behavior-only. No unscoped rules. `statusline.sh` shows tokens and cues `/clear` plus handoff at 200k. `CLAUDE.md` has a bulky-output rule. *Not 5:* plugin skill and agent descriptions load every session, `CONTRIBUTING.md`'s budgets don't cover them, and they weren't measured. `test-first`'s description is 427 characters, over the ~400 guideline. |
| 3 | Agents = context control | **5** | Each agent states what it receives, may touch, and returns. Only `implementer` has no `tools:` list, and it's the writer. `CLAUDE.md` requires files, boundary, and verification for every delegation. |
| 4 | Model tiering | **5** | Opus for `planner` and `challenger`, Sonnet for `implementer`, `reviewer`, and `researcher`, Haiku for `Explore`. `CLAUDE_CODE_SUBAGENT_MODEL=sonnet`. `planner` is pinned to `claude-opus-5-5` by user choice, which the README records. *Nit:* `CONTRIBUTING.md` §3 says "keep the alias convention" without naming that exception. |
| 5 | Creator/verifier separation | **4** | `/orchestrate` ends with a fresh `reviewer` that returns PASS/FAIL/UNVERIFIED per requirement. `/parallel-review` makes level 2 a command. `CLAUDE.md` has a definition of done. `test-first` and `root-cause` exist. *Not 5:* outside `/orchestrate`, review happens only when invoked or chosen, and reviewer and author share a model family. |
| 6 | Risk-matched orchestration | **4** | `skills/orchestrator` defines levels 0–3, and `CLAUDE.md` says to pick the lowest that fits, by risk and not file count. *Not 5:* "review this PR" or "review the diff" now matches `reviewer`, `/parallel-review`, the built-in `/code-review`, `caveman:caveman-review`, and `caveman:cavecrew-reviewer`, and no routing covers the caveman ones. |
| 7 | Enforcement over advice | **4** | Attribution is off in `settings.json`. Deny rules plus `hooks/block-secrets.sh` enforce the env-var rule (97 passing cases). `permissions.allow` holds read-only commands, and denies close the `--output`/`--pre` escapes. `security-guidance` warns on risky edits. *Not 5:* regex, not a sandbox (README lists the known gaps). The one-writer rule is advice, because read-only agents still have Bash. |
| 8 | Externalized state | **5** | `handoff` and `handoff-read` record goal, dead ends, and next action, and check branch and HEAD for drift. `HANDOFF.md` is git-ignored (`~/.config/git/ignore:2`). The current `HANDOFF.md` is from `production-practice` @ `31ff269`, which is stale, and `handoff-read` would flag it. |
| 9 | Provenance | **5** | README "Credits" separates adapted-with-permission, ideas-only, and evaluated-not-adopted material, with snapshots and licenses. All six adapted files carry a provenance line. `SKILLS.md` lists license and install for each third-party plugin. |
| 10 | Continuous improvement | **4** | `CONTRIBUTING.md` adds an admission test, context budgets, removal criteria, and a verification checklist that covers the config itself (JSON, hook tests, install dry-run, broken links). `hookify` turns a repeated correction into a hook rule. *Not 5:* nothing runs the checks automatically (no CI, no git hook), and `CONTRIBUTING.md` doesn't point to `hookify` as the path from repeated correction to rule. |

**Total: 43 / 50.** Down 2 from 45. Principles 1, 2, and 6 fell because of the plugins
added in `e57ed2a`. Principle 10 rose because of `CONTRIBUTING.md`.

### Findings

1. **Plugin triggers compete with this repo's** (principles 1 and 6). From the
   session's skill and agent listing:
   - review: `caveman:caveman-review` and `caveman:cavecrew-reviewer` vs `reviewer`,
     `/parallel-review`, and `/code-review`
   - search: `caveman:caveman-explore` and `caveman:cavecrew-investigator` vs
     `Explore`. The `caveman:cavecrew` skill says to use its agents instead of
     `Explore`.
   - debugging: `caveman:investigate-first` vs `root-cause`
   - done-checks: `caveman:verify-and-stop` vs the definition of done in `CLAUDE.md`

   `CONTRIBUTING.md` §3–4 say to resolve overlaps like these. `SKILLS.md` understates
   them.
2. **Budgets don't cover plugins** (principle 2). `CONTRIBUTING.md` §2 caps own agents
   and descriptions, but plugin skills and agents load into the same listing and
   aren't counted.
3. **One description over budget** (principle 2). `skills/test-first/SKILL.md` has 427
   characters against about 400.
4. **Model convention wording** (principle 4). `CONTRIBUTING.md` §3 says "keep the
   alias convention", but `planner` is pinned on purpose.
5. **Checks run by hand** (principle 10). The `CONTRIBUTING.md` §5 commands have no
   automatic runner.

### Recommendations

Options, in order of impact. None of them have been applied.

1. **Decide caveman's scope.** One option: keep the plugin, fix its `SKILLS.md`
   overlap entry, and add routing lines to `skills/orchestrator` (for example, caveman
   review and cavecrew agents only when caveman mode is on). The other: install
   caveman per project instead of globally. Either one addresses findings 1 and part
   of 2.
2. **Count plugin components in `CONTRIBUTING.md` §2.** Add a row for plugin agents
   and skills, and a step to check `/context` after any plugin install.
3. **Trim `test-first`'s description** to under 400 characters.
4. **Name the `planner` exception** in `CONTRIBUTING.md` §3.
5. **Optional:** a pre-commit hook or CI job for the §5 checks, and a line in
   `CONTRIBUTING.md` pointing repeated corrections to `hookify`. Earlier rounds judged
   CI more machinery than it's worth for a personal setup.

## History

| Date | Commit | Evaluator | Score | Main movement |
|---|---|---|:-:|---|
| 2026-09-25 | `d4467f1` | main session | 37 | Baseline against the two reference repos |
| 2026-09-25 | working tree on `d4467f1` | main session | 45 | Added `reviewer`, `challenger`, the orchestrator dial, the secrets hook and tests, and Credits |
| 2026-09-25 | `646f5ff` + round 2 | main session | 45 | Production-practice changes; no score moved |
| 2026-09-25 | round 2 working tree | fresh `challenger` (Opus) | 43 | Cold audit: 1 High, 7 Medium, 2 Low |
| 2026-09-25 | after audit fixes (`31ff269`) | main session | 45 | 200k-token threshold, risk-based dial, audit fixes; not re-audited |
| 2026-09-25 | `344c9ab` | main session | 43 | Plugins cost 1, 2, and 6; `CONTRIBUTING.md` raised 10 |

### Changes made in earlier rounds

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
