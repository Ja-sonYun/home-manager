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
  outputHash = "sha256-KtWX2nG9xgS313do+ybeWirCCETr4Vtiy5AUuuichYM=";
}

