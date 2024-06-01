{ config, lib, pkgs, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (lib)
    mapAttrs' nameValuePair foldr mapAttrsToList flip pipe mkEnableOption mkIf;

  cfg = config.within.mpv;

  # String -> AttrSet -> AttrSet
  addKeyPrefix = pre: mapAttrs' (k: nameValuePair (pre + "-" + k));
  # [AttrSet] -> AttrSet
  concatAttrs = foldr (a: acc: acc // a) { };
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
in {
  options.within.mpv = { enable = mkEnableOption "mpv"; };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;

      bindings = {
        "CTRL+UP" = "seek +3600 relative";
        "CTRL+DOWN" = "seek -3600 relative";
        "Ctrl+i" = "seek +85 relative";
        "ſ" = "seek 0 absolute";
        "Ctrl+BS" = "no-osd sub-seek 0";
      };

      config = {
        volume = 100;
        audio-display = "no";
        demuxer-max-bytes = "2048MiB";
        demuxer-max-back-bytes = "2048MiB";
        script-opts = toListOptionsPrefix {
          ytdl_hook = { ytdl_path = "${pkgs.yt-dlp}/bin/yt-dlp"; };
          sponsorblock = rec {
            categories =
              ''"sponsor,intro,outro,interaction,selfpromo,preview"'';
            skip_categories = categories;
            local_database = "no";
          };
        };
        ytdl-raw-options = toListOptions {
          sub-lang = ''"en,de"'';
          write-sub = "";
          write-auto-sub = "";
          embed-chapters = "";
        };
      };

      profiles = { p = { af = "scaletempo=stride=28:overlap=.9:search=25"; }; };

      scripts = with pkgs.mpvScripts; [ mpris sponsorblock ];
    };
  };
}
