{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "openai-codex";
  packages = [
    "@openai/codex@0.46.0"
  ];
  exposedBinaries = [
    "codex"
  ];
  outputHash = "sha256-jVeq3zw++ztRSyRCFG8SOsziPbWibtCa7kPgU5n9XCY=";
}
