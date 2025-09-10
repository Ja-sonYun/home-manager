{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.10.2"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-ge7WK/wXf1jDd214hUFKhlgj/kKv5OcmmdtXDXkc32g=";
}
