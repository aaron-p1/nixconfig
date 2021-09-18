{ pkgs, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "Nothing";
  };

  xdg.configFile."easyeffects" = {
    source = ../../dotfiles/easyeffects;
    recursive = true;
  };
}
