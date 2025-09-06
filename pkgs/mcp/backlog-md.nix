{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "backlog-md";
  packages = [
    "backlog.md@1.9.2"
  ];
  exposedBinaries = [
    "backlog"
  ];
  outputHash = "sha256-Nt3NuqvZtpzqhiKN10hIsANbQUFaA6PkVVBothEgyGQ=";
}
