# Claude Code theme for design/language.md, rendered from a design palette
# (~/.claude/themes/<slug>.json; see code.claude.com/docs/en/terminal-config).
# Claude Code draws in the terminal, so this follows the terminal's rules: ink
# on paper, the hue budget (signal, second, alarm), diffs in the truecolor
# diff tokens, and chrome-like surfaces (your messages, dialogs) in panel.
{
  lib,
  mode,
  p,
}:
let
  inherit (import ../design/lib.nix { inherit lib; }) mix;
  ansi = builtins.elemAt p.ansi;
  # the "after you reject an edit" diff: halfway back to the page
  dimmed = c: mix c p.paper 0.5;
  # spinner shimmer: the colour lifted a third of the way toward ink
  shimmer = c: mix c p.ink 0.35;
  success = ansi 2;
in
{
  name = "Datasheet";
  base = mode;
  overrides = {
    # text and accent
    claude = p.signal;
    text = p.ink;
    inverseText = p.paper;
    inactive = p.ink2;
    subtle = p.dim;
    suggestion = p.signal;
    permission = p.signal;
    remember = p.second;

    # status: one alert level, as on the desktop
    inherit success;
    error = p.alarm;
    warning = p.alarm;
    merged = p.second;

    # input box and modes: the box is a quiet frame; modes are categories,
    # told apart by the hue budget in order
    promptBorder = p.rule2;
    planMode = p.second;
    autoAccept = success;
    bashBorder = p.signal;
    ide = p.ink2;
    fastMode = p.signal;
    effortUltra = p.signal;

    # diffs: the truecolor diff backgrounds behind ink
    diffAdded = p.addbg;
    diffRemoved = p.delbg;
    diffAddedWord = p.addemph;
    diffRemovedWord = p.delemph;
    diffAddedDimmed = dimmed p.addbg;
    diffRemovedDimmed = dimmed p.delbg;

    # surfaces: your entries and side panels are panel; no hover states
    userMessageBackground = p.panel;
    userMessageBackgroundHover = p.panel;
    bashMessageBackgroundColor = p.panel;
    memoryBackgroundColor = p.panel;
    composerSidebarBackground = p.panel;
    selectionBg = p.seltint;

    # usage meter and brief-mode labels
    rate_limit_fill = p.signal;
    rate_limit_empty = p.rule;
    briefLabelYou = p.ink2;
    briefLabelClaude = p.signal;

    # spinner shimmer
    claudeShimmer = shimmer p.signal;
    warningShimmer = shimmer p.alarm;
    permissionShimmer = shimmer p.signal;
    promptBorderShimmer = p.ink2;
    inactiveShimmer = p.ink;
    fastModeShimmer = shimmer p.signal;

    # subagents pick colours by name; give them the terminal's own
    red_FOR_SUBAGENTS_ONLY = ansi 1;
    green_FOR_SUBAGENTS_ONLY = ansi 2;
    yellow_FOR_SUBAGENTS_ONLY = ansi 3;
    blue_FOR_SUBAGENTS_ONLY = ansi 4;
    purple_FOR_SUBAGENTS_ONLY = ansi 5;
    cyan_FOR_SUBAGENTS_ONLY = ansi 6;
    orange_FOR_SUBAGENTS_ONLY = ansi 11;
    pink_FOR_SUBAGENTS_ONLY = ansi 13;

    # the ultrathink rainbow, from the terminal's hues
    rainbow_red = ansi 1;
    rainbow_orange = ansi 11;
    rainbow_yellow = ansi 3;
    rainbow_green = ansi 2;
    rainbow_blue = ansi 4;
    rainbow_indigo = ansi 12;
    rainbow_violet = ansi 5;
    rainbow_red_shimmer = ansi 9;
    rainbow_orange_shimmer = shimmer (ansi 11);
    rainbow_yellow_shimmer = ansi 11;
    rainbow_green_shimmer = ansi 10;
    rainbow_blue_shimmer = ansi 12;
    rainbow_indigo_shimmer = shimmer (ansi 12);
    rainbow_violet_shimmer = ansi 13;
  };
}
