args@{ pkgs, ... }:
{
  codex = pkgs.callPackage ./codex.nix args;
  claude-code = pkgs.callPackage ./claude-code.nix args;
}
