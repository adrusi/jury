{ ... }:
{
  # Catppuccin Latte. Values lifted verbatim from the formerly-inline
  # definitions in the app modules.
  imports = [ ./options.nix ];

  theme = {
    palette = {
      rosewater = "#dc8a78";
      flamingo = "#dd7878";
      pink = "#ea76cb";
      mauve = "#8839ef";
      red = "#d20f39";
      maroon = "#e64553";
      peach = "#fe640b";
      yellow = "#df8e1d";
      green = "#40a02b";
      teal = "#179299";
      sky = "#04a5e5";
      sapphire = "#209fb5";
      blue = "#1e66f5";
      lavender = "#7287fd";
      text = "#4c4f69";
      subtext1 = "#5c5f77";
      subtext0 = "#6c6f85";
      overlay2 = "#7c7f93";
      overlay1 = "#8c8fa1";
      overlay0 = "#9ca0b0";
      surface2 = "#acb0be";
      surface1 = "#bcc0cc";
      surface0 = "#ccd0da";
      base = "#eff1f5";
      mantle = "#e6e9ef";
      crust = "#dce0e8";
      selectionBg = "#d8dae1";
    };

    ansi = [
      "#5c5f77" # black
      "#d20f39" # red
      "#40a02b" # green
      "#df8e1d" # yellow
      "#1e66f5" # blue
      "#ea76cb" # magenta
      "#179299" # cyan
      "#acb0be" # white
      "#6c6f85" # bright black
      "#d20f39" # bright red
      "#40a02b" # bright green
      "#df8e1d" # bright yellow
      "#1e66f5" # bright blue
      "#ea76cb" # bright magenta
      "#179299" # bright cyan
      "#bcc0cc" # bright white
    ];

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
