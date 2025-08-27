{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-documentation-mcp-server";
  packages = [
    "awslabs.aws-documentation-mcp-server==1.1.6"
  ];
  exposedBinaries = [
    "awslabs.aws-documentation-mcp-server"
  ];
  outputHash = "sha256-92Q73R4fOk/yK8mkadUhJsBENKGpIq516w8y1zL74cY=";
}