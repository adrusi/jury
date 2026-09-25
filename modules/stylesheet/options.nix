{ lib, ... }:
{
  # Declarations for the stylesheet interface consumed by the UI modules
  # (sway, kitty, ghostty, zathura, zed, zsh, kak, vscode). A stylesheet
  # module (latte.nix and future siblings) defines *all* of these values —
  # there are no hidden defaults — so copying an existing stylesheet gives a
  # complete starting point. Each host imports exactly one stylesheet, plus a
  # font module (e.g. modules/home/pragmatapro.nix) that supplies the font
  # packages and font-specific quirks matching the stylesheet's font names.
  # UI modules that read config.stylesheet import this file themselves; the
  # module system deduplicates path imports.
  options.stylesheet = {
    colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        All colors ("#rrggbb") consumed by the UI modules, in one flat
        namespace: semantic roles (bg, fg, accent, accent2, accent3, error,
        warning, muted, fgDim, surface, cursor, selection) alongside the
        plain terminal colors (color0..color15). The stylesheet is
        responsible for keeping the two groups coherent with each other.
      '';
    };

    fonts = {
      ui = lib.mkOption {
        type = lib.types.str;
        description = "Family for bars, menus, notifications, window titles (also ghostty and zathura, historically).";
      };
      mono = lib.mkOption {
        type = lib.types.str;
        description = "Monospace family (kitty).";
      };
      monoLiga = lib.mkOption {
        type = lib.types.str;
        description = "Monospace family with ligatures (zed, vscode).";
      };
    };

    # font sizes (dpi-contingent, like dims)
    sizes = {
      wm = lib.mkOption {
        type = lib.types.int;
        description = "Point size for sway titlebars and mako notifications.";
      };
      bar = lib.mkOption {
        type = lib.types.int;
        description = "Pixel size for waybar.";
      };
      menu = lib.mkOption {
        type = lib.types.int;
        description = "Pixel size for wofi.";
      };
      kitty = lib.mkOption { type = lib.types.float; };
      ghostty = lib.mkOption { type = lib.types.int; };
      zathura = lib.mkOption { type = lib.types.int; };
      zedBuffer = lib.mkOption { type = lib.types.int; };
      zedUi = lib.mkOption { type = lib.types.int; };
      zedTerminal = lib.mkOption { type = lib.types.int; };
    };

    # ui geometry (dpi-contingent)
    dims = {
      gaps = lib.mkOption {
        type = lib.types.int;
        description = "Sway inner gaps; also waybar module spacing (px).";
      };
      borderWidth = lib.mkOption {
        type = lib.types.int;
        description = "Border width for sway windows, wofi, and mako (px).";
      };
      cornerRadius = lib.mkOption {
        type = lib.types.int;
        description = "Corner radius for sway windows and mako (px); wofi renders at +2.";
      };
      menuWidth = lib.mkOption {
        type = lib.types.int;
        description = "wofi window width (px).";
      };
      menuHeight = lib.mkOption {
        type = lib.types.int;
        description = "wofi window height (px).";
      };
      notificationWidth = lib.mkOption {
        type = lib.types.int;
        description = "mako notification width (px).";
      };
      vtabWidth = lib.mkOption {
        type = lib.types.int;
        description = "swayfx vertical tab sidebar width (px).";
      };
      cursorSize = lib.mkOption {
        type = lib.types.int;
        description = "Pointer cursor size.";
      };
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
  };
}
