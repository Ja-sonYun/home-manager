{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.terraform-mcp-serves";
  packages = [
    "awslabs.terraform-mcp-server==1.0.7"
  ];
  exposedBinaries = [
    "awslabs.terraform-mcp-server"
  ];
  outputHash = "sha256-yhXLhjnovoOx1NQCOQvXZ4/8cq+9CR+1Et2111hQwuA=";
}
