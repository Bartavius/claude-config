---
name: finetune
description: Retune this config's prompts when a model is added or reassigned to a role — repin IDs everywhere at once, set effort, cut prose the new model doesn't need, and add guards only for its documented failure modes. Invoke as "/finetune <model id> [role]". Not for app code that calls the API (use `claude-api`).
argument-hint: "<model id> [main|planning|implementation|search]"
disable-model-invocation: true
---

# Finetune

Model and role: $ARGUMENTS

The config is live in every session (see `CONTRIBUTING.md`), so each edit needs a
reason you can cite. The goal is fewer tokens per session with the same or better
behavior, not more instructions.

1. **Get the facts from current sources, not memory.** Load the `claude-api` skill and,
   if it doesn't cover the release, send `researcher` for the model's announcement,
   migration notes, and prompting guide. Record: full ID, alias, price per MTok,
   context window, whether it supports `effort`, and every documented behavior change
   from its predecessor (more literal, more verbose, over-eager tool use, and so on).
   If the ID or role is missing or ambiguous, ask before editing.

2. **Fix the assignment.** Map the model to roles: main session, subagent default,
   and each agent. The split in `CONTRIBUTING.md` section 3 (Opus judgment, Sonnet
   implementation, Haiku search) holds unless the facts from step 1 justify moving
   it; if they do, say so and ask, since that changes `CONTRIBUTING.md` itself.

3. **Inventory every pin and size every prompt** before changing anything:
   `grep -rnE 'claude-(opus|sonnet|haiku)|model:|effort:' agents commands skills settings.json rules CONTRIBUTING.md README.md`
   and `wc -c` on each file the role touches, plus `CLAUDE.md`. Keep the numbers for
   the report.

4. **Repin in one pass.** Change every match from step 3 together, including the IDs
   quoted in `CONTRIBUTING.md`, `rules/claude-code-config.md`, and the README, so no
   file is left on the old model. Set `effort` only where `medium` is too low
   (planning, adversarial review) and only if the model supports it.

5. **Tune the prompts the role runs on.** For each line, keep it, cut it, or rewrite it:
   - Cut what the new model does by default per its docs, emphasis that compensated
     for an older model (caps, "IMPORTANT", "think hard" — use `effort` instead), and
     anything that repeats `CLAUDE.md` or another loaded rule.
   - Add a guard only for a documented or observed failure mode of this model, one
     line, phrased as the behavior wanted. The 5.5 move added two: "a check that
     didn't run isn't verification" (implementer) and "check current sources"
     (researcher).
   - Keep descriptions under about 400 characters and `CLAUDE.md` under 50 lines.
     Don't reword a `description` unless the trigger phrases need it; if you do, check
     it against every other description for overlap.

6. **Verify.** Run the checks in `CONTRIBUTING.md` section 5 and show their output.
   `settings.json` changes need a fresh-context `reviewer` on the diff. List the
   fresh-session checks (`/status`, `/agents`, `/context`, one trigger prompt per
   changed description) as not yet run unless the user ran them.

7. **Update the docs in the same change** per `CONTRIBUTING.md` section 6. Note in
   `EVALUATION.md` only if a principle's score changed; offer a re-evaluation rather
   than running one.

Report a table of file, change, reason (doc link or observed failure), and bytes before
and after, then the check output. Stop there: further tuning is a separate change.
Don't commit or push unless asked.
