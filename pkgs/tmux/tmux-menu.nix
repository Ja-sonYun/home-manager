{ pkgs, hashfile, ... }:
let
  system = pkgs.lib.systems.hostPlatform;
  outputHash = hashfile."tmux/tmux-menu.nix";
in

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system outputHash;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
}
