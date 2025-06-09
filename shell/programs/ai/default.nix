{
  pkgs,
  libs,
  system,
  ...
}:
let
  codex = libs.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs system;
    name = "openai-codex";
    packages = [
      "@openai/codex@0.1.2505172129"
    ];
    exposedBinaries = [
      "codex"
    ];
    outputHash = "sha256-zvAOUNvi8iudYsOBwHOpDTYx++rn8MODhLHWpOVqHGQ=";
  };
  llm = libs.pip.mkPipGlobalPackageDerivation {
    inherit pkgs system;
    name = "llm";
    packages = [
      "llm==0.26"
      "llm-mlx==0.4"
    ];
    exposedBinaries = [
      "llm"
    ];
    outputHash = "sha256-RGV0E65ioLick5aJ8ZqGfdWFoZWYhiqTeFNAYEWNjok=";
  };
  claude-code = libs.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs system;
    name = "claude-code";
    packages = [
      "@anthropic-ai/claude-code@1.0.17"
    ];
    exposedBinaries = [
      "claude"
    ];
    postFixup =
      {
        node,
      }:
      ''
        # Use global env rather than coreutils's env
        sed -i '1s@^#!/.*/env.*@#!/usr/bin/env -S ${node}/bin/node --no-warnings --enable-source-maps @' node_modules/claude-code/lib/node_modules/@anthropic-ai/claude-code/cli.js
      '';
    outputHash = "sha256-7q6+8yXAqFSOm9yCObssaLcfZubNr9dXe6OsHXF/1iw=";
  };
in
{
  home.packages = with pkgs; [
    codex
    claude-code
    llm
    ollama
  ];
}
