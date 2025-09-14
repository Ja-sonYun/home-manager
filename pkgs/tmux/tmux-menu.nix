{ pkgs, lib, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.15";
  rustEdition = "2021";
  outputHash = "sha256-v9NOy7eWnkcPCjRBIVMW2zxfBpQlEC5ACga6z8E/aSQ=";
}
