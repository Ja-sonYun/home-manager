args@{ pkgs, ... }:

{
  tmux-menu = pkgs.callPackage ./tmux-menu.nix args;
}
