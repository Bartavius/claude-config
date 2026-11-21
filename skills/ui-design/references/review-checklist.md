# Pre-ship review checklist (from design-library/guides/review-checklist.md, plus lessons learned)

Run this before declaring UI work done. For each item, note how you checked it: by screenshot, by inspecting the rendered page, or by reading the code. Report items you couldn't check as unchecked rather than passed.

**Hierarchy**
- [ ] Squint test: the most important element is the most prominent.
- [ ] At most one primary (`default` variant) button per region.
- [ ] Heading levels are sequential (h1 → h2 → h3), with one h1 per page.

**Color & contrast**
- [ ] Only semantic utilities. The raw-color `rg` in `tokens.md` comes back empty.
- [ ] Body text is at least 4.5:1, and large text and icons at least 3:1, in **both** modes. Check the dark-mode screenshots, not just light.
- [ ] Status is never conveyed by color alone (add an icon or a label).

**Typography**
- [ ] At most 2 font families (plus mono). Body is at least 16px, and line length is 45–75ch (`max-w-prose`).
- [ ] Headings use `font-heading`, and numbers in tables use `tabular-nums`.

**Spacing & layout**
- [ ] Spacing comes from the Tailwind scale, and related items are closer together than unrelated ones.
- [ ] Alignment is consistent; nothing is optically off by a few pixels.

**States**
- [ ] Hover, focus-visible, active and disabled are styled for every control.
- [ ] Loading (skeleton or spinner), empty (with a next action) and error (with recovery) states exist.

**Accessibility**
- [ ] Tab order follows visual order, with no CSS reordering (see "Reordering CSS" in `browser-verification.md`). Focus is trapped in dialogs and **returned on close**, including for dialogs opened without a trigger.
- [ ] Decorative or preview mocks are `inert` + `aria-hidden`.
- [ ] Icon-only controls have an `aria-label`, and images have a meaningful `alt` or `alt=""`.
- [ ] Touch targets are at least 44px on mobile (WCAG AA minimum: 24px).

**Motion**
- [ ] Durations come from `--duration-*`, and UI feedback takes about 400ms or less.
- [ ] `prefers-reduced-motion` removes non-essential motion.

**Responsive**
- [ ] No horizontal scroll at 375–390px, and tables scroll inside their own container.
- [ ] Navigation collapses intentionally (sheet or drawer), not by wrapping.

**Content**
- [ ] Button labels are verb-first, there's no lorem ipsum, and realistic data lengths have been tested.

**Ethics** (for anything touching pricing, consent, retention or urgency)
- [ ] Accept and reject are equally easy, cancelling is as easy as signing up, and there's no confirmshaming, fake scarcity or fake social proof.

## Anti-patterns
- Purple-to-blue gradients, glassmorphism, and emoji as icons used by default.
- Every section in a card with a shadow, centered body text, or more than three font weights.
- Citing folk rules (7±2 menu items, the three-click rule, the golden ratio, the Z-pattern) as reasons.
