{ config, lib, ... }:
let
  cfg = config.within.easyeffects;

  # get file names of directory
  getFiles = (lib.flip lib.pipe) (with builtins; [ readDir attrNames ]);

  # get all input and output files
  profileNames = builtins.foldl' (acc: dir:
    acc ++ builtins.map (file: "easyeffects/${dir}/" + file)
    (getFiles (../../dotfiles/easyeffects + "/${dir}")))
    [ ] [ "input" "output" ];

  # replace text
  profiles = builtins.foldl' (acc: file:
    let
      fileText = builtins.readFile (../../dotfiles + "/${file}");
      replacedFileText = builtins.replaceStrings [ "{config}" ]
        [ (builtins.toString config.xdg.configHome) ] fileText;
    in acc // { "${file}".text = replacedFileText; }) { } profileNames;

in with lib; {
  options.within.easyeffects = { enable = mkEnableOption "Easyeffects"; };

  config = mkIf cfg.enable {
    services.easyeffects = { enable = true; };

    # needs programs.dconf.enable = true; in nixos

    dconf.settings."com/github/wwmm/easyeffects" = {
      use-dark-theme = true;
      process-all-inputs = true;
    };

    xdg.configFile = lib.recursiveUpdate profiles {
      "easyeffects/rnnoise" = {
        source = ../../dotfiles/easyeffects/rnnoise;
        recursive = true;
      };
    };
  };
}
