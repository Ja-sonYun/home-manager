{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.18.5"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-T13IIsUCrgw1niGexIFENkhsEGH3DsCqtohdUKtLg54=";
}
