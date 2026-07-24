{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHcGBFNeXDBqJ0o3/SX+YfkCLTugtfyGeSR7rpmu7+o autumn@dmodel.ai";
in
{
  # east: GCE devbox (n2d-standard-16: 16 vCPU, 64 GiB RAM, no GPU — accelerator
  # workloads belong on ephemeral compute workers).
  # Provisioned and converged by OpenTofu via `nix run .#infra` (see
  # infra/east.nix): the first apply installs NixOS over the stock Debian image
  # with nixos-anywhere (kexec + disko), later applies nixos-rebuild it in
  # place. Headless server; deliberately does not import dmodel-common.nix
  # (that file is desktop-shaped: bluetooth, pipewire, sway, firefox, ...).
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    # system modules
    ../modules/system/nix-store.nix
    ../modules/system/zsh.nix
    ../modules/system/git.nix

    # home modules for root
    (import ../modules/home/zsh.nix "root")
    (import ../modules/home/git.nix "root")
    (import ../modules/home/kak/module.nix "root")

    # home modules for autumn
    (import ../modules/home/claude.nix "autumn")
    (import ../modules/home/direnv.nix "autumn")
    (import ../modules/home/git.nix "autumn")
    (import ../modules/home/kak/module.nix "autumn")
    (import ../modules/home/ssh.nix "autumn")
    (import ../modules/home/zsh.nix "autumn")
  ];

  # --- platform ---

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = "nix-command flakes";
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- disk ---

  # The boot persistent disk is the only disk and attaches via virtio-scsi
  # (N2D uses SCSI for PD), so it's /dev/sda during install. disko mounts by
  # partlabel afterwards, so nothing depends on the sda name post-boot.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # --- boot ---

  # GCE instances boot UEFI (Shielded VM, secure boot off by default). Skip
  # NVRAM entries and rely on systemd-boot's fallback loader path on the ESP.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "sd_mod"
    "nvme"
  ];
  # readable via `gcloud compute connect-to-serial-port east`
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  swapDevices = [ ];
  zramSwap.enable = true;

  # --- network ---

  networking.hostName = "east";
  networking.useDHCP = true;

  # run `sudo tailscale up` once after the first install
  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- docker ---

  virtualisation.docker.enable = true;

  # --- users ---

  security.sudo.wheelNeedsPassword = false;

  users.users.root = {
    shell = pkgs.zsh;
    # tofu converges the system as root@east
    openssh.authorizedKeys.keys = [ sshKey ];
  };

  users.users.autumn = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Autumn Russell";
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [ sshKey ];
  };

  # --- home-manager ---

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "home-manager-backup";

  home-manager.users.root = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.autumn = {
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };

  environment.systemPackages = [
    pkgs.wget
    pkgs.kitty # need terminfo entry
  ];
  environment.variables.EDITOR = "kak";

  system.stateVersion = "25.11";
}
