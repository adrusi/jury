username:
{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  mod = "Mod4";
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
    ];
    
    programs.wofi = {
      enable = true;
      settings = {
        allow_markup = true;
        width = 250;
      };
    };

    programs.firefox.profiles.default = {
      extensions.packages = [ pkgs.notable-firefox-addon ];
      userChrome = ''
        #TabsToolbar {
          visibility: collapse;
        }
      '';
    };
    
    wayland.windowManager.sway = {
      enable = true;
      package = inputs.swayfx.packages.${pkgs.stdenv.system}.default;
      wrapperFeatures.gtk = true;
      checkConfig = false;

      config = {
        modifier = mod;
        terminal = pkgs.kitty;
        fonts = [ "PragmataPro 10" ];

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

          "${mod}+Return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty --single-instance --instance-group=sway";
          "${mod}+space" = "exec --no-startup-id wofi --show drun,run";
          "${mod}+t" = "exec --no-startup-id ${pkgs.firefox}/bin/firefox --new-window";

          "${mod}+w" = "kill";

          "${mod}+a" = "focus parent";
          "${mod}+e" = "layout toggle split";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout vtabbed";
          "${mod}+d" = "layout tabbed";

          "${mod}+Shift+r" = "exec swaymsg reload";
          "--release Print" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${mod}+Escape" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
          "${mod}+Ctrl+Shift+e" = "exit";

          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 8.333%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 8.333%+";
            
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        focus.followMouse = false;
        startup = [
          # { command = "firefox"; }
        ];
        workspaceAutoBackAndForth = true;
        input = {
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
            dwt = "enabled";
          };
        };
      };
      extraConfig = ''
        vtab_width 180
        vtab_position left
        vtab_padding 11
        corner_radius 6
        default_border normal 2
        titlebar_padding 6 4
        gaps inner 8

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

            bindsym Escape mode "default"
            bindsym Return mode "default"
            bindsym g      mode "default"
        }
        bindsym ${mod}+g mode "vtab"

        set $rosewater #dc8a78
        set $flamingo #dd7878
        set $pink #ea76cb
        set $mauve #8839ef
        set $red #d20f39
        set $maroon #e64553
        set $peach #fe640b
        set $yellow #df8e1d
        set $green #40a02b
        set $teal #179299
        set $sky #04a5e5
        set $sapphire #209fb5
        set $blue #1e66f5
        set $lavender #7287fd
        set $text #4c4f69
        set $subtext1 #5c5f77
        set $subtext0 #6c6f85
        set $overlay2 #7c7f93
        set $overlay1 #8c8fa1
        set $overlay0 #9ca0b0
        set $surface2 #acb0be
        set $surface1 #bcc0cc
        set $surface0 #ccd0da
        set $base #eff1f5
        set $mantle #e6e9ef
        set $crust #dce0e8

        output * bg $base solid_color

        # target                 title     bg    text   indicator  border
        client.focused           $lavender $base $text  $rosewater $lavender
        client.focused_inactive  $overlay0 $base $text  $rosewater $overlay0
        client.unfocused         $overlay0 $base $text  $rosewater $overlay0
        client.urgent            $peach    $base $peach $overlay0  $peach
        client.placeholder       $overlay0 $base $text  $overlay0  $overlay0
        client.background        $base

        # bar
        bar {
          colors {
            background         $base
            statusline         $text
            focused_statusline $text
            focused_separator  $base

            # target           border bg        text
            focused_workspace  $base  $mauve    $crust
            active_workspace   $base  $surface2 $text
            inactive_workspace $base  $base     $text
            urgent_workspace   $base  $red      $crust
          }
        }
      '';
    };
  };
}
