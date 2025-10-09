{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-diagram-mcp-server";
  packages = [
    "awslabs.aws-diagram-mcp-server==1.0.9"
  ];
  exposedBinaries = [
    "awslabs.aws-diagram-mcp-server"
  ];
  outputHash = "sha256-wdGu1dwcEC5guYHwHYqb78YS1jKBF3MKEuN03LtzUR4=";
}
