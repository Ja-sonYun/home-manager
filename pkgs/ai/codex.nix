{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.29.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-3C/uVUyNroGd9EUUJwowgCG+E1PHSPbH4tAU+dtGNRc=";
}
