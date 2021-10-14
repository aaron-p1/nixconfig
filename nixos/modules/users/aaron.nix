{ pkgs, ... }:
{
  users.users.aaron = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  environment.etc."u2f-mappings" = {
    text = builtins.concatStringsSep ":" [
      "aaron"
      # yubikey ..9
      "Mb3DZGUsu4lhdja3HFiITo8bVdlYSSCisnNaXUukK0hLeIuHp7xHf7QFP/2VTwVei23pVNT9e3wE/eX1JJSkUQ==,Xu6hTKJhHgVU7Z3hIzqBhst3E0xW4J/MudMPLhruK4XFhIr74y69D9Z0aCsFZQ6YOcE0rk+4yTFSQhu/bR2S7A==,es256,+presence"
      # yubikey ..2
      "LV/FPWrKyNQBfWhHDGxXVZkx/LDoW+EJKV65A28igjqqGKPGJ7PWWEQlNtumOy6b0C2WHYXo9MeSbqQboAs98w==,dSfmZDimcp1x3ttEM9sBCd7/fBE+EZ2aoboLx9GR/YIfJCyU/DWH7t+6vWQv8MzxL5mjZOjboGHoUrnCxCopvQ==,es256,+presence"
    ];
  };
}
