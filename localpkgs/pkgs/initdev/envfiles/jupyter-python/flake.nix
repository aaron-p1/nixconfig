{
  description = "JupyterLab Flake";

  inputs = {
    jupyterWith.url = "github:tweag/jupyterWith";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      jupyterWith,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
        };
        iPython = pkgs.kernels.iPythonWith {
          name = "Python-env";
          packages =
            p: with p; [
              # packages
            ];
          ignoreCollisions = true;
        };
        jupyterEnvironment = pkgs.jupyterlabWith { kernels = [ iPython ]; };
      in
      rec {
        apps.jupterlab = {
          type = "app";
          program = "${jupyterEnvironment}/bin/jupyter-lab";
        };
        defaultApp = apps.jupterlab;
        devShell = jupyterEnvironment.env;
      }
    );
}
