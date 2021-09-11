{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    wget
    neovim-nightly
  ];
}
