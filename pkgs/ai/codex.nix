{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.24.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-fHkhoCx8t+uc4wwCFL25wAjIPDm9GlHUock1vsK03hA=";
}
