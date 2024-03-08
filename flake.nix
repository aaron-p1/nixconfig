{
  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";

    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";

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
  };

  outputs = { self, stable, unstable, nixpkgs, nixpkgs2305, flake-utils
    , nixos-hardware, nur, home-manager, neovim-nightly-overlay, ... }@inputs:
    let
      inherit (unstable) lib; # unstable for home manager
      overlays = [
        (final: prev: { stable = import stable { inherit (final) system; }; })
        nur.overlay
        neovim-nightly-overlay.overlay
        (import ./localpkgs { inherit inputs; })
        (import ./dotfiles { })
        (final: prev: {
          inherit (import nixpkgs2305 {
            inherit (final) system;
            config.permittedInsecurePackages = [ "nodejs-16.20.2" ];
          })
          # for nvim dotfiles vscode-php-debug
            nodejs_16;
        })
      ];
    in {
      nixosConfigurations = {
        aaron-pc = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = overlays; }

            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel-cpu-only

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
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = overlays; }

            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-cpu-intel-cpu-only
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
          packages = with pkgs; [ gnumake rsync git-crypt jq ];
        };
      });
}
