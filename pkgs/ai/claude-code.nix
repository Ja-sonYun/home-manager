{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "claude-code";
  packages = [
    "@anthropic-ai/claude-code@1.0.100"
  ];
  exposedBinaries = [
    "claude"
  ];
  postInstall = ''
    wrapProgram $out/bin/claude       \
      --set DISABLE_BUG_COMMAND     1 \
      --set DISABLE_AUTOUPDATER     1 \
      --set DISABLE_ERROR_REPORTING 1 \
      --set DISABLE_COST_WARNINGS   1 \
      --set DISABLE_TELEMETRY       1
  '';
  postFixup =
    {
      node,
    }:
    ''
      # Use global env rather than coreutils's env
      sed -i '1s@^#!/.*/env.*@#!/usr/bin/env -S ${node}/bin/node --no-warnings --enable-source-maps @' node_modules/claude-code/lib/node_modules/@anthropic-ai/claude-code/cli.js
    '';
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
}
