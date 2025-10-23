{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.11"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
  outputHash = "sha256-07YlcKvT80k2ONLaJlQrqkImLjivZwwvVwUUncu0SRA=";
}
