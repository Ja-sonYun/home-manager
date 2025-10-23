{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.25"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-NCoOq18vU+2Yy843fDaLLXptAqtCLxUC9sCCoaU9xOE=";
}
