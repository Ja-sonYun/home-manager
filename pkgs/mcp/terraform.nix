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
  outputHash = "sha256-/yMrjD8azcNp/HLtGlOAsgaNYO7q7rudKnveIH4xWXE=";
}
