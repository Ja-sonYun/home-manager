{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.9"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
  outputHash = "sha256-t+LaSrKCePV8dDAK1QaYgNM3haDa/LG9Yb+bbFLTocc=";
}
