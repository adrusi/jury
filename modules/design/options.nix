{ lib, config, ... }:
{
  # Interface for the design language (design/language.md). Colors and faces
  # are fixed by the design: a host picks only the mode and the DPI-dependent
  # dimensions. Every dimension must be set by the host; there are no hidden
  # defaults, since none of them are right across displays.
  options.design =
    let
      int = description: lib.mkOption { type = lib.types.int; inherit description; };
    in
    {
      mode = lib.mkOption {
        type = lib.types.enum [ "dark" "light" ];
        description = "Which token set to use (dark for personal machines, light for work).";
      };

      palette = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        default = (import ./palette.nix).${config.design.mode};
        defaultText = lib.literalExpression "(import ./palette.nix).\${config.design.mode}";
        description = "The token set for the chosen mode (see palette.nix).";
      };

      fonts = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        readOnly = true;
        default = {
          sans = "DIN Pro";
          mono = "Berkeley Mono";
        };
        description = "Font families. DIN names things; Berkeley Mono carries values and content.";
      };

      # dpi-contingent; device pixels on the host's built-in display unless noted
      dims = {
        titleSize = int "Point size for sway titles and mako notifications.";
        barSize = int "Pixel size for waybar text.";
        menuSize = int "Pixel size for wofi text; also scales the lock screen.";
        gaps = int "Sway inner gaps, and the gap between the bar and windows.";
        frame = int "Window frame width; also wofi, mako and lock input borders.";
        selectionRule = {
          horizontal = int "Selection rule on horizontal strips (top edge).";
          vertical = int "Selection rule on vertical strips (left edge).";
        };
        heavyRule = int "The head rule under a launcher query or the lock clock.";
        titlebarPadding = {
          horizontal = int "Sway titlebar/tab horizontal padding.";
          vertical = int "Sway titlebar/tab vertical padding.";
        };
        vtabWidth = int "swayfx vertical tab sidebar width.";
        vtabPadding = int "swayfx vertical tab top/bottom padding.";
        menuWidth = int "wofi window width.";
        menuHeight = int "wofi window height.";
        notificationWidth = int "mako notification width; also the lock input width.";
        cursorSize = int "Pointer cursor size.";
      };
    };
}
