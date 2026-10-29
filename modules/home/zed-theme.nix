# Zed theme for design/language.md, rendered from a design palette. Chrome is
# panel, buffers and the terminal are paper, selection is the tint, and syntax
# follows the terminal hue budget: keywords and types in the second hue,
# literals in signal, errors in alarm, comments dim, everything else ink.
{ mode, p }:
let
  name = if mode == "dark" then "Datasheet Dark" else "Datasheet Light";
  ansi = i: builtins.elemAt p.ansi i;
  # translucent variant of a token, for overlays zed draws on top of text
  alpha = hex: a: "${hex}${a}";
  plain = color: { inherit color; };
  italic = color: { inherit color; font_style = "italic"; };
  weight = font_weight: color: { inherit color font_weight; };
in
{
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  inherit name;
  author = "Autumn Russell";
  themes = [
    {
      inherit name;
      appearance = mode;
      style = {
        # surfaces
        "background" = p.panel;
        "surface.background" = p.panel;
        "elevated_surface.background" = p.panel;
        "panel.background" = p.panel;
        "title_bar.background" = p.panel;
        "title_bar.inactive_background" = p.panel;
        "toolbar.background" = p.paper;
        "status_bar.background" = p.panel;
        "tab_bar.background" = p.panel;
        "tab.inactive_background" = p.panel;
        "tab.active_background" = p.seltint;
        "editor.background" = p.paper;
        "editor.gutter.background" = p.paper;
        "editor.subheader.background" = p.panel;
        "editor.active_line.background" = alpha p.selgrey "80";
        "editor.highlighted_line.background" = p.selgrey;
        "search.match_background" = alpha p.signal "40";
        "editor.document_highlight.read_background" = alpha p.selgrey "c0";
        "editor.document_highlight.write_background" = alpha p.selgrey "c0";

        # rules
        "border" = p.rule;
        "border.variant" = p.rule;
        "border.focused" = p.signal;
        "border.selected" = p.signal;
        "border.transparent" = "#00000000";
        "border.disabled" = p.rule;
        "panel.focused_border" = p.signal;
        "pane.focused_border" = p.signal;
        "pane_group.border" = p.rule;
        "editor.indent_guide" = p.rule;
        "editor.indent_guide_active" = p.rule2;
        "editor.wrap_guide" = p.rule;
        "editor.active_wrap_guide" = p.rule2;
        "scrollbar.track.background" = "#00000000";
        "scrollbar.track.border" = "#00000000";
        "scrollbar.thumb.background" = alpha p.rule2 "80";
        "scrollbar.thumb.hover_background" = p.rule2;
        "scrollbar.thumb.border" = "#00000000";

        # elements
        "element.background" = p.panel;
        "element.hover" = p.selgrey;
        "element.active" = p.seltint;
        "element.selected" = p.seltint;
        "element.disabled" = p.panel;
        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = p.selgrey;
        "ghost_element.active" = p.seltint;
        "ghost_element.selected" = p.seltint;
        "ghost_element.disabled" = "#00000000";
        "drop_target.background" = alpha p.seltint "80";

        # text and icons
        "text" = p.ink;
        "text.muted" = p.ink2;
        "text.placeholder" = p.dim;
        "text.disabled" = p.dim;
        "text.accent" = p.signal;
        "icon" = p.ink2;
        "icon.muted" = p.dim;
        "icon.disabled" = p.dim;
        "icon.placeholder" = p.dim;
        "icon.accent" = p.signal;
        "link_text.hover" = p.signal;
        "editor.foreground" = p.ink;
        "editor.line_number" = p.dim;
        "editor.active_line_number" = p.ink;
        "editor.invisible" = p.rule2;

        # state
        "error" = p.alarm;
        "error.background" = p.panel;
        "error.border" = p.alarm;
        "warning" = p.signal;
        "warning.background" = p.panel;
        "warning.border" = p.signal;
        "info" = p.ink2;
        "info.background" = p.panel;
        "info.border" = p.rule;
        "hint" = p.dim;
        "hint.background" = p.panel;
        "hint.border" = p.rule;
        "success" = p.second;
        "success.background" = p.panel;
        "success.border" = p.rule;
        "created" = p.second;
        "created.background" = p.addbg;
        "modified" = p.signal;
        "modified.background" = p.panel;
        "deleted" = p.alarm;
        "deleted.background" = p.delbg;
        "conflict" = p.alarm;
        "conflict.background" = p.delbg;
        "ignored" = p.dim;
        "hidden" = p.dim;
        "unreachable" = p.dim;
        "predictive" = p.dim;
        "renamed" = p.signal;
        "version_control.added" = p.second;
        "version_control.modified" = p.signal;
        "version_control.deleted" = p.alarm;

        # terminal
        "terminal.background" = p.paper;
        "terminal.foreground" = p.ink;
        "terminal.bright_foreground" = p.ink;
        "terminal.dim_foreground" = p.ink2;
        "terminal.ansi.black" = ansi 0;
        "terminal.ansi.red" = ansi 1;
        "terminal.ansi.green" = ansi 2;
        "terminal.ansi.yellow" = ansi 3;
        "terminal.ansi.blue" = ansi 4;
        "terminal.ansi.magenta" = ansi 5;
        "terminal.ansi.cyan" = ansi 6;
        "terminal.ansi.white" = ansi 7;
        "terminal.ansi.bright_black" = ansi 8;
        "terminal.ansi.bright_red" = ansi 9;
        "terminal.ansi.bright_green" = ansi 10;
        "terminal.ansi.bright_yellow" = ansi 11;
        "terminal.ansi.bright_blue" = ansi 12;
        "terminal.ansi.bright_magenta" = ansi 13;
        "terminal.ansi.bright_cyan" = ansi 14;
        "terminal.ansi.bright_white" = ansi 15;

        players = [
          {
            cursor = p.signal;
            background = p.signal;
            selection = alpha p.seltint "ff";
          }
        ];

        syntax = {
          "comment" = italic p.dim;
          "comment.doc" = italic p.dim;
          "keyword" = plain p.second;
          "type" = plain p.second;
          "type.builtin" = plain p.second;
          "constructor" = plain p.second;
          "attribute" = italic p.second;
          "string" = plain p.signal;
          "string.escape" = plain p.signal;
          "string.regex" = plain p.signal;
          "string.special" = plain p.signal;
          "number" = plain p.signal;
          "boolean" = plain p.signal;
          "constant" = plain p.signal;
          "function" = weight 600 p.ink;
          "function.method" = weight 600 p.ink;
          "variable" = plain p.ink;
          "variable.special" = plain p.ink;
          "property" = plain p.ink;
          "label" = plain p.ink2;
          "namespace" = plain p.ink2;
          "operator" = plain p.ink;
          "punctuation" = plain p.ink2;
          "punctuation.bracket" = plain p.ink2;
          "punctuation.delimiter" = plain p.ink2;
          "punctuation.special" = plain p.ink2;
          "tag" = plain p.second;
          "title" = weight 700 p.ink;
          "emphasis" = italic p.ink;
          "emphasis.strong" = weight 700 p.ink;
          "link_text" = plain p.second;
          "link_uri" = italic p.second;
          "text.literal" = plain p.signal;
          "preproc" = plain p.dim;
          "embedded" = plain p.ink;
          "hint" = plain p.dim;
          "predictive" = italic p.dim;
        };
      };
    }
  ];
}
