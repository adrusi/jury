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
  # east: always-on GCE devbox (n2d-standard-8: 8 vCPU, 32 GiB RAM, 1 TiB
  # pd-balanced, no GPU — accelerator workloads belong on ephemeral compute
  # workers). A pet: deploy changes in place with
  #   nixos-rebuild switch --flake .#east --target-host root@east
  # Headless server; deliberately does not import dmodel-common.nix (that file
  # is desktop-shaped: bluetooth, pipewire, sway, firefox, ...).
  #
  # The VM lives in the shared dmodel project gen-lang-client-0029335129,
  # us-west1-b. If it ever has to be rebuilt from scratch:
  #   gcloud compute instances create east --zone us-west1-b \
  #     --machine-type n2d-standard-8 --boot-disk-size 1024 \
  #     --boot-disk-type pd-balanced --image-project debian-cloud \
  #     --image-family debian-12 \
  #     --metadata enable-oslogin=FALSE,ssh-keys="autumn:<sshKey>"
  #   # (needs a network allowing tcp:22, e.g. the existing "devbox" one)
  #   nix run github:nix-community/nixos-anywhere -- \
  #     --flake .#east --target-host autumn@<ip>
  # then `sudo tailscale up` on the box.
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    # headless: only the palette is used (zsh, git and kak colors)
    ../modules/design/options.nix

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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
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

  # Growing the persistent disk (`gcloud compute disks resize east`) then
  # rebooting expands the root partition and filesystem to match.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

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
  # only physical NICs; otherwise dhcpcd gives docker veths an IPv4LL
  # 169.254/16 route that hijacks the metadata server (and thus DNS)
  networking.dhcpcd.allowInterfaces = [ "en*" ];

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
    # `nixos-rebuild --target-host root@east` deploys as root
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
    pkgs.ghostty.terminfo # need terminfo entry
    pkgs.python314Packages.modal
    pkgs.dmodel-issue-tracker
    pkgs.google-cloud-sdk
    pkgs.libsecret
    (pkgs.writeShellApplication {
      name = "rl";
      runtimeInputs = [ pkgs.libsecret pkgs.bws ];
      text = ''
        BWS_ACCESS_TOKEN="$(secret-tool lookup service research-push-token account "$USER")" \
          exec bws run --project-id "207134e6-bd27-48cd-a405-b4420162470b" -- "$@"
      '';
    })
    pkgs.bws
    pkgs.awscli2
  ];
  environment.variables.EDITOR = "kak";

  # terminal colors (zsh prompt, LS_COLORS, git, kak) for the light mode the
  # work machine renders in
  design.mode = "light";

  system.stateVersion = "25.11";
}
