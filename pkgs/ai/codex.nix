{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.27.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-SpK3YE5m6U1mlx62vlOq8iE4ZFSCbdp2AuLd+2yuivU=";
}
