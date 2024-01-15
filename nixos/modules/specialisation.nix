{ config, lib, extendModules, noUserModules, options, inputs, ... }:
let cfg = config.within.specialisation;
in with lib; {
  options.within.specialisation = { };

  config = {
    # add /etc/specialisation with the name of the specialisations
    # specialisation.hyprland = mkIf cfg.hyprland {
    #   configuration = {
    #     imports = [ ../configs/specialisations/hyprland.nix ];
    #
    #     environment.etc."specialisation".text = "hyprland";
    #   };
    # };
  };
}
