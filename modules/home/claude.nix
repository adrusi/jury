username:
{ ... }:
{
  imports = [
  ];

  home-manager.users.${username} = {
    programs.claude-code = {
      enable = true;
      settings.default = {
        theme = "light";
      };
    };

    programs.git.ignores = [
      "CLAUDE.local.md"
    ];
  };
}
