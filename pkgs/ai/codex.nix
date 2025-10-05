{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.44.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-e+M07W7kqkPItFX80TvcjIx1so7ycSOhkK0DAFAOmSo=";
}
