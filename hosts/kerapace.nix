{
  config,
  pkgs,
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.home-manager.nixosModules.home-manager

    # system modules
    ../modules/system/nix-store.nix
    ../modules/system/haskell.nix
    ../modules/system/zsh.nix
    ../modules/system/git.nix
    ../modules/system/firefox.nix
    ../modules/system/mpv.nix

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
  ];

  # --- hardware ---

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/pool";
    fsType = "btrfs";
    options = [ "subvol=nixos-root" ];
  };
  fileSystems."/nix" = {
    device = "/dev/mapper/pool";
    fsType = "btrfs";
    options = [ "subvol=nixos-nix" ];
  };
  fileSystems."/home" = {
    device = "/dev/mapper/pool";
    fsType = "btrfs";
    options = [ "subvol=nixos-home" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/93B5-EF62";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  boot.initrd.luks.devices."pool".device = "/dev/disk/by-uuid/7aa28a7b-2dde-4078-ab1e-5c9b35fb7730";

  # boot as qemu guest via virtiofs instead of bare metal
  specialisation.vm.configuration = {
    fileSystems = lib.mkForce {
      "/" = {
        fsType = "virtiofs";
        device = "nixos";
      };
    };
    boot.initrd.luks.devices = lib.mkForce { };
    swapDevices = [ ];
    boot.loader.grub.enable = lib.mkForce false;
    boot.initrd.availableKernelModules = [ "virtio_pci" "virtiofs" ];
    boot.initrd.kernelModules = [ "virtio_pci" "virtiofs" ];
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    hardware.graphics = {
      enable = true;
      extraPackages = [ pkgs.mesa ];
    };
    environment.variables.MESA_LOADER_DRIVER_OVERRIDE = "virtio";
    system.build.installBootLoader = lib.mkForce "${pkgs.coreutils}/bin/true";
  };

  swapDevices = [ ];
  zramSwap.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # --- boot ---

  nix.settings.experimental-features = "nix-command flakes";
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  # --- network ---

  networking.hostName = "kerapace";
  networking.networkmanager.enable = true;

  # --- locale ---

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # --- desktop ---

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;

  # --- system packages ---

  environment.systemPackages = with pkgs; [
    wget
  ];
  environment.variables.EDITOR = "kak";

  # --- ssh ---

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --- users ---

  users.users.root.shell = pkgs.zsh;

  users.users.firefox = {
    isNormalUser = true;
    description = "Firefox isolation user";
    shell = pkgs.bash;
  };

  # --- home-manager ---

  nixpkgs.config.allowUnfree = true;

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

  system.stateVersion = "25.11";
}
