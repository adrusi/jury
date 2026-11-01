# atelier: agent-authored userstyles (github:adrusi/atelier). The signed
# extension in the default profile, its native host, the CLI, and agent
# sessions: Claude Code on atelier's queue (atelier-agent, with only
# atelier's MCP server), started in a new Ghostty window when a request is
# made from the extension's popup.
username:
{ pkgs, inputs, ... }:
{
  home-manager.users.${username} = {
    imports = [ inputs.atelier.homeManagerModules.default ];

    programs.atelier = {
      enable = true;
      atelierDir = "/home/${username}/src/atelier-styles";
      agent = {
        enable = true;
        # Edits are confined to the atelier directory and its task copies,
        # and every landing is undoable (atelier undo), so don't ask per edit.
        extraArgs = [ "--permission-mode" "acceptEdits" ];
      };
      session = {
        start = "spawn";
        command = "ghostty --working-directory={dir} -e atelier-agent";
      };
    };

    programs.firefox.profiles.default.extensions.packages = [
      inputs.atelier.packages.${pkgs.stdenv.system}.extension
    ];
  };
}
