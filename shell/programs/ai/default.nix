{
  pkgs,
  ...
}:
let
  codex = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "openai-codex";
    packages = [
      "@openai/codex@0.1.2505172129"
    ];
    exposedBinaries = [
      "codex"
    ];
    outputHash = "sha256-vGktwrxnkFtQIpAoWkppJQT5GALWHseQUQvtsEqeS1w=";
  };
  claude-code = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "claude-code";
    packages = [
      "@anthropic-ai/claude-code@1.0.43"
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
    outputHash = "sha256-8pPW8yDTq/tzdJKNGghG5QlUnoEFY1+9xqGEoWoMY2E=";
  };
  ccusage = pkgs.lib.npm.mkNpmGlobalPackageDerivation {
    inherit pkgs;
    name = "ccusage";
    packages = [
      "ccusage@15.2.0"
    ];
    exposedBinaries = [
      "ccusage"
    ];
    outputHash = "sha256-t+lIlb9bixk3estxHMtEwy0vyMoPsfjCh+vQLXP6RJw=";
  };
  claude-monitor-pkg = pkgs.lib.pip.mkPipGlobalPackageDerivation {
    inherit pkgs;
    name = "claude-monitor";
    packages = [
      "claude-monitor==1.2.0"
    ];
    exposedBinaries = [
      "claude-monitor"
    ];
    outputHash = "sha256-bPcS6nUJoIjZJPQdGiB7qxnUbWL7+ez/Qzt5fIe1HK0=";
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
