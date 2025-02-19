{
  description = "Python Node Terraform Project";

  inputs = {
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs-terraform,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nixpkgs-terraform.overlays.default
          ];
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Development
            pkgs.python310
            (pkgs.poetry.withPlugins (
              ps: with ps; [
                poetry-plugin-export
              ]
            ))
            pkgs.nodejs_20 # We are using npm
            pkgs.gnumake # Use most recent make

            # Infrastructure
            pkgs.awscli2
            pkgs.terraform-versions."1.8.2"
          ];
          shellHook = '''';
        };
      }
    );
}
