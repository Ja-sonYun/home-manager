{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "pyright";
  pythonVersion = "311";
  packages = [
    "pyright==1.1.405"
  ];
  exposedBinaries = [
    "pyright"
  ];
  outputHash = "sha256-BMwTZP8REF9graVW8zmiMcEKQIOogfaIcfzJxykYrSA=";
}
