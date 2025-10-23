{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.17.4"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
