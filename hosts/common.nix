{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Generic personal baseline shared by all graphical NixOS hosts.
  # Work-specific (dmodel) config layers on top in dmodel-common.nix;
  # hardware/boot-specific bits live in the per-host entrypoints.
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
  nix.settings.experimental-features = [ "nix-command flakes" ];

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

  # --- system packages ---

  environment.systemPackages = [
    pkgs.wget
    pkgs.kitty
  ];
  environment.variables.EDITOR = "kak";

  # --- docker ---
  virtualisation.docker = {
    enable = true;
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

  # --- misc (move to module) ---

  services.tailscale = {
    enable = true;
  };

  fonts.fontconfig.hinting = {
    enable = true;
    style = "full";
  };

  # --- home-manager ---

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.root = {
    home.stateVersion = lib.mkDefault "25.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.firefox = {
    home.stateVersion = lib.mkDefault "25.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.autumn = {
    home.stateVersion = lib.mkDefault "25.11";
    programs.home-manager.enable = true;

    # --- misc (move to module when it's clear what the module should be) ---

    home.packages = [
      pkgs.bitwarden-cli
      pkgs.claude-desktop
      pkgs.pavucontrol
      pkgs.python314Packages.subliminal
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.inotify-tools
      pkgs.texliveFull
    ];

    # TODO find a better way to manage differences in font size rendering across platforms and hosts
    programs.zed-editor.userSettings = {
      buffer_font_size = lib.mkForce 14;
      terminal.font_size = lib.mkForce 14;
      ui_font_size = lib.mkForce 16;
    };

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
    ];
  };
}
