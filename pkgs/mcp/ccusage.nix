{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "ccusage";
  packages = [
    "ccusage@17.0.2"
  ];
  exposedBinaries = [
    "ccusage"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
