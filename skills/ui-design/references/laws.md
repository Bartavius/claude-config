# Laws by situation

Snapshot of design-library at `276477e` (156 laws), built from its `catalog.jsonl` and `guides/laws-by-situation.md`.
When the library is checked out, prefer those files: they're current.
Each line: `slug` · evidence — what to do. Within a section, the most important law comes first.
Evidence order for conflicts: standard > empirical > consensus > convention > contested > folk.
`folk` / `contested` lines are cautions: don't cite them as reasons. Full entry: `$LIB/laws/<slug>.md`.

## Buttons, links, touch targets
- `fitts-law` · empirical — Make frequent and primary targets large and close to where the pointer or thumb already is.
- `wcag-target-size` · standard — Make pointer targets at least 24x24 CSS px (AA); use 44px or more for primary touch controls.
- `thumb-zone` · empirical — Put primary mobile actions where a thumb reaches easily, but never rely on reach alone; grips change.
- `von-restorff-effect` · empirical — Emphasize one item among similar ones, such as a single primary button, and keep everything else quieter.
- `button-labels` · consensus — Start button labels with a verb, use two to four words, and name the outcome.
- `hover-free-design` · consensus — Never make hover the only way to reveal a label, action or menu; touch has no hover.
- `icon-labels` · empirical — Pair every icon with a visible text label; treat only home, print and search as near-universal.

## Forms
- `top-aligned-labels` · empirical — Place labels above their fields, not beside or inside them, so the label and field read in one glance.
- `labels-not-placeholders` · consensus — Give every field a visible label; use placeholder text only for an example format, never as the label.
- `inline-validation` · empirical — Validate a field when the user leaves it, not on each keystroke, and keep the message visible beside the field.
- `one-column-forms` · consensus — Put one field per row in a single column; pair only short, related fields on one row.
- `optional-fields` · consensus — Minimize optional fields, label them "(optional)", and mark required fields with text or an asterisk plus legend, never color alone.
- `error-messages` · consensus — Put specific, plain-language errors next to the problem, with a fix, and keep the user's input.
- `forgiving-format` · consensus — Accept common input variants, normalize them silently, and display the value in the user's locale.
- `wcag-error-identification` · standard — Identify the field in error and describe the error in text, not by color or a toast alone.
- `wcag-labels-instructions` · standard — Give every input a visible label, including optional fields, and put format hints in help text.
- `wcag-redundant-entry` · standard — Never make users retype information they already entered in the same process; prefill or offer selection.
- `chunking` · empirical — Break content into meaningful, clearly separated groups with a visible hierarchy.

## Sign-in & authentication
- `wcag-accessible-authentication` · standard — Do not require remembering, transcribing or solving puzzles to log in; allow paste and password managers.
- `postels-law` · consensus — Accept varied input formats and normalize them, while outputting consistently formatted data.
- `error-messages` · consensus — Put specific, plain-language errors next to the problem, with a fix, and keep the user's input.

## Navigation & IA
- `jakobs-law` · consensus — Follow conventions users already know from other sites; diverge only where the difference carries a clear benefit.
- `hidden-navigation` · empirical — Show primary navigation on desktop; on mobile use a labeled menu trigger plus a few visible links.
- `mobile-navigation` · consensus — Show a visible tab bar for 5 or fewer top-level items; use a labeled menu only for larger sets.
- `information-scent` · empirical — Write specific, self-explanatory link labels so users can predict what they will find before clicking.
- `serial-position-effect` · empirical — Put the most important items first and last in a sequence, and the least important in the middle.
- `breadcrumbs` · consensus — Add hierarchy-based breadcrumbs on deep sites as a supplement to navigation; skip them on flat sites.
- `mega-menus` · empirical — Use mega menus for large option sets with grouped content, real link fallbacks and forgiving hover timing.
- `steering-law` · empirical — Keep menus shallow and widen the path to submenus so diagonal pointer movement does not trigger neighbors.
- `three-click-rule` · folk — Folk rule: no evidence users quit after 3 clicks. Optimize label clarity and wayfinding, not click counts.
- `wcag-consistent-help` · standard — Put help links and contact options in the same relative place on every page.
- `search-box` · consensus — Make the search field visible, simple and wide enough for typical queries.
- `pagination-vs-infinite-scroll` · empirical — Use infinite scroll for goalless browsing; use pagination or Load More when people find, compare or need the footer.
- `mental-models` · consensus — Match patterns users already know and use their vocabulary; test, don't assume, their model.
- `least-astonishment` · consensus — Make controls behave as they look and as platform conventions suggest; never surprise users.

## Choices, menus, pricing tables
- `hicks-law` · empirical — Reduce decision time by highlighting one recommended option and revealing the rest in steps or on demand.
- `choice-overload` · contested — Contested: group, filter and compare large option sets and feature a default; never hard-cap choices on this effect alone.
- `default-effect` · empirical — Preselect the option best for the user and show it as a recommendation; never preselect consent or add-ons.
- `anchoring-effect` · empirical — Show a reference price only if it was a real price, and order plans consistently.
- `decoy-effect` · contested — Contested: a three-tier pricing table is fine, but do not rely on a decoy tier for lift.
- `progressive-disclosure` · consensus — Defer advanced or rarely used features to a secondary view, and keep disclosure to two levels.
- `single-accent-color` · convention — Use one primary accent plus semantic status colors; decorative extra accents dilute the signal.
- `millers-law` · contested — Contested: Chunk information that users must hold in memory; do not cite 7±2 as a limit on visible navigation.
- `working-memory` · empirical — Favor recognition over recall; keep earlier choices visible so users never memorize across screens.
- `cognitive-load` · empirical — Cut extraneous mental effort with familiar patterns, grouped content and only what the current step needs.
- `loss-aversion` · contested — Contested: frame losses only for true, specific consequences; never invent loss, and test instead of assuming a lift.
- `reactance` · consensus — Offer a visible decline option and suggestive copy; forced actions and nagging provoke resistance.

## Feedback, loading, errors
- `response-time-limits` · empirical — Show nothing under 0.1s, give feedback past 1s, and show progress with a way to cancel near 10s.
- `doherty-threshold` · empirical — Acknowledge every user action within 400 ms, and show progress for waits beyond about one second.
- `loading-indicators` · consensus — Pick the loading indicator by expected wait, and use skeletons that match the final layout.
- `toast-notifications` · standard — Never make a toast the only way to learn something important; auto-dismiss only non-essential messages.
- `undo-over-confirmation` · consensus — Confirm only rare, serious, hard-to-reverse actions with specific wording; offer undo for everything else.
- `modal-dialogs` · consensus — Reserve modals for critical interrupting decisions; use inline or non-modal UI for everything else.
- `empty-states` · consensus — Tell users why a view is empty, what the feature does, and give one direct action.
- `no-results-pages` · consensus — Make the no-results state obvious and give users a way forward.
- `labor-illusion` · contested — Contested: show real progress steps for real work; never add artificial delay or fake loading.
- `change-blindness` · empirical — Surface changes in or near the user's focus; never assume a visible element was noticed.
- `selective-attention` · empirical — Do not style important content like an ad or place it in ad positions; avoid competing simultaneous changes.

## Layout & grouping
- `gestalt-proximity` · empirical — Place related elements closer together than unrelated ones so groups read without borders.
- `gestalt-common-region` · empirical — Enclose related items in one bounded region; use it sparingly so it stays a signal.
- `gestalt-similarity` · empirical — Give elements of the same role the same style, and different roles visibly different styles.
- `internal-external-spacing` · consensus — Keep space inside a group smaller than the space around it, so groups stay distinct.
- `eight-point-grid` · convention — Size and space everything in multiples of 8px, using 4px only for fine adjustments.
- `crap-principles` · consensus — Check layouts for contrast, repetition, alignment and proximity as a quick design review mnemonic.
- `whitespace` · empirical — Use side margins and spacing to aid reading and grouping, but not so much that groups fall apart.
- `scanning-patterns` · empirical — Put key points in the first lines and use real headings, so scanners find content without needing the F.
- `wcag-reflow` · standard — Make content work at 320 CSS px wide with no horizontal scrolling and no clipped content.
- `gestalt-continuity` · empirical — Align elements along a clear line or curve so the eye follows them as one sequence.
- `gestalt-closure` · empirical — Let icons, logos and partial outlines imply complete shapes; viewers fill gaps, so omit redundant detail.
- `gestalt-figure-ground` · empirical — Separate the focal element from its background with contrast, so the viewer knows what is in front.
- `gestalt-uniform-connectedness` · empirical — Join related items with lines or a shared filled region when order or relation must be obvious.
- `gestalt-pragnanz` · consensus — Prefer simple, regular, stable forms; ambiguous or complex layouts get mentally simplified, often wrongly.
- `banner-blindness` · empirical — Don't style important content like ads or place it where ads sit; users skip both.
- `gutenberg-z-pattern` · folk — Folk rule: Don't place content by an assumed Z gaze path; position primary actions by contrast and size.
- `golden-ratio-rule-of-thirds` · folk — Folk rule: Don't justify UI layouts by golden or thirds proportions; split layouts by function.

## Typography & reading
- `line-length` · convention — Keep body text to about 45-75 characters per line and never beyond 80.
- `line-height` · consensus — Set body leading to about 1.4-1.6, tighter for headings, and let layouts survive user spacing changes.
- `type-scale` · convention — Use one small set of sizes, keep body at 16px or more, and limit typefaces and weights.
- `wcag-text-spacing` · standard — Build text containers that survive user overrides of line, paragraph, letter and word spacing without clipping.
- `inverted-pyramid` · consensus — Put the conclusion and key facts first, then add supporting detail in descending importance.
- `scannable-writing` · empirical — Write concise, scannable, objective copy; avoid promotional prose and long paragraphs.

## Color & contrast
- `wcag-contrast` · standard — Give text at least 4.5:1 contrast (3:1 for large text); aim for 7:1 only where AAA is a goal.
- `wcag-non-text-contrast` · standard — Give input borders, focus rings, icons and chart marks at least 3:1 contrast against adjacent colors.
- `wcag-use-of-color` · standard — Never let color alone convey meaning; pair every color signal with text, an icon, a shape or an underline.
- `apca-contrast` · consensus — Use WCAG 2 ratios for conformance; treat APCA as an optional extra check, never as a reason to fail 4.5:1.
- `single-accent-color` · convention — Use one primary accent plus semantic status colors; decorative extra accents dilute the signal.
- `color-meaning` · convention — Don't rely on color symbolism alone; keep red, amber and green for state and pair them with text or icons.
- `sixty-thirty-ten` · folk — Folk rule: Don't measure color percentages; keep mostly neutrals with one accent used sparingly.

## Focus & keyboard
- `wcag-keyboard` · standard — Make every function operable from the keyboard with no timing requirements; use native controls.
- `wcag-focus-visible` · standard — Show a clear keyboard focus indicator and make sure sticky UI never fully hides the focused element.
- `wcag-focus-order` · standard — Keep DOM order identical to visual order so keyboard focus moves in a meaningful sequence.
- `wcag-hover-focus-content` · standard — Make hover and focus popups dismissible with Esc, hoverable by the pointer, and persistent until dismissed.

## Motion
- `motion-duration` · consensus — Keep most UI animation between 100 and 500ms; shorter for frequent actions, longer for large movement.
- `reduced-motion` · consensus — Honor prefers-reduced-motion by swapping large spatial movement for opacity fades while keeping state changes visible.
- `wcag-animation-from-interactions` · standard — Let users disable motion triggered by their own interactions, unless the motion is essential.
- `wcag-pause-stop-hide` · standard — Give auto-moving content longer than 5 seconds a pause control, and never flash more than 3 times per second.
- `gestalt-common-fate` · empirical — Animate related elements together and unrelated ones apart, so motion itself signals grouping.
- `carousels` · empirical — Don't auto-advance content; make carousels user-controlled and never hide key content only inside one.

## Charts & dashboards
- `encoding-accuracy` · empirical — Encode precise comparisons as position or length on a shared scale. Use area and color for coarse patterns.
- `data-ink-ratio` · convention — Strip chart ink that encodes no data, but keep the axes and labels a reader needs.
- `zero-baseline` · consensus — Start bar charts at zero. Lines may use a non-zero axis only with clearly shown tick labels.
- `lie-factor` · convention — Make the size of the effect drawn match the size of the effect in the data.
- `direct-labeling` · consensus — Label series and bars at the data instead of in a legend, and sort bars by value.
- `chart-color-schemes` · consensus — Match palette type to data type, and use the library's chart tokens in order for categories.
- `colorblind-safe-palettes` · empirical — Use a palette built for color vision deficiency, and never rely on color alone to separate series.
- `preattentive-attributes` · empirical — Spend one strong visual attribute on the single thing that must stand out in a view.
- `small-multiples` · consensus — Repeat one small chart with shared scales per category instead of overlaying many series.
- `dual-axes` · consensus — Don't plot two series on separate y-axes. Stack panels on a shared x-axis or index both series.
- `pie-charts` · empirical — Use pies only for a few parts of one whole. Use sorted bars for anything else.
- `number-formatting` · convention — Right-align numbers, use tabular figures, fix decimals per column, and put units in headers.
- `dashboard-glanceability` · convention — Fit the key numbers on one screen with the most important view first, so a glance is enough.
- `overview-zoom-details` · convention — Show the overview first, then offer zoom and filter, and reveal detail only when asked.
- `banking-to-45` · contested — Contested: choose a line chart's aspect ratio so average slope is near 45 degrees, but don't force it.

## Onboarding & progress
- `goal-gradient-effect` · empirical — Show progress in multi-step flows, start it above zero, and make the last steps feel short.
- `endowed-progress-effect` · contested — Contested: start progress from a real completed step, never from fake pre-filled progress.
- `paradox-of-the-active-user` · consensus — Put help in context and make the first action obvious; do not rely on manuals or tutorials.
- `peak-end-rule` · empirical — Make the most intense moment and the ending of a flow good; remove negative peaks and dead ends.
- `zeigarnik-effect` · folk — Folk rule: show visible incomplete state and progress, but do not assume it motivates completion.
- `progressive-disclosure` · consensus — Defer advanced or rarely used features to a secondary view, and keep disclosure to two levels.
- `ikea-effect` · empirical — Let users customize and build, and make sure setup can be finished; do not use it for lock-in.
- `commitment-consistency` · empirical — Ask for a small real step first and allow exit at every step; the effect is small.
- `reciprocity` · consensus — Give real value first, such as a free tier or useful content, without gating it behind data demands.
- `fogg-behavior-model` · consensus — Lift ability by cutting steps and time prompts for when users are already motivated; do not nag.

## Writing & microcopy
- `button-labels` · consensus — Start button labels with a verb, use two to four words, and name the outcome.
- `plain-language` · standard — Write in short sentences, common words and active voice for your actual audience.
- `scannable-writing` · empirical — Write concise, scannable, objective copy; avoid promotional prose and long paragraphs.
- `inverted-pyramid` · consensus — Put the conclusion and key facts first, then add supporting detail in descending importance.
- `sentence-case` · convention — Set buttons, labels, headings and menu items in sentence case, and apply it consistently.
- `error-messages` · consensus — Put specific, plain-language errors next to the problem, with a fix, and keep the user's input.
- `krugs-first-law` · consensus — Make the primary action obvious, labels unambiguous, and remove questions users must answer to proceed.

## Consent, pricing, retention (ethics)
- `deceptive-design` · consensus — Review every flow against Brignull's 18 deceptive types before shipping; never fake urgency, scarcity, social proof or price.
- `consent-symmetry` · standard — Show Accept all and Reject all with identical size, weight and click count, and keep withdrawal as easy as consent.
- `gdpr-consent` · standard — Default every consent control to off, use one toggle per purpose, and disclose cookie duration and third parties.
- `easy-cancellation` · standard — Let users cancel in the same channel and about the same steps as signup, with renewal terms shown before purchase.
- `confirmshaming` · consensus — Word decline options neutrally, such as "No thanks"; never guilt or shame the user for declining.
- `dsa-article-25` · standard — Give choices equal visual weight, never re-ask a decided choice, and make cancelling no harder than subscribing.
- `ftc-dark-patterns` · standard — Disclose material terms clearly next to the action, avoid disguised ads and keep the price unambiguous.
- `social-proof` · consensus — Show real counts, ratings and reviews with their source, and never fabricate them.
- `scarcity-effect` · folk — Folk rule: show only real inventory and real deadlines; never fake low stock or resetting timers.
- `eu-accessibility-act` · standard — Build e-commerce and banking UIs on accessible primitives, with contrast, keyboard access and no color-only state.
- `hook-model` · folk — Folk rule: use trigger-action-reward-investment loops only for the user's own goals; avoid variable rewards.
- `priming` · contested — Contested: do not design around behavioral priming; use explicit content instead of hidden cues.
- `ego-depletion` · contested — Contested: do not design around willpower depletion; never justify tiring users into accepting defaults.

## Visual polish & simplicity
- `aesthetic-usability-effect` · empirical — Polish spacing, type and tokens, but never skip usability testing because the design looks good.
- `weber-fechner-law` · empirical — Use ratio-based steps for scales and make hierarchy differences large enough to be clearly noticed.
- `mere-exposure-effect` · empirical — Keep brand elements, icons and patterns consistent so familiarity builds; don't change conventions needlessly.
- `kiss` · consensus — Prefer the simplest component that does the job; cut features and options without a clear user need.
- `occams-razor` · consensus — Remove elements that do not affect function; finish only when nothing more can be taken away.

## Power users & efficiency
- `keystroke-level-model` · empirical — Count steps for frequent tasks and remove pointer switches and mental decisions; add keyboard paths.
- `power-law-of-practice` · empirical — Keep layouts and shortcuts stable and add keyboard paths so expert speed-up accumulates.
- `flow` · empirical — Give immediate feedback, remove needless interruptions, and scale difficulty to the user's skill.
- `pareto-principle` · folk — Folk rule: find top tasks in usage data, make them prominent, and demote the rest without cutting critical edge cases.
- `parkinsons-law` · folk — Folk rule: make tasks take no longer than users expect; shorten flows with autofill and defaults.

## Scoping a product or redesign
- `galls-law` · folk — Folk rule: ship one working flow end to end first, then extend; grow design systems from a small base.
- `teslers-law` · consensus — Absorb irreducible complexity in the system with defaults and automation instead of pushing it onto users.
- `jakobs-law` · consensus — Follow conventions users already know from other sites; diverge only where the difference carries a clear benefit.

## Performance
- `core-web-vitals` · standard — Meet LCP 2.5 s, INP 200 ms and CLS 0.1 at the 75th percentile of field data.
- `layout-shift` · standard — Reserve space for anything that loads late and never insert content above existing content.
- `doherty-threshold` · empirical — Acknowledge every user action within 400 ms, and show progress for waits beyond about one second.

## Self-review
- `nielsen-heuristics` · consensus — Review every screen against ten broad usability heuristics to find problems; do not use them as a pass/fail score.
- `shneiderman-golden-rules` · consensus — Check each interface against eight rules covering consistency, feedback, closure, reversal, control and memory load.
- `norman-principles` · consensus — Make possible actions discoverable with visible signifiers, clear mapping, feedback and constraints; a signifier is not an affordance.
- `rams-principles` · consensus — Judge a design against ten principles: useful, understandable, unobtrusive, honest, thorough and as little design as possible.
- `wcag-pour` · standard — Organize accessibility work under Perceivable, Operable, Understandable, Robust; only success criteria are testable.
- `tognazzini-principles` · consensus — Apply Tognazzini's actionable principles: good defaults, protect users' work, visible navigation, low latency.
