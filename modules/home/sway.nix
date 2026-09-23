username:
{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  mod = "Mod4";
  gaps = "8";
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
in
{
  imports = [
    ../system/pragmatapro.nix
    ../system/sway.nix
  ];

  home-manager.users.${username} = {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
      MOZ_X11_EGL = 1;
      NIXOS_OZONE_WL = 1;
    };

    home.packages = [
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.mako
      pkgs.pcmanfm
      pkgs.nerd-fonts.fantasque-sans-mono
      pkgs.kanshi
      inputs.firefox-sway-favicon.packages.${pkgs.stdenv.system}.native-host
    ];

    home.pointerCursor = {
      enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
    };

    services.udiskie = {
      enable = true;
      settings = {
        program_options.file_manager = "${pkgs.pcmanfm}/bin/pcmanfm";
      };
    };

    services.kanshi = {
      enable = true;
      systemdTarget = "sway-session.target";
    };
    
    programs.wofi = {
      enable = true;
      settings = {
        allow_markup = true;
        width = 640;
        height = 480;
        always_parse_args = true;
        show_all = false;
        term = "kitty";
        hide_scroll = true;
        print_command = true;
        insensitive = true;
        prompt = "";
        columns = 2;
      };
      style = ''
        @define-color	rosewater  #dc8a78;
        @define-color	rosewater-rgb  rgb(220, 138, 120);
        @define-color	flamingo  #dd7878;
        @define-color	flamingo-rgb  rgb(221, 120, 120);
        @define-color	pink  #ea76cb;
        @define-color	pink-rgb  rgb(234, 118, 203);
        @define-color	mauve  #8839ef;
        @define-color	mauve-rgb  rgb(136, 57, 239);
        @define-color	red  #d20f39;
        @define-color	red-rgb  rgb(210, 15, 57);
        @define-color	maroon  #e64553;
        @define-color	maroon-rgb  rgb(230, 69, 83);
        @define-color	peach  #fe640b;
        @define-color	peach-rgb  rgb(254, 100, 11);
        @define-color	yellow  #df8e1d;
        @define-color	yellow-rgb  rgb(223, 142, 29);
        @define-color	green  #40a02b;
        @define-color	green-rgb  rgb(64, 160, 43);
        @define-color	teal  #179299;
        @define-color	teal-rgb  rgb(23, 146, 153);
        @define-color	sky  #04a5e5;
        @define-color	sky-rgb  rgb(4, 165, 229);
        @define-color	sapphire  #209fb5;
        @define-color	sapphire-rgb  rgb(32, 159, 181);
        @define-color	blue  #1e66f5;
        @define-color	blue-rgb  rgb(30, 102, 245);
        @define-color	lavender  #7287fd;
        @define-color	lavender-rgb  rgb(114, 135, 253);
        @define-color	text  #4c4f69;
        @define-color	text-rgb  rgb(76, 79, 105);
        @define-color	subtext1  #5c5f77;
        @define-color	subtext1-rgb  rgb(92, 95, 119);
        @define-color	subtext0  #6c6f85;
        @define-color	subtext0-rgb  rgb(108, 111, 133);
        @define-color	overlay2  #7c7f93;
        @define-color	overlay2-rgb  rgb(124, 127, 147);
        @define-color	overlay1  #8c8fa1;
        @define-color	overlay1-rgb  rgb(140, 143, 161);
        @define-color	overlay0  #9ca0b0;
        @define-color	overlay0-rgb  rgb(156, 160, 176);
        @define-color	surface2  #acb0be;
        @define-color	surface2-rgb  rgb(172, 176, 190);
        @define-color	surface1  #bcc0cc;
        @define-color	surface1-rgb  rgb(188, 192, 204);
        @define-color	surface0  #ccd0da;
        @define-color	surface0-rgb  rgb(204, 208, 218);
        @define-color	base  #eff1f5;
        @define-color	base-rgb  rgb(239, 241, 245);
        @define-color	mantle  #e6e9ef;
        @define-color	mantle-rgb  rgb(230, 233, 239);
        @define-color	crust  #dce0e8;
        @define-color	crust-rgb  rgb(220, 224, 232);

        * {
          font-family: 'PragmataPro', monospace;
          font-size: 14px;
        }

        /* Window */
        window {
          margin: 0px;
          padding: 10px;
          border: 3px solid @lavender;
          /* 8px instead of 6 like everywhere else because wofi has some weird scaling? */
          border-radius: 8px;
          /* @base at 99% opacity; forces wofi to enable alpha blending so border-radius works */
          background-color: rgba(239, 241, 245, 0.99);
        }

        /* Inner Box */
        #inner-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: @base;
        }

        /* Outer Box */
        #outer-box {
          margin: 5px;
          padding: 10px;
          border: none;
          background-color: @base;
        }

        /* Scroll */
        #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: @base;
        }

        /* Input */
        #input {
          margin: 0 0 10px 0;
          padding: 10px;
          border: none;
          border-radius: 8px;
          color: @text;
          background-color: @base;
        }

        #input image {
          border: none;
          color: @lavender;
        }

        #input * {
          outline: 4px solid @lavender!important;
        }

        /* Text */
        #text {
          margin: 5px;
          border: none;
          color: @text;
        }

        #entry {
          background-color: @base;
        }

        #entry arrow {
          border: none;
          color: @lavender;
        }

        /* Selected Entry */
        #entry:selected {
          outline: 1px solid @lavender;
        }

        #entry:drop(active) {
          background-color: @lavender!important;
        }
      '';
    };

    services.mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        background-color = base;
        text-color = text;
        border-color = lavender;
        border-radius = 6;
        border-size = 3;
        font = "PragmataPro 9";
        icons = true;
        layer = "top";
        markup = true;
        outer-margin = 8;
        margin = 8;
        padding = 9;
        width = 300;

        actions = true;
        max-visible = 5;
        default-timeout = 30000;
        ignore-timeout = true;
        history = true;
      };
    };

    programs.firefox = {
      nativeMessagingHosts = [ inputs.firefox-sway-favicon.packages.${pkgs.stdenv.system}.native-host ];
      profiles.default = {
        extensions.packages = [
          pkgs.notable-firefox-addon
          inputs.firefox-sway-favicon.packages.${pkgs.stdenv.system}.extension
        ];
        settings."sidebar.verticalTabs" = lib.mkForce false;
        settings."sidebar.backupState" = "";
        userChrome = ''
          #TabsToolbar {
            visibility: collapse;
          }
          #sidebar-main {
            visibility: collapse;
          }
        '';
      };
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [ "sway/workspaces" "sway/mode" ];
          modules-center = [ "clock" ];
          modules-right = ["network" "backlight" "pulseaudio" "battery" ];
          "sway/workspaces" = {
            disable-scroll = true;
            sort-by-name = true;
            numeric-first = true;
            format = "{name}";
          };
          "sway/mode" = {
            
          };
          "custom/music" = {
            format = "  {}";
            escape = true;
            interval = 5;
            tooltip = false;
            exec = "${pkgs.playerctl}/bin/playerctl metadata --format='{{ title }}'";
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
            max-length = 50;
          };
          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%Y-%m-%d %H:%M}";
          };
          network = {
            format-wifi = " {signalStrength}%";
            tooltip-format-wifi = "{essid} {ipaddr}";
            format-ethernet = "";
            tooltip-format-ethernet = "{ipaddr}";
            format-disconnected = "";
          };
          backlight = {
            device = "intel_backlight";
            format = "{icon} {percent}%";
            format-icons = ["" "" "" "" "" "" "" "" ""];
          };
          battery = {
            states = {
              critical = 15;
            };
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
            on-click = "pavucontrol";
          };
        };
      };
      style = ''
        * {
          font-family: PragmataPro;
          font-size: 13px;
          min-height: 0;
        }

        #waybar {
          background: transparent;
          color: ${text};
          margin: 0;
        }

        #workspaces {
          margin-left: ${gaps}px;
        }
        #workspaces button {
          transition: 0s;
          border-radius: 0;
          color: ${text};
          border: 0;
          background: transparent;
          padding-top: 8px;
          padding-left: 4px;
          padding-right: 4px;
          padding-bottom: 0;
          margin-right: ${gaps}px;
        }
        #workspaces button:hover {
          background: transparent;
          border: 0;
        }
        #workspaces button.focused {
          padding-top: 4px;
          border-top: 4px solid ${lavender};
        }
        #workspaces button.urgent {
          color: ${peach};
        }

        #mode {
          margin-top: 4px;
          margin-left: 8px;
          background: ${lavender};
          font-size: 16px;
          color: ${base};
          padding-left: 4px;
          padding-right: 4px;
        }

        #clock {
          color: ${text};
          padding-top: 8px;
        }

        #network {
          padding-top: 8px;
          margin-right: ${gaps}px;
        }

        #backlight {
          padding-top: 8px;
          margin-right: ${gaps}px;
        }

        #pulseaudio {
          padding-top: 8px;
          margin-right: ${gaps}px;
        }

        #battery {
          padding-top: 8px;
          margin-right: ${gaps}px;
        }
        #battery.critical {
          color: ${peach};
        }
      '';
    };
    
    wayland.windowManager.sway = {
      enable = true;
      package = inputs.swayfx.packages.${pkgs.stdenv.system}.default;
      wrapperFeatures.gtk = true;
      checkConfig = false;
      systemd.enable = true;

      config = {
        modifier = mod;
        terminal = pkgs.kitty;
        fonts = [ "PragmataPro 9" ];

        bars = [];

        keybindings = {
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+Space" = "focus mode_toggle";
          "${mod}+Shift+Space" = "floating toggle";

          "${mod}+Return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty --single-instance --instance-group=sway";
          "${mod}+Tab" = "exec --no-startup-id wofi --show drun,run";
          "${mod}+t" = "exec --no-startup-id ${pkgs.firefox}/bin/firefox --new-window";

          "${mod}+w" = "kill";

          "${mod}+a" = "focus parent";
          "${mod}+e" = "layout toggle split";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout vtabbed";
          "${mod}+d" = "layout tabbed";

          "${mod}+Shift+r" = "exec swaymsg reload";
          "--release Print" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${mod}+Escape" = "exec loginctl lock-session";
          "${mod}+Ctrl+Shift+e" = "exit";

          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 8.333%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 8.333%+";
            
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "${mod}+n" = "exec makoctl dismiss";
          "${mod}+Shift+n" = "exec makoctl restore";
        };
        focus.followMouse = false;
        workspaceAutoBackAndForth = false;
        defaultWorkspace = "workspace number 1";
        gaps.inner = builtins.fromJSON gaps;
        input = {
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
            dwt = "enabled";
          };
        };
      };
      extraConfig = ''
        exec ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY

        for_window [app_id="firefox"] title_replace_regex "s/^\[fx:[0-9]+\] (.*)— Mozilla Firefox$/$1/"
      
        vtab_width 180
        vtab_position left
        vtab_padding 11
        corner_radius 6
        default_border normal 3
        titlebar_padding 6 4
        workspace_layout vtabbed

        for_window [floating] shadows enable

        output * scale 1

        mode "vtab" {
            # Scroll sidebar without changing focus
            bindsym j      vtab_scroll down
            bindsym k      vtab_scroll up
            bindsym Down   vtab_scroll down
            bindsym Up     vtab_scroll up
            bindsym d      vtab_scroll down 5
            bindsym u      vtab_scroll up 5

            # Sidebar appearance
            bindsym h  vtab_position left
            bindsym Left vtab_position left
            bindsym l vtab_position right
            bindsym Right vtab_position right
            bindsym minus        vtab_width -20
            bindsym equal        vtab_width +20
            bindsym Alt+minus        vtab_width -1
            bindsym Alt+equal        vtab_width +1

            bindsym Escape mode "default"
            bindsym Return mode "default"
            bindsym g      mode "default"
        }
        bindsym ${mod}+g mode "vtab"

        mode "resize" {
          bindsym minus resize shrink width 20 px
          bindsym equal resize grow width 20 px
          bindsym bracketleft resize shrink height 20 px
          bindsym bracketright resize grow height 20 px

          bindsym Alt+minus resize shrink width 1 px
          bindsym Alt+equal resize grow width 1 px
          bindsym Alt+bracketleft resize shrink height 1 px
          bindsym Alt+bracketright resize grow height 1 px

          # bindsym Escape mode "default"
          # bindsym Return mode "default"
          # bindsym r      mode "default"
        }
        bindsym ${mod}+r mode "resize"

        output * bg ${base} solid_color

        # target                 title       bg      text     indicator    border
        client.focused           ${lavender} ${lavender} ${base}  ${lavender} ${lavender}
        client.focused_inactive  ${overlay0} ${lavender} ${base}  ${overlay0} ${overlay0}
        client.unfocused         ${overlay0} ${base} ${text}  ${overlay0} ${overlay0}
        client.urgent            ${peach}    ${peach} ${base} ${peach}  ${peach}
        client.placeholder       ${overlay0} ${base} ${text}  ${overlay0}  ${overlay0}
        client.background        ${base}
      '';
    };

    services.swayidle = {
      enable = true;

      events.lock =
        let
          fmt = lib.strings.removePrefix "#";
        in
          ''${pkgs.swaylock-effects}/bin/swaylock \
            --daemonize \
            --screenshots \
            --effect-pixelate 10 \
            --font PragmataPro \
            --indicator \
            --clock \
            --inside-color ${fmt base} \
            --text-color ${fmt text} \
            --inside-clear-color ${fmt base} \
            --text-clear-color ${fmt text} \
            --inside-ver-color ${fmt lavender} \
            --text-ver-color ${fmt base} \
            --inside-wrong-color ${fmt peach} \
            --text-wrong-color ${fmt base} \
            --key-hl-color ${fmt base} \
            --line-uses-inside \
            --line-color ${fmt base} \
            --line-clear-color ${fmt base} \
            --line-ver-color ${fmt base} \
            --line-wrong-color ${fmt base} \
            --separator-color ${fmt base} \
            --ring-color ${fmt lavender} \
            --ring-clear-color ${fmt base} \
            --ring-ver-color ${fmt lavender} \
            --ring-wrong-color ${fmt peach}'';
      events.before-sleep = "${pkgs.systemd}/bin/loginctl lock-session";
      timeouts =
        let
          swaymsg = "${inputs.swayfx.packages.${pkgs.stdenv.system}.default}/bin/swaymsg";
          loginctl = "${pkgs.systemd}/bin/loginctl";
          systemctl = "${pkgs.systemd}/bin/systemctl";
        in
        [
          {
            timeout = 300;
            command = "${pkgs.chayang}/bin/chayang && ${swaymsg} 'output * power off' && ${loginctl} lock-session";
            resumeCommand = "${swaymsg} 'output * power on'";
          }
          {
            timeout = 600;
            command = "${systemctl} suspend";
          }
        ];
    };
  };
}
