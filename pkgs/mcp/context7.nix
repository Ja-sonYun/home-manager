{ pkgs, hashfile, ... }:
let
  outputHash = hashfile."mcp/context7.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.26"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
}
