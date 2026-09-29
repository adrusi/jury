username:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  filter_shellint_osc = ''${pkgs.perl}/bin/perl -pe 's/\x1b\]133;[ACD].*?\x1b\\//g' '';
  kak = config.home-manager.users.${username}.programs.kakoune.finalPackage;
  scrollback_viewer = pkgs.writeShellScriptBin "kakoune-kitty-scrollback-viewer" ''
    exec ${filter_shellint_osc} | ${kak}/bin/kak "$@"
  '';
  c = config.stylesheet.colors;
in {
  imports = [
    ../stylesheet/options.nix
  ];

  home-manager.users.${username} = {
    programs.kitty = {
      enable = true;

      shellIntegration.enableZshIntegration = true;
      enableGitIntegration = true;

      keybindings = {
        "kitty_mod+c" = "copy_to_clipboard";
        "kitty_mod+v" = "paste_from_clipboard";
        "kitty_mod+equal" = "change_font_size all +1.0";
        "kitty_mod+plus" = "change_font_size all +1.0";
        "kitty_mod+minus" = "change_font_size all -1.0";
        "kitty_mod+0" = "change_font_size all 0";
        "kitty_mod+page_up" = "scroll_page_up";
        "kitty_mod+page_down" = "scroll_page_down";
        "kitty_mod+n" = "launch --cwd=current --type=os-window";
        "kitty_mod+/" = "launch --stdin-source=@screen_scrollback --stdin-add-formatting ${scrollback_viewer}/bin/kakoune-kitty-scrollback-viewer";
      };

      settings = {
        scrollback_lines = 100000;
        enabled_layouts = "stack";
        clear_all_shortcuts = true;
        kitty_mod = "ctrl+shift";
        
        # ------ theming ------
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        visual_bell_duration = 0.05;
        allow_remote_control = true;
        font_family = config.stylesheet.fonts.kitty;
        bold_font = config.stylesheet.fonts.kitty_bold;
        italic_font = config.stylesheet.fonts.kitty_italic;
        bold_italic_font = config.stylesheet.fonts.kitty_bold_italic;
        font_size = config.stylesheet.sizes.kitty;
        window_padding_width = 6;

        # The basic colors
        foreground = c.fg;
        background = c.bg;
        selection_foreground = c.bg;
        selection_background = c.cursor;

        # Cursor colors
        cursor = c.cursor;
        cursor_text_color = c.bg;

        # Scrollbar colors
        scrollbar_handle_color = c.fgDim;
        scrollbar_track_color = c.surface;

        # URL color when hovering with mouse
        url_color = c.cursor;

        # Kitty window border colors
        active_border_color = c.accent;
        inactive_border_color = c.muted;
        bell_border_color = c.warning;

        # OS Window titlebar colors
        wayland_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = c.bg;
        active_tab_background = c.accent2;
        inactive_tab_foreground = c.fg;
        inactive_tab_background = c.muted;
        tab_bar_background = c.surface;

        # Colors for marks (marked text in the terminal)
        mark1_foreground = c.bg;
        mark1_background = c.accent;
        mark2_foreground = c.bg;
        mark2_background = c.accent2;
        mark3_foreground = c.bg;
        mark3_background = c.accent3;
      }
      # The 16 terminal colors
      // lib.genAttrs (map (i: "color${toString i}") (lib.range 0 15)) (name: c.${name});
    };
  };
}
