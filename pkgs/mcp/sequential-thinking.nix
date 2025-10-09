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
  outputHash = "sha256-wuSmIkmCNdj+q9XMsD7RMBpQHqCIRnWZnQAyP3ISpxM=";
}
