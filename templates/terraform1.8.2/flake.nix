{
  description = "Terraform Infrastructure Deployment Shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs-terraform.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";
  };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-terraform
    ,
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
        { pkgs
        , pkgs-terraform
        ,
        }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              pkgs-terraform.terraform
            ];
          };
        }
      );
    };
}
