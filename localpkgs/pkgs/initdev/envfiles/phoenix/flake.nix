{
  description = "A very basic flake";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-compat }: {

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux;
      mkShell { packages = [ elixir inotify-tools ]; };
  };
}
