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
  outputHash = "sha256-kRoid1ejTPnxluU1Cv7v/n7AFhRZHg32hHY1HT+t0Hw=";
}
