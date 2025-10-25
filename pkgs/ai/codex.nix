{ pkgs, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.49.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-pYfrQlhWFEh5lttyPsCicX6Rr4kYPwZh7gsag4K64wU=";
}
