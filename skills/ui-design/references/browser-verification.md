# Checking the rendered page

This works with any browser tool: the `claude-in-chrome` skill, Playwright, Chrome DevTools, or screenshots from the user. The point is to catch what reading the code can't predict: CSS that never compiled, collapsed mocks, dark-mode contrast misses, awkward wrapping, crowded mobile layouts.

## What to check
| Check | How |
|---|---|
| Both widths | 390px (phone) and about 1280px. No horizontal scroll at 390px. |
| Both modes | Light and dark. Contrast misses usually show up in dark. |
| Viewport meta | `<meta name="viewport" content="width=device-width, initial-scale=1">` is present. Without it, phones render the page at ~980px, zoomed out. |
| Tab order | Tab through once. Focus should move in visual order, with a visible ring. In a dialog, focus stays inside it and returns to the opener on close. |
| Reordering CSS | Look in the source for `grid-auto-flow: dense`, `order:`, `flex-direction: *-reverse`, and positive `tabindex`. Each one separates visual order from focus order. |
| Names | Icon-only buttons have an `aria-label`, and images have `alt` (`alt=""` if decorative). |
| Targets | Interactive elements are at least 44px on mobile, and at least 24px anywhere (WCAG AA). Inline text links are exempt. |
| States | Hover, focus, disabled, loading, empty and error each render at least once. |

When the tool can run JavaScript in the page, this finds focus-order breakers quickly:

```js
[...document.querySelectorAll("*")].filter((el) => { const s = getComputedStyle(el)
  return s.gridAutoFlow.includes("dense") || s.flexDirection.endsWith("reverse") || (s.order !== "0" && el.matches("a,button,input,select,textarea,[tabindex]")) })
```

## Reading results
- **Look at every screenshot you take.** Don't infer how the page looks from code.
- **Measurements are leads.** Clipping is often intentional (ellipsis truncation, a demo of overflow), and a small inline link is acceptable. Reordering CSS on focusable content is almost always a real problem: fix the DOM order, don't add `tabindex`.
- **Compare before and after.** When you change a layout, capture both versions at the same widths. If the new one reads worse, revert it.

## Traps (each one cost time once)
- **Dark mode:** emulate `prefers-color-scheme` (in DevTools, Rendering → Emulate CSS media feature; in CDP, `Emulation.setEmulatedMedia`). Toggling a `.dark` class from the protocol didn't take effect in screenshots. If the app's toggle ignores system preference, click the toggle instead.
- **Narrow layouts:** Chrome's `--window-size` doesn't trigger them. Use device emulation (`Emulation.setDeviceMetricsOverride`).
- **Keyboard Enter** sent through CDP needs `text: "\r"` in `Input.dispatchKeyEvent`, or nothing happens.
- **Finishing animations** with `animation.finish()` throws on infinite animations. Wrap each call in try/catch.
- **A missing Tailwind class on a running dev server** usually means stale CSS, not a typo. Run `touch` on the global CSS and reload. A dev server can also cache a failed import after files briefly disappear (a branch switch, a stash). Restart it.
- **Headless Chrome you launch yourself** needs a temporary `--user-data-dir`. Delete it and stop Chrome when you're done: each profile is about 50 MB, and orphaned ones pile up fast.
- **Measuring "natural" heights in a grid:** cards stretch to their row. Set `height:auto; align-self:start` on them before measuring.
- **Focus return after closing a dialog:** check `document.activeElement`. Landing on `<body>` means focus was lost.
