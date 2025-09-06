{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.30.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-CW2k2aUya6Fr3JXFN6kbGEqbl1wyjBVGRPk9/VMYYqE=";
}
