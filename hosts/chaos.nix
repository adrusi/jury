{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # chaos: the NixOS system running as a systemd-nspawn --boot guest under the
  # Fedora host. The host owns the kernel, LUKS, bootloader, udev and
  # networking; this config is just userspace. Shared config is in
  # dmodel-common.nix. Hardware/boot bits from kerapace.nix are intentionally
  # absent (the host provides them).
  imports = [
    ./dmodel-common.nix
  ];

  # Stub out kernel/initrd/bootloader and make fileSystems optional: the host
  # mounts nixos-root (/), nixos-nix (/nix) and the shared /home for us.
  boot.isContainer = true;

  networking.hostName = "chaos";
  # Networking is owned by the Fedora host (shared netns, host NetworkManager
  # drives WiFi). The guest runs no NM, no firewall, no sshd of its own.

  # --- desktop / seat ---
  #
  # First pass: greetd autologins autumn straight into sway, which takes DRM
  # master on the real GPU via seatd (no logind VT dance). Device passthrough
  # (/dev/dri, /dev/input, /run/udev, backlight, ...) is configured host-side
  # in the nspawn unit; this is iterated on in the passthrough phase.
  services.seatd.enable = true;
  services.greetd =
    let
      # `bash -lc` sources autumn's profile so the home-manager-provided
      # (swayfx) sway is on PATH.
      session = {
        command = "${pkgs.bash}/bin/bash -lc sway";
        user = "autumn";
      };
    in
    {
      enable = true;
      settings = {
        initial_session = session;
        default_session = session;
      };
    };

  users.users.autumn.extraGroups = [
    "seat"
    "video"
    "input"
    "render"
  ];
}
