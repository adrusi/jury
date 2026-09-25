{ ... }:
{
  # Catppuccin Latte at kerapace-era sizes, as extracted from the
  # formerly-inline definitions. To make a new stylesheet, copy this file and
  # point the host's stylesheet import at the copy (pairing it with a font
  # module that provides the families named under `fonts`).
  imports = [ ./options.nix ];

  stylesheet = {
    colors = {
      # ---- semantic roles (old catppuccin latte name in comments) ----
      bg = "#eff1f5"; # base
      fg = "#4c4f69"; # text
      accent = "#7287fd"; # lavender: focused borders, highlights, statusbars
      accent2 = "#8839ef"; # mauve: kitty active tab, mark2
      accent3 = "#209fb5"; # sapphire: kitty mark3
      error = "#fe640b"; # peach: urgent workspaces, failed unlock, critical battery
      warning = "#df8e1d"; # yellow: kitty bell border
      muted = "#9ca0b0"; # overlay0: inactive borders and tabs
      fgDim = "#7c7f93"; # overlay2: kitty scrollbar handle
      surface = "#bcc0cc"; # surface1: kitty scrollbar track and tab bar
      cursor = "#dc8a78"; # rosewater: cursor, URL hover, kitty selection
      selection = "#d8dae1"; # ghostty selection background

      # ---- terminal colors ----
      color0 = "#5c5f77"; # black
      color1 = "#d20f39"; # red
      color2 = "#40a02b"; # green
      color3 = "#df8e1d"; # yellow
      color4 = "#1e66f5"; # blue
      color5 = "#ea76cb"; # magenta (also zathura's inputbar)
      color6 = "#179299"; # cyan
      color7 = "#acb0be"; # white
      color8 = "#6c6f85"; # bright black
      color9 = "#d20f39"; # bright red
      color10 = "#40a02b"; # bright green
      color11 = "#df8e1d"; # bright yellow
      color12 = "#1e66f5"; # bright blue
      color13 = "#ea76cb"; # bright magenta
      color14 = "#179299"; # bright cyan
      color15 = "#bcc0cc"; # bright white
    };

    fonts = {
      ui = "PragmataPro";
      mono = "PragmataPro Mono";
      monoLiga = "PragmataPro Mono Liga";
    };

    sizes = {
      wm = 9;
      bar = 13;
      menu = 14;
      kitty = 12.0;
      ghostty = 11;
      zathura = 10;
      zedBuffer = 14;
      zedUi = 16;
      zedTerminal = 14;
    };

    dims = {
      gaps = 8;
      borderWidth = 3;
      cornerRadius = 6;
      menuWidth = 640;
      menuHeight = 480;
      notificationWidth = 300;
      vtabWidth = 180;
      cursorSize = 24;
    };

    vivid = "catppuccin-latte";
    kak.colorscheme = "latte";
    zed = {
      theme = "Catppuccin Latte";
      iconTheme = "Catppuccin Latte";
      extensions = [
        "catppuccin"
        "catppuccin-icons"
      ];
    };
  };
}
