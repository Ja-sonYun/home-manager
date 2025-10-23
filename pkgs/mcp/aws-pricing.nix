{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-pricing-mcp-server";
  packages = [
    "awslabs.aws-pricing-mcp-server==1.0.15"
  ];
  exposedBinaries = [
    "awslabs.aws-pricing-mcp-server"
  ];
  outputHash = "sha256-j8sUqcxZ9VfOeOapIu/h0hug0afz1T06PmT18D8y0HE=";
}
