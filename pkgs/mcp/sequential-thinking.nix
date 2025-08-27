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
  outputHash = "sha256-Y9ohk0yUUiTesafZjTQP315AIsjBeKGayuJehCon98g=";
}
