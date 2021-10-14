{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;

    bindings = {
      "CTRL+UP" = "seek +3600 relative";
      "CTRL+DOWN" = "seek -3600 relative";
      "ſ" = "seek 0 absolute";
    };

    config = {
      volume = 100;
      osc = "no"; # mpv_thumbnail_script_client_osc
    };

    profiles = {
      p = {
        af = "scaletempo=stride=28:overlap=.9:search=25";
      };
    };

    scripts = with pkgs.mpvScripts; [
      mpris
      thumbnail
      sponsorblock
    ];
  };
}
