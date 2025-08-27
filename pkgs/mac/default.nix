{ pkgs, lib, ... }:

{
  inputSourceSelector = pkgs.callPackage ./input-source-selector.nix {};
  icalPal = pkgs.callPackage ./icalPal.nix {};
}