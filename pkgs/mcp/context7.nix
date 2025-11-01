{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.26"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-kxYXOFGr98EXK+Lp2UvipfK9z+LAWhf7CGtnQuNn4a8=";
}
