{ config, pkgs, inputs, ... }: {
  system.stateVersion = 6;
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  environment.systemPackages = [
  ];
}
