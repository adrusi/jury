# Red Dead Redemption 2 (Steam 1174180) under Proton.
#
# Steam-side state this expects (not managed here):
#   - compatibility tool: GE-Proton (Proton 9 can't run the current Rockstar
#     launcher; its embedded browser dies on startup)
#   - launch options: `/run/current-system/sw/bin/rdr2-launch %command%`
#   - in-game API: DX12. Through vkd3d-proton it runs ~60% faster than the
#     game's own Vulkan renderer on Intel Xe3 (54 vs 34 fps, same 1080p scene)
{ lib, pkgs, ... }:
let
  # The game's startup entitlement check races when it runs on several CPUs,
  # failing with "ACTIVATION ERROR: not entitled". Start the whole tree pinned
  # to cpu 0, free the launcher once RDR2.exe exists, and free the game's
  # threads a while after its window is up. Pinned, the main menu (and so the
  # end of the check) comes ~25s after the window; freeing it right at the
  # window still fails sometimes. WINE_CPU_TOPOLOGY keeps Wine reporting
  # every CPU while pinned, so the game sizes its thread pools for the whole
  # machine rather than for one core.
  rdr2-launch = pkgs.writeShellScriptBin "rdr2-launch" ''
    n=$(${pkgs.coreutils}/bin/nproc --all)
    all=0-$((n - 1))
    export WINE_CPU_TOPOLOGY=''${WINE_CPU_TOPOLOGY:-$n:$(${pkgs.coreutils}/bin/seq -s, 0 $((n - 1)))}
    # GE's protonfix forces -vulkan (as a single malformed argument); let the
    # in-game API setting decide instead
    export PROTONFIXES_DISABLE=1
    # only offer the game the Intel GPU; it will happily pick llvmpipe
    export VK_LOADER_DRIVERS_SELECT='*intel_icd*'

    pfx=''${STEAM_COMPAT_DATA_PATH:-$HOME/.local/share/Steam/steamapps/compatdata/1174180}
    launcherlog="$pfx/pfx/drive_c/users/steamuser/Documents/Rockstar Games/Launcher/launcher.log"
    root=$$

    (
      PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.procps pkgs.util-linux ]}

      descendants() {
        local k
        for k in $(pgrep -P "$1"); do echo "$k"; descendants "$k"; done
      }
      widen() {
        local p
        for p in $(descendants $root); do
          [ "$p" = "$1" ] || taskset -a -p -c $all "$p" >/dev/null 2>&1
        done
      }

      until game=$(pgrep -x RDR2.exe); do
        kill -0 $root 2>/dev/null || exit
        sleep 0.1
      done
      widen "$game"
      until grep -q 'Phase Four: Game Window Active' "$launcherlog" 2>/dev/null; do
        kill -0 "$game" 2>/dev/null || exit
        sleep 0.2
      done
      sleep "''${RDR2_WIDEN_DELAY:-40}"
      # wine remembers the affinity the process started with and applies it
      # to every new thread, so keep freeing them
      while kill -0 "$game" 2>/dev/null; do
        widen
        sleep 2
      done
    ) </dev/null >/dev/null 2>&1 & # don't hold steam's pipes open past the game

    exec ${pkgs.util-linux}/bin/taskset -c 0 "$@"
  '';
in
{
  environment.systemPackages = [
    rdr2-launch
    pkgs.mangohud
  ];
}
