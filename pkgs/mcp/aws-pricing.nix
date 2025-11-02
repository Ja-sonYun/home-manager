{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/aws-pricing.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "awslabs.aws-pricing-mcp-server";
  packages = [
    "awslabs.aws-pricing-mcp-server==1.0.16"
  ];
  exposedBinaries = [
    "awslabs.aws-pricing-mcp-server"
  ];
}
