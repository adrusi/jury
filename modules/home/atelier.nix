# atelier: agent-authored userstyles (github:adrusi/atelier). The signed
# extension in the default profile, its native host, the CLI, and agent
# sessions: Claude Code on atelier's queue (atelier-agent, with only
# atelier's MCP server), started in a new Ghostty window when a request is
# made from the extension's popup.
#
# Agents work out of the way, on the "atelier" workspace: their Claude Code
# windows in a tabbed column on the left, the Firefox window each session
# gets (session.windows) in a tabbed column on the right
# (atelier-sway-place.py). Sessions close themselves when their work is
# done, and their Firefox windows close with them.
username:
{ pkgs, inputs, ... }:
let
  appId = "com.adrusi.atelier.agent";
  # Firefox windows are found by firefox-sway-favicon's "[fx:ID] " title prefix.
  place = pkgs.writers.writePython3Bin "atelier-sway-place" {
    flakeIgnore = [ "E501" "E731" ];
  } (builtins.readFile ./atelier-sway-place.py);
in
{
  home-manager.users.${username} = {
    imports = [ inputs.atelier.homeManagerModules.default ];

    programs.atelier = {
      enable = true;
      atelierDir = "/home/${username}/src/atelier-styles";
      # Claude Code runs in auto permission mode (the module's default), and
      # ends once its work is done (agent.closeWhenDone).
      agent.enable = true;
      session = {
        start = "spawn";
        command = "ghostty --class=${appId} --working-directory={dir} -e atelier-agent";
        windows = true;
      };
      hooks.on_agent_window = ''${place}/bin/atelier-sway-place browser "$ATELIER_FIREFOX_WINDOW_ID"'';
    };

    wayland.windowManager.sway.extraConfig = ''
      for_window [app_id="${appId}"] exec ${place}/bin/atelier-sway-place agents ${appId}
    '';

    programs.firefox.profiles.default.extensions.packages = [
      inputs.atelier.packages.${pkgs.stdenv.system}.extension
    ];
  };
}
