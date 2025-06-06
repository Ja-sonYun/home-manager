{
  description = "A Nix-flake-based Terraform 1.8.2 with AWS and Node20 and Python3.12 development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";

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
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                nixpkgs-terraform.overlays.default
              ];
              config = {
                allowUnfree = true;
              };
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            venvDir = ".venv";
            packages = with pkgs; [
              terraform-versions."1.8.2"
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
