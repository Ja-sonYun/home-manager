{ pkgs, hashfile, ... }:
let
  outputHash = hashfile."mcp/terraform.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "awslabs.terraform-mcp-serves";
  packages = [
    "awslabs.terraform-mcp-server==1.0.7"
  ];
  exposedBinaries = [
    "awslabs.terraform-mcp-server"
  ];
}
