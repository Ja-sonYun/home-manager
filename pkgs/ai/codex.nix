{ pkgs, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.50.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-2OZXITFe4wJyPxRbhwHYfrwltpuSy92Uv3b1QbMUCLM=";
}
