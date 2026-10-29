username:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  p = config.design.palette;
  bare = lib.removePrefix "#";
in
{
  imports = [
    ../design/options.nix
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

        font-family = config.design.fonts.code;
        font-size = config.design.dims.terminalSize;
        theme = "jury";
      };

      # ghostty wants a named theme; "jury" is just the design palette rendered
      # in ghostty's format
      themes = {
        jury = {
          palette = lib.imap0 (i: hex: "${toString i}=${hex}") p.ansi;
          background = bare p.paper;
          foreground = bare p.ink;
          cursor-color = bare p.ink;
          cursor-text = bare p.paper;
          selection-background = bare p.seltint;
          selection-foreground = bare p.ink;
        };
      };
    };
  };
}
