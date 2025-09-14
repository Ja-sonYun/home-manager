{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.17"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-c7Ab9gEQSbUiBNQy2Yub01XPwnzCsgmmd4blVtY1bPc=";
}
