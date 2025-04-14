{
  description = "A Nix-flake-based Python3.10 development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
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
            pkgs = import nixpkgs { inherit system; };
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
            ];
          };
        }
      );
    };
}
