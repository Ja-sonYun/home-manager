{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.10"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
  outputHash = "sha256-Wjpl4E6/BGGi5t70tHM/eKmeK5Pioy+X9fqFjcrKng4=";
}
