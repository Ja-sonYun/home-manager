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
  outputHash = "sha256-eSaq5KadKV2VQ6ZMHYUcKlH4Ygx/zujYU4ej52Hjvvk=";
}
