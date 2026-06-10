{
  config,
  pkgs,
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  # Bare-metal kerapace. Owns the real hardware: kernel, LUKS, bootloader.
  # Kept as a fallback boot target while migrating to the Fedora-hosted
  # nspawn container (see chaos.nix). Shared config is in dmodel-common.nix.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./dmodel-common.nix
  ];

  # --- hardware ---

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

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
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  boot.initrd.luks.devices."pool".device = "/dev/disk/by-uuid/7aa28a7b-2dde-4078-ab1e-5c9b35fb7730";

  # boot as qemu guest via virtiofs instead of bare metal
  # specialisation.vm.configuration = {
  #   fileSystems = lib.mkForce {
  #     "/" = {
  #       fsType = "virtiofs";
  #       device = "nixos";
  #     };
  #   };
  #   boot.initrd.luks.devices = lib.mkForce { };
  #   swapDevices = [ ];
  #   boot.loader.grub.enable = lib.mkForce false;
  #   boot.initrd.availableKernelModules = [ "virtio_pci" "virtiofs" ];
  #   boot.initrd.kernelModules = [ "virtio_pci" "virtiofs" ];
  #   services.qemuGuest.enable = true;
  #   services.spice-vdagentd.enable = true;
  #   hardware.graphics = {
  #     enable = true;
  #     extraPackages = [ pkgs.mesa ];
  #   };
  #   environment.variables.MESA_LOADER_DRIVER_OVERRIDE = "virtio";
  #   system.build.installBootLoader = lib.mkForce "${pkgs.coreutils}/bin/true";
  # };

  swapDevices = [ ];
  zramSwap.enable = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # --- boot ---

  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    # grub = {
    #   enable = true;
    #   efiSupport = true;
    #   device = "nodev";
    # };
    systemd-boot = {
      enable = true;
      editor = false;

      # Chainload Fedora's shim -> grub. shim.efi loads grubx64.efi from the
      # same dir on the ESP, which reads /EFI/fedora/grub.cfg and redirects to
      # the real grub.cfg on Fedora's /boot partition (UUID 71c5909c).
      extraEntries = {
        "fedora.conf" = ''
          title Fedora
          efi /EFI/fedora/shim.efi
        '';
      };
    };
  };

  # --- network ---

  networking.hostName = "kerapace";
  networking.networkmanager.enable = true;

  # --- desktop ---

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
}
