{ config, lib, pkgs, ... }:
let
  inherit (lib)
    concatStringsSep mapAttrsToList mkEnableOption mkOption types mkIf;

  cfg = config.within.git;

  toAttributeProperties = attrs:
    concatStringsSep " "
    (mapAttrsToList (name: value: "${name}=${value}") attrs);

  toAttributeLines = attributes:
    mapAttrsToList (pattern: attrs: "${pattern} ${toAttributeProperties attrs}")
    attributes;
in {
  options.within.git = {
    enable = mkEnableOption "Git";

    signingKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "enable git commit signing";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        co = "checkout";
        f = "fetch";
      };
      userName = "Aaron Pietscher";
      signing = mkIf (cfg.signingKey != null) {
        signer = "${config.programs.gpg.package}/bin/gpg2";
        signByDefault = true;
        key = cfg.signingKey;
      };
      extraConfig = { init.defaultBranch = "main"; };
      attributes = toAttributeLines {
        "*.php" = { diff = "php"; };
        "*.css" = { diff = "css"; };
        "*.html" = { diff = "html"; };
      };
    };

    home.packages = [
      (pkgs.writeTextFile rec {
        name = "gitemail";
        destination = "/bin/${name}";
        executable = true;
        text = ''
          #!/bin/sh

          if [ ! -r "$HOME/.local/share/gitemails" ]
          then
            echo "create File $HOME/.local/share/gitemails"
            echo "[shortform]\\t[email]"
            exit 1
          fi

          usage() {
            echo "Usage: gitemail {shortform}"
            cat "$HOME/.local/share/gitemails"
            exit 2
          }

          [ -z "$1" ] && usage

          result=$(grep "^$1" "$HOME/.local/share/gitemails" | head | cut -f2)

          [ -z "$result" ] && usage

          echo "Setting user.email to '$result'"
          ${pkgs.git}/bin/git config user.email "$result"
        '';
      })
    ];
  };
}
