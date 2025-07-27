{
  pkgs,
  lib,
  ...
}:
let
  codex = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "openai-codex";
    packages = [
      "@openai/codex@0.7.0"
    ];
    exposedBinaries = [
      "codex"
    ];
    outputHash = "sha256-GYZ8E+OhqKLjfZFcWxQ2be1kv/8tVOeP+186VFq5lSw=";
  };
  claude-code = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "claude-code";
    packages = [
      "@anthropic-ai/claude-code@1.0.61"
    ];
    exposedBinaries = [
      "claude"
    ];
    postInstall = ''
      wrapProgram $out/bin/claude       \
        --set DISABLE_BUG_COMMAND     1 \
        --set DISABLE_AUTOUPDATER     1 \
        --set DISABLE_ERROR_REPORTING 1 \
        --set DISABLE_COST_WARNINGS   1
    '';
    postFixup =
      {
        node,
      }:
      ''
        # Use global env rather than coreutils's env
        sed -i '1s@^#!/.*/env.*@#!/usr/bin/env -S ${node}/bin/node --no-warnings --enable-source-maps @' node_modules/claude-code/lib/node_modules/@anthropic-ai/claude-code/cli.js
      '';
    outputHash = "sha256-RnYJupnEomnl5jLYziOMn3cgbnH9pPvipyP9ve5axmA=";
  };
  ccusage = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "ccusage";
    packages = [
      "ccusage@15.3.1"
    ];
    exposedBinaries = [
      "ccusage"
    ];
    outputHash = "sha256-mfXQjvWeEolvz8siVfWE1MW3LXWeUNgcSYadKbuIlMQ=";
  };
  claude-monitor-pkg = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "claude-monitor";
    packages = [
      "claude-monitor==3.0.4"
    ];
    exposedBinaries = [
      "claude-monitor"
    ];
    outputHash = "sha256-90EmrSP9EuHEIpj3QEfTNbYDTFa+J3rlFvMCH/Tyq4o=";
  };
  claude-monitor = pkgs.writeShellScriptBin "claude-monitor" ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    exec ${claude-monitor-pkg}/bin/claude-monitor "$@"
  '';
in
{
  home.packages = with pkgs; [
    codex
    claude-code
    ccusage
    claude-monitor
    ollama
  ];
}
