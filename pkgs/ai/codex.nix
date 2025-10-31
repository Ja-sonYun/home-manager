{ pkgs, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.52.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-1GPrQWt5UsUwKNsU157ZBavX0nDn/gNzxEpCiytXU4Y=";
}
