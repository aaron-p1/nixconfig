{ pkgs, lib, ... }:
let
  inherit (lib) mapAttrs' nameValuePair foldr mapAttrsToList flip pipe;
  inherit (builtins) concatStringsSep;

  # String -> AttrSet -> AttrSet
  addKeyPrefix = (pre: mapAttrs' (k: v: nameValuePair (pre + "-" + k) (v)));
  # [AttrSet] -> AttrSet
  concatAttrs = foldr (a: acc: acc // a) {};
  # AttrSet -> [String]
  toStringList = mapAttrsToList (k: v: k + "=" + (toString v));

  # AttrSet -> String
  toListOptions = flip pipe [
    toStringList # AttrSet to [ "key=value" ... ]
    (concatStringsSep ",")
  ];

  # AttrSet -> String
  toListOptionsPrefix = flip pipe [
    (mapAttrsToList addKeyPrefix) # { prefix.abc = 1 } -> [ { prefix-abc = 1 } ]
    concatAttrs
    toListOptions
  ];
in
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
      script-opts = toListOptionsPrefix {
        ytdl_hook = {
          ytdl_path = "${pkgs.yt-dlp}/bin/yt-dlp";
        };
      };
      ytdl-raw-options = toListOptions {
        sub-lang = "\"en,de\"";
        write-sub = "";
        write-auto-sub = "";
      };
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
