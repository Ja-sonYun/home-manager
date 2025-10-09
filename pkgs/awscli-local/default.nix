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
  outputHash = "sha256-WV1euKASzDTDkKk5+5vAp06gf+JAkNE1DTWtiTSfiuY=";
}
