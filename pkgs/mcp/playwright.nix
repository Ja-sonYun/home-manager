{ pkgs, lib, ... }:

pkgs.lib.npm.mkNpmGlobalPackageDerivation {
  inherit pkgs;
  name = "playwright-mcp";
  packages = [
    "@playwright/mcp@0.0.43"
  ];
  exposedBinaries = [
    "mcp-server-playwright"
  ];
  outputHash = "sha256-0000000000000000000000000000000000000000000=";
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
