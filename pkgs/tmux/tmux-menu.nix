{ pkgs, lib, system, ... }:

pkgs.lib.cargo.mkCargoGlobalPackageDerivation {
  inherit pkgs system;
  name = "tmux-menu";
  version = "0.1.15";
  rustEdition = "2021";
  outputHash = "sha256-r4k8je4ft5iEPU6/ePou+9dDl74lNPpLWSTIAFtVozM=";
}
