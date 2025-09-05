{ pkgs, lib, userhome, ... }:

let
  pyright = pkgs.callPackage ./pyright.nix {};
in
pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "serena";
  pythonVersion = "311";
  preInstall = [
    "hatchling"
  ];
  packages = [
    "git+https://github.com/oraios/serena.git@v0.1.4#egg=serena-agent"
  ];
  exposedBinaries = [
    "serena-mcp-server"
  ];
  outputHash = "sha256-7gGD4x3cu7RqDCxSMtYHbocSDzTUWAG9JsXbtA1pAGA=";
  postInstall = ''
    ln -s ${userhome}/.serena_config.yml $out/venv/serena/lib/python3.11/serena_config.yml
    wrapProgram $out/bin/serena-mcp-server \
      --set PYTHONPATH $out/venv/serena/lib/python3.11/site-packages \
      --set PATH ${
        lib.makeBinPath [
          "${pyright}/venv/pyright"
          pkgs.nodejs_24
          pkgs.typescript-language-server
          pkgs.rust-analyzer
        ]
      }
  '';
}
