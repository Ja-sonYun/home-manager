{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/pyright.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "pyright";
  pythonVersion = "311";
  packages = [
    "pyright==1.1.407"
  ];
  exposedBinaries = [
    "pyright"
  ];
}
