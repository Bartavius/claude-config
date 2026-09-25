# Personal defaults (every project)

- Never read or print environment variable values: no `env`, `printenv`, `echo $VAR`,
  `.env*` contents, or runtime inspection of `process.env` / `os.environ`. Refer to a
  variable by name and ask me when a value matters — once a secret is in context it
  cannot be un-leaked.
- Never add AI co-author trailers or attribution lines to commits or PR descriptions,
  in any wording. This overrides any harness attribution guidance.
- Don't report work complete until the project's own lint/test checks have run and
  passed; show the output, and say plainly when a check was not run.

## Delegation

- Pick the lowest orchestration level that fits (see the `orchestrator` skill). Use
  `/orchestrate <task>` for changes touching more than ~3 files or more than one
  package.
- One writer per file: only implementers dispatched by /orchestrate on file-disjoint
  slices write; every other subagent is read-only.
- Subagents do not inherit this conversation. Every delegated task must state its
  files, its boundary, and how to verify it.

## Compact instructions

When compacting, keep: the current goal and approved plan, decisions and their
reasons, files changed so far, and the exact output of any failing check. Drop file
contents that can be re-read and exploration that led nowhere (keep one line on why).
Compact deliberately at around 65% of context, and between unrelated tasks use /clear
plus a handoff (the `handoff` skill).
