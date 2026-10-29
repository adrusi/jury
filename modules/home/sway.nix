username:
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  mod = "Mod4";

  hmCfg = config.home-manager.users.${username};
  swayCfg = hmCfg.wayland.windowManager.sway;
in
{
  # Behavior only: keybinds, services, which programs run and how they act.
  # Everything visual (colors, fonts, borders, sizes, waybar formats) comes
  # from a theme module imported by the host: sway-design.nix implements
  # design/language.md; sway-stylesheet.nix is the older stylesheet-driven
  # look.
  imports = [
    ../system/sway.nix
  ];

  # password auth for hyprlock (fingerprint goes to fprintd directly, not pam)
  security.pam.services.hyprlock = { };

  fonts.packages = [ pkgs.nerd-fonts.noto ];

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
        always_parse_args = true;
        show_all = false;
        term = "ghostty";
        hide_scroll = true;
        print_command = true;
        insensitive = true;
        prompt = "";
        columns = 2;
      };
    };

    services.mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        icons = true;
        layer = "top";
        markup = true;

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
      # module formats are visual and come from the theme
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
          };
          network = {
            tooltip-format-wifi = "{essid} {ipaddr}";
            tooltip-format-ethernet = "{ipaddr}";
          };
          backlight = {
            device = "intel_backlight";
          };
          battery = {
            states = {
              critical = 15;
            };
          };
          pulseaudio = {
            on-click = "pavucontrol";
          };
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      # The swayfx flake only exports the unwrapped build, so run it through
      # nixpkgs' sway wrapper ourselves (as nixpkgs' own swayfx does); setting
      # `package` means home-manager no longer applies wrapperFeatures and
      # extraSessionCommands for us.
      package = pkgs.sway.override {
        sway-unwrapped = inputs.swayfx.packages.${pkgs.stdenv.system}.default;
        inherit (swayCfg) extraSessionCommands;
        withBaseWrapper = swayCfg.wrapperFeatures.base;
        withGtkWrapper = swayCfg.wrapperFeatures.gtk;
      };
      wrapperFeatures.gtk = true;
      # gdm launches sway without a login shell, so nothing else would put
      # home.sessionVariables into the session
      extraSessionCommands = ''
        . "${hmCfg.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
      '';
      checkConfig = false;
      systemd.enable = true;

      config = {
        modifier = mod;
        terminal = "${pkgs.ghostty}/bin/ghostty";

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

          "${mod}+Return" = "exec --no-startup-id ${pkgs.ghostty}/bin/ghostty";
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
        input = {
          "type:touchpad" = {
            natural_scroll = "enabled";
          };
        };
      };
      extraConfig = ''
        exec ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY

        for_window [app_id="firefox"] title_replace_regex "s/^\[fx:[0-9]+\] (.*)— Mozilla Firefox$/$1/"

        vtab_position left
        workspace_layout vtabbed

        # games, videos, etc. keep swayidle from firing while fullscreen and visible
        for_window [all] inhibit_idle fullscreen

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
      '';
    };

    # hyprlock rather than swaylock: it listens for a fingerprint (via fprintd
    # over dbus) concurrently with the password field, so a touch alone
    # unlocks. Runs fine on sway via ext-session-lock.
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };
        animations.enabled = false;
        auth."fingerprint:enabled" = config.services.fprintd.enable;
      };
    };

    services.swayidle =
      let
        swaymsg = "${inputs.swayfx.packages.${pkgs.stdenv.system}.default}/bin/swaymsg";
        loginctl = "${pkgs.systemd}/bin/loginctl";
        systemctl = "${pkgs.systemd}/bin/systemctl";
        hyprlock = "${hmCfg.programs.hyprlock.package}/bin/hyprlock";
      in
      {
      enable = true;

      # hyprlock doesn't daemonize, so hand it to sway to run: swayidle (run
      # with -w) doesn't block on it, and it lives outside swayidle's cgroup so
      # restarting swayidle can't kill the locker out from under a locked session
      events.lock = "${pkgs.procps}/bin/pidof hyprlock || ${swaymsg} exec ${hyprlock}";
      events.before-sleep = "${loginctl} lock-session";
      timeouts =
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
