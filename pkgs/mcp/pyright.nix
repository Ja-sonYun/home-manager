{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "pyright";
  pythonVersion = "311";
  packages = [
    "pyright==1.1.404"
  ];
  exposedBinaries = [
    "pyright"
  ];
  outputHash = "sha256-6tPcgfsou+tMH+4QYb+yzTXJhdGdPSHKRs03VErmqg4=";
}