{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.28.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-nOcrxH2XQh5VwfkWOTs9lqLEgJdrahSzQXI7ABtfu5s=";
}
