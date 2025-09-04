{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.9.1"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-SQeiXIUa9zFidkC5f7und6A+2d/SQn8U023L+qpWQwY=";
}
