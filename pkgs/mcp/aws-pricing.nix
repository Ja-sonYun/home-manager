{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-pricing-mcp-server";
  packages = [
    "awslabs.aws-pricing-mcp-server==1.0.14"
  ];
  exposedBinaries = [
    "awslabs.aws-pricing-mcp-server"
  ];
  outputHash = "sha256-3XUKi0tICAHMs8gdXyMuWCyIENVpCGCimzEpWY2pplA=";
}
