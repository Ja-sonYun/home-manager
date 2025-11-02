{ pkgs, ... }:
let
  outputHash = (import ../hash.nix)."ai/codex.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.53.0"
  ];
  exposedBinaries = [
    "codex"
  ];
}
