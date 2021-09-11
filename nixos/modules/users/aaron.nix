{ pkgs, ... }:
{
  users.users.aaron = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };
}
