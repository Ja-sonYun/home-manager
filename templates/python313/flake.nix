{
  description = "A Nix-flake-based Python3.13 development environment";

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
              uv
            ];
            shellHook = ''
              if [ ! -d .venv ]; then
                echo "Creating virtual environment in .venv using Python 3.13..."
                ${pkgs.python313}/bin/python3 -m venv .venv
              fi

              source .venv/bin/activate
            '';
            env = {
              # UVからPython3.13を使用するように設定
              UV_PYTHON = "${pkgs.python313}/bin/python3";
              UV_NO_SYNC = "1";
              UV_PYTHON_DOWNLOADS = "never";
            };
          };
        }
      );
    };
}
