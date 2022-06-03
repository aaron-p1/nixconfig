{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux;
      mkShell {
        src = with builtins;
          filterSource (path: type:
            elem path (map (e: toString (./. + "/${e}")) [
              "flake.nix"
              "flake.lock"
              ".envrc"
            ])) ./.;

        packages = [
          # packages
          dart
        ];

        shellHook = ''
          export PATH="$HOME/.pub-cache/bin:$PATH"
        '';
      };
  };
}
