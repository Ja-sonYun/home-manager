{ pkgs, lib, ... }:

pkgs.lib.pip.mkPipGlobalPackageDerivation {
  inherit pkgs;
  name = "awslabs.aws-documentation-mcp-server";
  packages = [
    "awslabs.aws-documentation-mcp-server==1.1.7"
  ];
  exposedBinaries = [
    "awslabs.aws-documentation-mcp-server"
  ];
  outputHash = "sha256-pi52/fHbke7g+gvMEUym3ezWAJRVXtMzfT4uJRzoulo=";
}
