{
  description = "A Nix-flake-based Terraform with Gcloud and Python310 development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-terraform.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

  outputs =
    { nixpkgs, nixpkgs-terraform, ... }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
            pkgs-terraform = import nixpkgs-terraform {
              inherit system;
              config.allowUnfree = true;
            };
          in
          f {
            inherit
              system
              pkgs
              pkgs-terraform
              ;
          }
        );
    in
    {
      devShells = forEachSystem (
        { pkgs, pkgs-terraform, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              python310

              # Packages manager
              (poetry.withPlugins (
                ps: with ps; [
                  poetry-plugin-export
                ]
              ))
              rye
              uv

              pkgs-terraform.terraform

              google-cloud-sdk
              (google-cloud-sdk.withExtraComponents (
                with google-cloud-sdk.components;
                [
                  gke-gcloud-auth-plugin
                ]
              ))
              kubernetes-helm
            ];
            shellHook = ''
              # Load environment variables from .env if present.
              set -a
              if [ -f ".env" ]; then
                source .env
              fi
              set +a

              if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
                uv venv "$UV_PROJECT_ENVIRONMENT" --python "$UV_PYTHON"
              fi

              source "$UV_PROJECT_ENVIRONMENT/bin/activate"
            '';
            env = {
              UV_PROJECT_ENVIRONMENT = ".venv";
              UV_PYTHON = "${pkgs.python310}/bin/python3";
              UV_NO_SYNC = "1";
              UV_PYTHON_DOWNLOADS = "never";
            };
          };
        }
      );
    };
}
