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
      "github:nixos/nixpkgs?rev=aa4be0ccb4e62231fddcfa1d95c5b7642c6b1423";
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
        (import ./dotfiles { })
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
        aaron-laptop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { _module.args = { inherit inputs; }; }
            { nixpkgs.overlays = overlays; }

            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-gpu-nvidia
            nixos-hardware.nixosModules.common-pc-ssd

            ./nixos/configs/main.nix
            ./hosts/aaron-laptop/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.aaron = {
                  imports = [
                    ./home-manager/configs/main.nix
                    ./hosts/aaron-laptop/home.nix
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
