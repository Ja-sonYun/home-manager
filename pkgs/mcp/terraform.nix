{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.terraform-mcp-serves";
  packages = [
    "awslabs.terraform-mcp-server==1.0.6"
  ];
  exposedBinaries = [
    "awslabs.terraform-mcp-server"
  ];
  outputHash = "sha256-Qr+p/POmPufqwCI//5N55s5yH3tSB6pYRBOHWXYyVz4=";
}
