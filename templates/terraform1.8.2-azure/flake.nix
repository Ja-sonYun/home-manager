{
  description = "A Nix-flake-based Terraform 1.8.2 with Azure development environment";

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
              pkgs-terraform.terraform

              azure-cli
            ];
          };
        }
      );
    };
}
