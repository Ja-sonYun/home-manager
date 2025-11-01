{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-pricing-mcp-server";
  packages = [
    "awslabs.aws-pricing-mcp-server==1.0.16"
  ];
  exposedBinaries = [
    "awslabs.aws-pricing-mcp-server"
  ];
  outputHash = "sha256-uV5rcCWzIZtAbwPYEqORSNtzmGiHITCDn+6+1ZGIoAI=";
}
