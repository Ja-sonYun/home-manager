{ pkgs, ... }:
let
  system = pkgs.lib.systems.hostPlatform;
  outputHash = pkgs.hashfile."tmux-menu";
in

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system outputHash;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
}
