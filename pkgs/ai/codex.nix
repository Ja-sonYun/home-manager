{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.39.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-UCpbJ5fIpLqhjqXkcBmd+Ri5uElIQR91o6gnNJme3/c=";
}
