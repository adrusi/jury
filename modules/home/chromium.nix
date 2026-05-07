username:
{ pkgs, lib, inputs, ... }:
{
  imports = [
    ../system/chromium.nix
  ];

  home-manager.users.${username} = {
    programs.chromium = {
      enable = true;

      commandLineArgs = [
        # Run natively under Wayland instead of XWayland.
        "--ozone-platform-hint=auto"
        # VA-API hardware encode/decode for video calls, plus PipeWire capture so
        # Wayland screen sharing works in Meet/Zoom/etc.
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,WebRTCPipeWireCapturer"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];

      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      ];
    };
  };
}
