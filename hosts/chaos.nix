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

  # nspawn doesn't grant the user namespaces Nix's build sandbox needs, so
  # disable it — lets `nixos-rebuild` run from inside the container.
  nix.settings.sandbox = false;

  networking.hostName = "chaos";
  # Networking is owned by the Fedora host (shared netns, host NetworkManager
  # drives WiFi). The guest runs no NM, no firewall, no sshd of its own.
  # nspawn binds the host's /etc/resolv.conf (read-only), so don't let NixOS's
  # resolvconf try to rewrite it (DNS comes from the host).
  networking.resolvconf.enable = lib.mkForce false;

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
    "audio-host"
  ];

  # --- audio ---
  #
  # The host's /dev/snd nodes are owned by the host's `audio` group (gid 63),
  # which is bind-mounted into the container. The guest's own `audio` group has
  # a different gid, so create a group matching the host's numeric gid and put
  # autumn in it, giving pipewire DAC access to the sound devices across the
  # namespace boundary. (The host-side nspawn unit binds /dev/snd + allows
  # char-alsa.)
  users.groups.audio-host.gid = 63;

  # --- host shell ---
  #
  # `hostshell` opens a shell (or runs a command) on the Fedora host that owns
  # this machine — handy since the host owns networking, the kernel, power and
  # the bootloader. Works because the container shares the host's network
  # namespace, so the host's sshd is reachable on loopback; auth uses autumn's
  # shared ~/.ssh key.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "hostshell" ''
      exec ${pkgs.openssh}/bin/ssh -t -o StrictHostKeyChecking=accept-new autumn@127.0.0.1 "$@"
    '')
  ];
}
