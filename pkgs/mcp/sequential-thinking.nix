{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "sequential-thinking-mcp-server";
  packages = [
    "@modelcontextprotocol/server-sequential-thinking@2025.7.1"
  ];
  exposedBinaries = [
    "mcp-server-sequential-thinking"
  ];
  outputHash = "sha256-fN0zp4Yv/hPdYHBsA78WlMCwrxv5+/dPT3XRszJUIw4=";
}
