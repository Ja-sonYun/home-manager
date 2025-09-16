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
  outputHash = "sha256-TKnEOoaun+MdQPFJ/QQszNNwfO20KuFRC/212sFoL7E=";
}
