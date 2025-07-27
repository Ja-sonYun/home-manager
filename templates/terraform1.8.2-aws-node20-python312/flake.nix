{
  description = "A Nix-flake-based Terraform 1.8.2 with AWS and Node20 and Python3.12 development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-terraform.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-terraform,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
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
              pkgs
              pkgs-terraform
              ;
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        {
          pkgs,
          pkgs-terraform,
        }:
        {
          default = pkgs.mkShell {
            venvDir = ".venv";
            packages = with pkgs; [
              pkgs-terraform.terraform
              awscli2

              nodejs_20
              nodePackages.pnpm
              yarn

              python312

              (with pkgs.python312Packages; [
                venvShellHook
              ])

              # Packages manager
              (poetry.withPlugins (
                ps: with ps; [
                  poetry-plugin-export
                ]
              ))
              rye
              uv
            ];
          };
        }
      );
    };
}
