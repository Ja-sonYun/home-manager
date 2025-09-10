{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.31.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-bxLZfPdfwhNIZ/xk1O6sRfiu9/YsJmMxAEfJCFwTBNg=";
}
