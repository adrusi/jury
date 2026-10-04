{ pkgs, ... }:
{
  # Catppuccin Mocha, sized for the Framework's 2256x1504 13.5" panel.
  imports = [ ./options.nix ];

  fonts.packages = [ pkgs.noto-fonts pkgs.nerd-fonts.noto pkgs.noto-sans-condensed-static ];

  stylesheet = {
    colors = {
      # ---- semantic roles (catppuccin mocha name in comments) ----
      bg = "#1e1e2e"; # base
      fg = "#cdd6f4"; # text
      accent = "#b4befe"; # lavender: focused borders, highlights, statusbars
      accent2 = "#cba6f7"; # mauve: kitty active tab, mark2
      accent3 = "#74c7ec"; # sapphire: kitty mark3
      error = "#fab387"; # peach: urgent workspaces, failed unlock, critical battery
      warning = "#f9e2af"; # yellow: kitty bell border
      muted = "#6c7086"; # overlay0: inactive borders and tabs
      fgDim = "#9399b2"; # overlay2: kitty scrollbar handle
      surface = "#45475a"; # surface1: kitty scrollbar track and tab bar
      cursor = "#f5e0dc"; # rosewater: cursor, URL hover, kitty selection
      selection = "#353749"; # ghostty selection background

      # ---- terminal colors ----
      color0 = "#45475a"; # black
      color1 = "#f38ba8"; # red
      color2 = "#a6e3a1"; # green
      color3 = "#f9e2af"; # yellow
      color4 = "#89b4fa"; # blue
      color5 = "#f5c2e7"; # magenta (also zathura's inputbar)
      color6 = "#94e2d5"; # cyan
      color7 = "#bac2de"; # white
      color8 = "#585b70"; # bright black
      color9 = "#f38ba8"; # bright red
      color10 = "#a6e3a1"; # bright green
      color11 = "#f9e2af"; # bright yellow
      color12 = "#89b4fa"; # bright blue
      color13 = "#f5c2e7"; # bright magenta
      color14 = "#94e2d5"; # bright cyan
      color15 = "#a6adc8"; # bright white
    };

    fonts = {
      ui = "NotoSans NFP Cond";
      kitty = "family='NotoSansM Nerd Font Mono' style='Condensed Regular'";
      kitty_bold = "family='NotoSansM Nerd Font Mono' style='Condensed SemiBold'";
      kitty_italic = "family='NotoSansM Nerd Font Mono' style='Condensed Regular'";
      kitty_bold_italic = "family='NotoSansM Nerd Font Mono' style='Condensed SemiBold'";
      monoLiga = "NotoSansM NFM ExtCond";
    };

    sizes = {
      wm = 12;
      bar = 16;
      menu = 20;
      kitty = 13.0;
      ghostty = 16;
      zathura = 16;
      zedBuffer = 18;
      zedUi = 20;
      zedTerminal = 18;
    };

    dims = {
      gaps = 10;
      borderWidth = 4;
      titlebarPadding = {
        horizontal = 9;
        vertical = 6;
      };
      cornerRadius = 8;
      menuWidth = 800;
      menuHeight = 600;
      notificationWidth = 400;
      vtabWidth = 200;
      cursorSize = 36;
    };

    toolkitScale = 1.25;
    colorScheme = "prefer-dark";
    vivid = "catppuccin-mocha";
    kak.colorscheme = "mocha";
    zed = {
      theme = "Catppuccin Mocha";
      iconTheme = "Catppuccin Mocha";
      extensions = [
        "catppuccin"
        "catppuccin-icons"
      ];
    };
  };
}
