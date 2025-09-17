{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.38.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-AW9AmbQ84acD4gI9tQwlfbVQNm4HY6uZ/JhT8pmlDGo=";
}
