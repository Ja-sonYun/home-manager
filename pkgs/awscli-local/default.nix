{ pkgs, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awscli";
  pythonVersion = "312";
  packages = [
    "setuptools>=40.8.0"
    "'awscli-local[ver1]'==0.22.2"
  ];
  exposedBinaries = [
    "awslocal"
  ];
  outputHash = "sha256-gZMgwUe8pCgpaJY7jAhhv2/bfRI0Ku8rF+9sN02+7cc=";
}
