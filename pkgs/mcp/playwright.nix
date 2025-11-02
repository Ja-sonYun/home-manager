{ pkgs, lib, ... }:
let
  outputHash = (import ../hash.nix)."mcp/playwright.nix";
in

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs outputHash;
  name = "playwright-mcp";
  packages = [
    "@playwright/mcp@0.0.45"
  ];
  exposedBinaries = [
    "mcp-server-playwright"
  ];
  postInstall = ''
    binary_path=$(readlink -f $out/bin/mcp-server-playwright)
    rm -f $out/bin/mcp-server-playwright
    cat > $out/bin/mcp-server-playwright <<EOF
    #!${pkgs.runtimeShell}
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    exec $binary_path "\$@"
    EOF
    chmod +x $out/bin/mcp-server-playwright
  '';
}
