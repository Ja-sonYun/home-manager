{ pkgs, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.53.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-iBiPSZe5Cwew3G1em2enQPh1FoNRmzwUKZ+JCVZfVSQ=";
}
