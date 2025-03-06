{
  description = "A Nix-flake-based Terraform 1.8.2 development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
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
            packages = with pkgs; [
              terraform-versions."1.8.2"
            ];
          };
        }
      );
    };
}
