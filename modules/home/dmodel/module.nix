username:
{ pkgs, ... }:
{
  home-manager.users.${username} = {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "ec2-manage";
        runtimeInputs = [ pkgs.bash pkgs.awscli2 pkgs.ssm-session-manager-plugin pkgs.jq ];
        text = ./ec2-manage.sh;
      })
    ];
  };
}

