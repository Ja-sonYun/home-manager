{
  description = "A Nix-flake-based AWS Node20 Python310 development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self
    , nixpkgs
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
          f {
            pkgs = import nixpkgs {
              inherit system;
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
              python310
              (with pkgs.python310Packages; [
                venvShellHook
              ])

              # Packages manager
              (poetry.withPlugins (
                ps: with ps; [
                  poetry-plugin-export
                ]
              ))
              uv
              rye

              nodejs_20
              nodePackages.pnpm
              yarn

              awscli2
            ];
          };
        }
      );
    };
}
