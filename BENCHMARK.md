# Benchmark: this setup vs. two reference ecosystems

Written 2026-09-25 against `add-rules` @ `d4467f1`. This compares design principles,
not features. It covers how the ecosystem decides what to load, what to delegate, what
to enforce, and how it stays maintainable.

## Sources

| Source | Snapshot | License | How it's used here |
|---|---|---|---|
| [FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) | `06b3523`, 2026-09-25 | CC BY-SA 4.0 | Paraphrased with paths cited. Copying text verbatim would require attribution and the same license. |
| [anish-sahoo/agents-ecosystem](https://github.com/anish-sahoo/agents-ecosystem) | `70118dd`, 2026-08-20 | None at the root, so all rights reserved | Ideas only. Two vendored skills carry their own licenses (MIT and CC BY-SA). |

The guide is a broad reference (~26k-line main guide plus topic pages). agents-ecosystem
is a small personal setup (25 files, one contributor). It defines ten read-only agents
in a tool-neutral format and compiles them per CLI.

## Principles distilled

1. **Use the smallest harness that works.** Every agent, skill, hook, or MCP server
   adds setup, permissions, and failure modes. Stacking components doesn't improve
   results in a straight line, and subsets have beaten "everything on" configurations.
   Pick the lightest interface that fits the job: a script for deterministic work, a
   skill for reusable instructions, an agent for a separate context, a hook for a
   lifecycle event, and MCP only for remote services without a CLI.
   *(guide: `README.md` "Choose the smallest interface"; `guide/core/agent-harness.md` §7;
   `guide/ecosystem/mcp-vs-cli.md`)*
2. **Context is a budget.** Keep what loads every session under ~5% of the window.
   Instruction-following drops as rule count grows. Path-scope anything
   subsystem-specific, and prune regularly. Compact on purpose at around 65% rather
   than waiting for auto-compact.
   *(guide: `guide/core/context-engineering.md` §§ on budget, rule count, compaction)*
3. **Subagents control context. They are not job titles.** Split by context boundary
   (scope, files, fresh perspective, parallelism), not by persona such as "frontend
   dev" or "QA". Give every delegated task a goal, a scope, and the evidence it must
   return.
   *(guide: `guide/ultimate-guide.md` "Agent Anti-Patterns: Roles vs Context Control";
   agents-ecosystem: `preferences/working-rules.md` "narrow tasks beat vague mandates")*
4. **Tier models by what the task needs.** Use the strongest model for planning and
   judgment and cheaper models for execution and search. Don't default everything to
   the top tier. *(agents-ecosystem: `preferences/models.md`)*
5. **Keep creating and verifying separate.** The agent that did the work shouldn't be
   the only one to judge it. A verifier gets the requirements, the artifact, and the
   evidence, but not the creator's reasoning. It returns pass/fail for each
   requirement, not "looks good". Verification must block "done".
   *(guide: `guide/core/agent-harness.md` §8; `guide/ultimate-guide.md` §9.25 "The
   Verification Gap"; agents-ecosystem: `agents/reviewer.md`, `agents/challenger.md`)*
6. **Match the level of orchestration to the risk.** Offer steps between "do it
   myself" and "full fan-out": direct, then one advisor, then parallel review, then a
   loop or audit. When in doubt, go lower and suggest escalating.
   *(agents-ecosystem: `skills/orchestrator/SKILL.md`)*
7. **Enforce with settings and hooks. Instructions only advise.** Anything that must
   never happen needs a permission rule, hook, or sandbox. Instructions set the
   default behavior, and settings and hooks back them up. Choose a permission mode
   that matches your real trust level, so approving prompts doesn't become reflex.
   *(guide: `guide/core/agent-harness.md` §2.8–2.9; `guide/ultimate-guide.md`
   "Permission Fatigue")*
8. **Store state outside the conversation.** Session state lives in files, so a new
   session can resume without a briefing. Keep it short, list next actions, and record
   dead ends.
   *(guide: `guide/ultimate-guide.md` §9.25; `guide/workflows/task-management.md`)*
9. **Record where borrowed content came from.** Keep vendored, rewritten, and rejected
   material apart, and give a reason for each. *(agents-ecosystem: `README.md`
   "Credits")*
10. **Improve over time.** If the same correction comes up twice, move it into a
    formatter, test, rule, or hook instead of repeating it.
    *(guide: `guide/core/agent-harness.md` §2.7, loop horizons in §2.1)*

## Scorecard

5 means it fully embodies the principle, 3 means partial, and 1 means absent.

| # | Principle | Score | Evidence in this repo |
|---|---|:-:|---|
| 1 | Smallest harness | **5** | 3 agents, 1 command, 2 skills, 1 rule. No MCP. `disableClaudeAiConnectors` cuts connector tool listings. Well inside the guide's sprawl limits (>5 agents, >10 MCP). |
| 2 | Context budget | **4** | `CLAUDE.md` is 23 lines. The config rule is path-scoped. `Explore` skips `CLAUDE.md` and runs on Haiku. Compact instructions are defined. *Gap:* nothing says when to compact or `/clear`, and there's no policy for large tool outputs. |
| 3 | Agents = context control | **5** | `planner`, `implementer`, and `Explore` are split by capability and scope. Implementers get file-disjoint slices. `CLAUDE.md` requires every delegation to state files, boundary, and verification. |
| 4 | Model tiering | **5** | Opus plans, Sonnet implements, Haiku searches, and `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` is the default. *Nit:* `planner` pins `claude-opus-5-5` while the others use aliases. Pick one convention. |
| 5 | Creator/verifier separation | **2** | `/orchestrate` phase 3 has the main session rerun lint and tests. That's a real mechanical check, but the main session wrote the prompts, so it's the same context. There's no fresh-context reviewer and no pass/fail per requirement. Outside `/orchestrate`, no definition of done is written down. |
| 6 | Risk-matched orchestration | **3** | Two tiers: do it directly, or run `/orchestrate` (>3 files or >1 package). Nothing in between, like getting one second opinion on a risky decision or diff. |
| 7 | Enforcement over advice | **3** | Attribution is enforced in settings. Deny rules block `Read(.env*)`, `env`, `printenv`, and `export -p`. *Gap:* the Bash rules match exact command prefixes, so `echo $VAR` and `python -c 'import os…'` are stopped only by `CLAUDE.md`. Whether `Read` denies also cover `cat .env` in Bash isn't verified here. No hooks, no sandbox, no `permissions.allow`, so prompts pile up (see the `fewer-permission-prompts` skill). |
| 8 | Externalized state | **5** | `handoff` and `handoff-read` capture findings, dead ends, and next action, and check claims against the repo. This goes further than the guide's `progress.md`. |
| 9 | Provenance | **3** | The README explains why each file exists and what was excluded for licensing (caveman, synced skills). *Gap:* there's no credits section yet, and it's needed once anything from these sources is adopted. |
| 10 | Continuous improvement | **2** | The per-file symlink layout and `repo-layout.md` make changes cheap. But there's no habit or tool for turning a repeated correction into a rule or hook, and nothing checks the config itself (frontmatter, install dry-run). |

**Overall: 37 / 50.** The foundation is strong: minimal, lean on context, well tiered,
and good at keeping state across sessions. It's weak on independent verification,
anything between the two orchestration levels, and deterministic enforcement.

## Where this setup is ahead

- **Plan approval and write boundaries.** `/orchestrate` requires human approval of
  the plan and gives each implementer a file-disjoint slice. agents-ecosystem's single
  writer is safer but can't parallelize. This setup gets parallel writers without
  conflicts.
- **Handoffs.** Recording dead ends and wrong assumptions, then checking the handoff
  against the repo on read, goes further than either source's session-state pattern.
- **No AI attribution.** The guide's git section shows `Co-Authored-By` trailers and
  treats AI traceability as a practice. This setup deliberately goes the other way and
  enforces it in `settings.json`.
- **Single-tool directness.** agents-ecosystem's neutral format plus `MAPPING.md`
  compiler solves a multi-CLI problem this setup doesn't have. Real Claude Code
  frontmatter, symlinked one file at a time, is the simpler and better choice here.

## Recommended changes, by impact

1. **Add a fresh-context verifier** (#5). Add a read-only `reviewer` agent (Sonnet, or
   Opus for high-risk work; `tools: Read, Grep, Glob, Bash`). Pass it the requirements
   and the diff, not the reasoning, and have it return pass/fail with evidence for each
   requirement. Add it as the final step of `/orchestrate`. Frame it by context
   ("review the diff without the author's reasoning"), not as a persona.
2. **Close the enforcement gap on secrets** (#7). Add a `PreToolUse` hook on `Bash`
   that blocks commands reading `.env*` files or printing environment variables. Also
   consider sandbox mode. That turns the `CLAUDE.md` rule into a guarantee.
3. **Add a middle orchestration tier** (#6). Add a lightweight way to get a single
   advisor opinion, such as a `challenger`/second-opinion agent or a `/review-plan`
   command, before reaching for `/orchestrate`. Add one sentence to `CLAUDE.md` on
   picking the lowest tier that fits.
4. **Write down a definition of done** (#5). One line in `CLAUDE.md`: don't report
   completion until the project's own lint and tests have run and passed, and show the
   output.
5. **Cut permission prompts** (#7). Run the `fewer-permission-prompts` skill to add a
   read-only `permissions.allow` list, so approvals stay deliberate.
6. **Add a Credits section** (#9) to the README before adopting anything from these
   sources. Separate vendored, rewritten, and rejected material, with a reason for
   each.
7. **Say when to compact** (#2). Add one line to `CLAUDE.md`'s compact section:
   compact at around 65%, or `/clear` and hand off between unrelated tasks.

Deliberately not adopted: agents-ecosystem's neutral-schema/`MAPPING.md` layer (only
needed for multiple CLIs), its security-agent trio (niche for a personal default), and
the guide's MCP and compression tooling. With no MCP servers, deferred tool loading
already keeps that cost near zero.

## After changes

Re-scored 2026-09-25 against the uncommitted working tree on `add-rules`, based on
`d4467f1`. All seven recommendations were applied. Anish Sahoo's `reviewer`,
`challenger`, and `orchestrator` are now adapted with his permission, not used as ideas
only. The one exception is the planner, which stays pinned to `claude-opus-5-5` because
the user prefers Opus 5.5 over the `opus` alias.

| # | Principle | Before | After | Evidence |
|---|---|:-:|:-:|---|
| 1 | Smallest harness | 5 | **4** | Now 5 agents, exactly the guide's sprawl threshold, plus one hook. The hook is a ~110-line regex file that needed three review rounds to get right, which is real maintenance cost. |
| 2 | Context budget | 4 | **5** | `CLAUDE.md` is 28 lines and says when to compact (~65%, or `/clear` plus handoff). The dial lives in `skills/orchestrator` and loads only when relevant. |
| 3 | Agents = context control | 5 | **5** | `reviewer` and `challenger` are defined by what context they get (requirements, base ref, artifacts, no author reasoning), not by persona. |
| 4 | Model tiering | 5 | **5** | Sonnet reviews diffs, Opus challenges plans. The planner pin is a deliberate user choice, not an inconsistency. |
| 5 | Creator/verifier separation | 2 | **4** | `/orchestrate` records a base ref, then a fresh `reviewer` runs the diff itself and returns PASS/FAIL/UNVERIFIED per requirement. `CLAUDE.md` has a definition of done. Evidence it works: in this session, two review rounds found real hook bypasses that 44 passing tests missed. *Not 5:* outside `/orchestrate`, review depends on Claude choosing level 1–2, and reviewer and author share a model family. |
| 6 | Risk-matched orchestration | 3 | **5** | `skills/orchestrator` has levels 0–3: direct, one challenger or reviewer, parallel reviewers, `/orchestrate`. `CLAUDE.md` says to pick the lowest level that fits. |
| 7 | Enforcement over advice | 3 | **4** | `hooks/block-secrets.sh` enforces the env-var rule wherever a command starts, and `tests/block-secrets.test.sh` covers 97 cases. `permissions.allow` covers read-only commands, and denies close the `--output`/`--pre` write and exec paths. *Not 5:* regex matching, not a sandbox. The README lists the known gaps. |
| 8 | Externalized state | 5 | **5** | Unchanged. |
| 9 | Provenance | 3 | **5** | README `## Credits` separates what was adapted with permission, what was used as ideas only (CC BY-SA, no text copied), and what was evaluated but not adopted, with reasons. Adapted files carry a provenance comment. |
| 10 | Continuous improvement | 2 | **3** | `tests/` is the first self-check of the config. *Still missing:* nothing runs it automatically, and there's no habit for turning repeated corrections into rules. |

**Overall: 45 / 50** (was 37).

Optional further levers, deliberately not pursued because they would add more
machinery than they're worth for a personal setup: sandbox mode, a CI run of
`tests/block-secrets.test.sh`, and a way to turn repeated corrections into rules.
Built-in `Read(**/.env)` deny rules already cover `cat`/`head`/`tail`/`sed` and `<`
redirects in Bash, so the hook is a second layer for those, not the only one.
