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
  p = config.theme.palette;
in {
  imports = [
    ../theme/options.nix
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
        font_size = config.theme.sizes.kitty;
        window_padding_width = 6;

        # The basic colors
        foreground = p.text;
        background = p.base;
        selection_foreground = p.base;
        selection_background = p.rosewater;

        # Cursor colors
        cursor = p.rosewater;
        cursor_text_color = p.base;

        # Scrollbar colors
        scrollbar_handle_color = p.overlay2;
        scrollbar_track_color = p.surface1;

        # URL color when hovering with mouse
        url_color = p.rosewater;

        # Kitty window border colors
        active_border_color = p.lavender;
        inactive_border_color = p.overlay0;
        bell_border_color = p.yellow;

        # OS Window titlebar colors
        wayland_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = p.base;
        active_tab_background = p.mauve;
        inactive_tab_foreground = p.text;
        inactive_tab_background = p.overlay0;
        tab_bar_background = p.surface1;

        # Colors for marks (marked text in the terminal)
        mark1_foreground = p.base;
        mark1_background = p.lavender;
        mark2_foreground = p.base;
        mark2_background = p.mauve;
        mark3_foreground = p.base;
        mark3_background = p.sapphire;
      }
      # The 16 terminal colors
      // lib.listToAttrs (
        lib.imap0 (i: c: {
          name = "color${toString i}";
          value = c;
        }) config.theme.ansi
      );
    };
  };
}
