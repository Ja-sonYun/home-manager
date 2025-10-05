{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.20"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-FG0HzTp2kc1Pl5wmVXYiLLj0E6GVLzygstRWQ1gXLpo=";
}
