{ pkgs, lib, system, ... }:

{
  tmux-menu = pkgs.callPackage ./tmux-menu.nix { inherit system; };
}