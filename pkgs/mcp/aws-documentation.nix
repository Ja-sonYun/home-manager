{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/aws-documentation.nix";
in

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "awslabs.aws-documentation-mcp-server";
  packages = [
    "awslabs.aws-documentation-mcp-server==1.1.9"
  ];
  exposedBinaries = [
    "awslabs.aws-documentation-mcp-server"
  ];
}
