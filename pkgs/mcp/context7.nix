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
  outputHash = "sha256-Vue3W0U8Q0O+1EdRnDnH4rJWi0p4s4QFQWK9vfJ2Gj4=";
}
