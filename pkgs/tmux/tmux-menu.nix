{ pkgs, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.17";
  rustEdition = "2021";
  outputHash = "sha256-hVKX4cYGkEzrV0B2Ssu+FoY9iDZADpYAYCyuoT/BeZw=";
}
