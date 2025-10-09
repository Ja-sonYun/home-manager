{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.21"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-537o0Tmeq8xgIaHAHJ5OPsgOdNbnATdVRZIe/s5fvYk=";
}
