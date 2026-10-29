username:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  c = config.stylesheet.colors;
  bare = lib.removePrefix "#";
in
{
  imports = [
    ../stylesheet/options.nix
  ];

  home-manager.users.${username} = {
    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty;
      enableZshIntegration = true;
      enableBashIntegration = true;

      # sway does all window management, so drop every default (tabs, splits,
      # alt+digit goto_tab, ...) and bind only what we actually want back
      clearDefaultKeybinds = true;

      settings = {
        keybind = [
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+shift+equal=increase_font_size:1"
          "ctrl+shift+minus=decrease_font_size:1"
          "ctrl+shift+digit_0=reset_font_size"
          "ctrl+shift+page_up=scroll_page_up"
          "ctrl+shift+page_down=scroll_page_down"
          "ctrl+shift+n=new_window"
          "ctrl+shift+f=start_search"
          # performable: so escape still reaches the program outside of search
          "performable:escape=end_search"
          "ctrl+shift+comma=reload_config"
        ];
        right-click-action = "ignore"; # context menu offers tabs and splits
        window-show-tab-bar = "never";

        scrollback-limit-lines = 100000;
        confirm-close-surface = false;
        window-padding-x = 6;
        window-padding-y = 6;

        font-family = config.stylesheet.fonts.monoLiga;
        font-size = config.stylesheet.sizes.ghostty;
        theme = "jury";
      };

      # ghostty wants a named theme; "jury" is just the stylesheet colors
      # rendered in ghostty's format
      themes = {
        jury = {
          palette = lib.genList (i: "${toString i}=${c."color${toString i}"}") 16;
          background = bare c.bg;
          foreground = bare c.fg;
          cursor-color = bare c.cursor;
          cursor-text = bare c.bg;
          selection-background = bare c.selection;
          selection-foreground = bare c.fg;
        };
      };
    };
  };
}
