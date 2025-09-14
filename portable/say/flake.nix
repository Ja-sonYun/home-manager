{
  description = "nvtts with `say` binary";

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

      say-overlay = import ./nix/say-overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ say-overlay ];
          config.allowUnfree = true;
        };
        shell = pkgs.mkShell {
          name = "nvtts-shell";
          packages = [
            pkgs.uv
            pkgs.sayEnvWrapped
          ];
        };
      in
      {
        packages = rec {
          default = say;
          say = pkgs.say;
          sayEnv = pkgs.sayEnv;
          sayEnvWrapped = pkgs.sayEnvWrapped;
        };

        apps.default = {
          type = "app";
          program = "${pkgs.say}/bin/say";
        };

        devShells.default = shell;
      }
    )
    // {
      overlays.default = say-overlay;
    };
}
