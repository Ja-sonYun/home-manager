{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "pyright";
  pythonVersion = "311";
  packages = [
    "pyright==1.1.407"
  ];
  exposedBinaries = [
    "pyright"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
