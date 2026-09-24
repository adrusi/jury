username:
{ pkgs, config, ... }:
let
  filter_shellint_osc = ''${pkgs.perl}/bin/perl -pe 's/\x1b\]133;[ACD].*?\x1b\\//g' '';
  kak = config.home-manager.users.${username}.programs.kakoune.finalPackage;
  scrollback_viewer = pkgs.writeShellScriptBin "kakoune-kitty-scrollback-viewer" ''
    exec ${filter_shellint_osc} | ${kak}/bin/kak "$@"
  '';
in {
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
        font_size = 12.0;
        window_padding_width = 6;

        # The basic colors
        foreground = "#4c4f69";
        background = "#eff1f5";
        selection_foreground = "#eff1f5";
        selection_background = "#dc8a78";

        # Cursor colors
        cursor = "#dc8a78";
        cursor_text_color = "#eff1f5";

        # Scrollbar colors
        scrollbar_handle_color = "#7c7f93";
        scrollbar_track_color = "#bcc0cc";

        # URL color when hovering with mouse
        url_color = "#dc8a78";

        # Kitty window border colors
        active_border_color = "#7287fd";
        inactive_border_color = "#9ca0b0";
        bell_border_color = "#df8e1d";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#eff1f5";
        active_tab_background = "#8839ef";
        inactive_tab_foreground = "#4c4f69";
        inactive_tab_background = "#9ca0b0";
        tab_bar_background = "#bcc0cc";

        # Colors for marks (marked text in the terminal)
        mark1_foreground = "#eff1f5";
        mark1_background = "#7287fd";
        mark2_foreground = "#eff1f5";
        mark2_background = "#8839ef";
        mark3_foreground = "#eff1f5";
        mark3_background = "#209fb5";

        # The 16 terminal colors

        # black
        color0 = "#5c5f77";
        color8 = "#6c6f85";

        # red
        color1 = "#d20f39";
        color9 = "#d20f39";

        # green
        color2 = "#40a02b";
        color10 = "#40a02b";

        # yellow
        color3 = "#df8e1d";
        color11 = "#df8e1d";

        # blue
        color4 = "#1e66f5";
        color12 = "#1e66f5";

        # magenta
        color5 = "#ea76cb";
        color13 = "#ea76cb";

        # cyan
        color6 = "#179299";
        color14 = "#179299";

        # white
        color7 = "#acb0be";
        color15 = "#eff1f5";
      };
    };
  };
}
