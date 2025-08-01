{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    concatStringsSep
    mapAttrsToList
    filterAttrs
    length
    mapAttrs'
    nameValuePair
    mkMerge
    mkIf
    ;

  cfg = config.within.users;
in
{
  options.within.users = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, config, ... }:
        {
          options = {
            uid = mkOption {
              type = types.int;
              description = "uid";
            };
            sshKeys = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "SSH Keys";
            };
            u2fKeys = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "U2F Keys";
            };
          };
        }
      )
    );
    default = { };
    description = "User config";
  };

  config =
    let
      u2fText = concatStringsSep "\n" (
        mapAttrsToList (n: v: concatStringsSep ":" ([ n ] ++ v.u2fKeys)) (
          filterAttrs (n: v: length v.u2fKeys > 0) cfg
        )
      );
    in
    {
      users.users = mapAttrs' (
        name: config:
        nameValuePair name {
          inherit (config) uid;
          isNormalUser = true;
          createHome = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          shell = pkgs.zsh;

          autoSubUidGidRange = true; # for containers

          openssh.authorizedKeys.keys = config.sshKeys;
        }
      ) cfg;

      environment.etc = mkMerge [ (mkIf (u2fText != "") { "u2f-mappings".text = u2fText; }) ];
    };
}
