{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.8.3"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-yQjULrYIMtVmsrC90tjjKn2QuzS+1fF6Ibzfr2PMEkA=";
}