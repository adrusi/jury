# Roarke design language

The visual language for everything that draws on screen on Autumn's machines:
the compositor, bar, launcher, notifications, lock screen, terminal, editors,
toolkit apps, Firefox chrome, and (through userstyles) the websites that are on
screen most of the time. Roarke (personal, dark) is the first host. The work
machine (light) uses the same language with the light token set.

This document is the source of truth. The nix modules implement it; when the
two disagree, fix the modules or amend this file deliberately.

`design/specimen.html` holds live mockups of the final language (bar, tiled
windows with nested tabs, a userstyled web page, launcher, notifications,
terminal palette, diffs) with a dark/light switch. It shows intent; this file
holds the rules, so check values here, not in the specimen. The exploratory
study, including rejected options, is the artifact at
https://claude.ai/artifact/8pugEW3LLioFD2jmLSNSQW.

## 1. Lineage

The reference points are the U.S. Graphics Company / Berkeley Mono sensibility
and late 20th century industrial design: engineering datasheets (National
Semiconductor databooks, HP application notes, IBM manuals) and instrument
front panels (HP bench meters, Tektronix scopes, Collins radios).

The language is a **datasheet** at its core: one ink on one paper, structure
from rules and labels, hierarchy from size and case. From the **front panel**
it takes the amber signal, the uppercase legends, and the two-material split
between the panel (chrome) and paper (content). It does not take the lamps,
grooves, or recessed wells.

## 2. Principles

1. **One ink.** Hierarchy comes from size, case, weight and position, not from
   shades of grey. Labels are full ink, small and uppercase. Secondary text
   steps down once (`ink2`). True grey (`dim`) is only for metadata:
   timestamps, IDs, counts.
2. **Rules have weight.** A 2px heavy rule marks the head of a unit, like the
   query of a launcher or the header of a page. Use at most one per surface.
   Rows within a unit are divided by 1px hairlines. Rules are mostly
   horizontal, and closed boxes are reserved for windows and popups. The bar
   has no heavy rule.
3. **Panel field, paper windows.** The desktop background, the bar, the gaps,
   and every tab strip are `panel`. Client surfaces are `paper`. They meet at
   a rule, with no inset and no doubled padding.
4. **Signal follows the mode.** Amber on dark, blue on light. Each mode's
   second terminal hue is the other mode's signal, so both machines use the
   same two hues in swapped roles.
5. **Focus is the frame.** 6px gaps, a 1px `rule` frame on every window, and a
   1px `signal` frame on the focused one. No surface lights up as a whole to
   show focus.
6. **Selection is tint plus rule, always both.** A selected item gets a tinted
   background and a rule on its strip's **outer edge**: top for horizontal
   strips (workspaces, horizontal tabs, web tabs), left for vertical strips
   (vtabs, launcher rows). On the focus path the tint and rule are `signal`
   (`seltint` behind `signal` text). Off the focus path they are neutral
   (`selgrey` behind `ink` text, `rule2` rule). A rule never appears without
   its tint.
7. **Alarm is text only.** Urgent items get `alarm`-colored text and nothing
   else: no rule, no tint, no frame color. A rule always means selection,
   including when the selected tab is scrolled out of a vtab column.
8. **A hue budget for the terminal.** Three hues at full chroma: signal,
   second, and alarm. Everything else is ink. Programs are configured to the
   budget. The unbudgeted ANSI slots (green, cyan, magenta) are muted, so a
   program that ignores the budget falls back quietly instead of turning the
   screen into a rainbow.
9. **Conventions earn truecolor.** Tools with strong color conventions, like
   diffs, may use more color, but through dedicated truecolor tokens set in
   their own config, never by leaning on a muted ANSI slot.
10. **Two faces, two widths.** DIN names things. Berkeley Mono carries values
    and content. Legends are condensed uppercase DIN. Titles and running text
    are regular-width DIN. The width tells you whether you're reading a label
    or a name.
11. **Flat, square, still.** Corner radius 0. No drop shadows, gradients,
    blur, translucency, or dimming. The swayfx effects stay off.
12. **Don't depend on clients.** Desktop chrome uses only the signals clients
    actually send: focus, urgency, title, and app ID. It assumes nothing about
    what a client draws, such as its background color at an edge. Wayland has
    one urgency level, so the language has one alert level. Patching client
    applications is out of scope.
13. **The userstyle test.** A rule must survive "same layout, new colors,
    faces, borders, corners". Anything that would need new page structure can
    only be chrome-side polish and must never carry meaning.

## 3. Tokens

The token names are the interface between this spec and the nix modules.
Colors collapse to a single light/dark switch; there are no other color
variants.

### 3.1 Neutrals

| Token   | Role                                              | Dark      | Light     |
|---------|---------------------------------------------------|-----------|-----------|
| `panel` | Desktop field, bar, gaps, tab strips, menu heads  | `#1c1b18` | `#e4dfd2` |
| `paper` | Client surfaces                                   | `#141311` | `#f3efe6` |
| `rule`  | 1px hairlines, unfocused window frames            | `#34312b` | `#c6bfaf` |
| `rule2` | Stronger hairline, off-path selection rule        | `#5a564d` | `#948d7e` |
| `heavy` | The 2px head rule                                 | `#8a8478` | `#3a3731` |
| `ink`   | Primary text and labels                           | `#e4dfd3` | `#1a1916` |
| `ink2`  | Secondary text, unselected tabs                   | `#aaa497` | `#4d4943` |
| `dim`   | Metadata only                                     | `#76716a` | `#857f73` |

### 3.2 Signal and state

| Token     | Role                                         | Dark      | Light     |
|-----------|----------------------------------------------|-----------|-----------|
| `signal`  | Focus frame, on-path selection rule and text | `#eea53a` | `#1a66cc` |
| `second`  | Second terminal hue (the other mode's signal) | `#6ea6e6` | `#a35a00` |
| `seltint` | On-path selected background                  | `#33291a` | `#d3e0f2` |
| `selgrey` | Off-path selected background                 | `#2a2823` | `#d6d0c2` |
| `alarm`   | Urgent text, critical notification frame     | `#ee5a42` | `#c02e18` |

The light signal is deliberately a mid-lightness, high-chroma blue. A thin line
reads as a color only when its chroma does the work; the earlier deep blue
(`#1d5c96`) read as a dark line instead of a blue one. `#1a66cc` is about 4.7:1
against light `paper`, so it is also usable as text.

### 3.3 Diff (truecolor)

| Token     | Role                         | Dark      | Light     |
|-----------|------------------------------|-----------|-----------|
| `addbg`   | Added line background        | `#1c2a19` | `#dcead0` |
| `addemph` | Added words, emphasis        | `#2d4625` | `#bcd9a6` |
| `delbg`   | Deleted line background      | `#2e1a16` | `#f4dad3` |
| `delemph` | Deleted words, emphasis      | `#4d241b` | `#ebb8aa` |

Diff text stays `ink`; only the backgrounds carry the color.

### 3.4 Terminal (ANSI 0–15)

The budgeted slots are full chroma. "Muted" slots are fallbacks for programs
that ignore the budget.

| Slot | Name           | Dark      | Light     | Role (dark / light)  |
|------|----------------|-----------|-----------|----------------------|
| 0    | black          | `#2a2824` | `#1a1916` | ink                  |
| 1    | red            | `#ee5a42` | `#c02e18` | alarm                |
| 2    | green          | `#a2ab84` | `#5f6b3c` | muted                |
| 3    | yellow         | `#eea53a` | `#a35a00` | signal / second      |
| 4    | blue           | `#6ea6e6` | `#1a66cc` | second / signal      |
| 5    | magenta        | `#b49aa8` | `#7a5569` | muted                |
| 6    | cyan           | `#94afa9` | `#476e66` | muted                |
| 7    | white          | `#c9c3b5` | `#c6bfaf` | ink                  |
| 8    | bright black   | `#5f5a51` | `#857f73` | ink (dim)            |
| 9    | bright red     | `#ff7a5f` | `#d6402a` | alarm                |
| 10   | bright green   | `#b7bf98` | `#707d4a` | muted                |
| 11   | bright yellow  | `#ffbd5c` | `#b86d0c` | signal / second      |
| 12   | bright blue    | `#90bdf0` | `#3b82dc` | second / signal      |
| 13   | bright magenta | `#c6adba` | `#8c667b` | muted                |
| 14   | bright cyan    | `#a9c2bc` | `#588075` | muted                |
| 15   | bright white   | `#e4dfd3` | `#f3efe6` | ink                  |

Terminal background is `paper` and foreground is `ink`. The cursor is `ink`.

## 4. Typography

- **Faces.** DIN Pro for names, labels, titles, and UI text. Berkeley Mono for
  values, paths, numbers, times, terminal and editor content, and anything the
  user typed. No other faces. Futura is retired; the lock clock is a readout
  and is set in Berkeley Mono. Fonts are fixed by the design, not
  configurable per host.
- **Legends** (bar labels like `NET` and `BAT`, notification sources, launcher
  prompt, web tab labels): DIN Pro Condensed, uppercase, medium weight, tracked
  about +7%, a step smaller than the adjacent text (about 0.85×). Legends are
  full `ink` unless they carry a state color.
- **Titles** (window and tab titles, launcher entries, notification bodies):
  regular-width DIN Pro, mixed case. Never condensed.
- **Field pattern.** A label is a legend; its value sits beside or below it in
  Berkeley Mono at full size. This is the datasheet field, and it applies in
  the bar, menus, notifications, and web pages alike.
- **Weight.** Bold is reserved for the single most important thing on a
  surface, and usually nothing qualifies. Selection is never shown by weight
  alone.
- **Figures** are tabular wherever digits line up.
- **Edge-rule compensation.** A rule drawn on a horizontal strip's top edge
  takes space from the text area. Center the text in the space below the rule,
  not in the full strip, so the rule doesn't crowd the cap height.

Sizes are host-specific (they depend on DPI) and live with the per-host
dimensions, not in this spec.

## 5. Shape and space

| Element                         | Value                                     |
|---------------------------------|-------------------------------------------|
| Corner radius                   | 0 everywhere                              |
| Window gaps (inner and outer)   | 6px, including between the bar and windows |
| Window frame                    | 1px `rule`; 1px `signal` when focused     |
| Selection rule, horizontal strip| 2px, top edge                             |
| Selection rule, vertical strip  | 3px, left edge                            |
| Head rule                       | 2px `heavy`                               |
| Hairline                        | 1px `rule`                                |

Pixel values are at the host's native scale and are part of the per-host
dimensions; the proportions above are the design.

## 6. States

| State                        | Background | Text     | Rule      | Frame    |
|------------------------------|------------|----------|-----------|----------|
| Unselected                   | `panel`    | `ink2`   | none      | —        |
| Selected, on focus path      | `seltint`  | `signal` | `signal`  | —        |
| Selected, off focus path     | `selgrey`  | `ink`    | `rule2`   | —        |
| Urgent                       | unchanged  | `alarm`  | none      | unchanged |
| Focused window               | —          | —        | —         | `signal` |
| Unfocused window             | —          | —        | —         | `rule`   |

"Focus path" means the focused window and every container tab that leads to
it. With horizontal tabs nested in a vtab, both the vtab and the htab on the
path take signal colors.

Hover and pressed states aren't specified yet.

## 7. Surfaces

### 7.1 swayfx

- `gaps inner 6`, `gaps outer 0` (outer spacing comes from the inner gap at
  the screen edges; verify against the bar).
- `default_border pixel 1`. Effects (`blur`, `shadows`, `corner_radius`,
  `default_dim_inactive`) are off.
- Color classes:

  | Class                      | border   | background | text     | indicator | child_border |
  |----------------------------|----------|------------|----------|-----------|--------------|
  | `client.focused`           | `signal` | `seltint`  | `signal` | `signal`  | `signal`     |
  | `client.focused_tab_title` | `signal` | `seltint`  | `signal` | —         | —            |
  | `client.focused_inactive`  | `rule`   | `selgrey`  | `ink`    | `rule`    | `rule`       |
  | `client.unfocused`         | `rule`   | `panel`    | `ink2`   | `rule`    | `rule`       |
  | `client.urgent`            | `rule`   | `panel`    | `alarm`  | `rule`    | `rule`       |

- Titles use regular-width DIN Pro.
- **Patch:** draw the selection rule on selected tabs (left edge on vtabs, top
  edge on horizontal tabs), using the tab's border color. This is the only
  swayfx patch the language requires. Without it the tint and text color
  still mark selection.

### 7.2 waybar

- Background `panel`, no bottom rule.
- Height matches a sway titlebar, so workspace buttons line up with tab rows.
- Binding modes (resize, vtab) are a keyboard state, not a selection: the
  mode name as an inverted legend (`ink` field, `panel` text), never the
  selection tint.
- Workspaces: `button.focused` gets `seltint` background, `signal` text, and
  `box-shadow: inset 0 2px <signal>`. Visible-but-unfocused workspaces on
  other outputs get the off-path treatment. `button.urgent` gets `alarm` text
  only.
- Modules use the field pattern: condensed legend span plus Berkeley Mono
  value. Critical readings (low battery) color the value `alarm`.

### 7.3 Launcher (wofi)

- Window: `paper` with a 1px `rule` frame.
- Query row: `panel` background, condensed legend prompt, Berkeley Mono input,
  2px `heavy` rule beneath.
- Entries: regular DIN, `ink2`. The selected entry gets `seltint`, `signal`
  text, and a 3px `signal` rule on the left.
- Metadata (entry kind) in Berkeley Mono, `dim`.

### 7.4 Notifications (mako)

- `panel` background, 1px `rule` border, radius 0.
- Format: condensed legend source line with `dim` timestamp, then the body in
  regular DIN, then any detail in Berkeley Mono `ink2`.
- `[urgency=critical]`: `alarm` border and `alarm` legend. The body stays
  `ink`.

### 7.5 Lock screen

- `panel` field. The clock is Berkeley Mono, large, with a 2px `heavy` rule
  beneath it, and the date and host as condensed legends below.
- Failed unlock colors the indicator `alarm`.

### 7.6 Terminal (ghostty)

- `background = paper`, `foreground = ink`, palette from section 3.4, cursor
  `ink`, selection `seltint` background with `ink` text.

### 7.7 Programs in the terminal

These configure programs to the hue budget:

- **zsh prompt:** `user@host` in `dim`, the directory in the second hue
  (italic), and the prompt character in signal. Errors in the last exit status
  use alarm.
- **git:** commit hashes and modified status in signal, refs in the second
  hue, and errors in alarm. `color.diff` uses the truecolor diff tokens.
- **vivid (`LS_COLORS`):** directories in bold second hue, executables in
  signal, symlinks and special files `dim`, everything else `ink`.
- **delta:** `plus-style`, `plus-emph-style`, `minus-style` and
  `minus-emph-style` use the diff tokens. Hunk headers are `dim`, and file
  headers are `ink` with a hairline.
- **Compilers and linters:** where configurable (`GCC_COLORS` etc.), warnings
  in signal and errors in alarm.

### 7.8 Editors (zed, kak)

- Hand-written themes. Editor chrome follows the desktop: `panel` for chrome,
  `paper` for buffers, and the selection and focus states from section 6.
- Syntax highlighting follows the hue budget. Most syntax is `ink`, with
  weight or italic for structure. Keywords or types take the second hue,
  literals take the signal hue, and errors take alarm. Comments are `dim`.

### 7.9 GTK and libadwaita

- Colors through `@define-color` in `gtk.css` for GTK 3 and 4: accent is
  `signal`, window backgrounds are `paper`, headerbars and sidebars are
  `panel`.
- libadwaita's radii and layout are left alone; only colors and faces are
  set. This is partial by nature.

### 7.10 Firefox and the web

- **Chrome (userChrome):** follows the desktop. The tab strip is `panel` (or
  hidden, since sway's vtabs carry tabs), the URL bar is `paper` with a
  hairline, and selected items follow section 6.
- **Userstyles:** a userstyle may change only color, faces, borders, rules,
  and corners. It may not restructure the page. Within that:
  - Recolor to the tokens: `paper` for page backgrounds, `panel` for site
    chrome (headers, sidebars, nav).
  - Faces: DIN for UI text, Berkeley Mono for code, data, and identifiers.
    Legend-like labels become condensed uppercase DIN.
  - Radius 0. Outlines and chips become rules or plain legends.
  - Active tabs and nav items get tint plus a top rule.
  - Links are `ink` with a `rule2` underline. They are not colored, because
    signal means selection.
  - A page header gets the 2px `heavy` rule.
  - **Content keeps its meaningful color**: CI status, diffs, charts, syntax
    highlighting, and status badges keep their semantics, mapped onto
    `alarm`, the diff tokens, and the hue budget. Chrome loses decorative hue;
    content does not lose meaning.

## 8. Implementation notes

- **Required patch:** the swayfx selection-rule patch (section 7.1). Nothing
  else in the language needs a patch.
- **Nix structure.** The current `modules/stylesheet` system mixes DPI
  compensation, color variants, and font choices. Under this language:
  - per-host dimensions (sizes, gaps, cursor size, toolkit scale) stay as a
    small per-host module, since DPI really does vary by host;
  - colors become one fixed palette with a light/dark switch, generated from
    the token tables in section 3;
  - fonts are fixed by the design and stop being options.

  The token names in section 3 are the intended interface for that
  reorganization.

## 9. Rejected alternatives

Recorded so they don't get reproposed without new reasons.

- **Indicator lamps** (Front Panel). They clash with favicons in the vtabs.
- **Recessed client wells.** They double the padding, which is bad for tiling
  side by side on a 13.5" panel.
- **No gaps.** A 1px focus border without gaps is too hard to see. Thick
  borders on all sides would be ugly.
- **Lit tab column for focus.** It's redundant once gaps make the 1px frame
  legible, and it complicates nested tab containers.
- **Paper tab** (the selected tab merging into the client). It depends on the
  client's background at the edge, which can't be guaranteed.
- **Warning-level leading rule.** Wayland has no second urgency level, and
  clients can't be patched.
- **Alarm edge rule.** It reads as selection in a different color.
- **Inverse Video** (monochrome, selection by inversion). Too much contrast
  and hard on the eyes. Its heavier use of amber and red survives here.
- **Grey hierarchy, boxes around everything, link-blue accent.** That read as
  a "2009 serious website" rather than a datasheet.
- **Uniformly low-chroma ANSI.** Drab. The problem was every hue at once, not
  chroma.
- **Condensed DIN for titles.** Too hard to read. Condensed is for legends
  only.
- **Futura.** Out of place in this lineage.
- **Trailing or mixed edge rules.** Outer edges (top and left) won once the
  rule is compensated for (section 4), and they're consistent.

## 10. Open items

- Hover and pressed states.
- The swayfx selection-rule patch.
- Whether ghostty's bell should set urgency (it then takes the alarm text
  treatment like any urgent window).
- The nix reorganization described in section 8.
- A machine-readable token file (likely JSON, read with `builtins.fromJSON`)
  generated from or replacing the tables in section 3.
