{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.36.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-NMNtKga6uS9UucObtuSaZTCDjVl/bwFahKRE2totIR8=";
}
