{
  inputs = rec {
    stable.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";

    localpkgs = {
      url = "path:./localpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, nixpkgs, stable, nur, localpkgs, nixos-hardware, flake-utils, ...}@inputs:
  let
    inherit (inputs.unstable) lib; # unstable for home manager
    overlays = [
      inputs.neovim-nightly-overlay.overlay
      nur.overlay
      localpkgs.overlay
      (final: prev: {
        stable = import stable { inherit (final) system; };
      })
    ];
  in {
    nixosConfigurations = {
      aaron-pc = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }

          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel

          ./nixos/configs/main.nix
          ./hosts/aaron-pc/configuration.nix

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.aaron = {
                imports = [
                  ./home-manager/configs/main.nix
                  ./hosts/aaron-pc/home.nix
                ];
              };
            };
          }
        ];
        extraArgs = { inherit inputs; };
      };
    };
  }
  //
  flake-utils.lib.eachDefaultSystem (system: 
  let
    pkgs = nixpkgs.legacyPackages."${system}";
  in {
    devShell = pkgs.mkShell {
      packages = with pkgs; [
        gnumake
        rsync

        # lsp
        sumneko-lua-language-server
      ];
    };
  }
  );
}
