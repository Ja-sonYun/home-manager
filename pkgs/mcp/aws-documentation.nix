{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-documentation-mcp-server";
  packages = [
    "awslabs.aws-documentation-mcp-server==1.1.9"
  ];
  exposedBinaries = [
    "awslabs.aws-documentation-mcp-server"
  ];
  outputHash = "sha256-JfcEIGra0i+MTgVsOhIRuJonsjX1Yjye9JQ+0pbyyyw=";
}

