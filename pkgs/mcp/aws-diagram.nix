{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/aws-diagram.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.11"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
}
