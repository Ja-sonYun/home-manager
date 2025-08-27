{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-pricing-mcp-server";
  packages = [
    "awslabs.aws-pricing-mcp-server==1.0.12"
  ];
  exposedBinaries = [
    "awslabs.aws-pricing-mcp-server"
  ];
  outputHash = "sha256-MRvjz+YVhs9Si1mi9jYjvrpxqyY9ipFo9aGWtwFXivo=";
}