{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/ccusage.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "ccusage";
  packages = [
    "ccusage@17.1.3"
  ];
  exposedBinaries = [
    "ccusage"
  ];
}
