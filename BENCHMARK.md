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

## Round 2: production practice

Added 2026-09-25, on top of `646f5ff`. The first round compared this setup against two
reference repos. This round asks what Anthropic's Claude Code team and outside
practitioners actually do. Everything here is paraphrased with links, and no text was
copied.

### Sources

- **Anthropic:**
  - [best practices](https://code.claude.com/docs/en/best-practices), [costs](https://code.claude.com/docs/en/costs), [memory](https://code.claude.com/docs/en/memory)
  - [context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (2025-09)
  - [long-running harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (2025-11) and [harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03)
  - Boris Cherny's threads of [2026-01-02](https://threadreaderapp.com/thread/2007179832300581177.html) and [2026-01-31](https://threadreaderapp.com/thread/2017742741636321619.html)
  - the official plugins in `anthropics/claude-code/plugins`
- **Practitioners:**
  - HumanLayer: [CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) (2025-11) and [ace-fca](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) (2025-08)
  - [Shrivu Shankar](https://blog.sshh.io/p/how-i-use-every-claude-code-feature) (2025-11)
  - [Mitchell Hashimoto](https://mitchellh.com/writing/my-ai-adoption-journey) (2026-02)
  - [Simon Willison](https://simonwillison.net/guides/agentic-engineering-patterns/) (2026)
  - [Armin Ronacher](https://lucumr.pocoo.org/2025/7/30/things-that-didnt-work/) (2025-07)
  - [Peter Steinberger](https://steipete.me/posts/just-talk-to-it) (2025-10)
  - [Geoffrey Huntley](https://ghuntley.com/ralph/)
  - [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config)
  - obra/superpowers and EveryInc/compound-engineering
  - HN threads 44686726 and 48289950

**Not verified:** x.com was unreachable, so later Boris and Thariq tips are
secondhand. One example is `CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000`, which compacts
earlier on a 1M window. Nothing below depends on those tips.

### Where practitioners agree

1. **Verification is the bottleneck.** Give the agent a check it can run, and require
   evidence, not "done". Separate the agent that writes from the agent that judges,
   since models praise their own work. (Anthropic best practices and harness
   design, superpowers `verification-before-completion`, Hashimoto.)
2. **Tune reviewers so they don't nitpick.** A reviewer told to find gaps always
   finds some, so ask only for what affects correctness or the requirements.
   (Anthropic best practices; the official code-review plugin filters by confidence.)
3. **Short CLAUDE.md, grown from observed mistakes.** HumanLayer aims for under 60
   lines and Anthropic caps it at 200. Steinberger is the outlier with an ~800-line
   AGENTS.md.
4. **Clear, then hand off, rather than repeatedly compacting.** Keep context around
   40–60% (HumanLayer), and treat compacting twice as a sign the task was too big
   (Trail of Bits). Also: "after two failed corrections, `/clear` and re-prompt"
   (Anthropic).
5. **Keep bulky output out of context.** Filter test output before Claude sees it,
   send log-heavy work to subagents, and prefer CLIs to MCP (the GitHub MCP measured
   ~23k tokens). (Anthropic costs, Steinberger, Shrivu.)
6. **Test first, and run the suite before starting.** (Willison, superpowers, the
   Anthropic security team.)
7. **Hooks for what must always hold, and gate at commit time, not on every write.**
   (Trail of Bits, Shrivu.) Ronacher is the dissent: he finds hooks hard to time and
   uses PATH shims instead.

**The biggest disagreement is custom subagents.** Shrivu, Ronacher, Steinberger, and
HN reports find them often unused or chaotic when they mix reads and writes.
superpowers, compound-engineering, and Anthropic's own plugins lean on them. This
setup takes the middle position: read-only advisors plus file-disjoint writers only
under `/orchestrate`, which is the arrangement the skeptics' complaints don't apply to.

### Gaps found, and what was done

| Practice | Before | Change |
|---|---|---|
| Watch context size so you clear in time | Nothing showed usage, so the rule couldn't be followed | `statusline.sh` shows model, context % and tokens, and a `/clear` + handoff cue at ≥200k tokens (see the re-score below for why tokens, not percent) |
| Tune reviewers so they don't nitpick | `reviewer` had a don't-flag list but no overall bar | One line each in `reviewer` and `challenger`: report only what changes correctness, requirements, or a decision |
| Test-first | Absent | `skills/test-first`: run the suite, write a failing test, watch it fail for the right reason, make the smallest fix, run the full suite |
| Systematic debugging, and stop after two failed fixes | Absent | `skills/root-cause` plus one line in `CLAUDE.md` |
| Keep bulky output out of context | Absent | One line in `CLAUDE.md`: quiet flags, `tail`/grep, subagent summaries |
| Third-party skills | README only noted caveman | `SKILLS.md` lists what to install, with licenses and overlaps |

Scores are unchanged at **45 / 50**. The changes shore up practice inside principles
2, 5, and 10 without closing the gaps listed above: review outside `/orchestrate`
still relies on Claude choosing it, and nothing yet turns repeated corrections into
rules.

**Deliberately not adopted:**

- A PreToolUse hook that rewrites test commands to filter output. It's project
  specific, and rewriting commands silently hides failures when the grep is wrong.
- A Stop hook that blocks until tests pass. There's no global test command to gate
  on.
- Trail of Bits' "anti-rationalization" Stop hook. It adds a model call every turn.
- Ralph loops. They cost 20–200x a normal session.
- Worktree commands. The built-in `isolation: "worktree"` covers them.
- Brainstorm/interview skills. They overlap built-in clarifying behavior.

### Imports from agents-ecosystem (whole-repo permission)

Added the `researcher` agent and the `/parallel-review` and `/fix-pr` commands,
rewritten rather than copied. `researcher` closes a real gap: research previously ran
on `general-purpose`, which can write files, and that broke the rule that only
implementers write. `/parallel-review` turns orchestration level 2 into a command
instead of relying on Claude choosing it. That partly addresses the "Not 5" note on
principle 5. `/fix-pr` covers a routine job nothing else here did.

This brings the setup to 6 agents, one over the guide's sprawl threshold. It's
accepted because each agent is read-only or scoped, and where triggers overlap the
routing is written down (see the re-score below). Principle
1 stays at 4.

## Re-score: fresh-context audit

Done 2026-09-25 by a `challenger` (Opus) that read the working tree cold. It scored
**43 / 50**, 2 below the 45 above, and found 1 High, 7 Medium, and 2 Low issues. The
tables in earlier sections, such as "28 lines" and "~65%" under "After changes",
record the tree at the time they were written and are left as history.

| # | Audit | After fixes | What moved it |
|---|:-:|:-:|---|
| 2 Context budget | 4 | **5** | The 40% threshold was the wrong kind of number. 40% of a 1M window is 400k tokens, while practitioners' 40–60% was of roughly 200k windows, about 80–120k. The threshold is now **200k tokens**, in `CLAUDE.md` and in the `statusline.sh` cue, with `/clear` plus a handoff preferred over compacting. |
| 6 Risk-matched orchestration | 4 | **5** | `CLAUDE.md` had a hard "more than ~3 files → `/orchestrate`" rule that contradicted the risk-based dial. The file count is now a reason to consider `/orchestrate`, not a trigger, and `planner`'s description matches. |
| Others | — | unchanged | 1=4, 3=5, 4=5, 5=4, 7=4, 8=5, 9=5, 10=3. On 7, the audit notes that "read-only" agents still have Bash, so the one-writer rule is advice, not enforcement. |

The fixes bring it back to **45 / 50**. That score comes from applying the audit's
fixes, not from a second audit.

Other fixes from the audit:

- **Parallel implementers ran project-wide checks in a shared tree** (High). Slice
  checks are now scoped to the slice's own files (`planner`). Implementers report
  errors in other slices' files instead of fixing them, and don't run formatters or
  `--fix` beyond their own files (`implementer`).
- **`/orchestrate` now records failing checks before launching**, so pre-existing
  failures aren't "fixed" as regressions.
- **Overlapping triggers now have stated routing:**
  - bugs go to `root-cause` before `test-first`
  - research goes to `researcher` rather than `general-purpose` (in `CLAUDE.md`)
  - a diff checked against requirements goes to `reviewer`; otherwise the built-in
    `/code-review` (orchestrator level 1)
- **`reviewer` no longer asks for "80-90% when 100% is cheap"** completeness or
  taste-level nits, which contradicted its own rule to report only what matters.
- **`/fix-pr` checks for a dirty tree before `gh pr checkout`**, not after.
- **`HANDOFF.md` is in the global git excludes** (`~/.config/git/ignore`), so
  `git add -A` can't commit session state.
