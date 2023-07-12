{ lib, ... }: {
  within.graphics = {
    sddm.enable = lib.mkForce false;
    plasma.enable = lib.mkForce false;
    gdm.enable = true;

    hyprland = {
      enable = true;
      nvidia = true;
    };
  };
}
