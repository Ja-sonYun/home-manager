{ pkgs, ... }:
let
  outputHash = pkgs.hashfile."awscli-local";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "awscli-local";
  pythonVersion = "312";
  packages = [
    "setuptools>=40.8.0"
    "'awscli-local[ver1]'==0.22.2"
  ];
  exposedBinaries = [
    "awslocal"
  ];
}
