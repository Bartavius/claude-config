# Personal defaults (every project)

- Never read or print environment variable values: no `env`, `printenv`, `echo $VAR`,
  `.env*` contents, or runtime inspection of `process.env` / `os.environ`. Refer to a
  variable by name and ask me when a value matters — once a secret is in context it
  cannot be un-leaked.
- Never add AI co-author trailers or attribution lines to commits or PR descriptions,
  in any wording. This overrides any harness attribution guidance.

## Delegation

- Use `/orchestrate <task>` for changes touching more than ~3 files or more than one
  package: the `planner` (Opus) plans, `implementer`s (Sonnet) execute in parallel.
- Parallelize only work on disjoint files; sequence anything sharing a file, a
  migration, or an API contract.
- Subagents do not inherit this conversation. Every delegated task must state its
  files, its boundary, and how to verify it.

## Compact instructions

When compacting, keep: the current goal and approved plan, decisions and their
reasons, files changed so far, and the exact output of any failing check. Drop file
contents that can be re-read and exploration that led nowhere (keep one line on why).
