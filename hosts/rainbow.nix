{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.brew-nix.darwinModules.default
    inputs.mac-app-util.darwinModules.default

    # system-only modules
    ../modules/system/nix-store.nix
    ../modules/system/haskell.nix
    ../modules/system/homebrew.nix
    ../modules/system/bartender.nix
    # ../modules/system/linux-builder.nix

    # home modules for autumn
    (import ../modules/home/firefox.nix "autumn")
    (import ../modules/home/bitwarden.nix "autumn")
    (import ../modules/home/discord.nix "autumn")
    (import ../modules/home/zed.nix "autumn")
    (import ../modules/home/vscode.nix "autumn")
    # (import ../modules/home/zen.nix "autumn")
    (import ../modules/home/ghostty.nix "autumn")
    (import ../modules/home/pragmatapro.nix "autumn")
    (import ../modules/home/zsh.nix "autumn")
    (import ../modules/home/direnv.nix "autumn")
    (import ../modules/home/mpv.nix "autumn")
    (import ../modules/home/git.nix "autumn")
    (import ../modules/home/ssh.nix "autumn")
    (import ../modules/home/obsidian.nix "autumn")
    (import ../modules/home/kak/module.nix "autumn")
    (import ../modules/home/macos-settings.nix "autumn")
    (import ../modules/home/karabiner-elements.nix "autumn")
    (import ../modules/home/touchid.nix "autumn")
  ];

  # system.activationScripts.applications.text = lib.mkForce "";

  system.stateVersion = 6;
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.defaults = {
    loginwindow.GuestEnabled = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };

  networking = {
    computerName = "rainbow";
    hostName = "rainbow";
    localHostName = "rainbow";
  };

  environment.systemPackages = [
    pkgs.yt-dlp
    pkgs.git
    pkgs.claude-code
    pkgs.zulu25
    pkgs.zulu17
  ];

  nix-homebrew.taps = {
    "italomandara/homebrew-cxpatcher" = inputs.brewtap-cxpatcher;
  };

  homebrew.casks = [
    "bitwarden"
    "betterdisplay"
    "mullvad-vpn"
    "crossover"
    "steam"
    "transmission"
    "gimp"
    "inkscape"
    "racket"
    "italomandara/CXPatcher/cxpatcher"
    "zoom"
    "calibre"
    "spotify"
    "multimc"
  ];

  users.users.autumn.name = "autumn";
  users.users.autumn.home = "/Users/autumn";
  system.primaryUser = "autumn";
  nix.settings.allowed-users = [ "@admin" ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.autumn = {
    imports = [
      inputs.mac-app-util.homeManagerModules.default
    ];

    # NOTE: massive hack. see https://github.com/nix-community/home-manager/issues/8336
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;

    home.packages = [
      pkgs.brewCasks.claude
      pkgs.brewCasks.signal
      pkgs.brewCasks.supercollider
      pkgs.prismlauncher
    ];
  };
}
