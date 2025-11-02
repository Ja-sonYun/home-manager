args@{ pkgs, ... }:

{
  aws-documentation = pkgs.callPackage ./aws-documentation.nix args;
  aws-diagram = pkgs.callPackage ./aws-diagram.nix args;
  aws-pricing = pkgs.callPackage ./aws-pricing.nix args;
  terraform = pkgs.callPackage ./terraform.nix args;
  sequential-thinking = pkgs.callPackage ./sequential-thinking.nix args;
  context7 = pkgs.callPackage ./context7.nix args;
}
