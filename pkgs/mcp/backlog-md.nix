{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.18.0"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-9DGcOO/9k+2AHVKZKwOc1HW0hc5t0oxDy2lCCAZLTVY=";
}
