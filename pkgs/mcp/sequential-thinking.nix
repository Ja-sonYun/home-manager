{ pkgs, hashfile, ... }:
let
  outputHash = hashfile."mcp/sequential-thinking.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "sequential-thinking-mcp-server";
  packages = [
    "@modelcontextprotocol/server-sequential-thinking@2025.7.1"
  ];
  exposedBinaries = [
    "mcp-server-sequential-thinking"
  ];
}
