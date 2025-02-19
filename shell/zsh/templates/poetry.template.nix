{
  description = "Poetry Project";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
          config = { };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.gnumake # Use most recent make

            pkgs.python310
            (pkgs.poetry.withPlugins (
              ps: with ps; [
                poetry-plugin-export
              ]
            ))
          ];
          shellHook = '''';
        };
      }
    );
}
