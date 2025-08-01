{ config, lib, ... }:
let
  inherit (builtins)
    readDir
    attrNames
    foldl'
    readFile
    replaceStrings
    toString
    ;
  inherit (lib)
    flip
    pipe
    mkEnableOption
    mkIf
    recursiveUpdate
    ;

  cfg = config.within.easyeffects;

  # get file names of directory
  getFiles = (flip pipe) [
    readDir
    attrNames
  ];

  # get all input and output files
  profileNames = foldl' (
    acc: dir:
    acc ++ map (file: "easyeffects/${dir}/" + file) (getFiles (../../dotfiles/easyeffects + "/${dir}"))
  ) [ ] [ "input" "output" ];

  # replace text
  profiles = foldl' (
    acc: file:
    let
      fileText = readFile (../../dotfiles + "/${file}");
      replacedFileText = replaceStrings [ "{config}" ] [ (toString config.xdg.configHome) ] fileText;
    in
    acc // { "${file}".text = replacedFileText; }
  ) { } profileNames;

in
{
  options.within.easyeffects = {
    enable = mkEnableOption "Easyeffects";
  };

  config = mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };

    # needs programs.dconf.enable = true; in nixos

    dconf.settings."com/github/wwmm/easyeffects" = {
      use-dark-theme = true;
      process-all-inputs = true;
    };

    xdg.configFile = recursiveUpdate profiles {
      "easyeffects/rnnoise" = {
        source = ../../dotfiles/easyeffects/rnnoise;
        recursive = true;
      };
    };
  };
}
