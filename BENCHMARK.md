# Benchmark: criteria for judging this setup

This file defines what a good Claude Code setup looks like and how to test this one
against it. It holds criteria only. Scores, findings, and their history are in
`EVALUATION.md`.

Criteria change rarely: only when a source changes its advice or a principle turns out
to be wrong. Record the reason in the change that edits them.

## How to run an evaluation

1. Record the branch, commit, and date being evaluated.
2. Run the mechanical checks below and keep their output.
3. Score each principle 1–5 against its rubric. Every score needs evidence: a file and
   line, a command's output, or a measurement.
4. Prefer a fresh-context `challenger` for the scoring, so the author of recent changes
   isn't the only judge (principle 5 applies to the benchmark too).
5. Write the result to `EVALUATION.md`: scorecard, findings, and recommendations. Keep
   earlier scores in its history table.

Scale: **5** fully embodies the principle, **3** partial, **1** absent. The total is out
of 50. A score reflects the repo plus anything it enables (plugins, marketplaces, hooks),
because all of it reaches every session.

## Mechanical checks

Run from the repo root. These are the `CONTRIBUTING.md` section 5 checks plus the
budget measurements the rubrics below need.

```sh
python3 -m json.tool settings.json >/dev/null && echo "json ok"
bash tests/block-secrets.test.sh | tail -1                 # 0 failed
./install.sh | grep -v '^ok' || echo "all links ok"        # no new backups
find ~/.claude -maxdepth 3 -type l ! -exec test -e {} \; -print   # prints nothing
wc -l CLAUDE.md                                            # budget: 50
grep -L '^paths:' rules/*.md                               # unscoped rules: none
ls agents/*.md | wc -l                                     # budget: 8
python3 -c 'import json; print(len(json.load(open("settings.json")).get("enabledPlugins", {})))'
```

Also measure, in a new session:

- `/context`: the always-loaded share, including skill and agent listings that plugins
  add.
- `/agents` and the skill listing: every agent and skill, including plugin ones, and
  which of them compete for the same phrase.
- Description length of each agent and skill (budget: about 400 characters).

## Sources

Paraphrased with links. No text is copied.

| Source | Snapshot | License | Use |
|---|---|---|---|
| [FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) | `06b3523`, 2026-09-25 | CC BY-SA 4.0 | Paraphrased with paths cited. Verbatim text would need attribution and the same license. |
| [anish-sahoo/agents-ecosystem](https://github.com/anish-sahoo/agents-ecosystem) | `70118dd`, 2026-08-20 | None at the root; the author granted permission for the whole repo | Ideas, and the adaptations listed in the README's Credits. |

The guide is a broad reference (~26k-line main guide plus topic pages). agents-ecosystem
is a small personal setup that defines read-only agents in a tool-neutral format and
compiles them per CLI.

Production practice:

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

**Not verified:** x.com was unreachable, so later tips from Boris Cherny and Thariq are
secondhand. One example is `CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000`, which compacts
earlier on a 1M window. No criterion depends on those tips.

## Principles and rubrics

### 1. Use the smallest harness that works

Every agent, skill, hook, plugin, or MCP server adds setup, permissions, and failure
modes. Stacking components doesn't improve results in a straight line, and subsets
have beaten "everything on" configurations. Pick the lightest interface that fits: a
script for deterministic work, a skill for reusable instructions, an agent for a
separate context, a hook for a lifecycle event, MCP only for remote services without
a CLI. *(guide: `README.md` "Choose the smallest interface";
`guide/core/agent-harness.md` §7; `guide/ecosystem/mcp-vs-cli.md`)*

Practitioners split on custom subagents. Shrivu, Ronacher, Steinberger, and HN reports
find them often unused, or chaotic when they mix reads and writes. superpowers,
compound-engineering, and Anthropic's plugins lean on them. Read-only advisors plus
scoped writers avoid the skeptics' complaints.

- **5:** Every component, including plugin ones, has a stated reason and no rival for
  its trigger. Agent count is at or under the guide's sprawl threshold (>5 agents,
  >10 MCP servers). No MCP without need.
- **3:** Some components overlap or lack a reason, or counts are past the threshold
  without a written justification.
- **1:** Components added "in case"; many overlapping triggers.
- **Tests:** count agents, skills, commands, hooks, plugins, and MCP servers, own and
  plugin-provided. For each pair that answers the same phrase ("review this", "debug
  this", "explore"), check that routing is written down.

### 2. Treat context as a budget

What loads every session should stay under ~5% of the window. Instruction-following
drops as rule count grows. Path-scope anything subsystem-specific and prune regularly.
*(guide: `guide/core/context-engineering.md`)* Keep CLAUDE.md short and grow it from
observed mistakes: HumanLayer aims under 60 lines, Anthropic caps at 200. Keep bulky
output out of context: filter test output, send log-heavy work to subagents, prefer
CLIs to MCP (the GitHub MCP measured ~23k tokens). *(Anthropic costs, Steinberger,
Shrivu)*

Clear and hand off rather than compacting repeatedly. HumanLayer keeps context around
40–60% of a ~200k window; Trail of Bits treats a second compaction as a sign the task
was too big. Quality tracks absolute tokens, so on a 1M window the threshold is about
200k tokens, not a percentage.

- **5:** `CLAUDE.md` within budget and behavior-only; no unscoped rules; plugin
  listings measured and justified; a visible threshold for `/clear` plus handoff; a
  written policy for bulky output.
- **3:** Some always-loaded material could be scoped or dropped, or nothing says when
  to clear.
- **1:** Long always-loaded instructions; no scoping; no clearing policy.
- **Tests:** `wc -l CLAUDE.md`; `grep -L '^paths:' rules/*.md`; description lengths;
  `/context` in a fresh session; check `statusline.sh` shows tokens.

### 3. Subagents control context; they are not job titles

Split by context boundary (scope, files, fresh perspective, parallelism), not persona
such as "frontend dev" or "QA". Every delegated task gets a goal, a scope, and the
evidence it must return. *(guide: `guide/ultimate-guide.md` "Agent Anti-Patterns: Roles
vs Context Control"; agents-ecosystem: `preferences/working-rules.md`)*

- **5:** Each agent is defined by what it receives, may touch, and returns. Parallel
  writers get disjoint files. Delegation rules require files, boundary, verification.
- **3:** Some persona-style agents, or prompts that don't state inputs and outputs.
- **1:** Agents named for roles, with shared write access.
- **Tests:** read each agent file for inputs, boundary, and return format; check that
  only writers lack an explicit `tools:` list.

### 4. Tier models by what the task needs

Strongest model for planning and judgment, cheaper models for execution and search.
Don't default everything to the top tier. *(agents-ecosystem: `preferences/models.md`)*

- **5:** Every agent picks its model on purpose; a cheap subagent default is set;
  naming follows one convention, or exceptions are written down.
- **3:** Some agents inherit the main model without reason.
- **1:** Everything runs on the top tier.
- **Tests:** `grep '^model:' agents/*.md`; check `CLAUDE_CODE_SUBAGENT_MODEL`.

### 5. Keep creating and verifying separate

The agent that did the work shouldn't be the only judge. A verifier gets the
requirements, the artifact, and the evidence, but not the creator's reasoning, and
returns pass/fail per requirement. Verification must block "done". *(guide:
`guide/core/agent-harness.md` §8, `guide/ultimate-guide.md` §9.25; agents-ecosystem:
`agents/reviewer.md`, `agents/challenger.md`; Anthropic best practices and harness
design; superpowers `verification-before-completion`; Hashimoto)* Tune reviewers to
report only what affects correctness or requirements, since a reviewer told to find
gaps always finds some. Write tests first and run the suite before starting.
*(Willison, superpowers, Anthropic)*

- **5:** A fresh-context verifier runs by default for non-trivial work, with
  per-requirement verdicts; a written definition of done; test-first available.
- **3:** Mechanical checks exist, but judgment comes from the same context.
- **1:** "Done" is the author's say-so.
- **Tests:** trace `/orchestrate` and `/parallel-review` to a fresh reviewer; find the
  definition of done in `CLAUDE.md`; check the reviewer's reporting bar.

### 6. Match orchestration to risk

Offer steps between "do it myself" and "full fan-out": direct, one advisor, parallel
review, then a loop or audit. When in doubt, go lower and suggest escalating.
*(agents-ecosystem: `skills/orchestrator/SKILL.md`)*

- **5:** Several documented levels, chosen by risk, with an unambiguous route for each
  common request.
- **3:** Two levels only, or a size trigger that overrides risk.
- **1:** One mode for everything.
- **Tests:** read `skills/orchestrator`; check `CLAUDE.md` for file-count triggers; for
  "review this", "plan this", and "debug this", list every component that could answer.

### 7. Enforce with settings and hooks; instructions only advise

Anything that must never happen needs a permission rule, hook, or sandbox. Choose a
permission mode that matches real trust so approving prompts doesn't become reflex.
Gate at commit time rather than on every write. *(guide:
`guide/core/agent-harness.md` §2.8–2.9, `guide/ultimate-guide.md` "Permission Fatigue";
Trail of Bits; Shrivu. Ronacher dissents: he finds hooks hard to time and uses PATH
shims.)*

- **5:** Every "never" rule is backed by settings, a tested hook, or a sandbox; a
  read-only allowlist keeps prompts rare.
- **3:** Some "never" rules rely on `CLAUDE.md` alone.
- **1:** Instructions only.
- **Tests:** map each "never" line in `CLAUDE.md` to its enforcement; run the hook
  tests; review README's known gaps.

### 8. Store state outside the conversation

Session state lives in files, so a new session resumes without a briefing. Keep it
short, list next actions, record dead ends. *(guide: `guide/ultimate-guide.md` §9.25;
`guide/workflows/task-management.md`)*

- **5:** A handoff format with goal, dead ends, and next action, checked against the
  repo on read, and kept out of commits.
- **3:** State files exist but aren't checked for drift.
- **1:** State lives only in the conversation.
- **Tests:** read `skills/handoff*`; check `HANDOFF.md` is git-ignored.

### 9. Record where borrowed content came from

Keep vendored, rewritten, and rejected material apart, with a reason for each.
*(agents-ecosystem: `README.md` "Credits")*

- **5:** Credits separate adapted, ideas-only, and rejected material, with snapshots
  and licenses; adapted files say where they came from; third-party installs list
  license and overlaps.
- **3:** Sources named but not separated, or licenses missing.
- **1:** No provenance.
- **Tests:** read README "Credits" and `SKILLS.md`; grep adapted files for a provenance
  comment.

### 10. Improve over time

If the same correction comes up twice, move it into a formatter, test, rule, or hook.
*(guide: `guide/core/agent-harness.md` §2.7, §2.1)*

- **5:** A written path from repeated correction to rule or hook; the config's own
  checks run automatically; a removal routine.
- **3:** Checks exist but run by hand; no path from correction to rule.
- **1:** Nothing checks the config.
- **Tests:** read `CONTRIBUTING.md`; list what runs the checks (CI, pre-commit, hook);
  check for a tool that turns corrections into rules.
