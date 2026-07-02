{ pkgs }:
let
  inherit (pkgs) lib;
  electron = pkgs.electron_42; # closest nixpkgs major to the bundled 42.5.1
  pname = "claude-desktop";
  version = "1.17377.0";

  # Anthropic ships a real native-Linux Electron build (.deb) for the beta,
  # so unlike the old community Windows-repackaging flakes there's no need
  # to reimplement any native modules. We discard the bundled Electron
  # binary and Chromium runtime files (libffmpeg.so, locales/*.pak, the
  # bundled chrome-sandbox, etc.) in favor of nixpkgs' electron, and keep
  # only the app's own resources/ (app.asar + the small native addons and
  # helper binaries it ships alongside it), autoPatchelf'd against nix
  # libs. See https://code.claude.com/docs/en/desktop-linux
  src = pkgs.fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-VjyN+O47lXyiNBFZgDhulgAH7Yz8jMBMd9WKjUP2wBg=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = with pkgs; [
    binutils # ar, to unpack the .deb
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc.lib # libstdc++/libgcc_s, for node-pty's pty.node
    pkgs.libseccomp # virtiofsd
    pkgs.libcap_ng # virtiofsd
  ];

  unpackPhase = ''
    runHook preUnpack
    ar x $src
    # avoid dpkg-deb's attempt to set chrome-sandbox's setuid bit, which we
    # discard anyway (we only keep resources/, see installPhase)
    tar --no-same-permissions --no-same-owner -xf data.tar.*
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  # autoPatchelf only needs to look at the few real ELF binaries we keep
  # (the two native node addons, chrome-native-host, virtiofsd); it skips
  # the statically-linked cowork-linux-helper automatically.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/claude-desktop $out/bin
    cp -r usr/lib/claude-desktop/resources/. $out/share/claude-desktop/

    for size in 16 32 48 128 256; do
      install -Dm444 usr/share/icons/hicolor/''${size}x''${size}/apps/claude-desktop.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/claude-desktop.png
    done

    makeWrapper ${lib.getExe electron} $out/bin/claude-desktop \
      --add-flags $out/share/claude-desktop/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1

    runHook postInstall
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "claude-desktop";
      desktopName = "Claude";
      genericName = "AI Assistant";
      comment = "Desktop application for Claude.ai";
      icon = "claude-desktop";
      exec = "claude-desktop %U";
      startupNotify = true;
      startupWMClass = "claude-desktop";
      categories = [
        "Utility"
        "Development"
      ];
      keywords = [
        "AI"
        "Chat"
        "Assistant"
        "Claude"
        "Code"
        "LLM"
      ];
      mimeTypes = [ "x-scheme-handler/claude" ];
      actions = {
        NewChat = {
          name = "New chat";
          exec = "claude-desktop claude://claude.ai/new";
        };
        NewCode = {
          name = "New Claude Code session";
          exec = "claude-desktop claude://code/new";
        };
      };
    })
  ];

  # The "Cowork" sandbox (qemu + virtiofsd microVM) looks for OVMF firmware
  # at hardcoded Debian/Ubuntu paths (/usr/share/OVMF/OVMF_CODE*.fd) and
  # won't find it under NixOS even with qemu/OVMF installed; Chat and Code
  # work fine without it.
  meta = {
    description = "Desktop application for Claude.ai (Linux beta)";
    homepage = "https://claude.ai";
    downloadPage = "https://claude.com/download";
    changelog = "https://code.claude.com/docs/en/desktop-linux";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
