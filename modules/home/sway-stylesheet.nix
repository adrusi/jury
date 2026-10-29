username:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.stylesheet)
    colors
    fonts
    sizes
    dims
    ;
  inherit (colors)
    bg
    fg
    accent
    error
    muted
    ;
  gaps = toString dims.gaps;

  # "#rrggbb" -> "r, g, b" (decimal), for CSS rgb()/rgba()
  rgbCsv =
    hex:
    let
      h = lib.toLower (lib.removePrefix "#" hex);
      digits = lib.stringToCharacters "0123456789abcdef";
      val = c: lib.lists.findFirstIndex (d: d == c) (throw "bad hex digit '${c}'") digits;
      byte = i: val (lib.substring i 1 h) * 16 + val (lib.substring (i + 1) 1 h);
    in
    lib.concatMapStringsSep ", " (i: toString (byte i)) [
      0
      2
      4
    ];
in
{
  # The stylesheet-driven look for the desktop shell (sway, waybar, wofi,
  # mako, hyprlock), as it was before design/language.md. Pairs with the
  # behavior in sway.nix. Hosts still on a modules/stylesheet theme import
  # this; hosts on the design language import sway-design.nix instead.
  imports = [
    ../stylesheet/options.nix
  ];

  home-manager.users.${username} = {
    home.sessionVariables = lib.optionalAttrs (config.stylesheet.toolkitScale != 1.0) {
      QT_SCALE_FACTOR = config.stylesheet.toolkitScale;
    };

    home.pointerCursor = {
      enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = dims.cursorSize;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
    };

    dconf.settings = lib.mkMerge [
      (lib.mkIf (config.stylesheet.colorScheme != "default") {
        "org/gnome/desktop/interface".color-scheme = config.stylesheet.colorScheme;
      })
      (lib.mkIf (config.stylesheet.toolkitScale != 1.0) {
        "org/gnome/desktop/interface".text-scaling-factor = config.stylesheet.toolkitScale;
      })
    ];

    programs.wofi = {
      settings = {
        width = dims.menuWidth;
        height = dims.menuHeight;
      };
      style = lib.concatStrings (
        lib.mapAttrsToList (name: hex: ''
          @define-color	${name}  ${hex};
          @define-color	${name}-rgb  rgb(${rgbCsv hex});
        '') colors
      )
      + ''
        * {
          font-family: '${fonts.ui}', monospace;
          font-size: ${toString sizes.menu}px;
        }

        /* Window */
        window {
          margin: 0px;
          padding: 10px;
          border: ${toString dims.borderWidth}px solid @accent;
          /* +2px over the radius used everywhere else because wofi has some weird scaling? */
          border-radius: ${toString (dims.cornerRadius + 2)}px;
          /* @bg at 99% opacity; forces wofi to enable alpha blending so border-radius works */
          background-color: rgba(${rgbCsv bg}, 0.99);
        }

        /* Inner Box */
        #inner-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: @bg;
        }

        /* Outer Box */
        #outer-box {
          margin: 5px;
          padding: 10px;
          border: none;
          background-color: @bg;
        }

        /* Scroll */
        #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: @bg;
        }

        /* Input */
        #input {
          margin: 0 0 10px 0;
          padding: 10px;
          border: none;
          border-radius: ${toString (dims.cornerRadius + 2)}px;
          color: @fg;
          background-color: @bg;
        }

        #input image {
          border: none;
          color: @accent;
        }

        #input * {
          outline: 4px solid @accent!important;
        }

        /* Text */
        #text {
          margin: 5px;
          border: none;
          color: @fg;
        }

        #entry {
          background-color: @bg;
        }

        #entry arrow {
          border: none;
          color: @accent;
        }

        /* Selected Entry */
        #entry:selected {
          outline: 1px solid @accent;
        }

        #entry:drop(active) {
          background-color: @accent!important;
        }
      '';
    };

    services.mako.settings = {
      background-color = bg;
      text-color = fg;
      border-color = accent;
      border-radius = dims.cornerRadius;
      border-size = dims.borderWidth;
      font = "${fonts.ui} ${toString sizes.wm}";
      outer-margin = 8;
      margin = 8;
      padding = 9;
      width = dims.notificationWidth;
    };

    programs.waybar = {
      settings.mainBar = {
        clock.format = "{:%Y-%m-%d %H:%M}";
        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "";
          format-disconnected = "";
        };
        backlight = {
          format = "{icon} {percent}%";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };
        battery = {
          format = "{icon} {capacity}%";
          format-icons = {
            default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
          };
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
        };
      };
      style = ''
        * {
          font-family: ${fonts.ui}, NotoSans NFP Cond;
          font-size: ${toString sizes.bar}px;
          min-height: 0;
        }

        #waybar {
          background: transparent;
          color: ${fg};
          margin: 0;
          padding-bottom: ${toString (dims.gaps / 2)}px;
        }

        #workspaces {
          margin-left: ${gaps}px;
        }
        #workspaces button {
          transition: 0s;
          border-radius: 0;
          color: ${fg};
          border: 0;
          background: transparent;
          padding-top: ${toString dims.gaps}px;
          padding-left: ${toString (dims.gaps / 2)}px;
          padding-right: ${toString (dims.gaps / 2)}px;
          padding-bottom: 0;
          margin-right: ${gaps}px;
        }
        #workspaces button:hover {
          background: transparent;
          border: 0;
        }
        #workspaces button.focused {
          padding-top: ${toString (dims.gaps - dims.borderWidth)}px;
          border-top: ${toString dims.borderWidth}px solid ${accent};
        }
        #workspaces button.urgent {
          color: ${error};
        }

        #mode {
          margin-top: ${toString (dims.gaps / 2)}px;
          margin-left: ${toString dims.gaps}px;
          background: ${accent};
          font-size: ${toString sizes.bar}px;
          color: ${bg};
          padding-left: ${toString (dims.gaps / 2)}px;
          padding-right: ${toString (dims.gaps / 2)}px;
        }

        #clock {
          color: ${fg};
          padding-top: ${toString dims.gaps}px;
        }

        #network {
          padding-top: ${toString dims.gaps}px;
          margin-right: ${gaps}px;
        }

        #backlight {
          padding-top: ${toString dims.gaps}px;
          margin-right: ${gaps}px;
        }

        #pulseaudio {
          padding-top: ${toString dims.gaps}px;
          margin-right: ${gaps}px;
        }

        #battery {
          padding-top: ${toString dims.gaps}px;
          margin-right: ${gaps}px;
        }
        #battery.critical {
          color: ${error};
        }
      '';
    };

    wayland.windowManager.sway = {
      config = {
        fonts = { names = [ "${fonts.ui}"]; size = "${toString sizes.wm}"; };
        gaps.inner = dims.gaps;
      };
      extraConfig = ''
        vtab_width ${toString dims.vtabWidth}
        vtab_padding ${toString (dims.vtabPadding)}
        corner_radius ${toString dims.cornerRadius}
        default_border normal ${toString dims.borderWidth}
        titlebar_padding ${toString dims.titlebarPadding.horizontal} ${toString dims.titlebarPadding.vertical}

        for_window [floating] shadows enable

        output * bg ${bg} solid_color

        # target                 title       bg      text     indicator    border
        client.focused           ${accent} ${accent} ${bg}  ${accent} ${accent}
        client.focused_inactive  ${muted} ${accent} ${bg}  ${muted} ${muted}
        client.unfocused         ${muted} ${bg} ${fg}  ${muted} ${muted}
        client.urgent            ${error}    ${error} ${bg} ${error}  ${error}
        client.placeholder       ${muted} ${bg} ${fg}  ${muted}  ${muted}
        client.background        ${bg}
      '';
    };

    programs.hyprlock.settings =
      let
        rgb = hex: "rgb(${lib.removePrefix "#" hex})";
      in
      {
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        label = [
          {
            text = "$TIME";
            color = rgb fg;
            font_family = fonts.uiDisplay;
            font_size = sizes.menu * 4;
            position = "0, ${toString (sizes.menu * 4)}";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            size = "${toString dims.notificationWidth}, ${toString (sizes.menu * 3)}";
            outline_thickness = dims.borderWidth;
            rounding = dims.cornerRadius;
            outer_color = rgb accent;
            inner_color = rgb bg;
            font_color = rgb fg;
            font_family = fonts.ui;
            check_color = rgb accent;
            fail_color = rgb error;
            capslock_color = rgb colors.warning;
            fade_on_empty = false;
            placeholder_text = if config.services.fprintd.enable then "$FPRINTPROMPT" else "";
            fail_text = "$FAIL";
            position = "0, -${toString (sizes.menu * 2)}";
            halign = "center";
            valign = "center";
          }
        ];
      };
  };
}
