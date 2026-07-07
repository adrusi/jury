{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Shared configuration for dmodel workstations. Hardware/boot-specific bits
  # live in the per-host entrypoints:
  #   - kerapace.nix : bare-metal (boot, LUKS, bootloader, gdm/gnome)
  #   - chaos.nix    : systemd-nspawn container guest (greetd/sway)
  imports = [
    inputs.home-manager.nixosModules.home-manager

    # system modules
    ../modules/system/nix-store.nix
    ../modules/system/haskell.nix
    ../modules/system/zsh.nix
    ../modules/system/git.nix
    ../modules/system/firefox.nix
    ../modules/system/mpv.nix
    ../modules/system/keyd.nix

    # home modules for root
    (import ../modules/home/zsh.nix "root")
    (import ../modules/home/git.nix "root")
    (import ../modules/home/direnv.nix "root")
    (import ../modules/home/kak/module.nix "root")
    (import ../modules/home/ssh.nix "root")
    (import ../modules/home/mpv.nix "root")

    # home modules for firefox isolation user
    (import ../modules/home/firefox.nix "firefox")
    (import ../modules/home/bitwarden.nix "firefox")

    # (import ../modules/home/astroid.nix "autumn")
    (import ../modules/home/bitwarden.nix "autumn")
    (import ../modules/home/chromium.nix "autumn")
    (import ../modules/home/claude.nix "autumn")
    (import ../modules/home/direnv.nix "autumn")
    (import ../modules/home/discord.nix "autumn")
    (import ../modules/home/dmodel/module.nix "autumn")
    (import ../modules/home/firefox.nix "autumn")
    (import ../modules/home/ghostty.nix "autumn")
    (import ../modules/home/git.nix "autumn")
    (import ../modules/home/kitty.nix "autumn")
    (import ../modules/home/kak/module.nix "autumn")
    (import ../modules/home/mpv.nix "autumn")
    (import ../modules/home/pragmatapro.nix "autumn")
    (import ../modules/home/sway.nix "autumn")
    (import ../modules/home/ssh.nix "autumn")
    (import ../modules/home/zathura.nix "autumn")
    (import ../modules/home/zed.nix "autumn")
    (import ../modules/home/zsh.nix "autumn")
  ];

  # --- REMOVE THIS ---
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # --- platform ---

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = "nix-command flakes";

  # --- bluetooth ---

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  # --- locale ---

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # --- desktop ---

  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.extraConfig."50-disable-ucm" = {
      "monitor.alsa.properties" = {
        "alsa.use-ucm" = false;
      };
    };
  };
  services.libinput.enable = true;

  # Secret Service (org.freedesktop.secrets) provider, used by `rl` to fetch
  # the bws access token via secret-tool. Both hosts autologin, so PAM can't
  # unlock the keyring with a login password; the default collection must be
  # created with an empty password to auto-unlock.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # --- system packages ---

  environment.systemPackages = [
    pkgs.wget
    pkgs.kitty
  ];
  environment.variables.EDITOR = "kak";

  # --- docker ---
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  # --- users ---

  users.users.root.shell = pkgs.zsh;

  users.users.firefox = {
    isNormalUser = true;
    description = "Firefox isolation user";
    shell = pkgs.bash;
  };

  users.users.autumn = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Autumn Russell";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  # --- home-manager ---

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.root = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.firefox = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.autumn = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    # --- misc (move to module when it's clear what the module should be) ---

    home.packages = [
      pkgs.libsecret # secret-tool, for managing the keyring used by `rl`
      pkgs.dmodel-issue-tracker
      pkgs.google-cloud-sdk # this is needed so docker can authenticate to registries!
      pkgs.bitwarden-cli
      pkgs.claude-desktop
      (pkgs.writeShellApplication {
        name = "rl";
        runtimeInputs = [ pkgs.libsecret pkgs.bws ];
        text = ''
          BWS_ACCESS_TOKEN="$(secret-tool lookup service research-push-token account "$USER")" \
            exec bws run --project-id "207134e6-bd27-48cd-a405-b4420162470b" -- "$@"
        '';
      })
      pkgs.bws
      pkgs.pavucontrol
      pkgs.python314Packages.subliminal
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.slack
      pkgs.ripcord
      pkgs.inotify-tools
      pkgs.texliveFull
    ];

    # TODO find a better way to manage differences in font size rendering across platforms and hosts
    programs.zed-editor.userSettings = {
      buffer_font_size = lib.mkForce 14;
      terminal.font_size = lib.mkForce 14;
      ui_font_size = lib.mkForce 16;
    };

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
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.0;
            status = "enable";
            mode = "2256x1504@59.999Hz";
          }
        ];
      }
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
