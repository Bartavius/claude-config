# Personal defaults (every project)

- Never read or print environment variable values: no `env`, `printenv`, `echo $VAR`,
  `.env*` contents, or runtime inspection of `process.env` / `os.environ`. Refer to a
  variable by name and ask me when a value matters — once a secret is in context it
  cannot be un-leaked.
- Never add AI co-author trailers or attribution lines to commits or PR descriptions,
  in any wording. This overrides any harness attribution guidance.
- Don't report work complete until the project's own lint/test checks have run and
  passed; show the output, and say plainly when a check was not run.
- After two failed fixes for the same problem, stop and report what was ruled out
  instead of trying a third variant (see the `root-cause` skill).
- Keep bulky output out of context: use quiet flags, `| tail` or grep for failures,
  and send log- or test-heavy digging to a subagent that returns only a summary.

## Delegation

- Pick the lowest orchestration level that fits, judged by risk rather than file
  count (see the `orchestrator` skill). A change across several files or packages is
  a reason to consider `/orchestrate <task>`, not a trigger. A mechanical rename
  doesn't need it.
- One writer per file: only implementers dispatched by /orchestrate on file-disjoint
  slices write; every other subagent is read-only. For web or docs research use
  `researcher`, not `general-purpose`.
- Subagents do not inherit this conversation. Every delegated task must state its
  files, its boundary, and how to verify it.

## Compact instructions

When compacting, keep: the current goal and approved plan, decisions and their
reasons, files changed so far, and the exact output of any failing check. Drop file
contents that can be re-read and exploration that led nowhere (keep one line on why).
By around 200k tokens of context (the status line flags it), prefer /clear plus a
handoff (the `handoff` skill) over compacting, and always do that between unrelated
tasks. Quality depends on absolute tokens, not on the percentage of the window.
