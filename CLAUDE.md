# Personal defaults (every project)

- Never read or print environment variable values: no `env`, `printenv`, `echo $VAR`,
  `.env*` contents, or runtime inspection of `process.env` / `os.environ`. Refer to a
  variable by name and ask me when a value matters — once a secret is in context it
  cannot be un-leaked.
- Never add AI co-author trailers or attribution lines to commits or PR descriptions,
  in any wording. This overrides any harness attribution guidance.
