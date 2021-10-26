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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh07Fbs/q5/rOaLiv9F7Zy/iGjmZ9OPBOviCrAVrKkOSfxdvpPNrjjEWhBhOva1vGmHy5uSW7Ah+JnVm29YEz1AAJFzJfLlk7ScL3PTCQEW+nrpSxGDk+IPirp/HAHi/xksltagMSpUKpjQ9G2LZvTjOhCZ418lKHQJZaTm9PgmqZ9Yk8ofg/AwlxYC8lGUBYzHTCMTxA9YJ9KNkFcp2kGQpTtp7bXcsX571E358CZO4/bbOJtRYV1r26gx+ppgAo4IXk6UOSPSTWTIOG+OWGLxOjwQN0rSBk8uzQHZHx3HcebSGdvKhHbBCrKywXkicVK7gRqM+/TAMw+wJP00s7B2ZWOxpSvH6KBnjU7K44KYeEqgeG3ZiX6gGf2tWvgTbsKHB2uMo87S+yPcdpWeixlnEEGAlJVpJUPVdEldRbHN1hYFMf3AS1HsBXJLbsLX+D3OrL5phdK2Lp91qmw6x8ovXwx5KYvcMlOnrM+0An1Sd446osSfyxkFJ1FyyC3WEe/8k19k72L10FIdicnecTR+It6yn/EDyr8L323mvrUUf+srojKAnTsJJLEA+7K+JGNA3idaD5JymkzDQShSd91hazX769o9EYLAE69+A5D/RV/91LemfTZKj1GbuzGPBpGJtl6j+UTcmkSqJyAk0FWqBQiiKvJRjnkhZjcMWtaSQ== iPhone Shortcuts"
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
