{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.46.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-9Zm9hzz91aO56p8eRr6Bi59UIunphoKoalohcf+QpFo=";
}
