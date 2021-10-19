{ pkgs, ... }:
{
  users.users.aaron = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB668EmES2fAD6UVJEEAZCpbzX4Tu/S2dOfIG9ncuqIWyCBNz0IQfE+rGqwdpkjoagp5sy7V5OqSZLCct0IDMX9DrtSq1ucxSib14lmuKm6b1BhHMhexC7XSjmpn0QWAtmhaLz0P8eEsO+V3BWz6aNRZKhJ+1FmI3yKgQ5B2Et5UrZ2l0v0d/Pw799uhO0P+JGPYyWwHEWK2+vT1bHP9c/xjs37SnNrFv/EEWRiP55J8e2htNpJsDbmwi933Vg1UU+PJCp/g4m5O98pY6xOOp6bKC2mOHHwwGoWeX2yXvwHB62UqCspssoBg4GYkdu8/szrR1MEjbIXGDiermKoaWym/efJOEgNqM1aZTx8ojp5K8oveVOt7UrReLmbopQuz13y8mftv9CSvAjC7DTgqgb0ncRYfh1jgLOUjojejqkZ7wT3BC2/koP3VqZDVCb4qLN56juGWnApjgrAyKW7lSZ+++lw+mblwj0Zd6kKspoend1vSLtYQTKUpSEoLPCiWVJAM7pAcA5oup47iRfkOWHb5/mhfPL3soVO2AAf0z5aBO5curtuYDbgLle6KdWXfuzp6bDrwTsaGa0Sti0fDFuVERQvWixAY86b92P2GJwamK1s/los3Pvs4GjkdlrY5O6FuYVpYaPTWrJuAzu5Qp3SLbyvLHM5zvR31Q4t0+MRw== iPhone Terminus"
    ];
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
