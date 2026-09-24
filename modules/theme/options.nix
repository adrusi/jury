{ lib, ... }:
{
  # Declarations for the theme interface consumed by the app modules
  # (sway, kitty, ghostty, zathura, zed, zsh, kak, and the font module).
  # Values live in sibling theme modules (latte.nix), imported at the host
  # layer so that different hosts can run different themes. App modules that
  # read config.theme import this file themselves; the module system
  # deduplicates path imports.
  options.theme = {
    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Named colors (\"#rrggbb\") used throughout the desktop modules.";
    };

    ansi = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The 16 terminal colors: normal 0-7, then bright 8-15.";
    };

    fonts.ui = lib.mkOption {
      type = lib.types.str;
      description = "Font family for bars, menus, notifications, and window titles.";
    };

    vivid = lib.mkOption {
      type = lib.types.str;
      description = "vivid theme name used to generate LS_COLORS.";
    };

    kak.colorscheme = lib.mkOption {
      type = lib.types.str;
      description = "kakoune colorscheme name.";
    };

    zed = {
      theme = lib.mkOption { type = lib.types.str; };
      iconTheme = lib.mkOption { type = lib.types.str; };
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Zed extensions that supply the theme.";
      };
    };

    # Sizes are a per-host (DPI) concern rather than a per-scheme one, so they
    # carry defaults here and hosts override as needed.
    sizes = {
      wm = lib.mkOption {
        type = lib.types.int;
        default = 9;
        description = "Point size for sway titlebars and mako notifications.";
      };
      bar = lib.mkOption {
        type = lib.types.int;
        default = 13;
        description = "Pixel size for waybar.";
      };
      menu = lib.mkOption {
        type = lib.types.int;
        default = 14;
        description = "Pixel size for wofi.";
      };
      kitty = lib.mkOption {
        type = lib.types.float;
        default = 12.0;
      };
      ghostty = lib.mkOption {
        type = lib.types.int;
        default = 11;
      };
      zedBuffer = lib.mkOption {
        type = lib.types.int;
        default = 14;
      };
      zedUi = lib.mkOption {
        type = lib.types.int;
        default = 16;
      };
      zedTerminal = lib.mkOption {
        type = lib.types.int;
        default = 14;
      };
    };
  };
}
