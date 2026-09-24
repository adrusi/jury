{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Shared configuration for dmodel workstations, layered on the generic
  # baseline in common.nix. Hardware/boot-specific bits live in the per-host
  # entrypoints:
  #   - kerapace.nix : bare-metal (boot, LUKS, bootloader, gdm/gnome)
  #   - chaos.nix    : systemd-nspawn container guest (greetd/sway)
  imports = [
    ./common.nix

    # theme (swappable per host)
    ../modules/theme/latte.nix
    (import ../modules/home/pragmatapro.nix "autumn")

    (import ../modules/home/dmodel/module.nix "autumn")
  ];

  # Secret Service (org.freedesktop.secrets) provider, used by `rl` to fetch
  # the bws access token via secret-tool. Both hosts autologin, so PAM can't
  # unlock the keyring with a login password; the default collection must be
  # created with an empty password to auto-unlock.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # --- docker ---
  virtualisation.docker = {
    storageDriver = "btrfs";
  };

  # --- home-manager ---

  home-manager.users.autumn = {
    home.packages = [
      pkgs.libsecret # secret-tool, for managing the keyring used by `rl`
      pkgs.dmodel-issue-tracker
      pkgs.google-cloud-sdk # this is needed so docker can authenticate to registries!
      (pkgs.writeShellApplication {
        name = "rl";
        runtimeInputs = [ pkgs.libsecret pkgs.bws ];
        text = ''
          BWS_ACCESS_TOKEN="$(secret-tool lookup service research-push-token account "$USER")" \
            exec bws run --project-id "207134e6-bd27-48cd-a405-b4420162470b" -- "$@"
        '';
      })
      pkgs.bws
      pkgs.slack
      pkgs.ripcord
      pkgs.awscli2
    ];

    programs.git.settings.user.email = lib.mkForce "autumn@dmodel.ai";

    programs.firefox.profiles.default.extensions.packages = [
      (pkgs.firefox-addons.buildFirefoxXpiAddon {
        pname = "golinks";
        version = "2.7.27";
        addonId = "teamgolinks@gmail.com";
        url = "https://addons.mozilla.org/firefox/downloads/file/4471234/golinks-2.7.27.xpi";
        sha256 = "sha256-s6Rw+Je936bd+tJQs4bm86y9ohKW4ndYZuAw+/BpaTM=";
        meta = with lib; {
          homepage = "https://www.golinks.io/";
          description = "Go links extension for Firefox.";
          license = licenses.unfree;
          platforms = platforms.all;
        };
      })
    ];

    services.kanshi.settings = [
      {
        profile.name = "office";
        profile.outputs = [
          {
            criteria = "BNQ BenQ GW2786TC ETR4S02935SL0";
            scale = 1.0;
            position = "168,0";
            mode = "1920x1080@60Hz";
          }
          {
            criteria = "eDP-1";
            scale = 1.0;
            position = "0,1080";
            mode = "2256x1504@59.999Hz";
          }
        ];
      }
    ];
  };

  system.stateVersion = "25.11";
}
