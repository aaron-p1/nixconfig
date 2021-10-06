{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      window.dimensions = {
        lines = 24;
        columns = 80;
      };
      key_bindings = [
        {
          key = "F11";
          action = "ToggleFullscreen";
        }
      ];
    };
  };
}
