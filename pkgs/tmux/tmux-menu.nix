{ pkgs, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
  outputHash = "sha256-n4bJLPj/jDGa4Bio2N8cBU/gJieYRbVojLA2RCQES3w=";
}
