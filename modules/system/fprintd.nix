{ config, lib, ... }:
{
  # Fingerprint unlock for the lock screen only: hyprlock talks to fprintd
  # directly (see modules/home/sway.nix). Enroll with `fprintd-enroll`.
  config.services.fprintd.enable = true;

  # fprintd is normally dbus-activated and exits after ~30s idle, but hyprlock
  # queries it synchronously right after taking the session lock, so each
  # cold start (~450ms) showed up as a black screen before the lock rendered.
  # Keep it resident instead; it only claims the reader while verifying.
  config.systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = [
      ""
      "${config.services.fprintd.package}/libexec/fprintd --no-timeout"
    ];
  };

  # fprintd.enable defaults fprintAuth on for every pam service (sudo, su,
  # polkit, ...); knock that default back down so services opt in explicitly.
  # (gdm's own gdm-fingerprint service for the greeter is unaffected.)
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        fprintAuth = lib.mkDefault false;
      }
    );
  };
}
