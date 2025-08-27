{ pkgs, lib, userhome, ... }:

{
  aws-documentation = pkgs.callPackage ./aws-documentation.nix {};
  aws-diagram = pkgs.callPackage ./aws-diagram.nix {};
  aws-pricing = pkgs.callPackage ./aws-pricing.nix {};
  terraform = pkgs.callPackage ./terraform.nix {};
  pyright = pkgs.callPackage ./pyright.nix {};
  serena = pkgs.callPackage ./serena.nix { inherit userhome; };
  sequential-thinking = pkgs.callPackage ./sequential-thinking.nix {};
  playwright = pkgs.callPackage ./playwright.nix {};
  backlog-md = pkgs.callPackage ./backlog-md.nix {};
  ccusage = pkgs.callPackage ./ccusage.nix {};
}