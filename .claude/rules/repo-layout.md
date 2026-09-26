---
paths:
  - "agents/**"
  - "commands/**"
  - "skills/**"
  - "hooks/**"
  - "rules/**"
  - "CLAUDE.md"
  - "settings.json"
  - "install.sh"
---

# This repo is live config

- Every file here is symlinked into `~/.claude/` by `install.sh`, so an edit changes
  every project's sessions right away. Treat edits as global.
- A new agent, command, skill, hook, or rule is picked up by the existing globs in
  `install.sh`. A new top-level file or directory needs a `link` line there.
- Anything added or removed must also be updated in the README's "What's here and why"
  section, including the reason it exists.
- Before adding, removing, or changing anything, follow `CONTRIBUTING.md`: the
  admission test, the context budgets, and the checks in its section 5.
- `.claude/` in this repo is project config for working on the repo itself. It is not
  installed.
