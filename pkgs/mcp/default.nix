{ pkgs, ... }:

{
  aws-documentation = pkgs.callPackage ./aws-documentation.nix { };
  aws-diagram = pkgs.callPackage ./aws-diagram.nix { };
  aws-pricing = pkgs.callPackage ./aws-pricing.nix { };
  terraform = pkgs.callPackage ./terraform.nix { };
  pyright = pkgs.callPackage ./pyright.nix { };
  sequential-thinking = pkgs.callPackage ./sequential-thinking.nix { };
  playwright = pkgs.callPackage ./playwright.nix { };
  browser-use = pkgs.callPackage ./browser-use.nix { };
  backlog-md = pkgs.callPackage ./backlog-md.nix { };
  ccusage = pkgs.callPackage ./ccusage.nix { };
  context7 = pkgs.callPackage ./context7.nix { };
}
