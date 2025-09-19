{ pkgs, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
  outputHash = "sha256-kB8pQHyxq0gtWUD/Rd/X1hBWcRq+Ud2B3zbfu+m36Jk=";
}
