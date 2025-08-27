{ pkgs, lib, ... }:

{
  codex = pkgs.callPackage ./codex.nix {};
  claude-code = pkgs.callPackage ./claude-code.nix {};
}