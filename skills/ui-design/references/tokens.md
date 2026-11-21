# Token contract (distilled from design-library/foundations/token-contract.md)

The variable names are **shadcn's**, plus success/warning/info, a heading font, shadows and motion. So any shadcn `globals.css` or theme block works unchanged.

## Rules
- Style with semantic utilities only. Raw colors (`#…`, `oklch(…)`, `rgb(…)`) and palette utilities (`bg-blue-500`, `text-gray-600`) belong only inside theme/palette CSS.
- `primary` is the brand color, main CTA and active state. `accent` is the **subtle hover/selected background** (shadcn's meaning), not a brand color.
- Don't style a mode by hand (`dark:bg-…`) when a variable covers it, because the variables already switch.
- Don't hardcode radii (`rounded-[10px]`). `--radius` drives `rounded-sm/md/lg/xl`.
- Quick check for violations in source:
  `rg -n '#[0-9a-fA-F]{3,8}\b|oklch\(|rgb\(|\b(bg|text|border|ring|fill)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d{2,3}' src`

## Color roles
| Variable | Utility | Use for |
|---|---|---|
| background / foreground | `bg-background` `text-foreground` | page surface, body text |
| card, popover (+ `-foreground`) | `bg-card` `bg-popover` | raised surfaces, floating menus |
| primary (+ `-foreground`) | `bg-primary` | brand, main CTA, active state |
| secondary (+ `-foreground`) | `bg-secondary` | secondary buttons, chips |
| muted / muted-foreground | `bg-muted` `text-muted-foreground` | quiet fills; captions, helper text |
| accent (+ `-foreground`) | `bg-accent` | hover/selected rows, menu items |
| destructive | `bg-destructive` `text-destructive` | delete, errors |
| success / warning / info (+ `-foreground`) | `bg-success` … | status badges, alerts, toasts |
| border / input / ring | `border-border` `border-input` `ring-ring` | dividers, field borders, focus |
| chart-1…5 | `fill-chart-1` `bg-chart-2` | data series, in order |
| sidebar-* | `bg-sidebar` … | shadcn Sidebar only |

Every `X` / `X-foreground` pair must meet AA (4.5:1) in **both** light and dark mode. Also check `muted-foreground` on `background`, which most often fails.

## Shape, type, depth, motion
- Fonts: `font-sans` (body), `font-heading` (h1–h6), `font-serif`, `font-mono`. Use at most 2 families plus mono. Body text is at least 16px. Use `tabular-nums` for numbers in tables.
- Shadows: `shadow-sm/md/lg`, mapped to the theme's `--shadow-*`.
- Durations aren't a Tailwind namespace, so write `duration-(--duration-fast)` / `duration-(--duration-normal)`. Easing: `ease-out`, `ease-in-out`, `ease-spring`. UI feedback should take 400ms or less.
- Dark mode: a `.dark` class on `<html>`, with every color variable defined in both blocks. To show several themes on one page, scope them as `[data-theme="<slug>"]` and `[data-theme="<slug>"].dark`.

## Setup (new project)
1. Run `npx shadcn@latest init`, which sets up Tailwind v4, `tw-animate-css`, `cn()` in `@/lib/utils` and `components.json`. Then run `npm i lucide-react`.
2. If the library is present: replace the global CSS with `$LIB/foundations/globals.css`, pick a theme (`rg '"kind":"theme"' $LIB/catalog.jsonl`), and paste its `theme.css` over the `:root` / `.dark` blocks.
3. Load the theme's fonts, which are listed in its font-pair entry under `## Load`.
