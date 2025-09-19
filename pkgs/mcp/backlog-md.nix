{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.12.3"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
