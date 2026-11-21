---
name: ui-design
description: Evidence-based UI design and review for shadcn/ui + Tailwind v4 + lucide. Semantic tokens, 156 UX laws ranked by evidence, and a pre-ship check in a real browser (light/dark, mobile, focus order). Use when building, restyling or reviewing web UI (forms, nav, pricing, dashboards, empty/error states), or for "make this look better", "design review", "is this accessible".
---

# UI design

Design decisions should rest on evidence and be checked in a real browser, not reasoned about in the abstract. This skill gives you three things:

- **What to build with:** semantic tokens and shadcn components.
- **Which rules apply:** laws per situation, ranked by how well-supported they are.
- **How to know you're done:** a review checklist plus a look at the rendered page.

Neighbors: for claude.ai artifact pages, `artifact-design` owns the page format, but the laws and the review here still apply. For chart styling alone, use `dataviz`.

## The design library (use it when it's there)

The user maintains a design library at `~/Desktop/projects/design-library`. It holds 156 laws (one file each), themes, palettes, font pairs, components, an icon map, and guides. When that directory exists, it's the source of truth. Query it instead of relying on memory:

```sh
LIB=~/Desktop/projects/design-library
rg -i "<keyword>" $LIB/catalog.jsonl          # one line per entry: id, summary, evidence, path
rg -i "<concept>" $LIB/foundations/icon-map.md # verified lucide names; don't guess icon names
```

Open the `path` from a hit and read it top-down. Stop once you have the answer: entries put the most important content first. `$LIB/AGENTS.md` has the full lookup protocol.

When the library is missing (another machine, a cloud session), use the bundled references. They're distilled from it:
- `references/laws.md`: every law grouped by situation, with its evidence rank and a one-line rule. It's a snapshot of the library, so prefer the library itself when it's present.
- `references/tokens.md`: the semantic token contract and the class rules.
- `references/review-checklist.md`: the pre-ship checklist.
- `references/browser-verification.md`: what to check in the rendered page, with whatever browser tool is available, and the traps.

## Workflow

### 1. Frame: which laws govern this?

Name the situations the task touches: forms, navigation, choices and pricing, feedback and loading, layout, typography, color, focus and keyboard, motion, charts, onboarding, microcopy, consent and ethics. Then open only those sections of `references/laws.md`, or `$LIB/guides/laws-by-situation.md`. Read a law's full file only when you're applying it in a non-obvious way.

Evidence decides conflicts. The order is standard > empirical > consensus > convention > contested > folk.
- **`standard` (WCAG and similar):** these are requirements, not trade-offs. Meet them first.
- **`contested` and `folk`:** these entries exist so you *don't* over-apply them. Examples are the 7±2 menu limit, the three-click rule, and the golden ratio. Never cite one as the reason for a design decision. When you mention one, say it's a myth or contested and give the better-supported alternative.
- **Behavioral laws** (anchoring, scarcity, defaults, social proof) help the user decide. They never trick the user. If a request amounts to a dark pattern (confirmshaming, asymmetric consent, hidden cancellation), say so, cite the law, and offer the honest version.

### 2. Build

- **Tokens only.** Use semantic utilities such as `bg-background`, `text-muted-foreground`, `bg-primary text-primary-foreground` and `border-border`. Never use raw `#hex`/`oklch()` or palette utilities like `bg-blue-500` outside a theme file. That way themes and dark mode work for free, and a palette swap doesn't mean a hunt through the code. `primary` is the brand color and main CTA; `accent` is shadcn's *subtle hover background*, not a brand color. Details are in `references/tokens.md`.
- **Components.** Use shadcn first (`npx shadcn@latest add <slug>`) and compose from there. Use lucide icons only, with names you've verified (some common names are deprecated aliases).
- **Hierarchy.**
  - Have one primary action per region.
  - The most important thing should win the squint test.
  - Related items sit closer together than unrelated ones.
- **States are part of the design.** Style hover, focus-visible, active and disabled for every control. Design loading, empty (with a next action) and error (with recovery) states, not just the happy path.
- **Copy.**
  - Use verb-first button labels ("Delete file", not "Yes").
  - Use sentence case.
  - Write errors that say how to fix the problem.
  - Use realistic data lengths, never lorem ipsum.

### 3. Verify in a real browser

Rendering is where design work actually fails: CSS that didn't compile, a mobile overflow, a dark-mode contrast miss, a focus ring that never shows. So look at the UI. Don't infer how it looks from the code.

Use whatever browser tool the session has, such as the `claude-in-chrome` skill or Playwright. If there's none, ask the user for screenshots. At minimum, look at **390px and desktop width, in light and dark mode**, and Tab through the page once.

Judge the screenshots yourself. Measurements (overflow, contrast ratios, element sizes) are leads, not verdicts. A clipped element may be the point of a demo, and a measurement can come back clean while the screen looks wrong. When you try a design change, compare it against the previous screenshot. Revert it if it reads worse, even if it seemed like an obvious improvement. `references/browser-verification.md` lists what to check and the traps.

If nothing could be rendered, say so plainly. Don't report visual checks you didn't do.

### 4. Review before calling it done

Go through `references/review-checklist.md`. Report each finding as **problem → law (evidence) → concrete fix**, for example:

> Pricing shows 6 equal tiers with no default → hicks-law (empirical) → mark one "Popular", move the rest behind "Compare all plans".

Say plainly which checks you ran and which you didn't (for example, "no screen reader pass").

## Practices learned building the library

These came from mistakes that looked right on paper:

- **DOM order is focus order.** CSS that moves things visually breaks keyboard and screen-reader order: `grid-auto-flow: dense`, `order`, `flex-direction: *-reverse`, absolute repositioning. If a layout needs reordering, reorder the data in JS so the DOM matches what's on screen. The audit flags these.
- **Decorative mocks stay out of the tab order.** Fake buttons inside an illustration or preview get `inert` + `aria-hidden`. Otherwise keyboard users tab through dozens of controls that do nothing.
- **Dialogs opened without a trigger lose focus on close.** Radix returns focus to a `DialogTrigger`. When a dialog opens from a card click or a URL, handle `onCloseAutoFocus` yourself (`preventDefault()`, then focus the originating control).
- **Missing Tailwind class? Suspect the dev server, not the class.** A running Tailwind v4 dev server can lag behind newly created files, so mocks render collapsed. Run `touch` on the global CSS file and re-render. Don't patch around it with inline `style`, which then needs reverting.
- **Width serves the content.** A wide layout helps content that has a horizontal shape: dashboards, side-by-side forms, menus, nav bars. It hurts content whose point depends on wrapping, like paragraph measure or line-height demos. Check by rendering both.
- **Keep text a click away when visuals carry the point.** Let the visual lead in a gallery, card or preview, and put explanations in the detail view. Instructions for live controls stay visible.
- **Folk rules need a "Myth / Better" framing.** Don't present them as "Avoid / Prefer", which restates the myth as fact.
- **After `npx shadcn add`, check the imports.** It has written `import { cn } from "cn"` and installed an npm package called `cn`. Fix the import to `@/lib/utils` and run `npm uninstall cn`.
