{
  inputs = rec {
    stable.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";

    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    # LOCAL PACKAGES
    jdt-ls.url =
      "github:nixos/nixpkgs?rev=3ae6abea23628f16a1c60ce9f9ec36deb0b5a59e";
  };

  outputs = { self, stable, unstable, nixpkgs, flake-utils, nixos-hardware, nur
    , home-manager, neovim-nightly-overlay, ... }@inputs:
    let
      inherit (unstable) lib; # unstable for home manager
      overlays = [
        (final: prev: { stable = import stable { inherit (final) system; }; })
        nur.overlay
        neovim-nightly-overlay.overlay
        (import ./localpkgs { inherit inputs; })
      ];
    in {
      nixosConfigurations = {
        aaron-pc = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { _module.args = { inherit inputs; }; }
            { nixpkgs.overlays = overlays; }

            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel

            ./nixos/configs/main.nix
            ./hosts/aaron-pc/configuration.nix

            home-manager.nixosModules.home-manager
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
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages."${system}";
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            gnumake
            rsync

            # lsp
            sumneko-lua-language-server
          ];
        };
      });
}
