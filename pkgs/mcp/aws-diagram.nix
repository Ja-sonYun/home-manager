{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.8"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
  outputHash = "sha256-Ir7kFc7sX8Zay5aGdLCx14nJ6xpNE/ClULgrGO4EQq4=";
}