{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.15.1"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
