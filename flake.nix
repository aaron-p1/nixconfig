{
  inputs = rec {
    stable.url = "github:nixos/nixpkgs/nixos-23.05";
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

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, stable, unstable, nixpkgs, flake-utils, nixos-hardware, nur
    , home-manager, neovim-nightly-overlay, hyprland, ... }@inputs:
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
            nixos-hardware.nixosModules.common-cpu-intel-cpu-only

            hyprland.nixosModules.default

            ./nixos/configs/main.nix
            ./hosts/aaron-pc/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.aaron = {
                  imports = [
                    hyprland.homeManagerModules.default

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
            nixos-hardware.nixosModules.common-cpu-intel-cpu-only
            nixos-hardware.nixosModules.common-gpu-nvidia
            nixos-hardware.nixosModules.common-pc-ssd

            hyprland.nixosModules.default

            ./nixos/configs/main.nix
            ./hosts/aaron-laptop/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.aaron = {
                  imports = [
                    hyprland.homeManagerModules.default

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
            git-crypt
            jq
          ];
        };
      });
}
