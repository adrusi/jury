username:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.design) palette fonts dims;
  p = palette;
  px = n: "${toString n}px";

  # Pango markup for the datasheet field (design/language.md section 4): a
  # condensed uppercase DIN legend, and a Berkeley Mono value beside it.
  # letter_spacing is in 1/1024 pt; ~800 is the spec's +7% at these sizes.
  legend =
    text:
    ''<span font_family="${fonts.sans}" font_stretch="condensed" font_weight="medium" size="smaller" letter_spacing="800" text_transform="uppercase">${text}</span>'';
  value = text: ''<span font_family="${fonts.mono}">${text}</span>'';
  quiet = text: ''<span font_family="${fonts.mono}" foreground="${p.ink2}">${text}</span>'';
  field = l: v: "${legend l} ${v}";

  rgb = hex: "rgb(${lib.removePrefix "#" hex})";
in
{
  # The desktop shell (sway, waybar, wofi, mako, hyprlock, cursor) styled per
  # design/language.md. Pairs with the behavior in sway.nix. The host sets
  # design.mode and design.dims.
  imports = [
    ../design/options.nix
    # toolkitScale still lives in the stylesheet, which firefox reads too
    ../stylesheet/options.nix
  ];

  fonts.packages = [
    pkgs.berkeley-mono-font
    pkgs.ff-din-font
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
      {
        "org/gnome/desktop/interface".color-scheme =
          if config.design.mode == "dark" then "prefer-dark" else "prefer-light";
      }
      (lib.mkIf (config.stylesheet.toolkitScale != 1.0) {
        "org/gnome/desktop/interface".text-scaling-factor = config.stylesheet.toolkitScale;
      })
    ];

    # ---- sway (section 7.1) ----
    wayland.windowManager.sway = {
      config = {
        fonts = {
          names = [ fonts.sans ];
          size = toString dims.titleSize;
        };
        gaps.inner = dims.gaps;
        # pixel borders; tabbed and vtabbed containers still draw their tabs
        window = {
          border = dims.frame;
          titlebar = false;
        };
        floating = {
          border = dims.frame;
          titlebar = false;
        };
      };
      extraConfig = ''
        vtab_width ${toString dims.vtabWidth}
        vtab_padding ${toString dims.vtabPadding}
        titlebar_padding ${toString dims.titlebarPadding.horizontal} ${toString dims.titlebarPadding.vertical}
        # tabs are not boxed: the selected one gets a tint and an edge rule
        # (titlebar_indicator), and tab_frame draws one frame around tabs and
        # content together, with a neutral divider between them
        titlebar_border_thickness 0
        titlebar_indicator ${toString dims.selectionRule.vertical} ${toString dims.selectionRule.horizontal}
        tab_frame enable

        # flat, square, still
        corner_radius 0
        shadows disable
        blur disable
        default_dim_inactive 0

        output * bg ${p.panel} solid_color

        # target                   border       background   text       indicator    child_border
        # border colors the selection rule; child_border the frame
        client.focused             ${p.signal}  ${p.seltint} ${p.signal} ${p.signal} ${p.signal}
        client.focused_tab_title   ${p.signal}  ${p.seltint} ${p.signal}
        client.focused_inactive    ${p.rule2}   ${p.selgrey} ${p.ink}    ${p.rule}   ${p.rule}
        client.unfocused           ${p.rule}    ${p.panel}   ${p.ink2}   ${p.rule}   ${p.rule}
        client.urgent              ${p.rule}    ${p.panel}   ${p.alarm}  ${p.rule}   ${p.rule}
        client.placeholder         ${p.rule}    ${p.panel}   ${p.ink2}   ${p.rule}   ${p.rule}
        client.background          ${p.panel}
      '';
    };

    # ---- waybar (section 7.2) ----
    programs.waybar = {
      settings.mainBar = {
        # Where a module's tooltip defaults to its format, waybar shows the
        # markup literally, so every marked-up module gets a plain tooltip.
        clock.format = value "{:%Y-%m-%d %H:%M}";
        network = {
          format-wifi = field "Net" (value "{signalStrength}%");
          format-ethernet = field "Eth" (value "{ifname}");
          format-disconnected = field "Net" (quiet "off");
          tooltip-format-disconnected = "Disconnected";
        };
        backlight = {
          format = field "Brt" (value "{percent}%");
          tooltip-format = "Brightness {percent}%";
        };
        battery = {
          format = field "Bat" (value "{capacity}%");
          format-charging = field "Chg" (value "{capacity}%");
          format-plugged = field "AC" (value "{capacity}%");
          tooltip-format = "{capacity}% · {timeTo}";
        };
        pulseaudio = {
          format = field "Vol" (value "{volume}%");
          format-muted = field "Vol" (quiet "mute");
          tooltip-format = "{desc} · {volume}%";
        };
      };
      style = ''
        * {
          font-family: "${fonts.sans}";
          font-size: ${px dims.barSize};
          min-height: 0;
          border: none;
          border-radius: 0;
          box-shadow: none;
          text-shadow: none;
        }

        window#waybar {
          background: ${p.panel};
          color: ${p.ink};
        }

        /* Every module carries a transparent top rule the width of the
           selection rule, so text sits centered below it whether or not the
           rule is lit (edge-rule compensation, section 4). */
        #workspaces button,
        #mode,
        #clock,
        #network,
        #backlight,
        #pulseaudio,
        #battery {
          border-top: ${px dims.selectionRule.horizontal} solid transparent;
          padding: 0 ${px (dims.gaps * 2)};
        }

        #workspaces {
          margin-left: ${px dims.gaps};
        }
        #workspaces button {
          transition: none;
          color: ${p.ink2};
          background: transparent;
        }
        #workspaces button:hover {
          background: transparent;
        }
        #workspaces button.visible {
          color: ${p.ink};
          background: ${p.selgrey};
          border-top-color: ${p.rule2};
        }
        #workspaces button.focused {
          color: ${p.signal};
          background: ${p.seltint};
          border-top-color: ${p.signal};
        }
        #workspaces button.urgent {
          color: ${p.alarm};
        }

        #mode {
          color: ${p.signal};
          background: ${p.seltint};
          border-top-color: ${p.signal};
        }

        #battery {
          margin-right: ${px dims.gaps};
        }
        #battery.critical:not(.charging) {
          color: ${p.alarm};
        }
      '';
    };

    # ---- launcher (section 7.3) ----
    programs.wofi = {
      settings = {
        width = dims.menuWidth;
        height = dims.menuHeight;
      };
      style = ''
        * {
          font-family: "${fonts.sans}";
          font-size: ${px dims.menuSize};
        }

        window {
          margin: 0;
          padding: 0;
          border: ${px dims.frame} solid ${p.rule};
          border-radius: 0;
          background-color: ${p.paper};
        }

        #outer-box, #inner-box, #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: ${p.paper};
        }

        #input {
          margin: 0 0 ${px dims.gaps} 0;
          padding: ${px (dims.gaps * 2)};
          border: none;
          border-bottom: ${px dims.heavyRule} solid ${p.heavy};
          border-radius: 0;
          box-shadow: none;
          outline: none;
          font-family: "${fonts.mono}";
          color: ${p.ink};
          background-color: ${p.panel};
        }
        #input image {
          color: ${p.ink2};
        }

        #entry {
          padding: ${px dims.gaps} ${px (dims.gaps * 2)};
          border-radius: 0;
          outline: none;
          background-color: ${p.paper};
        }
        #entry:selected {
          background-color: ${p.seltint};
          box-shadow: inset ${px dims.selectionRule.vertical} 0 ${p.signal};
          outline: none;
        }

        #text {
          margin: 0;
          color: ${p.ink2};
        }
        #entry:selected #text {
          color: ${p.signal};
        }

        #entry arrow {
          color: ${p.ink2};
        }
      '';
    };

    # ---- notifications (section 7.4) ----
    services.mako.settings = {
      background-color = p.panel;
      text-color = p.ink;
      border-color = p.rule;
      border-radius = 0;
      border-size = dims.frame;
      font = "${fonts.sans} ${toString dims.titleSize}";
      outer-margin = dims.gaps;
      margin = dims.gaps;
      padding = dims.gaps * 2;
      width = dims.notificationWidth;
      format = "${legend "%a"}\\n%s\\n${quiet "%b"}";

      "urgency=critical" = {
        border-color = p.alarm;
        format = ''<span foreground="${p.alarm}">${legend "%a"}</span>\n%s\n${quiet "%b"}'';
      };
    };

    # ---- lock screen (section 7.5) ----
    programs.hyprlock.settings =
      let
        clockSize = dims.menuSize * 4;
        clockY = dims.menuSize * 4;
      in
      {
        background = [ { color = rgb p.panel; } ];

        label = [
          {
            text = "$TIME";
            color = rgb p.ink;
            font_family = fonts.mono;
            font_size = clockSize;
            position = "0, ${toString clockY}";
            halign = "center";
            valign = "center";
          }
          {
            text = "cmd[update:60000] date +'${legend "%a %d %b %Y"}'";
            color = rgb p.ink;
            font_family = fonts.sans;
            font_size = dims.menuSize;
            position = "0, ${toString (clockY - clockSize + dims.menuSize / 2)}";
            halign = "center";
            valign = "center";
          }
        ];

        # the heavy rule under the clock
        shape = [
          {
            size = "${toString (clockSize * 3)}, ${toString dims.heavyRule}";
            color = rgb p.heavy;
            rounding = 0;
            border_size = 0;
            position = "0, ${toString (clockY - clockSize / 2 - dims.menuSize / 4)}";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            size = "${toString dims.notificationWidth}, ${toString (dims.menuSize * 3)}";
            outline_thickness = dims.frame;
            rounding = 0;
            outer_color = rgb p.rule;
            inner_color = rgb p.paper;
            font_color = rgb p.ink;
            font_family = fonts.sans;
            check_color = rgb p.signal;
            fail_color = rgb p.alarm;
            capslock_color = rgb p.signal;
            fade_on_empty = false;
            placeholder_text = if config.services.fprintd.enable then "$FPRINTPROMPT" else "";
            fail_text = "$FAIL";
            position = "0, -${toString (dims.menuSize * 2)}";
            halign = "center";
            valign = "center";
          }
        ];
      };
  };
}
