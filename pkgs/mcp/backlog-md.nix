{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/backlog-md.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "backlog-md";
  packages = [
    "backlog.md@1.18.5"
  ];
  exposedBinaries = [
    "backlog"
  ];
}
