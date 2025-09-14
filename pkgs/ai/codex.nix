{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.34.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-aTeEhwELhTe+ToyIfPcZosohsmO0wbY2jXTdXtZ5FNg=";
}
