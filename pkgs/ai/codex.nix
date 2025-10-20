{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.47.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-VwyALcMQPk8VgZ+70gedP9yr6i75WuHwWEIAv0+j8b4=";
}
