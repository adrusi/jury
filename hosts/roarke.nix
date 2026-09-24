{
  config,
  pkgs,
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  # Personal laptop (Intel Framework). No dmodel/work config here — just the
  # generic baseline from common.nix plus hardware and desktop glue.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./common.nix

    # theme (swappable per host): same as the work machines for now; replace
    # these two with a different scheme/font module to retheme this host
    ../modules/theme/latte.nix
    (import ../modules/home/pragmatapro.nix "autumn")
  ];

  # --- hardware ---

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "cryptd"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
    extraConfig = ''
      DeviceScale=1
    '';
  };

  # Enable "Silent boot"
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
  ];
  # Hide the OS choice for bootloaders.
  # It's still possible to open the bootloader list by pressing any key
  # It will just not appear on screen unless a key is pressed
  boot.loader.timeout = 0;

  services.displayManager.autoLogin = {
    enable = true;
    user = "autumn";
  };

  fileSystems."/" = {
    device = "/dev/mapper/roarke-nixroot";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  boot.initrd.luks.devices."pool".device = "/dev/nvme0n1p2";

  swapDevices = [ ];
  zramSwap.enable = true;

  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # --- boot ---

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
    };
  };

  # --- network ---

  networking.hostName = "roarke";
  networking.networkmanager.enable = true;

  # --- desktop ---

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- state versions (fresh install on 26.05) ---

  system.stateVersion = "26.05";
  home-manager.users.root.home.stateVersion = "26.05";
  home-manager.users.firefox.home.stateVersion = "26.05";
  home-manager.users.autumn.home.stateVersion = "26.05";
}
