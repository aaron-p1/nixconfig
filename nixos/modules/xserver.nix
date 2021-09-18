{ pkgs, ... }:
{
  services.xserver = {
    enable = true;

    layout = "de";

    xkbOptions = builtins.concatStringsSep "," [
      "terminate:ctrl_alt_bksp"
      "caps:escape"
      "compose:sclk"
    ];
  };
}
