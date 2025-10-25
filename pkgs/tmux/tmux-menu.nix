{ pkgs, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
  outputHash = "sha256-ptqHfTn18l1rRnAAXowvC6yIg8MzrGQcZ3Tcd/4zctI=";
}
