{
  description = "plot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    uv2nix.url = "github:pyproject-nix/uv2nix";
    pyproject-build-systems.url = "github:pyproject-nix/build-system-pkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      plot-overlay = import ./nix/overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ plot-overlay ];
          config.allowUnfree = true;
        };
        shell = pkgs.mkShell {
          venvDir = ".venv";
          packages = with pkgs; [
            uv
          ];

          shellHook = ''
            export UV_PYTHON=${pkgs.python313}/bin/python
            venvDir=.venv
            if [ ! -d "$venvDir" ]; then
              uv venv .venv
              echo "Created virtual environment in $venvDir"
            fi
            source $venvDir/bin/activate
          '';
        };
      in
      {
        packages = rec {
          default = plot;
          plot = pkgs.plot;
        };

        apps.default = {
          type = "app";
          program = "${pkgs.plot}/bin/plot";
        };

        devShells.default = shell;
      }
    )
    // {
      overlays.default = plot-overlay;
    };
}
