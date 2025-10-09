{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "context7-mcp";
  packages = [
    "@upstash/context7-mcp@1.0.21"
  ];
  exposedBinaries = [
    "context7-mcp"
  ];
  outputHash = "sha256-YTON52KqUltnYFwmYYH49eHo1+tpPh9CqvhsHpXXUr8=";
}
