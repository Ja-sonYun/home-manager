{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-documentation-mcp-server";
  packages = [
    "awslabs.aws-documentation-mcp-server==1.1.8"
  ];
  exposedBinaries = [
    "awslabs.aws-documentation-mcp-server"
  ];
  outputHash = "sha256-vLWar2K+0KWpGlamppvk2uD1HqbSb9woR2epPU9bzD0=";
}
